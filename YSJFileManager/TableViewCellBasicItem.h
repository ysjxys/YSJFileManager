//
//  TableViewCellBasicItem.h
//  YSJFileManager
//
//  Created by ysj on 16/1/27.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BasicItemOption)();
@interface TableViewCellBasicItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) BasicItemOption selectedOption;
@property (nonatomic, copy) NSString *userDefaultKey;

+ (instancetype)itemWithTitle:(NSString *)title icon:(NSString *)iconName;
+ (instancetype)itemWithTitle:(NSString *)title;

@end
