//
//  ZJHUIWebViewController.h
//  ZJHVideoProcessing
//
//  Created by ZJH on 2022/9/13.
//  Copyright © 2022 ZJH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZJHUIWebViewController : UIViewController

@property (nonatomic, copy) NSString *urlStr;

@property (nonatomic, assign) BOOL isAutoLoadVideo;

@property (nonatomic, copy) NSString *outputPath;

@property (nonatomic, copy) void (^completeBlock)(BOOL isSucc);

@property (nonatomic, copy) void (^videoUrlBlock)(NSString *videoUrl);


@end

NS_ASSUME_NONNULL_END
