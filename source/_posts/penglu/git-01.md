title: Git常用命令和基础简介
date: 2017-1-22 11:00:00
categories: penglu
tags: 
- git

---
<iframe src="//slides.com/xgfe/deck-a989e27f-2a33-4351-a7b9-cb675607152b/embed" width="576" height="420" scrolling="no" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
<!-- more -->

## 初识Git

### 背景
<img src="http://p1.meituan.net/sjstpic/c366d874c3ae58085a175a4408c9766b98467.jpeg">

1. 处理修改文件，保留修改文件的方式:
	- 复制整个项目目录的方式来保存不同的版本
	- 改名加上备份时间以示区别
2. 优劣势分析
	- 好处：简单
	- 坏处：有时候会混淆所在的工作目录，一旦弄错文件丢了数据就没法撤销恢复

### 版本控制
1. 定义：一种纪录一个或若干文件内容变化，以便将来查阅特定版本修订情况的系统。
2. 作用：可以将文件回溯到之前的状态，甚至将整个项目都回退到过去某个时间点的状态，可以比较文件的变化细节，查出谁修改了哪些地方。
3. 发展阶段：本地版本控制—>集中化版本控制—>分布式版本控制
	- 本地版本控制
		<br><img src="http://p0.meituan.net/sjstpic/c231ae8dc3a9c15e357f11a0ffd23a7930950.jpeg"> 
		- 本地版本控制系统，大多都是采用某种简单的数据库来记录文件的历次更新差异（rsc）它的工作原理基本上就是保存并管理文件补丁（patch）。文件补丁是一种特定格式的文本文件，记录着对应文件修订前后的内容变化。所以，根据每次修订后的补丁，rcs 可以通过不断打补丁，计算出各个版本的文件内容
	- 集中化版本控制
	<img src="http://p1.meituan.net/sjstpic/4c0afe43b48bbe76da6604531055886844270.jpeg"/>
		- 如何让在不同系统上的开发者协同工作？集中化的版本控制系统（ Centralized Version Control Systems，简称 CVCS .有一个单一的集中管理的服务器，保存所有文件的修订版本，而协同工作的人们都通过客户端连到这台服务器，取出最新的文件或者提交更新.这么做好处，特别是相较于老式的本地 SVN来说。每个人都可以在一定程度上看到项目中的其他人正在做些什么。而管理员也可以轻松掌控每个开发者的权限，并且管理一个 CVCS 要远比在各个客户端上维护本地数据库来得轻松容易。缺点是中央服务器的单点故障。如果宕机一小时，那么在这一小时内，谁都无法提交更新，也就无法协同工作。要是中央服务器的磁盘发生故障，碰巧没做备份，或者备份不够及时，就会有丢失数据的风险。最坏的情况是彻底丢失整个项目的所有历史更改记录，而被客户端偶然提取出来的保存在本地的某些快照数据就成了恢复数据的希望。
	
	- 分布式版本控制
	<img src="http://p0.meituan.net/sjstpic/58a7145ef372c86d70ab44a264df120635773.jpeg"/>
		- 分布式版本控制系统（ Distributed Version Control System，简称 DVCS ），客户端并不只提取最新版本的文件快照，而是把代码仓库完整地镜像下来。这么一来，任何一处协同工作用的服务器发生故障，事后都可以用任何一个镜像出来的本地仓库恢复。因为每一次的提取操作，实际上都是一次对代码仓库的完整备份（GIT）
		
### 认识Git
1. 直接记录快照,而非差异比较
	- 其它版本控制系统，以稳健变更列表的方式存储信息；Git把数据看作是对小型文件系统的一组快照。如果文件没有修改，Git不再重新存储该文件，而只是保留一个链接指向之前存储的文件
2. 近乎所有操作都是本地执行
	- 大多数操作都只需要访问本地文件和资源，一般不需要来自网络上其它计算机的信息
