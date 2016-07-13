title: Paper源码分析（Android上的`NoSql`）
date: 2016.7.13 16:00:00
updated: 2016.7.13 16:01:00
categories:
- tianyouzhen
tags:
- Android
- NoSql
- Paper
---

什么是`NoSql`？从表面上可以理解成，存储在数据库中的并不是一条条的数据，而是一个个Map对象。


`NoSql`在Android上应用得不多，`Paper`是目前刚出现的性能比较好而且比较小巧的一款。翻翻源代码，分析一下他的原理


介绍
---
代码地址： https://github.com/pilgr/Paper

配置

```java
compile 'io.paperdb:paperdb:1.1'
```

使用
```java
Paper.init(context);


Paper.book().write("city", "Lund"); // Primitive
Paper.book().write("task-queue", queue); // LinkedList
Paper.book().write("countries", countryCodeMap); // HashMap

String city = Paper.book().read("city");
LinkedList queue = Paper.book().read("task-queue");
HashMap countryCodeMap = Paper.book().read("countries");
```

分析
---

paper代码不多，大致结构是

- io.paperdb
  + serializer
     + NoArgCollectionSerializer.java
  + Book.java
  + DbStoragePlainFile.java
  + Paper.java
  + PaperDbException.java
  + PaperTable.java
  + Storage.java

果然很小巧，接下来逐步分析:

Paper.java
----------
核心代码是
```
    private static final ConcurrentHashMap<String, Book> mBookMap = new ConcurrentHashMap<>();
```
这个类储存了一个`Book`集合。提供了一些方法查询、创建、删除数据。

Book.java
---------
核心代码
```
    protected Book(Context context, String dbName) {
        mStorage = new DbStoragePlainFile(context.getApplicationContext(), dbName);
    }
```
book层只是Storage的代理，基本上都是诸如此类的方法:
```
    public void delete(String key) {
        mStorage.deleteIfExists(key);
    }
```

Storage.java
------------
一个接口，声明了增删改查方法
```
interface Storage {

    void destroy();

    <E> void insert(String key, E value);

    <E> E select(String key);

    boolean exist(String key);

    void deleteIfExists(String key);

    List<String> getAllKeys();
}
```
在`Book`中，`Storage`的具体的实现是`DbStoragePlainFile `

DbStoragePlainFile.java
-----------------------
首先代码内定义了Kryo对象
```
    private Kryo getKryo() {
        return mKryo.get();
    }

    private final ThreadLocal<Kryo> mKryo = new ThreadLocal<Kryo>() {
        @Override
        protected Kryo initialValue() {
            return createKryoInstance();
        }
    };
```

Kryo : https://github.com/EsotericSoftware/kryo

猜测使用Kryo做序列化。看看保存方法的实现能不能证明猜测

```
    @Override
    public synchronized <E> void insert(String key, E value) {
        assertInit();

        final PaperTable<E> paperTable = new PaperTable<>(value);

        final File originalFile = getOriginalFile(key);
        final File backupFile = makeBackupFile(originalFile);

  ....
}
```

每个`key`都对应了一个`File`对象？难道`Paper`的原理只是建立了一个目录，然后把每个key的对象序列化之后存到目录下的文件里？

```
    private <E> void writeTableFile(String key, PaperTable<E> paperTable, File originalFile, File backupFile) {
        try {
            FileOutputStream fileStream = new FileOutputStream(originalFile);

            final Output kryoOutput = new Output(fileStream);
            getKryo().writeObject(kryoOutput, paperTable);
            kryoOutput.flush();
            fileStream.flush();
            sync(fileStream);
            kryoOutput.close(); //also close file stream

            // Writing was successful, delete the backup file if there is one.
            //noinspection ResultOfMethodCallIgnored
            backupFile.delete();
        } catch (IOException | KryoException e) {
            // Clean up an unsuccessfully written file
            if (originalFile.exists()) {
                if (!originalFile.delete()) {
                    throw new PaperDbException("Couldn't clean up partially-written file "
                            + originalFile, e);
                }
            }
            throw new PaperDbException("Couldn't save table: " + key + ". " +
                    "Backed up table will be used on next read attempt", e);
        }
    }
```
果然如此

总结
----

`Paper`作为新出的比较火的`NoSql`存储库，实现思路还是很棒的。

首先是代码量很小，实现简单，继承容易。

其次提供了一套函数式Api，调用方便。

最重要的是在数据存储原理上，他不像SqLite或者其他的NoSql存储，将数据打包成数据库。而是建立了一个数据文件夹，将每个Key使用Kryo序列化之后存储在文件夹内。

这种实现方式的优点是，查询数据时不需要读取索引文件。数据 **数量** 小时速度快

缺点也很多，例如文件夹内文件过多可能造成性能下降（单条数据太大倒不会造成性能影响）、只能存储一级Map，加载会将所有内容都加载进内存。等等

但是在Android平台上，确实是一个很棒的`NoSql`库





