//
//  File.m
//  YSJFileManager
//
//  Created by ysj on 16/2/2.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "File.h"
#import "NSObject+YSJ.h"

@implementation File

- (instancetype)initWithDic:(NSDictionary *)dic TypeImg:(UIImage *)typeImg;{
    if (self = [super init]) {
        if ([[dic objectForKey:@"fileName"] isNotNull]) {
            self.fileName = [dic objectForKey:@"fileName"];
        }
        if ([[dic objectForKey:@"fileSize"] isNotNull]) {
            self.fileSize = [dic objectForKey:@"fileSize"];
        }
        if ([[dic objectForKey:@"updateTime"] isNotNull]) {
            self.updateTime = [dic objectForKey:@"updateTime"];
        }
        if ([[dic objectForKey:@"createTime"] isNotNull]) {
            self.createTime = [dic objectForKey:@"createTime"];
        }
        if ([[dic objectForKey:@"fileType"] isNotNull]) {
            self.fileType = [dic objectForKey:@"fileType"];
        }
        if ([[dic objectForKey:@"filePath"] isNotNull]) {
            self.filePath = [dic objectForKey:@"filePath"];
        }
        if ([[dic objectForKey:@"fileSizeNumber"] isNotNull]) {
            self.fileSizeNumber = [dic objectForKey:@"fileSizeNumber"];
        }
        if ([[dic objectForKey:@"isFolder"] isNotNull]) {
            if ([[dic objectForKey:@"isFolder"] integerValue] == 1) {
                self.isFolder = YES;
            }else{
                self.isFolder = NO;
            }
        }
        if ([[dic objectForKey:@"isFavourite"] isNotNull]) {
            if ([[dic objectForKey:@"isFavourite"] integerValue] == 1) {
                self.isFavourite = YES;
            }else{
                self.isFavourite = NO;
            }
        }
        if (typeImg) {
            self.fileTypeImg = typeImg;
        }
    }
    return self;
}

+ (instancetype)fileWithDic:(NSDictionary *)dic TypeImg:(UIImage *)typeImg;{
    return [[self alloc]initWithDic:dic TypeImg:typeImg];
}

@end
