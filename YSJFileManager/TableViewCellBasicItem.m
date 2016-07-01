//
//  TableViewCellBasicItem.m
//  YSJFileManager
//
//  Created by ysj on 16/1/27.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "TableViewCellBasicItem.h"

@implementation TableViewCellBasicItem

+ (instancetype)itemWithTitle:(NSString *)title icon:(NSString *)iconName{
    TableViewCellBasicItem *item = [[self alloc]init];
    item.iconName = iconName;
    item.title = title;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title{
    return [self itemWithTitle:title icon:nil];
}

@end
