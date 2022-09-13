//
//  AppDelegate.m
//  ZJHVideoProcessing
//
//  Created by ZJH on 2018/1/29.
//  Copyright © 2018年 ZJH. All rights reserved.
//

#import "AppDelegate.h"
#import "ZJHURLProtocol.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//    [ZJHURLProtocol startMonitor];
    
    // 沙盒路径
    NSString *directory = NSHomeDirectory();
    NSLog(@"沙盒路径 : %@", directory);
    
    return YES;
}



@end
