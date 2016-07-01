//
//  FileManagerViewController.h
//  YSJFileManager
//
//  Created by ysj on 16/1/26.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSJViewController.h"

@interface FileManagerViewController : YSJViewController
@property (nonatomic, assign) BOOL shouldLock;

- (instancetype)initWithDirectoryPathString:(NSString *)pathString;
@end
