//
//  DownloadFileViewController.m
//  ZJHVideoProcessing
//
//  Created by ZJH on 2018/1/30.
//  Copyright © 2018年 ZJH. All rights reserved.
//

#import "DownloadFileViewController.h"
#import "ConverFileViewController.h"
#import "AFNetworking.h"
#import "FFmpegManager.h"

@interface DownloadFileViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *tipLab;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


@end

@implementation DownloadFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"M3U8文件下载";

    // 测试链接
    self.textView.text = @"https://dco4urblvsasc.cloudfront.net/811/81095_ywfZjAuP/game/1000kbps.m3u8";
}

// 下载m3u8文件
- (IBAction)clickDownload {
    if (!self.tipLab.text.length || ![self.textView.text containsString:@"http"]) {
        self.tipLab.text = @"链接不合法";
        return;
    }
    self.tipLab.text = @"下载m3u8文件";
    
    NSString *destinationPath = [self.documentPath stringByAppendingPathComponent:self.textView.text.lastPathComponent];
    
    __weak typeof(self)wkSelf = self;
    [self downloadURL:self.textView.text
      destinationPath:destinationPath
             progress:nil
           completion:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
               if (!error) {
                   [wkSelf dealPlayList];
               } else {
                   wkSelf.tipLab.text = error.debugDescription;
               }
           }];
}

// 处理m3u8文件
- (void)dealPlayList {
    self.tipLab.text = @"处理m3u8文件";
    
    // 读取m3u8文件内容
    NSString *filePath = [self.documentPath stringByAppendingPathComponent:self.textView.text.lastPathComponent];
    NSString *content = [NSString stringWithContentsOfFile:filePath
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    NSArray *array = [content componentsSeparatedByString:@"\n"];
    
    // 筛选出 .ts 文件
    NSMutableArray *listArr = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *str in array) {
        if ([str containsString:@".ts"]) {
            [listArr addObject:str];
        }
    }
    
    NSString *firstStr = listArr.firstObject;
    NSString *videoName = [firstStr componentsSeparatedByString:@"."].firstObject;
    self.tipLab.text = [NSString stringWithFormat:@"共有 %ld 个视频", listArr.count];
    // 下载 ts 文件
    [self downloadVideoWithArr:listArr andIndex:0 videoName:videoName];
}

// 循环下载 ts 文件
- (void)downloadVideoWithArr:(NSArray *)listArr andIndex:(NSInteger)index videoName:(NSString *)videoName {
    if (index >= listArr.count) {
        self.tipLab.text = @"视频下载完成";
        [self combVideos];
        return;
    }
    
    self.tipLab.text = [NSString stringWithFormat:@"共有 %ld 个ts文件, 下载中：%.2f%%", listArr.count, (float)index/listArr.count * 100];
    self.progressView.progress = (float)index/listArr.count;
    
    // 拼接ts全路径，有的文件直接包含，不需要拼接
    NSString *downloadURL = [self.textView.text stringByReplacingOccurrencesOfString:self.textView.text.lastPathComponent withString:listArr[index]];
    
    // 存储路径
    NSString *listName = listArr[index];
    NSString *fileName = [NSString stringWithFormat:@"video_%ld.%@",(long)index,listName.pathExtension];
    NSString *destinationPath = [self.videoPath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        [self downloadVideoWithArr:listArr andIndex:index+1 videoName:videoName];
        return;
    }
    
    __weak typeof(self)wkSelf = self;
    [self downloadURL:downloadURL
      destinationPath:destinationPath
             progress:nil
           completion:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
               if (!error) {
                   [wkSelf downloadVideoWithArr:listArr andIndex:index+1 videoName:videoName];
               }
           }];
}


// 合成为一个ts文件
- (void)combVideos {
    NSString *fileName = @"合成原文件.ts";
    NSString *filePath = [[self documentPath] stringByAppendingPathComponent:fileName];
    NSFileManager *mgr = [NSFileManager defaultManager];
    if ([mgr fileExistsAtPath:filePath]) {
        self.tipLab.text = @"已合成视频";
        return;
    }

    NSArray *contentArr = [mgr contentsOfDirectoryAtPath:[self videoPath]
                                                   error:nil];
    NSMutableData *dataArr = [NSMutableData alloc];
    int videoCount = 0;
    for (NSString *str in contentArr) {
        // 按顺序拼接 TS 文件
        if ([str containsString:@"video_"]) {
            NSString *videoName = [NSString stringWithFormat:@"video_%d.%@",videoCount, str.pathExtension];
            NSString *videoPath = [[self videoPath] stringByAppendingPathComponent:videoName];
            // 读出数据
            NSData *data = [[NSData alloc] initWithContentsOfFile:videoPath];
            // 合并数据
            [dataArr appendData:data];
            videoCount++;
        }
    }

    [dataArr writeToFile:filePath atomically:YES];
    
    [self convert];
}

- (void)convert {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    ConverFileViewController *vc = [ConverFileViewController new];
    vc.inputPath = [docDir stringByAppendingPathComponent:@"合成原文件.ts"];
    vc.outputPath = [docDir stringByAppendingPathComponent:@"转码后的的视频.mp4"];
    [self.navigationController pushViewController:vc animated:NO];
}


// 视频列表路径
- (NSString *)videoPath {
    NSString *vedioPath = [self.documentPath stringByAppendingPathComponent:@"VideoList"];
    NSFileManager *mgr = [NSFileManager defaultManager];
    if (![mgr fileExistsAtPath:vedioPath]) {
        [mgr createDirectoryAtPath:vedioPath
       withIntermediateDirectories:YES
                        attributes:nil
                             error:nil];
    }
    return vedioPath;
}

// 沙盒 document 路径
- (NSString *)documentPath  {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return docDir;
}

// 下载方法
- (void)downloadURL:(NSString *)downloadURL
    destinationPath:(NSString *)destinationPath
           progress:(void (^)(NSProgress *downloadProgress))progress
         completion:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completion {
    AFHTTPSessionManager *manage  = [AFHTTPSessionManager manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: downloadURL]];
    
    NSURLSessionDownloadTask *downloadTask =
    [manage downloadTaskWithRequest:request
                           progress:^(NSProgress * _Nonnull downloadProgress) {
                               if (progress) {
                                   progress(downloadProgress);
                               }
                           }
                        destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                            
                            NSURL *filePathUrl = nil;
                            if (destinationPath) {
                                filePathUrl = [NSURL fileURLWithPath:destinationPath];
                            }
                            if (filePathUrl) {
                                return filePathUrl;
                            }
                            NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                            NSString *fullpath = [caches stringByAppendingPathComponent:response.suggestedFilename];
                            filePathUrl = [NSURL fileURLWithPath:fullpath];
                            return filePathUrl;
                        }
                  completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
                      if (completion) {
                          completion(response, filePath, error);
                      }
                  }];
    
    [downloadTask resume];
}

@end
