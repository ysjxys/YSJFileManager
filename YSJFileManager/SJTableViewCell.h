//
//  SJTableViewCell.h
//  YSJFileManager
//
//  Created by ysj on 16/1/27.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TableViewCellBasicItem;
@class SJTableViewCell;
@protocol SJTableViewCellDelegate <NSObject>
- (void)startUserDefault:(SJTableViewCell *)cell switchIsOn:(BOOL)isOn;
@end

@interface SJTableViewCell : UITableViewCell

@property (nonatomic, strong) TableViewCellBasicItem *item;
@property (nonatomic, weak) id<SJTableViewCellDelegate> deleagte;


+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)setSwitchState:(BOOL)isOn;


@end
