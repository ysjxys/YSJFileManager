//
//  YSJFileSearcher.h
//  YSJFileManager
//
//  Created by ysj on 16/3/10.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>
#define FOLDERIMAGENAME @"folder-share-icon"

@class YSJFile;
@interface YSJFileSearcher : NSObject



+ (NSArray *)ysjFileArrayInPath:(NSString *)path;
+ (BOOL)updateYSJFile:(YSJFile *)ysjFile inFileArray:(NSArray *)fileArray;
+ (BOOL)updateModifyTxtYSJFile:(YSJFile *)ysjFile inFileArray:(NSArray *)fileArray;

@end
