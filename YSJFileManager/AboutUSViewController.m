//
//  AboutUSViewController.m
//  YSJFileManager
//
//  Created by ysj on 16/1/27.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "AboutUSViewController.h"
#import "UIView+YSJ.h"

@interface AboutUSViewController ()
@property (nonatomic, strong) NSLayoutConstraint *labelHeightVertical;
@property (nonatomic, strong) NSLayoutConstraint *labelHeightHorizontal;
@property (nonatomic, strong) NSLayoutConstraint *labelTopVertical;
@property (nonatomic, strong) NSLayoutConstraint *labelTopHorizontal;
@end

@implementation AboutUSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *msgLabel = [[UILabel alloc]init];
    msgLabel.numberOfLines = 0;
    msgLabel.textAlignment = NSTextAlignmentCenter;
    msgLabel.textColor = [UIColor darkGrayColor];
    msgLabel.font = [UIFont systemFontOfSize:16.0f];
    NSDictionary *info= [[NSBundle mainBundle] infoDictionary];
//    info[@"CFBundleShortVersionString"]; //Version
//    info[@"CFBundleVersion"]; // Build
    msgLabel.text = [NSString stringWithFormat:@"当前版本：%@    \n      感谢您的使用！个人工作时间之外开发之作，疏漏难免，还望海涵。如若发现bug，或有任何功能改进意见建议，请发送邮件至ysjxys@163.com。欢迎加群134564143互动讨论：）",info[@"CFBundleShortVersionString"]];
    
    
    [self.view addSubview:msgLabel];
    
    UIImageView *logoImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"IMG_0009.jpg"]];
    logoImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:logoImg];
    
    msgLabel.translatesAutoresizingMaskIntoConstraints = NO;
    logoImg.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *labelLeading = [NSLayoutConstraint constraintWithItem:msgLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:20];
    
    NSLayoutConstraint *labelTailing = [NSLayoutConstraint constraintWithItem:msgLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-20];
    
    NSLayoutConstraint *labelTopVertical = [NSLayoutConstraint constraintWithItem:msgLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:30];
    labelTopVertical.priority = UILayoutPriorityDefaultHigh;
    self.labelTopVertical = labelTopVertical;
    
    NSLayoutConstraint *labelTopHorizontal = [NSLayoutConstraint constraintWithItem:msgLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:10];
    labelTopHorizontal.priority = UILayoutPriorityDefaultLow;
    self.labelTopHorizontal = labelTopHorizontal;
    
    NSLayoutConstraint *labelHeightVertical = [NSLayoutConstraint constraintWithItem:msgLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:100];
    labelHeightVertical.priority = UILayoutPriorityDefaultHigh;
    self.labelHeightVertical = labelHeightVertical;
    
    NSLayoutConstraint *labelHeightHorizontal = [NSLayoutConstraint constraintWithItem:msgLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:60];
    labelHeightHorizontal.priority = UILayoutPriorityDefaultLow;
    self.labelHeightHorizontal = labelHeightHorizontal;
    
    if (IOS_VERSION < 8) {
        [self.view addConstraint:labelHeightVertical];
        [self.view addConstraint:labelHeightHorizontal];
        [self.view addConstraint:labelLeading];
        [self.view addConstraint:labelTailing];
        [self.view addConstraint:labelTopVertical];
        [self.view addConstraint:labelTopHorizontal];
    }else{
        labelHeightVertical.active = YES;
        labelHeightHorizontal.active = YES;
        labelLeading.active = YES;
        labelTailing.active = YES;
        labelTopVertical.active = YES;
        labelTopHorizontal.active = YES;
    }
    
    
    NSLayoutConstraint *logoWidth = [NSLayoutConstraint constraintWithItem:logoImg attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.0f constant:200.0f];
    
    NSLayoutConstraint *logoHeight = [NSLayoutConstraint constraintWithItem:logoImg attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:200.0f];
    
    NSLayoutConstraint *logoTop = [NSLayoutConstraint constraintWithItem:logoImg attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:msgLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:10.0f];
    
    NSLayoutConstraint *logoCenterX = [NSLayoutConstraint constraintWithItem:logoImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:msgLabel attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    
    if (IOS_VERSION < 8) {
        [self.view addConstraint:logoWidth];
        [self.view addConstraint:logoHeight];
        [self.view addConstraint:logoTop];
        [self.view addConstraint:logoCenterX];
    }else{
        logoWidth.active = YES;
        logoHeight.active = YES;
        logoTop.active = YES;
        logoCenterX.active = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDirectionChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self screenDirectionChanged:nil];
}

- (void)screenDirectionChanged:(NSNotification *)notification{
    UIDevice *device = [UIDevice currentDevice];
    switch (device.orientation) {
        case UIDeviceOrientationPortrait://home botton on the buttom
            self.labelHeightHorizontal.priority = UILayoutPriorityDefaultLow;
            self.labelHeightVertical.priority = UILayoutPriorityDefaultHigh;
            self.labelTopHorizontal.priority = UILayoutPriorityDefaultLow;
            self.labelTopVertical.priority = UILayoutPriorityDefaultHigh;
            break;
        case UIDeviceOrientationLandscapeLeft://home button on the right
        case UIDeviceOrientationLandscapeRight://home button on the left
            self.labelHeightHorizontal.priority = UILayoutPriorityDefaultHigh;
            self.labelHeightVertical.priority = UILayoutPriorityDefaultLow;
            self.labelTopHorizontal.priority = UILayoutPriorityDefaultHigh;
            self.labelTopVertical.priority = UILayoutPriorityDefaultLow;
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
