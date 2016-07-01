//
//  LockView.h
//  LockView
//
//  Created by ysj on 15/7/28.
//  Copyright (c) 2015年 ysj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LockView;

@protocol LockViewDelegate <NSObject>

@optional
- (void)lockView:(LockView *)lockView didFinishedPath:(NSString *)path;

@end

@interface LockView : UIView

@property (nonatomic, weak) id<LockViewDelegate> delegate;

@end
