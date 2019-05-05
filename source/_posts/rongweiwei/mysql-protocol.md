title: mysql通信协议浅解 
date: 2018-12-21 
categories: rongweiwei 
tags:
- mysql 
- nodejs 

---

	

##  序 
计划通过本地代理远程mysql，尝试实现透明缓存中间件功能这个需求，在实现过程中，需要对mysql协议的请求和下发包进行解析以便进一步处理，网络上有大量关于mysql协议的文章，但过于分散，而且mysql协议在4.1版本做了大升级，本文将涉及到的一部分整理汇总，资料来自mysql官网，网络blog，和npm上的mysql模块源码。

代码部分经过nodejs的mysql模块和php的mysqli模块验证。

此次只作为对mysql协议熟悉的练习，对数据变动自动清理相应缓存建议还是使用基于binlog的解析,然后通过消息机制更新。

<!--more-->

---

##  基本
mysql链接分为TCP握手链接，服务端对客户端认证，数据交互，断开链接几个阶段。
服务器启动后，会使用 TCP 监听一个本地端口，当客户端的连接请求到达时，就会执行三段握手以及 MySQL 的权限验证；验证成功后，客户端开始发送请求，服务器会以响应的报文格式返回数据；当客户端发送完成后，会发送一个特殊的报文，告知服务器已结束会话。

MySQL 定义了几种包类型，A) 客户端->服务器，登录时的 auth 包、执行 SQL 时的 CMD 包；B) 服务器->客户端，登录时的握手包、数据包、数据流结束包、成功包(OK Packet)、错误信息包。

协议定义了基本的数据类型，如 int、string 等；数据的传送格式等。

###  一些规则
当server端和client端数据交互时，如果数据包size大于2^24时，要将包拆成多个；
每个包由header和payload两部分组成；

###  认证阶段
    服务端 -> 客户端：发送握手初始化包 (Handshake Initialization Packet)。
    客户端 -> 服务端：发送验证包 (Client Authentication Packet)。
    服务端 -> 客户端：认证结果消息
mysql的认证过程相对复杂，这里简单介绍4.1版本之后的认证过程（计划功能中对这部分请求可以透明透给远程mysql，没有必要进行处理，以下内容摘自网络）。

1. 服务器发送随机字符串 (scramble) 给客户端。

2. 客户端作如下计算，然后客户端将 token 发送给服务端。

	> stage1_hash = SHA1(明文密码)

	> token = SHA1(scramble + SHA1(stage1_hash)) XOR stage1_hash

3. 服务端作如下计算，比对 SHA1(stage1_hash) 和 mysql.user.password 是否相同

	> stage1_hash = token XOR SHA1(scramble + mysql.user.password)
server -> client， client-> server 包类型

	校验时，只需要 SHA1(stage1_hash) 与 mysql.user.password 比较一下即可
 
handshake包(protocol41)
 
|Bytes | Name|
|---|---|
|1  | protocol_version|
|n  | (Null-Terminated String)   server_version|
|4  | thread_id|
|8  | scramble_buff|
|1  | (filler) always 0x00|
|2  | server_capabilities|
|1  | server_language|
|2  | server_status|
|13 | (filler) always 0x00 ...|
|13 | rest of scramble_buff (4.1)|

###  获得use db
 对本次需求只需要取出初始化mysql链接的时候会初始化使用哪个库(use database;),需要从包里解出，其它部分忽略。

		function parseHandShake(buff){
			let _check_pos = buff.indexOf(Buffer.alloc(23,0x00));
			if (_check_pos > 0){
				//protocol41
				buff =  buff.slice(_check_pos + 23);
				protocol41 = true;
			}
			//find user field end
			_check_pos = buff.indexOf(0x00);
			buff =  buff.slice(_check_pos + 1);
			if (protocol41) {
				buff =  buff.slice(21);	 
			} else {
				buff =  buff.slice(10); 	
			}
			_check_pos = buff.indexOf(0x00);
			
	
			let default_db = buff.slice(0, _check_pos).toString();
 		}
 		
 


