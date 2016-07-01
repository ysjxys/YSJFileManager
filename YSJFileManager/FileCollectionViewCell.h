//
//  FileCollectionViewCell.h
//  YSJFileManager
//
//  Created by ysj on 16/2/16.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FILECOLLECTIONVIEWCELL @"FileCollectionViewCell"
@class YSJFile;

@interface FileCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) YSJFile *ysjFile;

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

- (void)setSelected:(BOOL)selected;
- (void)setSelectedMarkHidden:(BOOL)hidden;
@end
