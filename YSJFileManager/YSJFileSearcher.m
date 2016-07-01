//
//  YSJFileSearcher.m
//  YSJFileManager
//
//  Created by ysj on 16/3/10.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "YSJFileSearcher.h"
#import "YSJFile.h"

@implementation YSJFileSearcher
+ (BOOL)updateModifyTxtYSJFile:(YSJFile *)ysjFile inFileArray:(NSArray *)fileArray{
    if ([fileArray containsObject:ysjFile]) {
        return YES;
    }
    for (YSJFile *file in fileArray) {
        YSJLog(@"%@",file.filePath);
        if ([file.fileCreationDate isEqualToDate:ysjFile.lastModifyDate]
            &&[file.fileSize  isEqualToNumber:ysjFile.oldFileSize]
            &&[file.fileType isEqualToString:ysjFile.fileType]
            &&(file.isFolder == ysjFile.isFolder)) {
            file.filePath = ysjFile.filePath;
            file.fileImage = ysjFile.fileImage;
            file.isInCollect = ysjFile.isInCollect;
            file.fileSizeByteStr = ysjFile.fileSizeByteStr;
            file.fileName = ysjFile.fileName;
            file.fileModificationDate = ysjFile.fileModificationDate;
            file.fileSize = ysjFile.fileSize;
            file.oldFileSize = ysjFile.oldFileSize;
            file.fileCreationDate = ysjFile.fileCreationDate;
            file.lastModifyDate = ysjFile.lastModifyDate;
            return YES;
        }
    }
    return NO;
}

+ (BOOL)updateYSJFile:(YSJFile *)ysjFile inFileArray:(NSArray *)fileArray{
    if ([fileArray containsObject:ysjFile]) {
        return YES;
    }
    for (YSJFile *file in fileArray) {
        YSJLog(@"%@",file.filePath);
        if ([file.fileCreationDate isEqualToDate:ysjFile.fileCreationDate]
            &&[file.fileSize isEqualToNumber:ysjFile.fileSize]
            &&(file.isFolder == ysjFile.isFolder)) {
//        if ([file.fileCreationDate isEqualToDate:ysjFile.fileCreationDate]
//            &&[file.fileSize isEqualToNumber:ysjFile.fileSize]
//            &&(file.isFolder == ysjFile.isFolder)
//            &&[[file.filePath stringByDeletingLastPathComponent] isEqualToString:[ysjFile.filePath stringByDeletingLastPathComponent]]) {
            file.fileImage = ysjFile.fileImage;
            file.isInCollect = ysjFile.isInCollect;
            file.fileSizeByteStr = ysjFile.fileSizeByteStr;
            file.fileName = ysjFile.fileName;
            file.fileModificationDate = ysjFile.fileModificationDate;
            file.fileSize = ysjFile.fileSize;
            file.fileType = ysjFile.fileType;
            return YES;
        }
    }
    return NO;
}

+ (NSArray *)ysjFileArrayInPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileNameArr = [fileManager contentsOfDirectoryAtPath:path error:&error];
    YSJLog(@"%@",path);
    YSJLog(@"%@",fileNameArr);
    NSMutableArray *fileArray = [NSMutableArray array];
    
    for (NSString * fileName in fileNameArr) {
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        YSJFile *file = [self checkFileInPath:filePath fileName:fileName];
        [fileArray addObject:file];
    }
    return fileArray;
}

+ (YSJFile *)checkFileInPath:(NSString *)filePath fileName:(NSString *)fileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
        return nil;
    }
    NSError *error = nil;
    NSString *fileSizeByteStr;
    NSString *fileType;
    UIImage *fileImage = nil;
    NSNumber *isFolder = [NSNumber numberWithBool:NO];
    NSNumber *isInCollect = [NSNumber numberWithBool:NO];
    //日期改为字符串显示
    NSDictionary *attributeDic = [fileManager attributesOfItemAtPath:filePath error:&error];
    NSDate *fileModificationDate = [attributeDic objectForKey:NSFileModificationDate];
    NSDate *fileCreationDate = [attributeDic objectForKey:NSFileCreationDate];
    NSNumber *fileSizeNumber = [attributeDic objectForKey:NSFileSize];
    
    if (isDir) {
        //is folder
        NSArray *fileNameList = [fileManager contentsOfDirectoryAtPath:filePath error:NULL];
        YSJLog(@"%@",fileNameList);
        //计算文件夹内文件数量
        fileSizeByteStr = [NSString stringWithFormat:@"%lu file",(unsigned long)fileNameList.count];
        //设置类型
        fileType = @"文件夹";
        // 文件类型图片设置
        fileImage = [UIImage imageNamed:FOLDERIMAGENAME];
        //isFolder设置为yes
        isFolder = [NSNumber numberWithBool:YES];
    }else{
        //is file
        //设置类型
        fileType = [NSString stringWithFormat:@"%@文件",[self checkFileType:fileName]];
        //计算文件大小之和
        NSDictionary *fileAttribute = [fileManager attributesOfItemAtPath:filePath error:nil];
        NSInteger fileSize = [[fileAttribute objectForKey:NSFileSize] integerValue];
        fileSizeByteStr = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
    }
    NSDictionary *param = @{@"fileName":fileName,
                            @"fileCreationDate":fileCreationDate,
                            @"fileModificationDate":fileModificationDate,
                            @"fileSizeByteStr":fileSizeByteStr,
                            @"fileSize":fileSizeNumber,
                            @"fileType":fileType,
                            @"filePath":filePath,
                            @"isInCollect":isInCollect,
                            @"isFolder":isFolder,
                            @"fileImage":fileImage};
    YSJFile *ysjFile = [YSJFile fileWithAttributeDic:param];
    return ysjFile;
}


+ (NSString *)checkFileType:(NSString *)fileName{
    if (IOS_VERSION < 8.0) {
        if ([fileName rangeOfString:@"."].location == NSNotFound) {
            return @"未知类型";
        }
    }else{
        if (![fileName containsString:@"."]) {
            return @"未知类型";
        }
    }
    NSRange markRange = [fileName rangeOfString:@"." options:NSBackwardsSearch];
    if (fileName.length <= markRange.location+1) {
        return(@"未知类型");
    }
    return [fileName substringFromIndex:markRange.location+1];
}

@end