----

##  query请求 封包

client到server的包（Command Packet ），由两部分构成：header 和 payload。header包括3位整数表示payload长度，1位整数表示顺序号；payload包括1位COM标识符和请求sql语句

|Type	|Name	|Description|
|---|---|----|
|int<3>| payload_length |payload的长度|
|int<1>|	sequence_id|顺序号，每次从0开始|
|string<var>|	payload|	COM + sql ，COM_QUERY 标识符为0x03|

Example:

|header|sequence	|Description|
|---|---|----|
|01 00 00 |00| 03 xx xx...|
|length 1 |sequence_id 0 |payload [0x03,Buffer from sql string ...]|


部分代码

	 var MAX_PACKET_LENGTH = Math.pow(2, 24) - 1;
	 var buffer = Buffer.from(sql);

	 for (var packet = 0; packet < packets; packet++) {
   	 	var isLast = (packet + 1 === packets);
    	var packetLength = (isLast)
   			? length % MAX_PACKET_LENGTH
   			: MAX_PACKET_LENGTH;

   		var packetNumber = incrementPacketNumber();

   		this.writeUnsignedNumber(3, packetLength);
   		this.writeUnsignedNumber(1, packetNumber);

   		var start = packet * MAX_PACKET_LENGTH;
   		var end   = start + packetLength;

   		this.writeBuffer(buffer.slice(start, end));
	}


writeUnsignedNumber用来把包长度和序号写入packet header

	function writeUnsignedNumber(bytes, value) {
   		for (var i = 0; i < bytes; i++) {
       	this._buffer[this._offset++] = (value >> (i * 8)) & 0xff
   		}
	}

当header的长度小于MAX_PACKET_LENGTH时表示包传输完成，极端情况下会多传个空包过去（正好整分）。

通常sql不长的情况下，只需要一个包就可以。

	ComQueryPacket.prototype.write = function write(){
		let _sql_buff = Buffer.from(this.sql),
			_cmd_len = Buffer.byteLength(this.sql),
			_buff = Buffer.alloc(_cmd_len + 1 + 3 + 1);	
	
		_sql_buff.copy(_buff , 5);
	
		this._buffer = _buff;
		this.writeUnsignedNumber(4, _cmd_len+1);
		this.writeUnsignedNumber(1, this.command);
	

		return this._buffer; 
	}

---

##  query返回 解包
从服务器发往客户端的数据包有四种：成功报告包以及错误消息包，数据结束包、数据包。

- 0x00: Packets.OkPacket
- 0xff: Packets.ErrorPacket
- 0xfe: Packets.EofPacket
- 其它

###  处理逻辑
	let first = data.readUInt8(4)，	//探测包类型
		last = data.readUInt8(Buffer.byteLength(data) -1); //用来检测字符串类型数据是否传输完成
	
	if (first === 0xff) {
		//查询错误
	} else if (first === 0x00) {
		//查询OK，这里可以解析握手包等
	} else {
		//数据包
		//NullTerminatedString（Null结尾方式）: 字符串以遇到Null作为结束标志，相应的字节为00
		if (last === 0x00 ){ 
			//检查数据包中列信息和数据信息是否都接收完成
		}
	}
	

###  OK Packet 

Payload

|相对包内容的位置 |	长度（字节）|	名称 |	描述|
| ------ | ------ | ------ |------ |
|0	|	1 |	包头标识 |	0x00 代表这是一个OK 包|
|1	| rows_len |	影响行数 |	相应操作影响的行数，比如一个Update操作的记录是5条，那么这个值就为5|
|1 + rows_len |	id_len	|自增id	 |插入一条记录时，如果是自增id的话，返回的id值
|1 + rows_len + id_len |	2 |	服务器状态 |	用于表示服务器状态，比如是否是事务模式或者自动提交模式
|3 + rows_len + id_len	| 2 |	警告数 |	上次命令引起的警告数
|5 + rows_len + id_len	| msg_len	| 额外信息 |	此次操作的一些额外信息



