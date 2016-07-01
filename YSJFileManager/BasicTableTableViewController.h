//
//  BasicTableTableViewController.h
//  YSJFileManager
//
//  Created by ysj on 16/1/27.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSJTableViewController.h"

@interface BasicTableTableViewController : YSJTableViewController

@property (nonatomic, strong) NSMutableArray *dataArr;

- (UILabel *)rightLabel:(NSString *)msg;
- (UILabel *)centerLabel:(NSString *)msg;
@end
