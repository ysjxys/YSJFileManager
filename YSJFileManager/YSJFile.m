//
//  YSJFile.m
//  YSJFileManager
//
//  Created by ysj on 16/3/10.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "YSJFile.h"
#import "NSObject+YSJ.h"

@implementation YSJFile

+ (instancetype)fileWithAttributeDic:(NSDictionary *)dic{
    return [self fileWithAttributeDic:dic fileImage:nil];
}

+ (instancetype)fileWithAttributeDic:(NSDictionary *)dic fileImage:(UIImage *)fileImage{
    return [[self alloc]initWithAttributeDic:dic fileImage:fileImage];
}

- (instancetype)initWithAttributeDic:(NSDictionary *)dic{
    return [self initWithAttributeDic:dic fileImage:nil];
}

- (instancetype)initWithAttributeDic:(NSDictionary *)dic fileImage:(UIImage *)fileImage{
    if (self = [super init]) {
        if (fileImage) {
            self.fileImage = fileImage;
        }
        if ([[dic objectForKey:@"isFolder"] isNotNull]) {
            self.isFolder = [[dic objectForKey:@"isFolder"] integerValue]==1?YES:NO;
        }
        if ([[dic objectForKey:@"isInCollect"] isNotNull]) {
            self.isInCollect = [[dic objectForKey:@"isInCollect"] integerValue]==1?YES:NO;
        }
        if ([[dic objectForKey:@"fileType"] isNotNull]) {
            self.fileType = dic[@"fileType"];
        }
        if ([[dic objectForKey:@"fileSizeByteStr"] isNotNull]) {
            self.fileSizeByteStr = dic[@"fileSizeByteStr"];
        }
        if ([[dic objectForKey:@"fileName"] isNotNull]) {
            self.fileName = dic[@"fileName"];
        }
        if ([[dic objectForKey:@"filePath"] isNotNull]) {
            self.filePath = dic[@"filePath"];
        }
        if ([[dic objectForKey:@"fileModificationDate"] isNotNull]) {
            self.fileModificationDate = dic[@"fileModificationDate"];
        }
        if ([[dic objectForKey:@"fileCreationDate"] isNotNull]) {
            self.fileCreationDate = dic[@"fileCreationDate"];
        }
        if ([[dic objectForKey:@"fileSize"] isNotNull]) {
            self.fileSize = dic[@"fileSize"];
        }
        if ([[dic objectForKey:@"oldFileSize"] isNotNull]) {
            self.oldFileSize = dic[@"oldFileSize"];
        }
        if ([[dic objectForKey:@"lastModifyDate"] isNotNull]) {
            self.lastModifyDate = dic[@"lastModifyDate"];
        }
    }
    return self;
}

@end