###  Error Packet 

Payload

|Type |Name |Description |
|---|---|---|
|int<1> [ff]	|	header	|  header of the ERR packet|
|int<2>	|	error_code |	错误码|
|if capabilities & CLIENT_PROTOCOL_41 { |
|  string[1]	|	sql_state_marker |	# marker of the SQL State
|  string[5]	|	sql_state |	SQL State
|} 
|string<EOF>	| error_message	| 报错信息



###  Result Set Packet 

Result Set包产生于我们每次数据库执行需要返回结果集的时候，Server端发送给我们的包，比如平常的SELECT,SHOW等命令，Result Set包相对比较复杂，查询结果的完整内容由：
列数量信息 + 列包 + EOF包 + 行包 + EOF包，这五部分组成。

|内容 |	含义 |
|---|---|
|Result Set Header |	返回数据的字段(列)数量|
|Field	| 返回数据的列信息（多个）|
|EOF |	列结束 |
|Row Data |	行数据（多个）|
|EOF |	数据结束 |


例子 SELECT @@version_comment查询的返回结果：

	01 00 00 01 01|27 00 00    02 03 64 65 66 00 00 00    .....'....def...
	11 40 40 76 65 72 73 69    6f 6e 5f 63 6f 6d 6d 65    .@@version_comme
	6e 74 00 0c 08 00 1c 00    00 00 fd 00 00 1f 00 00|   nt..............
	05 00 00 03 fe 00 00 02    00|1d 00 00 04 1c 4d 79    ..............My
	53 51 4c 20 43 6f 6d 6d    75 6e 69 74 79 20 53 65    SQL Community Se
	72 76 65 72 20 28 47 50    4c 29|05 00 00 05 fe 00    rver (GPL)......
	00 02 00                                              ...


VERSION 4.0

|Bytes            |          Name|
|---|---|
|n (Length Coded String)  |  table|
|n (Length Coded String)  |  name|
|4 (Length Coded Binary)  |  length|
|2 (Length Coded Binary)  |  type|
|2 (Length Coded Binary)  |  flags|
|1                        |  decimals|
|n (Length Coded Binary)  |  default|  
 
    
VERSION 4.1

