//
//  YSJPlist.m
//  YSJFileManager
//
//  Created by ysj on 16/3/4.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "YSJPlist.h"

@implementation YSJPlist

+ (NSString *)pathStringInDocumentationDirectory{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES)lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ifPathExist = [fileManager fileExistsAtPath:path isDirectory:NULL];
    if (!ifPathExist) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (void)addDictionary:(NSDictionary *)dic inFilePath:(NSString *)path{
    NSMutableArray *pathArr = [NSMutableArray arrayWithContentsOfFile:path];
    if (!pathArr) {
        pathArr = [NSMutableArray array];
    }
    [pathArr addObject:dic];
    [pathArr writeToFile:path atomically:YES];
}

+ (void)removeDictionary:(NSDictionary *)dic inFilePath:(NSString *)path{
    NSMutableArray *pathArr = [NSMutableArray arrayWithContentsOfFile:path];
    if (!pathArr) {
        pathArr = [NSMutableArray array];
    }
    [pathArr removeObject:dic];
    [pathArr writeToFile:path atomically:YES];
}

@end
