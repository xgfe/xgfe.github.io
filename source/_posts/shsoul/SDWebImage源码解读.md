title: SDWebImage源码解读
date: 2017-05-27 19:48:29
categories: shsoul
tags: 
- iOS
- SDWebImage
---

### 概述
SDWebImage库是iOS应用中常用的一个图片处理库，包括图片的下载和缓存等。非常好用。本文对其源码做了分析和总结。

<!-- more -->

### SDWebImage的结构
![结构图](https://p1.meituan.net/dpnewvc/20aa73ab887e77461938f858bac37dc164266.png)

1. 整个架构是MVC架构。
	* 发起图片请求的是View层， 包括UIButton和UIImageView的Category。
	* ImageManager是Controller层，请求的转发，是请求下载模块还是缓存模块。
	* 下载模块（Downloader）和缓存模块（ImageCache）是Model层。
2. prefetcher 批量下载相关
3. combinedOperation 组合操作，主要是取消请求操作。
4. 支持webP和gif等。

### 缓存模块（SDImageCache）
SDImageCache缓存有两层缓存，一是内存缓存，二是磁盘缓存。SDImageCache是一个单例。
#### 1. NSCache 做内存缓存
```objectivec
- (id)initWithNamespace:(NSString *)ns diskCacheDirectory:(NSString *)directory {
        // Init the memory cache
        _memCache = [[AutoPurgeCache alloc] init]; // AutoPurgeCaCache是继承与NSCache，对NSCache简单封装。
        _memCache.name = fullNamespace;
}
- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!url) {
        return @"";
    }
    
    if (self.cacheKeyFilter) {
        return self.cacheKeyFilter(url);
    } else {
        return [url absoluteString];
    }
}


```
* NSCache 跟NSMutableDictionary用法很像，但是NSCache是线程安全的，而且在系统内存不足的情况下回自动释放部分内存。键不会被copy，只是强引用。
* 默认以url字符串为key，UIImage为value。
* 键值对都是strong引用
* 对NSCache缓存空间没有限制

#### 2. 磁盘缓存
```objectivec
// Init the disk cache
-(NSString *)makeDiskCachePath:(NSString*)fullNamespace{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:fullNamespace];
}

```
* 目录在应用沙盒中的缓存目录下。会创建一个默认目录。
* 默认情况下既有内存缓存也有磁盘缓存。
* 可以加自定义的目录，作用是读取那个目录下预存的文件。但是文件名也是根据SDWebImage的命名方式。

```objectivec
- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];

    return filename;
}
```
* 文件名以url的16位MD5后的字符，然后每一位字符转换成两位16进制数命名，防止文件名冲突

```objectivec
- (void)storeImage:(UIImage *)image recalculateFromImage:(BOOL)recalculate imageData:(NSData *)imageData forKey:(NSString *)key toDisk:(BOOL)toDisk {
    if (!image || !key) {
        return;
    }
    // if memory cache is enabled
    if (self.shouldCacheImagesInMemory) {
        NSUInteger cost = SDCacheCostForImage(image);
        [self.memCache setObject:image forKey:key cost:cost];
    }

    if (toDisk) {
        dispatch_async(self.ioQueue, ^{
            NSData *data = imageData;

            if (image && (recalculate || !data)) {
#if TARGET_OS_IPHONE
                // We need to determine if the image is a PNG or a JPEG
                // PNGs are easier to detect because they have a unique signature (http://www.w3.org/TR/PNG-Structure.html)
                // The first eight bytes of a PNG file always contain the following (decimal) values:
                // 137 80 78 71 13 10 26 10

                // If the imageData is nil (i.e. if trying to save a UIImage directly or the image was transformed on download)
                // and the image has an alpha channel, we will consider it PNG to avoid losing the transparency
                int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
                BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                                  alphaInfo == kCGImageAlphaNoneSkipFirst ||
                                  alphaInfo == kCGImageAlphaNoneSkipLast);
                BOOL imageIsPng = hasAlpha;

                // But if we have an image data, we will look at the preffix
                if ([imageData length] >= [kPNGSignatureData length]) {
                    imageIsPng = ImageDataHasPNGPreffix(imageData);
                }

                if (imageIsPng) {
                    data = UIImagePNGRepresentation(image);
                }
                else {
                    data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
                }
#else
                data = [NSBitmapImageRep representationOfImageRepsInArray:image.representations usingType: NSJPEGFileType properties:nil];
#endif
            }

            [self storeImageDataToDisk:data forKey:key];
        });
    }
}

```
* iphone设备先判断是png还是其他，是png用png压缩存储，其他用jpeg压缩存储。其他设备不用压缩。
* 异步存储和获取
* 多线程用的是GCD

```objectivec
- (UIImage *)diskImageForKey:(NSString *)key {
    NSData *data = [self diskImageDataBySearchingAllPathsForKey:key];
    if (data) {
        UIImage *image = [UIImage sd_imageWithData:data];
        image = [self scaledImageForKey:key image:image];
        if (self.shouldDecompressImages) {
            image = [UIImage decodedImageWithImage:image];
        }
        return image;
    }
    else {
        return nil;
    }
}
```
* 获取图片先从内存中找，如果没有找到则在磁盘中找，找到后先解码(SDWebImageDecoder)，然后放到内存中。
* 缓存的清除：
	* -(void)clearMemory;
		清内存缓存，在UIApplicationDidReceiveMemoryWarningNotification时主动调用。
	* -(void)clearDisk; 清空磁盘缓存
	* -(void)cleanDisk; 先清过期缓存，默认期限为一周，且如果设置最大缓存间时，清除最久的缓存，直到在size小于最大缓存空间的一半。
	* 需要注意的是，在UIApplicationWillTerminateNotification时会执行`- (void)cleanDisk`，在UIApplicationDidEnterBackgroundNotification时执行`- (void)backgroundCleanDisk`，两者的策略都是cleanDisk策略。

### 下载模块 
#### 1. SDWebImageDownloader
```objectivec
- (id)init {
    if ((self = [super init])) {
        _operationClass = [SDWebImageDownloaderOperation class];
        _shouldDecompressImages = YES;
        _executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = 6;
        _downloadQueue.name = @"com.hackemist.SDWebImageDownloader";
        _URLCallbacks = [NSMutableDictionary new];
#ifdef SD_WEBP
        _HTTPHeaders = [@{@"Accept": @"image/webp,image/*;q=0.8"} mutableCopy];
#else
        _HTTPHeaders = [@{@"Accept": @"image/*;q=0.8"} mutableCopy];
#endif
        _barrierQueue = dispatch_queue_create("com.hackemist.SDWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _downloadTimeout = 15.0;

        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = _downloadTimeout;

        /**
         *  Create the session for this task
         *  We send nil as delegate queue so that the session creates a serial operation queue for performing all delegate
         *  method calls and completion handler calls.
         */
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                     delegate:self
                                                delegateQueue:nil];
    }
    return self;
}
- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url options:(SDWebImageDownloaderOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageDownloaderCompletedBlock)completedBlock {
	...
}
- (void)addProgressCallback:(SDWebImageDownloaderProgressBlock)progressBlock completedBlock:(SDWebImageDownloaderCompletedBlock)completedBlock forURL:(NSURL *)url createCallback:(SDWebImageNoParamsBlock)createCallback {
	...
}
```
* 维护一个downloadeQueue，用的是NSOperationQueue。最大并发数为6
* 维护url的所有callback，一个url对应一次下载任务线程（downloaderOperation），多个callback。
* 网络请求用的是urlsession，downloader实现urlsession的delegate。
* 是一个单例。

#### 2. 下载线程 - downloaderOperation

* 下载线程，继承NSOperation，实现SDWebImageOperation协议，就是取消操作。
* 用的是urlsession执行下载任务。
* 实现urlsession的delegate，实际在这里处理callback。
* 默认超时设置为15s

### 取消模块 
```objectivec
- (void)sd_cancelImageLoadOperationWithKey:(NSString *)key {
    // Cancel in progress downloader from queue
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    id operations = [operationDictionary objectForKey:key];
    if (operations) {
        if ([operations isKindOfClass:[NSArray class]]) { // gif（一组图片）下载
            for (id <SDWebImageOperation> operation in operations) {
                if (operation) {
                    [operation cancel];
                }
            }
        } else if ([operations conformsToProtocol:@protocol(SDWebImageOperation)]){
            [(id<SDWebImageOperation>) operations cancel];
        }
        [operationDictionary removeObjectForKey:key];
    }
}
```
* UIView+WebCacheOperation，view层维护所有Operation

```objectivec
@interface SDWebImageCombinedOperation : NSObject <SDWebImageOperation>

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
@property (copy, nonatomic) SDWebImageNoParamsBlock cancelBlock; //下载模块
@property (strong, nonatomic) NSOperation *cacheOperation; // 缓存模块

@end
```
* CombinedOperation（SDWebImageOperation协议）组合缓存和下载的Operation
* DownloaderOperation（SDWebImageOperation协议） 下载线程的Operation
* 每次执行读取（下载）图片操作会取消上次的读取（下载）操作。

### Manager模块

```objectivec
- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                         options:(SDWebImageOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageCompletionWithFinishedBlock)completedBlock;

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL;

```
* MVC结构中的C层。一个中间层。
* 维护runningOperation
* 决定执行Cache还是Downloader
* 维护failedURLs黑名单
* 默认情况下，对黑名单的url不处理。
* transformDownloadedImage -delegate可以对下载的图片先做处理。再做缓存。

### prefetcher批量下载模块

```objectivec
- (void)startPrefetchingAtIndex:(NSUInteger)index {
    if (index >= self.prefetchURLs.count) return;
    self.requestedCount++;
    [self.manager downloadImageWithURL:self.prefetchURLs[index] options:self.options progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (!finished) return;
        self.finishedCount++;

        if (image) {
            if (self.progressBlock) {
                self.progressBlock(self.finishedCount,[self.prefetchURLs count]);
            }
        }
        else {
            if (self.progressBlock) {
                self.progressBlock(self.finishedCount,[self.prefetchURLs count]);
            }
            // Add last failed
            self.skippedCount++;
        }
        if ([self.delegate respondsToSelector:@selector(imagePrefetcher:didPrefetchURL:finishedCount:totalCount:)]) {
            [self.delegate imagePrefetcher:self
                            didPrefetchURL:self.prefetchURLs[index]
                             finishedCount:self.finishedCount
                                totalCount:self.prefetchURLs.count
             ];
        }
        if (self.prefetchURLs.count > self.requestedCount) {
            dispatch_async(self.prefetcherQueue, ^{ //默认主线程
                [self startPrefetchingAtIndex:self.requestedCount];
            });
        } else if (self.finishedCount == self.requestedCount) {
            [self reportStatus];
            if (self.completionBlock) {
                self.completionBlock(self.finishedCount, self.skippedCount);
                self.completionBlock = nil;
            }
            self.progressBlock = nil;
        }
    }];
}
```
* 默认在主线程请求，调用Manager的downloadImageWithURL：方法。
* 默认并发数为3。 这里的并发是指一次加3个请求到downloader队列中。·
* 默认的option是SDWebImageLowPriority。

### SDWebImage的Options

```objectivec
typedef NS_OPTIONS(NSUInteger, SDWebImageOptions) {
    SDWebImageRetryFailed = 1 << 0, //不加入url黑名单

    /**
     * By default, image downloads are started during UI interactions, this flags disable this feature,
     * leading to delayed download on UIScrollView deceleration for instance.
     */
    SDWebImageLowPriority = 1 << 1, //这个试过了，没起作用。在源代码中只是设置了NSOperation的低优先级。
    SDWebImageCacheMemoryOnly = 1 << 2, //只内存缓存
    SDWebImageProgressiveDownload = 1 << 3, //图片边下载边展示
    SDWebImageRefreshCached = 1 << 4, //重新下载
    SDWebImageContinueInBackground = 1 << 5, // 可以在后台下载
    SDWebImageHandleCookies = 1 << 6,
    SDWebImageAllowInvalidSSLCertificates = 1 << 7, //允许私有证书，用于测试
    SDWebImageHighPriority = 1 << 8, // 默认是先进先出的，这个可以提到前面
    SDWebImageDelayPlaceholder = 1 << 9, //延后放置占位图
    SDWebImageTransformAnimatedImage = 1 << 10, //设置转换图片，可以执行transformDownloadedImage的delegate。
    SDWebImageAvoidAutoSetImage = 1 << 11 //不自动设置图片
};
```