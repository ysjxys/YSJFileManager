//
//  PhotoCollectionViewCell.m
//  YSJFileManager
//
//  Created by ysj on 16/3/22.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
@interface PhotoCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;


@end


@implementation PhotoCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setAsset:(ALAsset *)asset{
    _asset = asset;
    self.selectedView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.photoImgView.image = [UIImage imageWithCGImage:[asset thumbnail]];
}

@end
