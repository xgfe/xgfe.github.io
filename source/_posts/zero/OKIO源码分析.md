title: OKIO源码分析
date: 2017-06-26
categories: zero
tags:
- java
- IO

---

本文主要分析了OKIO源码中用到的Timeout，Buffer和设计模式。

<!-- more -->

# AsyncTimeout
## AsyncTimeout源码
<pre><code>
public class Timeout {
public final void waitUntilNotified(Object monitor) throws InterruptedIOException {
    try {
      boolean hasDeadline = hasDeadline();
      long timeoutNanos = timeoutNanos();

      if (!hasDeadline && timeoutNanos == 0L) {
        monitor.wait(); // There is no timeout: wait forever.
        return;
      }

      // Compute how long we'll wait.
      long waitNanos;
      long start = System.nanoTime();
      if (hasDeadline && timeoutNanos != 0) {
        long deadlineNanos = deadlineNanoTime() - start;
        waitNanos = Math.min(timeoutNanos, deadlineNanos);
      } else if (hasDeadline) {
        waitNanos = deadlineNanoTime() - start;
      } else {
        waitNanos = timeoutNanos;
      }

      // Attempt to wait that long. This will break out early if the monitor is notified.
      long elapsedNanos = 0L;
      if (waitNanos > 0L) {
        long waitMillis = waitNanos / 1000000L;
        monitor.wait(waitMillis, (int) (waitNanos - waitMillis * 1000000L));
        elapsedNanos = System.nanoTime() - start;
      }

      // Throw if the timeout elapsed before the monitor was notified.
      if (elapsedNanos >= waitNanos) {
        throw new InterruptedIOException("timeout");
      }
    } catch (InterruptedException e) {
      throw new InterruptedIOException("interrupted");
    }
  }
}

AsyncTimeout extends Timeout
private static AsyncTimeout head
private boolean inQueue;//True if this node is currently in the queue
private AsyncTimeout next;
private long timeoutAt;
public final void enter() {
    if (inQueue) throw new IllegalStateException("Unbalanced enter/exit");
    long timeoutNanos = timeoutNanos();
    boolean hasDeadline = hasDeadline();
    if (timeoutNanos == 0 && !hasDeadline) {
      return; // No timeout and no deadline? Don't bother with the queue.
    }
    inQueue = true;
    scheduleTimeout(this, timeoutNanos, hasDeadline);
  }
private static synchronized void scheduleTimeout(
      AsyncTimeout node, long timeoutNanos, boolean hasDeadline)
public final boolean exit() {
    if (!inQueue) return false;
    inQueue = false;
    return cancelScheduledTimeout(this);
  }   
</code></pre>

waitUntilNotified：等待Object monitor Timeout时间或者提前被唤醒。
  
