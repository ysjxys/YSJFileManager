//
//  FileCollectionHeadView.m
//  YSJFileManager
//
//  Created by ysj on 16/2/25.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "FileCollectionHeadView.h"
#import "UIView+YSJ.h"

@interface FileCollectionHeadView()
@property (nonatomic, strong) UIView *topButtonsView;
@end

@implementation FileCollectionHeadView


+ (instancetype)headViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath{
    NSString *identifier = FILECOLLECTIONHEADVIEW;
    FileCollectionHeadView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifier forIndexPath:indexPath];
    [headView initViews];
    return headView;
}

- (void)initViews{
//    CGFloat topButtonsHeight = 40;
    UIView *topButtonsView = [[UIView alloc]init];
    [self addSubview:topButtonsView];
    _topButtonsView = topButtonsView;
    
    topButtonsView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *topBVLeading = [NSLayoutConstraint constraintWithItem:topButtonsView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *topBVTop = [NSLayoutConstraint constraintWithItem:topButtonsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *topBVWidth = [NSLayoutConstraint constraintWithItem:topButtonsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *topBVHeight = [NSLayoutConstraint constraintWithItem:topButtonsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:0.0f constant:40];
    
    
    if (IOS_VERSION < 8) {
        [self addConstraint:topBVLeading];
        [self addConstraint:topBVTop];
        [self addConstraint:topBVWidth];
        [self addConstraint:topBVHeight];
    }else{
        topBVLeading.active = YES;
        topBVTop.active = YES;
        topBVWidth.active = YES;
        topBVHeight.active = YES;
    }
    
    topButtonsView.backgroundColor = RGBA(220, 220, 220, 1);
    NSArray *imgNameArr = @[@"add-option", @"sort-button", @"table-mode", @"search-option"];
    CGFloat btnWidth = self.width/imgNameArr.count;
    for (int i = 0; i < imgNameArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:imgNameArr[i]] forState:UIControlStateNormal];
        btn.tag = i;
        btn.frame = CGRectMake(i*btnWidth, 0, btnWidth, 40);
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [topButtonsView addSubview:btn];
        
        
//        btn.translatesAutoresizingMaskIntoConstraints = NO;
//        YSJLog(@"%lf",(1.0f*i*btnWidth));
//        NSLayoutConstraint *btnLeading = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:topButtonsView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:(1.0f*i*btnWidth)];
//        
//        NSLayoutConstraint *btnTop = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topButtonsView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
//        
//        NSLayoutConstraint *btnWidth = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:topButtonsView attribute:NSLayoutAttributeWidth multiplier:(1.0f/imgNameArr.count) constant:0.0f];
//        
//        NSLayoutConstraint *btnHeight = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:topButtonsView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
//        
//        btnLeading.active = YES;
//        btnTop.active = YES;
//        btnWidth.active = YES;
//        btnHeight.active = YES;
    }
    
}

- (UIView *)topButtonsView{
    return _topButtonsView;
}

- (void)btnClicked:(UIButton *)btn{
    [self.delegate collectionHeadViewBtnClicked:btn.tag];
}


@end
