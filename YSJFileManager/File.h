//
//  File.h
//  YSJFileManager
//
//  Created by ysj on 16/2/2.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface File : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSDate *updateTime;
@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, copy) NSString *fileSize;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) UIImage *fileTypeImg;
@property (nonatomic, assign) BOOL isFolder;
@property (nonatomic, assign) BOOL isFavourite;
@property (nonatomic, strong) NSNumber *fileSizeNumber;


- (instancetype)initWithDic:(NSDictionary *)dic TypeImg:(UIImage *)typeImg;
+ (instancetype)fileWithDic:(NSDictionary *)dic TypeImg:(UIImage *)typeImg;


@end
