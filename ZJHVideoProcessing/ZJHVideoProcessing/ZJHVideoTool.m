//
//  ZJHVideoTool.m
//  ZJHVideoProcessing
//
//  Created by ZJH on 2022/9/13.
//  Copyright © 2022 ZhangJingHao2345. All rights reserved.
//

#import "ZJHVideoTool.h"
#import "AFNetworking.h"

@implementation ZJHVideoTool

+ (void)getDataWithUrl:(NSString *)urlStr
                params:(NSDictionary *)params
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    AFHTTPSessionManager *sessionMgr = [AFHTTPSessionManager manager];
    sessionMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionMgr.requestSerializer = [AFHTTPRequestSerializer serializer];
    sessionMgr.responseSerializer.acceptableContentTypes =
    [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    [sessionMgr GET:urlStr parameters:params progress:nil success:success failure:failure];
}

+ (NSDictionary *)dictWithStr:(NSString *)dictStr {
    NSString * jsonString = dictStr;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [self dictWithData:jsonData];
}

+ (NSDictionary *)dictWithData:(NSData *)data {
    NSData *jsonData = data;
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
      //解析出错
        return nil;
    }
    return dic;
}

+ (void)createFilePath:(NSString *)filePath fileMgr:(NSFileManager *)fileMgr {
    if (!fileMgr) {
        fileMgr = [NSFileManager defaultManager];
    }
    
    if (![fileMgr fileExistsAtPath:filePath]) {
        [fileMgr createDirectoryAtPath:filePath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    }
}



@end
