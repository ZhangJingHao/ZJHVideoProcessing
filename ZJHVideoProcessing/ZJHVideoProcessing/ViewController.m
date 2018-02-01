//
//  ViewController.m
//  ZJHVideoProcessing
//
//  Created by ZhangJingHao2345 on 2018/1/29.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//

#import "ViewController.h"
#import "DownloadFileViewController.h"
#import "ConverFileViewController.h"
#import "FFmpegManager.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *nameArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.nameArr = @[ @"M3U8文件下载",
                      @"视频格式转码"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.nameArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cell_Id = @"cell_id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_Id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_Id];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = self.nameArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: {
            DownloadFileViewController *vc = [DownloadFileViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1: {
            ConverFileViewController *vc = [ConverFileViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}


@end
