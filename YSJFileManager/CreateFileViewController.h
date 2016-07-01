//
//  CreateFileViewController.h
//  YSJFileManager
//
//  Created by ysj on 16/3/24.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "YSJViewController.h"
@class YSJFile;
typedef NS_ENUM (NSInteger, EditType) {
    EditTypeCreateFile = 1,
    EditTypeModifyFile = 2,
};
@interface CreateFileViewController : YSJViewController

@property (nonatomic, assign) EditType editType;

- (instancetype)initWithDirectoryPathString:(NSString *)directory;
- (instancetype)initWithModifyFile:(YSJFile *)ysjFile;
@end
