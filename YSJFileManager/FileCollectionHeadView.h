//
//  FileCollectionHeadView.h
//  YSJFileManager
//
//  Created by ysj on 16/2/25.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FILECOLLECTIONHEADVIEW @"FileCollectionHeadView"

@protocol FileCollectionHeadViewDelegate <NSObject>

- (void)collectionHeadViewBtnClicked:(NSInteger)btnTag;

@end

@interface FileCollectionHeadView : UICollectionReusableView

@property (nonatomic, weak) id<FileCollectionHeadViewDelegate> delegate;

+ (instancetype)headViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

- (UIView *)topButtonsView;
@end
