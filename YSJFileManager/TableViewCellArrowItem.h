//
//  TableViewCellArrowItem.h
//  YSJFileManager
//
//  Created by ysj on 16/1/27.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "TableViewCellBasicItem.h"

@interface TableViewCellArrowItem : TableViewCellBasicItem

@property (nonatomic, assign) Class destVcClass;

+ (instancetype)itemWithTitle:(NSString *)title destVcClass:(Class)destVcClass;
+ (instancetype)itemWithTitle:(NSString *)title icon:(NSString *)iconName destVcClass:(Class)destVcClass;

@end
