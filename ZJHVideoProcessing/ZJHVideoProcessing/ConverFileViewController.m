//
//  ConverFileViewController.m
//  ZJHVideoProcessing
//
//  Created by ZJH on 2018/1/30.
//  Copyright © 2018年 ZJH. All rights reserved.
//

#import "ConverFileViewController.h"
#import "FFmpegManager.h"

@interface ConverFileViewController ()

@property (weak, nonatomic) IBOutlet UITextView *inputView;
@property (weak, nonatomic) IBOutlet UITextView *outputView;
@property (weak, nonatomic) IBOutlet UILabel *tipLab;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation ConverFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频格式转码";
    
    if (self.inputPath && self.outputPath) {
        self.inputView.text = self.inputPath;
        self.outputView.text = self.outputPath;
        [self clickConverBtn];
    } else {
        // 测试数据
        NSString *inputPath = [[NSBundle mainBundle] pathForResource:@"video.mp4" ofType:nil];
        self.inputView.text = inputPath;
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *outputPath = [docDir stringByAppendingPathComponent:@"videoConver.mov"];
        self.outputView.text = outputPath;
    }
}

- (IBAction)clickConverBtn {
    if (!self.inputView.text.length || !self.outputView.text.length) {
        self.tipLab.text = @"请先输入路径";
        return ;
    }
    
    [[FFmpegManager sharedManager] converWithInputPath:self.inputView.text
                                            outputPath:self.outputView.text
                                          processBlock:^(float process) {
                                              self.tipLab.text = [NSString stringWithFormat:@"转码中 %.2f%%", process * 100];
                                              self.progressView.progress = process;
                                          }
                                       completionBlock:^(NSError *error) {
                                           if (error) {
                                               NSLog(@"转码失败 : %@", error);
                                               self.tipLab.text = @"转码失败";
                                           } else {
                                               NSLog(@"转码成功，请在相应路径查看，默认在沙盒Documents路径");
                                               self.tipLab.text = @"恭喜，转码成功！";
                                           }
                                       }];
    
}

@end
