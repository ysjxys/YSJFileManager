//
//  CreateFolderViewController.h
//  YSJFileManager
//
//  Created by ysj on 16/2/24.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSJViewController.h"
@class YSJFile;
typedef NS_ENUM(NSInteger, InputMode) {
    inputModeCreateFolder = 1,
    inputModeRename
};

@interface CreateFolderViewController : YSJViewController


- (instancetype)initWithDirectoryPathString:(NSString *)pathString;
- (instancetype)initWithYSJFile:(YSJFile*)ysjFile;

@end
