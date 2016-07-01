//
//  FileManagerNavigationController.m
//  YSJFileManager
//
//  Created by ysj on 16/1/26.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "FileManagerNavigationController.h"

@interface FileManagerNavigationController ()

@end

@implementation FileManagerNavigationController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
//    self.navigationBar.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return self.orietation;
//    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != self.orietation);
//    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

@end
