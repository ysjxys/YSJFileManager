//
//  SJTableViewCell.m
//  YSJFileManager
//
//  Created by ysj on 16/1/27.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "SJTableViewCell.h"
#import "TableViewCellBasicItem.h"
#import "TableViewCellSwitchItem.h"
#import "TableViewCellArrowItem.h"
#import "TableViewCellViewItem.h"
#import "TableViewCellCenterViewItem.h"

@interface SJTableViewCell()
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIView *centerView;
@end

@implementation SJTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


+ (instancetype)cellWithTableView:(UITableView *)tableView{
    NSString *ID = @"TableViewCellID";
    SJTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[SJTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    return cell;
}

- (void)setItem:(TableViewCellBasicItem *)item{
    _item = item;
    [self setData];
    [self setRightView];
}

- (void)setData{
    self.textLabel.text = self.item.title;
    self.detailTextLabel.text = self.item.subTitle;
    if (self.item.iconName) {
        self.imageView.image = [UIImage imageNamed:self.item.iconName];
    } else {
        self.imageView.image = nil;
    }
}

- (void)setRightView{
    if ([self.item isKindOfClass:[TableViewCellArrowItem class]]) {
        self.accessoryView = self.arrowView;
    }else if ([self.item isKindOfClass:[TableViewCellSwitchItem class]]){
        self.accessoryView = self.switchView;
    }else if ([self.item isKindOfClass:[TableViewCellViewItem class]]){
        self.accessoryView = self.rightView;
    }else if ([self.item isKindOfClass:[TableViewCellCenterViewItem class]]){
        self.accessoryView = nil;
        [self.contentView addSubview:self.centerView];
        [self initConstraint];
    }else{
        self.accessoryView = nil;
    }
}

- (void)initConstraint{
    _centerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerViewCenterX = [NSLayoutConstraint constraintWithItem:_centerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *centerViewCenterY = [NSLayoutConstraint constraintWithItem:_centerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    
//    NSLayoutConstraint *centerViewWidth = [NSLayoutConstraint constraintWithItem:_centerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
//    
//    NSLayoutConstraint *centerViewHeight = [NSLayoutConstraint constraintWithItem:_centerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
    
    
    if (IOS_VERSION < 8) {
        [self addConstraint:centerViewCenterX];
        [self addConstraint:centerViewCenterY];
    }else{
        centerViewCenterX.active = YES;
        centerViewCenterY.active = YES;
    }
//    centerViewHeight.active = YES;
//    centerViewWidth.active = YES;
}



- (UIImageView *)arrowView{
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Arrow"]];
    }
    return _arrowView;
}

- (UISwitch *)switchView{
    if (!_switchView) {
        _switchView = [[UISwitch alloc]init];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [_switchView setOn:[user boolForKey:self.item.userDefaultKey]];
        [_switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (void)switchValueChanged{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![self.deleagte respondsToSelector:@selector(startUserDefault:switchIsOn:)]) {
        return;
    }
    if ([userDefault objectForKey:self.item.userDefaultKey] == nil) {
        [self.deleagte startUserDefault:self switchIsOn:self.switchView.isOn];
        return;
    }
    [userDefault setBool:self.switchView.isOn forKey:self.item.userDefaultKey];
}

- (void)setSwitchState:(BOOL)isOn{
    if (_switchView) {
        _switchView.on = isOn;
    }
}

- (UIView *)rightView{
    if (!_rightView) {
        if (![self.item isKindOfClass:[TableViewCellViewItem class]]) {
            return nil;
        }
        TableViewCellViewItem *viewItem = (TableViewCellViewItem*)self.item;
        _rightView = viewItem.rightView;
    }
    return _rightView;
}

- (UIView *)centerView{
    if (!_centerView) {
        if (![self.item isKindOfClass:[TableViewCellCenterViewItem class]]) {
            return nil;
        }
        TableViewCellCenterViewItem *item = (TableViewCellCenterViewItem *)self.item;
        _centerView = item.centerView;
        
        
    }
    return _centerView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
