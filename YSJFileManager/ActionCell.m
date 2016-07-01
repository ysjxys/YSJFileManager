//
//  ActionCell.m
//  YSJFileManager
//
//  Created by ysj on 16/2/1.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "ActionCell.h"

@implementation ActionCell

- (instancetype)initWithName:(NSString *)name{
    if (self = [super init]) {
        self.name= name;
    }
    return self;
}


+ (instancetype)actionCellWithName:(NSString *)name{
    return [[self alloc]initWithName:name];
}

@end
