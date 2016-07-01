//
//  LockViewViewController.h
//  YSJFileManager
//
//  Created by ysj on 16/3/14.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, StartMode){
    startCreatePWD = 1,
    startInputPWD,
    startModifyPWD,
};

@interface LockViewViewController : UIViewController

@property (nonatomic, assign) StartMode startMode;

- (instancetype)initWithMsg:(NSString *)msg startMode:(StartMode)startMode;

@end
