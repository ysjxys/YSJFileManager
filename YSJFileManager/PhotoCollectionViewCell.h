//
//  PhotoCollectionViewCell.h
//  YSJFileManager
//
//  Created by ysj on 16/3/22.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) ALAsset *asset;
@property (weak, nonatomic) IBOutlet UIView *selectedView;
@end
