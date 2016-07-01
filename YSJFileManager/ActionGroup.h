//
//  ActionGroup.h
//  YSJFileManager
//
//  Created by ysj on 16/2/1.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActionGroup : NSObject

@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, strong) NSArray *actionCellArr;

@end
