//
//  ActionCell.h
//  YSJFileManager
//
//  Created by ysj on 16/2/1.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^actionCellOption)();
@interface ActionCell : NSObject


@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) actionCellOption option;

- (instancetype)initWithName:(NSString *)name;
+ (instancetype)actionCellWithName:(NSString *)name;

@end
