//
//  ZJHUIWebViewController.m
//  ZJHVideoProcessing
//
//  Created by ZJH on 2022/9/13.
//  Copyright © 2022 ZJH. All rights reserved.
//

#import "ZJHUIWebViewController.h"
#import "DownloadFileViewController.h"

@interface ZJHUIWebViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;

@property (nonatomic, assign) BOOL isJumpTag;

@end

@implementation ZJHUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat statusH = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navH = self.navigationController.navigationBar.frame.size.height;
    CGFloat webH = self.view.frame.size.height - statusH - navH;
    CGRect webF = CGRectMake(0, navH + statusH, self.view.frame.size.width, webH);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webF];
    [self.view addSubview:webView];
    self.webView = webView;
    self.webView.delegate = self;
    
    NSString *urlStr = @"http:www.baidu.com";
    if (self.urlStr) {
        urlStr = self.urlStr;
    }
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    [self.webView loadRequest:req];
    
    [self setupNavigationItem];
}

- (void)setupNavigationItem {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(clickBackItem)];
    
    UIBarButtonItem *htmlItem = [[UIBarButtonItem alloc] initWithTitle:@"Html"
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(clickHtmlItem)];
    
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(clickRefreshItem)];
    
    UIBarButtonItem *downloadItem = [[UIBarButtonItem alloc] initWithTitle:@"下载"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(clickDownloadItem)];
    
    self.navigationItem.rightBarButtonItems = @[backItem, htmlItem, refreshItem, downloadItem];
}

#pragma mark - Deal Action

// 返回上一个页面
- (void)clickBackItem {
    [self.webView goBack];
}

// 刷新按钮
- (void)clickRefreshItem {
    [self.webView reload];
}

// 获取到得网页内容
- (void)clickHtmlItem {
    NSString *allHtml = @"document.documentElement.innerHTML";
    NSString *allHtmlInfo = [self.webView stringByEvaluatingJavaScriptFromString:allHtml];
    NSLog(@"网页HTML内容：%@", allHtmlInfo);
}

// 下载视频按钮
- (void)clickDownloadItem {
    NSString *JSStr = @"(document.getElementsByTagName(\"video\")[0]).src";
    NSString *videoUrlStr = [self.webView stringByEvaluatingJavaScriptFromString:JSStr];
    if (!videoUrlStr.length) {
        NSLog(@"未能检测到视频链接");
    } else {
        if (self.isJumpTag) {
            return;
        }
        
        NSLog(@"检测到视频链接 videoUrlStr == %@",videoUrlStr);
        DownloadFileViewController *vc = [DownloadFileViewController new];
        vc.videoUrl = videoUrlStr;
        vc.isAutoDownLoad = self.isAutoLoadVideo;
        vc.outputPath = self.outputPath;
        [self.navigationController pushViewController:vc animated:YES];
        vc.completeBlock = self.completeBlock;
        
        self.isJumpTag = YES;
        
        if (self.videoUrlBlock) {
            self.videoUrlBlock(videoUrlStr);
        }
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // 获取网页title
    NSString *htmlTitle = @"document.title";
    NSString *titleHtmlInfo = [webView stringByEvaluatingJavaScriptFromString:htmlTitle];
    self.title = titleHtmlInfo;
    
    if (self.isAutoLoadVideo) {
        double time = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)time*NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self clickDownloadItem];
        });
    }
}

@end
