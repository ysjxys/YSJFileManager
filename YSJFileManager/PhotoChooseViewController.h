//
//  PhotoChooseViewController.h
//  YSJFileManager
//
//  Created by ysj on 16/3/22.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "YSJViewController.h"

@interface PhotoChooseViewController : YSJViewController

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end