3. Git保证完整性
	-  Git中所有数据在存储前都计算校验和，然后以校验和引用。因此，不可能在Git不知情时更改任何文件内容或目录内容。[Git用以计算校验和的机制叫做SHA-1散列(hash, 哈希)，一个由40个十六进制字符(0-9和a-f)组成字符串]
4. Git一般只添加数据
	- 未提交更新时有可能丢失或弄乱修改的内容，但是一旦提交快照到Git，就很难丢失数据
5. 三种状态(committed、modified以及staged)、三个工作区域（Git仓库、工作目录以及暂存区域）
	- committed(已提交)，modified(已修改)，staged(已暂存)；
6. 命令行
	- 可以使用原生命令行模式，也可使用GUI模式

#### 安装Git
1. 安装Git
2. 初次运行前Git的配置
	- git config
	- /etc/gitconfig文件
	- ~/.gitconfig或者~/.config/git/config文件config文件
3. Git配置常用命令
	- git config --global user.name  "XXX"
	- git config --global user.email  "YYY"
	- git config --list


## Git基础简介
### 三种状态
1. committed(已提交)
	- 数据已安全保存在本地数据库中
2. modified(已修改)
	- 修改文件，但是还没保存到数据库中
3. staged(已暂存)
	- 表示对一个已修改文件的当前版本做了标记，使之包含在下一次提交的快照中
	
### 三个工作区
1. Git仓库目录
	- Git用来保存项目的元数据和对象数据库的地方
2. 工作目录
	- 对项目某个版本独立提取出来的内容
3. 暂存区域
	- 一个文件，保存了下次讲提交的文件列表信息，一般在仓库目录中，有时称索引
	
#### 状态与工作区对应关系
1. Git工作流
	- 在工作目录中修改文件
	- 暂存文件，将文件的快照放入暂存区域
	- 提交更新，找到暂存区域的文件，将快照永久性存储到Git仓库目录
2. 状态与工作区对应
	- 如果Git目录中保存着特定版本文件，就属于已提交状态
	- 如果做了修改并已放入暂存区就属于已暂存状态
	- 如果自上次取出后，做了修改但是没有放到暂存区域，就是已修改状态
	<img src="http://p0.meituan.net/sjstpic/8b7b135f720ea35b7413dc76d975554d90563.jpeg"/>
	
### 三棵树
1. HEAD
	- 定义: 当前分支引用的指针，总指向该分支上的最近一次提交。这表示HEAD将是下一次提交的父节点
		- 上一次提交的快照，下一次提交的父节点
		- 显示HEAD命令:s; git ls-tree -r HEAD
2. Index
	- 定义: 索引是预期的下一次提交，即Git的’暂存区域’。Git将三次检出的工作目录中的所有文件填充到索引区,之后通过git add 和git rm命令来更新文件版本，接着通过git commit将它们转换为树来作新提交
		- 预期下一次提交的父节点
		- 显示索引当前样子: git ls-files -s
3. Working Directory
	- 定义: HEAD和索引将它们的内容存储在.git文件中，工作目录将它们解包为实际的文件以便编辑。可以把工作目录当成沙盒，在修改提交到暂存区并纪录历史之前，可以随意更改
		- 沙盒
		
## Git常用命令
### 获取Git仓库
#### 现有目录中初始化仓库
1. git init
	- 该命令将创建一个名为.git的子目录，这个子目录含有初始化的Git仓库中所有的必须文件
2. git add 
3. git commit

#### 克隆现有仓库
1. git  clone url  [ localProjectName ]
	- Git克隆的是该Git仓库服务器上的几乎所有数据，而不是仅仅复制完成你的工作所需要文件.当执行git clone命令的时候，默认配置下远程Git仓库中的每一个文件的每一个版本都被拉去下来.
	
### 纪录每次更新到仓库
Git仓库(clone)—>工作区(修改文件，提交更新)—>Git仓库 

