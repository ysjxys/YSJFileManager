//
//  FileTableViewController.h
//  YSJFileManager
//
//  Created by ysj on 16/2/29.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSJTableViewController.h"
@class YSJFile;
@protocol FileTableViewControllerDelegate <NSObject>
@required
- (void)searchFileClicked:(YSJFile *)ysjFile;
@end

@interface FileTableViewController : YSJTableViewController
@property (nonatomic, weak) id<FileTableViewControllerDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewStyle)style fileArray:(NSMutableArray *)fileArray;
- (void)setFileArray:(NSMutableArray *)fileArray;
@end
