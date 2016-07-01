//
//  TableViewCellGroup.h
//  YSJFileManager
//
//  Created by ysj on 16/1/27.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewCellGroup : NSObject

@property (nonatomic, copy) NSString *header;
@property (nonatomic, copy) NSString *footer;
@property (nonatomic, strong) NSArray *itemArr;

@end