1. 工作目录文件状态: 已跟踪和未跟踪
	- 已跟踪:指那些被纳入版本控制的文件，在上一次快照中有他们的纪录，在工作一段时间后，他们的状态可能处于未修改，已修改或已放入暂存区
	- 未跟踪(Untracked files): 除了已跟踪文件意外的所有其他文件，他们既不存在于上次快照的纪录中，也没有放入暂存区。初次克隆某个仓库的时候，工作目录中的所有文件都属于已跟踪文件，并处于未修改状态
	- 编辑过某些文件之后，由于自上次提交后你对它们做了修改，Git将它们标记为已修改文件，我们逐步将这些已修改过的文件放入暂存区，然后提交所有暂存了的修改，如此反复
2. 检查当前文件状态: git status
	- 确定当前目录是否未跟踪状态的新文件
	- 确定当前目录是否有已跟踪修改文件
	- 显示当前所在分支
3. 跟踪新文件: git add
	- git add命令可以用来跟踪新文件
	- git add命令可以用来把已跟踪的文件放入暂存区
	- git add命令还能用于合并时把有冲突的文件标记为已解决状态 
4. 暂存已修改文件: 使用`git status`命令，会显示'Changes not staged for commit',这说明'已跟踪文件的内容发生了变化，但还没放到暂存区'
	- 使用`git status`命令，会查看到add的文件XXX已被跟踪，并且处于暂存状态.`git add`命令使用文件或目录的路径作为参数;如果参数是目录的路径，该命令将递归地跟踪该目录下的所有文件
	- 使用`git add`之后(`git add XXX`)，使用`git status`命令，显示'Changes to be committed’,表示文件都已暂存，下次提交时就会一并记录到仓库.
5. 状态概览:git status -s或git status —short（??、A、M、MM）
	 - ‘??’: 新添加的未跟踪文件前面标记
	 - ’A': 新添加到暂存区中的文件前面标记
	 - ’M': 修改过文件前面标记(M有两个可出现位置，靠左边的M表示该文件被修改了但是还没放入暂存区；靠右边的M表示该文件被修改了并且放入暂存区.)
	 - 'MM': 表示被修改并提交到暂存区后又在工作去中被修改了，因此暂存区和工作去都有该文件被修改的纪录
6. 查看已缓存和未暂存的修改:git diff
	- 比较工作目录中当前文件和暂存区域快照之间的差异，也就是*修改之后还没有暂存起来的变化内容*
7. 提交更新: git commit
8. 跳过使用暂存区域: git commit -a 
	- `git commit -a`Git会自动把所有已经跟踪过的文件暂存起来一并提交，从而跳过git add步骤`git commit -a 'added new file’`
9. 移除文件: git rm
	- 要从Git中移除某个文件，就必须要从已跟踪文件清单中移除，然后提交.使用`git rm`命令，连带从工作目录中删除指定文件
	- 使用rm`rm XXX`删除文件之后，需要再运行git rm`git rm XXX`记录此次移除文件的操作。下次提交时，该文件就不会再纳入版本管理
	- 如果相关文件从Git仓库删除，但仍保留在当前工作目录中(即文件保留在磁盘，但是不想让Git继续跟踪)，可以使用cached`git rm --cached XX`

10. 移动文件: git mv file_from file_to
	- git不会显示跟踪文件移动操作。mv命令用于在git中对文件改名。
	- `git mv file_from file_to`  ;git mv命名只会对已跟踪文件有效
	- `git mv README.md README`指令等于依次运行了三条指令:`mv README.md README` 、`git rm README.MD`、 `git add README`
11. 查看提交历史: git log
	- -p: 按补丁格式显示每个更新之间的差异`git log -p`
	- -2: 显示最近两次提交`git log -2 -p`
	- --name-status:显示新增、修改、删除的文件清单
	
### 撤销操作
1. 取消暂存的文件: git reset HEAD <file> 
	- 使用该命令，对文件做的任何修改都会消失(因为可以看看做是拷贝另一个文件来覆盖它)
