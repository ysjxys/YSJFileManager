//
//  FileInfoViewController.h
//  YSJFileManager
//
//  Created by ysj on 16/3/16.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicTableTableViewController.h"

#define FILESIZENUMBER @"fileSizeNumber"
#define FILECREATETIME @"fileCreateTime"
#define FAVOURITEPLIST @"favourite.plist"
@class YSJFile;

@interface FileInfoViewController : BasicTableTableViewController



- (instancetype)initWithYSJFile:(YSJFile *)ysjFile;

@end
