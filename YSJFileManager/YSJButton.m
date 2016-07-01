//
//  YSJButton.m
//  YSJFileManager
//
//  Created by ysj on 16/3/16.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "YSJButton.h"

@implementation YSJButton


+ (instancetype)buttonWithTitle:(NSString *)title frame:(CGRect)frame{
    YSJButton *customBtn = [YSJButton buttonWithType:UIButtonTypeCustom];
    customBtn.frame = frame;
    customBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [customBtn setTitle:title forState:UIControlStateNormal];
    customBtn.layer.borderColor = [SystemBlueColor CGColor];
    [customBtn setTitleColor:SystemBlueColor forState:UIControlStateNormal];
    customBtn.layer.borderWidth = 1;
    customBtn.layer.cornerRadius = 5.0f;
    return customBtn;
}

@end
