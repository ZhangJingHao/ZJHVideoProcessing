//
//  ZJHUIWebViewController.m
//  ZJHVideoProcessing
//
//  Created by ZJH on 2022/9/13.
//  Copyright © 2022 ZJH. All rights reserved.
//

#import "ZJHUIWebViewController.h"

@interface ZJHUIWebViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;


@end

@implementation ZJHUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    self.webView = webView;
    self.webView.delegate = self;
    
    NSString *urlStr = @"http:www.baidu.com";
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
        NSLog(@"videoUrlStr == %@",videoUrlStr);
        
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
    
    // 获取网页的一个值
//    NSString *htmlNum = @"document.getElementById('title').innerText";
//    NSString *numHtmlInfo = [web stringByEvaluatingJavaScriptFromString:htmlNum];
//    NSLog(@"%@",numHtmlInfo);
}

@end
