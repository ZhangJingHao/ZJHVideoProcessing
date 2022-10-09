//
//  ZJHVideoTool.h
//  ZJHVideoProcessing
//
//  Created by ZJH on 2022/9/13.
//  Copyright © 2022 ZhangJingHao2345. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZJHVideoTool : NSObject

+ (void)getDataWithUrl:(NSString *)urlStr
                params:(NSDictionary *)params
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (NSDictionary *)dictWithStr:(NSString *)dictStr;

+ (NSDictionary *)dictWithData:(NSData *)data;

+ (void)createFilePath:(NSString *)filePath fileMgr:(NSFileManager *)fileMgr;

@end

NS_ASSUME_NONNULL_END