## AsyncTimeout流程图
![AsyncTimeout流程图](https://raw.githubusercontent.com/zero21ke/pic/master/blog/okio/TimeOut.jpg)
# Buffer
## Segment和SegmentPool
### Segment源码
```java
final class Segment {
static final int SIZE = 8192;
static final int SHARE_MINIMUM = 1024;
final byte[] data;
int pos;
int limit;
boolean shared;
boolean owner;
Segment next;
Segment prev;
Segment(Segment shareFrom) {
    this(shareFrom.data, shareFrom.pos, shareFrom.limit);
    shareFrom.shared = true;
  }
public Segment split(int byteCount) {
    if (byteCount <= 0 || byteCount > limit - pos) throw new IllegalArgumentException();
    Segment prefix;

    // We have two competing performance goals:
    //  - Avoid copying data. We accomplish this by sharing segments.
    //  - Avoid short shared segments. These are bad for performance because they are readonly and
    //    may lead to long chains of short segments.
    // To balance these goals we only share segments when the copy will be large.
    if (byteCount >= SHARE_MINIMUM) {
      prefix = new Segment(this);
    } else {
      prefix = SegmentPool.take();
      System.arraycopy(data, pos, prefix.data, 0, byteCount);
    }

    prefix.limit = prefix.pos + byteCount;
    pos += byteCount;
    prev.push(prefix);
    return prefix;
  }
```
Segment是一个双向链表，pos是读操作指针，limit是写操作指针，data是内存array，shared代表data是否与其他Segment共享，owner代表data是否归属于Segment。   
split：分裂成两个Segment，一个是pos-pos+byteCount另一个是pos+byteCount-limit，分裂时如果byteCount >= SHARE_MINIMUM即分裂生成的Segment的数据量比较大则共享被分裂Segment的data（prefix = new Segment(this)），prefix的limit等于被分裂Segment的pos+byteCount，被分裂Segment的pos=pos+byteCount，分裂生成的Segment插入被分裂Segment的前面。如果byteCount < SHARE_MINIMUM即分裂生成的Segment的数据量比较小则内存copy的代价比较小，从pool中取一个Segment从被分裂Segment copy byteCount到此Segment中。
### SegmentPool源码
```java
final class SegmentPool {
static final long MAX_SIZE = 64 * 1024; // 64 KiB.
static Segment next;
static long byteCount;
static Segment take() {
    synchronized (SegmentPool.class) {
      if (next != null) {
        Segment result = next;
        next = result.next;
        result.next = null;
        byteCount -= Segment.SIZE;
        return result;
      }
    }
    return new Segment(); // Pool is empty. Don't zero-fill while holding a lock.
  }

  static void recycle(Segment segment) {
    if (segment.next != null || segment.prev != null) throw new IllegalArgumentException();
    if (segment.shared) return; // This segment cannot be recycled.
    synchronized (SegmentPool.class) {
      if (byteCount + Segment.SIZE > MAX_SIZE) return; // Pool is full.
      byteCount += Segment.SIZE;
      segment.next = next;
      segment.pos = segment.limit = 0;
      next = segment;
    }
  }
```
take从SegmentPool取Segment，recycle回收Segment到pool中，只有未被share过的（即shared == false）才可以被回收。
Segment A 被share后，Segment A的shared被赋值true，则即使与Segment A 共享data的Segment都被回收了，在Segment A被回收时，Segment A是不可以放到pool中的，可推断只有owner=true 且 shared=false时才可以放到pool中。   
   
### Buffer源码   
```java
public final class Buffer implements BufferedSource, BufferedSink, Cloneable {  
Segment head; 
long size;
Segment writableSegment(int minimumCapacity) {
    if (minimumCapacity < 1 || minimumCapacity > Segment.SIZE) throw new IllegalArgumentException();

    if (head == null) {
      head = SegmentPool.take(); // Acquire a first segment.
      return head.next = head.prev = head;
    }

    Segment tail = head.prev;
    if (tail.limit + minimumCapacity > Segment.SIZE || !tail.owner) {
      tail = tail.push(SegmentPool.take()); // Append a new empty segment to fill up.
    }
    return tail;
  }
 public byte readByte() {
    if (size == 0) throw new IllegalStateException("size == 0");

    Segment segment = head;
    int pos = segment.pos;
    int limit = segment.limit;

    byte[] data = segment.data;
    byte b = data[pos++];
    size -= 1;

    if (pos == limit) {
      head = segment.pop();
      SegmentPool.recycle(segment);
    } else {
      segment.pos = pos;
    }

    return b;
  }
  public long completeSegmentByteCount() {
    long result = size;
    if (result == 0) return 0;

    // Omit the tail if it's still writable.
    Segment tail = head.prev;
    if (tail.limit < Segment.SIZE && tail.owner) {
      result -= tail.limit - tail.pos;
    }

    return result;
  }
  public void skip(long byteCount) throws EOFException {
    while (byteCount > 0) {
      if (head == null) throw new EOFException();

      int toSkip = (int) Math.min(byteCount, head.limit - head.pos);
      size -= toSkip;
      byteCount -= toSkip;
      head.pos += toSkip;

      if (head.pos == head.limit) {
        Segment toRecycle = head;
        head = toRecycle.pop();
        SegmentPool.recycle(toRecycle);
      }
    }
  }
  public void write(Buffer source, long byteCount) {
    if (source == null) throw new IllegalArgumentException("source == null");
    if (source == this) throw new IllegalArgumentException("source == this");
    checkOffsetAndCount(source.size, 0, byteCount);

    while (byteCount > 0) {
      if (byteCount < (source.head.limit - source.head.pos)) {
        Segment tail = head != null ? head.prev : null;
        if (tail != null && tail.owner
            && (byteCount + tail.limit - (tail.shared ? 0 : tail.pos) <= Segment.SIZE)) {
          // Our existing segments are sufficient. Move bytes from source's head to our tail.
          source.head.writeTo(tail, (int) byteCount);
          source.size -= byteCount;
          size += byteCount;
          return;
        } else {
          // We're going to need another segment. Split the source's head
          // segment in two, then move the first of those two to this buffer.
          source.head = source.head.split((int) byteCount);
        }
      }

      // Remove the source's head segment and append it to our tail.
      Segment segmentToMove = source.head;
      long movedByteCount = segmentToMove.limit - segmentToMove.pos;
      source.head = segmentToMove.pop();
      if (head == null) {
        head = segmentToMove;
        head.next = head.prev = head;
      } else {
        Segment tail = head.prev;
        tail = tail.push(segmentToMove);
        tail.compact();
      }
      source.size -= movedByteCount;
      size += movedByteCount;
      byteCount -= movedByteCount;
    }
  }
```

### Buffer内存共享结构图
![Buffer内存共享结构图](https://raw.githubusercontent.com/zero21ke/pic/master/blog/okio/buffer.jpg)

图中方框代表共享的内存byte[] data,不同的Segment共享可以共享data，但是每个Segment维护自己的pos和limit，buffer写操作时会先调用writableSegment。
writableSegment内部实现是，取队尾tail看剩余空间是否满足minimumCapacity：


1. 如果tail剩余空间不满足minimumCapacity，从SegmentPool take Segment插入tail之后
2. 如果tail剩余空间满足minimumCapacity但是Segment底层的data不归Segment所有（tail.owner==false），从SegmentPool take Segment插入tail之后
3. 如果tail剩余空间满足minimumCapacity且Segment底层的data归Segment所有（tail.owner==ture），直接写入tail剩余空间

读操作时从head的pos读起，如果head被读取完了回收head。   
completeSegmentByteCount:当前已complete的byte数，如果taile的data归taile所属，则很可能还会继续对tail进行写操作所以tail处于未 complete状态，tail前的Segment处于complete状态。   
skip：从head开始跳过n个字节，跳过的Segment放到pool中。   
write(Buffer source, long byteCount):从source的head摘取Segment连接到taile之后，当待写入的剩余字节小于source的head且taile不可写（owner==false）时，head做split操作。  
### RealBufferedSink
<pre><code>
final class RealBufferedSink implements BufferedSink {
  public final Buffer buffer = new Buffer();
  public final Sink sink;
  boolean closed;
public BufferedSink emitCompleteSegments() throws IOException {
    if (closed) throw new IllegalStateException("closed");
    long byteCount = buffer.completeSegmentByteCount();
    if (byteCount > 0) sink.write(buffer, byteCount);
    return this;
  }
public BufferedSink writeByte(int b) throws IOException {
    if (closed) throw new IllegalStateException("closed");
    buffer.writeByte(b);
    return emitCompleteSegments();
  }
</code></pre>
每个写操作都是先写入Buffer中，之后都调用emitCompleteSegments把Buffer中complete Segment写入Sink。
### Pipe
```java
public final class Pipe {
  final long maxBufferSize;
  final Buffer buffer = new Buffer();
  boolean sinkClosed;
  boolean sourceClosed;
  private final Sink sink = new PipeSink();
  private final Source source = new PipeSource();
final class PipeSink implements Sink {
public void write(Buffer source, long byteCount) throws IOException {
      synchronized (buffer) {
        if (sinkClosed) throw new IllegalStateException("closed");

        while (byteCount > 0) {
          if (sourceClosed) throw new IOException("source is closed");

          long bufferSpaceAvailable = maxBufferSize - buffer.size();
          if (bufferSpaceAvailable == 0) {
            timeout.waitUntilNotified(buffer); // Wait until the source drains the buffer.
            continue;
          }

          long bytesToWrite = Math.min(bufferSpaceAvailable, byteCount);
          buffer.write(source, bytesToWrite);
          byteCount -= bytesToWrite;
          buffer.notifyAll(); // Notify the source that it can resume reading.
        }
      }
    }
}
final class PipeSource implements Source {
public long read(Buffer sink, long byteCount) throws IOException {
      synchronized (buffer) {
        if (sourceClosed) throw new IllegalStateException("closed");

        while (buffer.size() == 0) {
          if (sinkClosed) return -1L;
          timeout.waitUntilNotified(buffer); // Wait until the sink fills the buffer.
        }

        long result = buffer.read(sink, byteCount);
        buffer.notifyAll(); // Notify the sink that it can resume writing.
        return result;
      }
    }
}
```
PipeSink负责向Buffer写，PipeSource负责从Buffer读，读写操作需要用synchronized (buffer)进行同步，Pipe满时调用timeout.waitUntilNotified(buffer)，PipeSink写线程会等待buffer对象timeout设置的时间，如果timeout到时抛出InterruptedIOException，Pipe空时PipeSource读线程会调用timeout.waitUntilNotified(buffer)，读线程会等待buffer对象timeout设置的时间，如果timeout到时抛出InterruptedIOException。
# 设计模式
## 装饰器模式
为Sink增加压缩功能的DeflaterSink
为Sink增加Gzip压缩功能的GzipSink
为Sink增加hash计算功能的HashingSink
为Sink增加buffer功能的RealBufferedSink
## 对象适配器模式
<pre><code>
final class RealBufferedSink implements BufferedSink {
public OutputStream outputStream() {
    return new OutputStream() {
      @Override public void write(int b) throws IOException {
        if (closed) throw new IOException("closed");
        buffer.writeByte((byte) b);
        emitCompleteSegments();
      }

</code></pre>
把RealBufferedSink对象适配成OutputStream

