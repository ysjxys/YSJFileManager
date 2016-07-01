//
//  TableViewCellArrowItem.m
//  YSJFileManager
//
//  Created by ysj on 16/1/27.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "TableViewCellArrowItem.h"

@implementation TableViewCellArrowItem

+ (instancetype)itemWithTitle:(NSString *)title destVcClass:(Class)destVcClass{
    TableViewCellArrowItem *item = [self itemWithTitle:title];
    item.destVcClass = destVcClass;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title icon:(NSString *)iconName destVcClass:(Class)destVcClass{
    TableViewCellArrowItem *item = [self itemWithTitle:title icon:iconName];
    item.destVcClass = destVcClass;
    return item;
}
@end
