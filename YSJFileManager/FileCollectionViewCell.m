//
//  FileCollectionViewCell.m
//  YSJFileManager
//
//  Created by ysj on 16/2/16.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "FileCollectionViewCell.h"
#import "YSJFile.h"
#import "UIView+YSJ.h"

@interface FileCollectionViewCell()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *selectedBtn;
@end

@implementation FileCollectionViewCell

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath{
    FileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FILECOLLECTIONVIEWCELL forIndexPath:indexPath];
    [cell initCellViews];
    return cell;
}

- (void)initCellViews{
    if (!self.nameLabel) {
        CGFloat labelH = 20;
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(-5, self.height-labelH, self.width+10, labelH)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:13.0];
        self.nameLabel = nameLabel;
        [self.contentView addSubview:nameLabel];
    }
    
    if (!self.imgView) {
        CGFloat labelH = 20;
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(labelH/2, 0, self.width-labelH, self.height-labelH)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        self.imgView = imgView;
        [self.contentView addSubview:imgView];
    }
    
    if (!self.selectedBtn) {
        CGFloat selectedBtnH = 25;
        UIButton *selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectedBtn.frame = CGRectMake(0, self.imgView.bottom-selectedBtnH, selectedBtnH, selectedBtnH);
        [selectedBtn setImage:[UIImage imageNamed:@"select-all-tick"] forState:UIControlStateNormal];
        [selectedBtn setImage:[UIImage imageNamed:@"tick"] forState:UIControlStateSelected];
        self.selectedBtn = selectedBtn;
        [self.contentView addSubview:selectedBtn];
        selectedBtn.hidden = YES;
    }
    [self setSelected:NO];
}

- (void)setYsjFile:(YSJFile *)ysjFile{
    _ysjFile = ysjFile;
    self.nameLabel.text = ysjFile.fileName;
    self.imgView.image = ysjFile.fileImage;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    self.selectedBtn.selected = selected;
}

- (void)setSelectedMarkHidden:(BOOL)hidden{
    self.selectedBtn.hidden = hidden;
    if (hidden) {
        [self setSelected:NO];
    }
}

@end
