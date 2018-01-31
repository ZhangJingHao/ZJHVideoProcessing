//
//  FFmpegConverOC.h
//  ZJHVideoProcessing
//
//  Created by ZhangJingHao2345 on 2018/1/29.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//


/**
 监测ffmpeg中C方法转化为OC方法
 */

// 转换停止回调
void stopRuning(void);

// 获取总时间长度
void setDuration(long long int time);

// 获取当前时间
void setCurrentTime(char info[1024]);
