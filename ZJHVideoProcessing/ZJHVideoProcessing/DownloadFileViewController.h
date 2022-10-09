//
//  DownloadFileViewController.h
//  ZJHVideoProcessing
//
//  Created by ZJH on 2018/1/30.
//  Copyright © 2018年 ZJH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadFileViewController : UIViewController

@property (nonatomic, copy) NSString *videoUrl;

@property (nonatomic, assign) BOOL isAutoDownLoad;

@property (nonatomic, copy) NSString *outputPath;

@property (nonatomic, copy) void (^completeBlock)(BOOL isSucc);

@end
