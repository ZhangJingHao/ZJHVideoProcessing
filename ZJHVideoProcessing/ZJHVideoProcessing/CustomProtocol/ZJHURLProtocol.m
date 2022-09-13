//
//  ZJHURLProtocol.m
//  ZJHURLProtocol
//
//  Created by ZJH on 2018/8/24.
//  Copyright © 2018年 ZJH. All rights reserved.
//

#import "ZJHURLProtocol.h"
#import "ZJHSessionConfiguration.h"

// 为了避免canInitWithRequest和canonicalRequestForRequest的死循环
static NSString *const kProtocolHandledKey = @"kProtocolHandledKey";

@interface ZJHURLProtocol () <NSURLConnectionDelegate,NSURLConnectionDataDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOperationQueue     *sessionDelegateQueue;
@property (nonatomic, strong) NSURLResponse        *response;

@end

@implementation ZJHURLProtocol

#pragma mark - Public

/// 开始监听
+ (void)startMonitor {
    ZJHSessionConfiguration *sessionConfiguration = [ZJHSessionConfiguration defaultConfiguration];
    [NSURLProtocol registerClass:[ZJHURLProtocol class]];
    if (![sessionConfiguration isSwizzle]) {
        [sessionConfiguration load];
    }
}

/// 停止监听
+ (void)stopMonitor {
    ZJHSessionConfiguration *sessionConfiguration = [ZJHSessionConfiguration defaultConfiguration];
    [NSURLProtocol unregisterClass:[ZJHURLProtocol class]];
    if ([sessionConfiguration isSwizzle]) {
        [sessionConfiguration unload];
    }
}

#pragma mark - Override

/**
 需要控制的请求
 
 @param request 此次请求
 @return 是否需要监控
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    // 如果是已经拦截过的就放行，避免出现死循环
    if ([NSURLProtocol propertyForKey:kProtocolHandledKey inRequest:request] ) {
        return NO;
    }
    
    // 不是网络请求，不处理
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    // 指定拦截网络请求，如：www.baidu.com
    //    if ([request.URL.absoluteString containsString:@"www.baidu.com"]) {
    //        return YES;
    //    } else {
    //        return NO;
    //    }
    
    // 拦截所有
    return YES;
}

/**
 设置我们自己的自定义请求
 可以在这里统一加上头之类的
 
 @param request 应用的此次请求
 @return 我们自定义的请求
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    // 设置已处理标志
    [NSURLProtocol setProperty:@(YES)
                        forKey:kProtocolHandledKey
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

// 重新父类的开始加载方法
- (void)startLoading {
    NSLog(@"***ZJH 监听接口：%@", self.request.URL.absoluteString);
    
    NSURLSessionConfiguration *configuration =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.sessionDelegateQueue = [[NSOperationQueue alloc] init];
    self.sessionDelegateQueue.maxConcurrentOperationCount = 1;
    self.sessionDelegateQueue.name = @"com.hujiang.wedjat.session.queue";
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:configuration
                                  delegate:self
                             delegateQueue:self.sessionDelegateQueue];
    
    self.dataTask = [session dataTaskWithRequest:self.request];
    [self.dataTask resume];
}

// 结束加载
- (void)stopLoading {
    [self.dataTask cancel];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!error) {
        [self.client URLProtocolDidFinishLoading:self];
    } else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
    } else {
        [self.client URLProtocol:self didFailWithError:error];
    }
    self.dataTask = nil;
}

#pragma mark - NSURLSessionDataDelegate

// 当服务端返回信息时，这个回调函数会被ULS调用，在这里实现http返回信息的截
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    // 返回给URL Loading System接收到的数据，这个很重要，不然光截取不返回，就瞎了。
    [self.client URLProtocol:self didLoadData:data];
    
    // 打印返回数据
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (dataStr) {
        NSLog(@"***ZJH 截取数据 : %@", dataStr);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);
    self.response = response;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    if (response != nil){
        self.response = response;
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
}

@end