|Bytes            |          Name|
|---|---|
|n (Length Coded String)  |catalog  | 
|n (Length Coded String)  |db     |
|n (Length Coded String)  |table   |
|n (Length Coded String)  |org_table 原表名|
|n (Length Coded String)  |name   |
|n (Length Coded String)  |org_name 原字段名 | 
|(filler)            0c    | |
|charsetnr           08 00 | |                   
|n (Length Coded String)  |length |              
|n (Length Coded String)  |type |             
|n (Length Coded String)  |flags |             
|n (Length Coded String)  |decimals |         
|(filler) 00 00 | |
 
 处理代码：

    /*
    * 解析字段信息
    * @param Buffer 
    * @result Object 
    */
	function parseColDef(buff){
		let _stack = _parseLine(buff);
		if (_stack.length < 2) return false;
		if (!_stack) return false;
		if (_stack[0] === 'def'){
			//protocol41
			return {
				'db' : _stack[1],
				'table' : _stack[2],
				'table_full' : _stack[3],
				'field' : _stack[4],
				'field_full' : _stack[5]
			};	
		}else{
			return {
				'table' : _stack[0],
				'field' : _stack[1],
			};
		}
	}
	
    /*
    * 解析行数据
    * @param Buffer 
    * @result Array 
    */
	function parseColVal(buff){
		let _stack = _parseLine(buff);
		return _stack;
	}
	
	function _parseLine(buff){
		let _stack = [];
		for(let i=0,j=buff.length ; i < j ; i++){
			let _len = buff[i].toString() * 1;
			let _content = buff.slice(i+1, i+ 1 + _len  );
			_stack.push(_content.toString());
			i += _len;  
		}
		return _stack;
	}
	
	
	function Parser(options) {
		options = options || {};
		this.reset(options);
	}
	
	Parser.prototype.reset = function(options){
		this._header = [];
		this._body = [];
		this._parsed_columns = [];
		this._parsed_col_vals = [];
		this.header_len = 4;
		this._head_set = false;
		this._body_set = false;
		this._reset();
	}
	Parser.prototype._reset = function(){
		this._buffer = Buffer.alloc(0);
		this._offset = 0;
	}
	
    //将字段部分和数据部分分开存放
	Parser.prototype._put = function(chunk){
		if (0 === chunk.length) return;
		if (this._head_set){
			this._body.push(chunk);
		}else{
			this._header.push(chunk);
		}
	}

    //获得result packet
	Parser.prototype.write = function(chunk ,to_parse){
		if (this._body_set) return false;
		this._buffer = Buffer.concat([this._buffer,chunk]);
		this._offset = 0;
		this._process(to_parse);
	}
	
	Parser.prototype._process = function(to_parse){
		let _header_len = this.header_len;
		while(true){
			if (this._buffer.length === 0 ){
				break;
			}
			let _len = this.parseUnsignedNumber(3),
				_number = this.parseUnsignedNumber(1);
			if ((_len + _header_len) > this._buffer.length){
				break;
			}
			let _piece = this._buffer.slice(0,_len + _header_len), 
				_first = _piece.readUInt8(4);
	
			this._put(_piece);
			if (0xfe === _first){
				if (!this._head_set){
					this._head_set = true;	
					this._parsed_col_vals = [];
					for (let _m = 0,_n = this._parsed_columns.length; _m < _n ; _m++){
						this._parsed_col_vals.push([]);
					}
				
				}else{
					this._body_set = true;
				}
			} else if(to_parse){
				if (!this._head_set){
					let _column = parseColDef(_piece.slice(_header_len));
					if (_column){
						this._parsed_columns.push(_column.field);
					}
				}else{
					let _col_val = parseColVal(_piece.slice(_header_len));
					for(let _m=0,_n=_col_val.length; _m < _n;_m++){
						this._parsed_col_vals[_m].push(_col_val[_m]);	
					} 
				}
			}
	
			this._buffer = this._buffer.slice(_piece.length );
			
			this._offset = 0;
		}
	}
	
    //读取解析后数据
	Parser.prototype.read = function(){
		return {
			head : this._header,
			body : this._body,
			headed : this._head_set,
			bodyed : this._body_set,
			columns : this._parsed_columns,
			columns_vals : this._parsed_col_vals
		}
	}
	
	
    //写入数字类型信息
	Parser.prototype.parseUnsignedNumber = function parseUnsignedNumber(bytes) {
		if (bytes === 1) {
			return this._buffer[this._offset++];
		}
	
		var buffer = this._buffer;
		var offset = this._offset + bytes - 1;
		var value  = 0;
	
		if (bytes > 4) {
			var err    = new Error('parseUnsignedNumber: Supports only up to 4 bytes');
			err.offset = (this._offset - this._packetOffset - 1);
			err.code   = 'PARSER_UNSIGNED_TOO_LONG';
			throw err;
		}
	
		while (offset >= this._offset) {
			value = ((value << 8) | buffer[offset]) >>> 0;
			offset--;
		}
	
		this._offset += bytes;
	
		return value;
	}; 
	  


---
  
  
## 资料
https://dev.mysql.com/doc/internals/en/text-protocol.html
https://blog.csdn.net/caisini_vc/article/details/5356136
https://jin-yang.github.io/post/mysql-protocol.html

HandShake: 
https://my.oschina.net/alchemystar/blog/833598 ,  https://my.oschina.net/alchemystar/blog/833598

com标识: 
https://dev.mysql.com/doc/internals/en/text-protocol.html


