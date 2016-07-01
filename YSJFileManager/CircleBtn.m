//
//  CircleBtn.m
//  LockView
//
//  Created by ysj on 15/7/28.
//  Copyright (c) 2015年 ysj. All rights reserved.
//

#import "CircleBtn.h"

@implementation CircleBtn

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initImage];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initImage];
    }
    return self;
}

- (void)initImage{
    self.userInteractionEnabled = NO;
    [self setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
    [self setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
}
@end