2. 撤销对文件的修改: git checkout -- <file>
	- Git中任何已提交的东西几乎总是可以恢复的(甚至那些被删除的分支中的提交或是用—amend选项覆盖的提交也可以恢复)，然而任何未提交的东西丢失后很可能再也找不到
3. 重新提交: git commit —amend
	- --amend命令会将暂存区中的文件提交，并且编辑保存后会覆盖原来的提交信息，最终只会有一条提交结果
	
### 远程仓库的使用
1. 查看远程仓库: git remote [-v]/git remote show [remote-name]
	- 列出指定的每一个远程服务器的简写,如果克隆了自己的仓库，则至少可以看到origin(Git给克隆仓库的服务器默认名字) .
	- -v: 显示需要读写远程仓库使用的Git保存的简写与其对应的URL`git remote -v`
	- git remote show [remote-name]: 查看某一个远程仓库的更多信息,列出远程仓库URL与跟踪分支信息  
2. 添加远程仓库: git remote add <shortName> <url>
	- 使用`git remote add <shortname> <url>`添加一个新的远程Git仓库(url)，同时指定可以引用的简写(shortname).在命令中可以使用shortname来代替整个URL

3. 从远程仓库中抓取与拉取: git fetch [remote-name],git clone,git pull
	- 访问远程仓库，从中拉取所有本地没有的数据。执行完成之后本地会拥有远程仓库所有分支的引用，可以随时合并或查看. git fetch命令会将数据拉取到本地仓库，但是并不会自动合并或修改当前的工作。
	- 克隆一个仓库，命令会自动将其添加为远程仓库并默认以`origin`为简写,git clone命令会自动设置本地master分支跟踪克隆的远程仓库的master分支(或不管是什么名字的默认分支) 
	- 自动抓取然后合并远程分支到当前分支。git pull会从最初克隆的服务器上抓取数据并自动常识合并到当前所在的分支
4. 推送到远程仓库: git push [remote-name] [branch-name]
	- 将本地branch-name分支推送到remote-name服务器;只有对克隆服务器有写入权限，并且之前没有人推送过时，这条命令才能生效。如果有人推送过，则必须先拉取合并后再进行推送
5. 远程仓库的移除与重命名
	- git remote rename [oldName] [newName]
	- git remote rm [remoteName]
	- 重命名引用的远程仓库的简写名,值得注意的是，这样也会修改远程分支名称

### 打标签
1. 列出标签: git tag [-l ‘vX.Y.Z*']
	- git tag: 以字母顺序列出标签,顺序并不重要
	- git tag -l 'vX.Y.Z*': 以特定的模式查找标签, 列出以vX.Y.Z开始的所有标签
2. 附注标签: git tag -a, git show [tag-name]
	- git tag -a创建一个附注标签,-m: 指定一条鉴会存储在标签中的信息
	- git show [tag-name]: 查看标签信息与对应的提交信息:输出打标签者的信息、打标签的日期时间、附注信息、具体提交信息
3. 后期打标签: git tag -a [tag-name] [校验和]
4. 共享标签: git push origin [tag-name], git push origin —tags
5. 删除标签
	- git tag -d [tag-name]; git push origin :refs/tags/vX.Y.Z
	- git push origin --delete tag <tagname>
	- 这样只能删除本地tag和远程tag，其它人本地的tag依旧存在，需要手动删除，否则很容易被推到远程(如果使用工具之行git push操作，则本地tag也会被一起推送上去)


## 参考资料
1. [pro Git](https://git-scm.com/book/en/v2)
2. [Git版本控制](https://git-scm.com/book/zh/v1/%E8%B5%B7%E6%AD%A5-%E5%85%B3%E4%BA%8E%E7%89%88%E6%9C%AC%E6%8E%A7%E5%88%B6)
 	
	      
			
		

		

