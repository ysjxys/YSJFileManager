//
//  FileTableViewCell.m
//  YSJFileManager
//
//  Created by ysj on 16/2/1.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "FileTableViewCell.h"
#import "YSJFile.h"
#import "NSDate+YSJ.h"
#import "UIView+YSJ.h"
#import "YSJPlist.h"





@interface FileTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@property (weak, nonatomic) IBOutlet UIView *backOptionView;
@property (weak, nonatomic) IBOutlet UIImageView *favouriteImageView;
@property (weak, nonatomic) IBOutlet UIView *cellBackView;
@property (weak, nonatomic) IBOutlet UIView *backModelView;


@property (nonatomic, strong) UITableView *selfTableView;



@end
@implementation FileTableViewCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleGray;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView YSJFile:(YSJFile *)ysjFile  delegate:(id)delegate{
    NSString *identifier = @"FileTableViewCell";
    FileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        //此处nib文件名与Identifier相同才可共用宏，nib文件内也需要设置Identifier
        cell = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil][0];
//        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selfTableView = tableView;
//        cell = [[FileTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        if (delegate) {
            cell.delegate = delegate;
            UISwipeGestureRecognizer *swipeFromLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:cell.delegate action:@selector(fileTableViewCellSwipedFromLeft:)];
            swipeFromLeft.direction = UISwipeGestureRecognizerDirectionRight;
            [cell addGestureRecognizer:swipeFromLeft];
            
            UISwipeGestureRecognizer *swipeFromRight = [[UISwipeGestureRecognizer alloc]initWithTarget:cell.delegate action:@selector(fileTableViewCellSwipedFromRight:)];
            swipeFromRight.direction = UISwipeGestureRecognizerDirectionLeft;
            [cell addGestureRecognizer:swipeFromRight];
            
            cell.backOptionView.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, tableView.frame.size.width, cell.frame.size.height);
            [cell.backModelView addSubview:cell.backOptionView];
            
//            cell.backgroundColor = [UIColor blackColor];
//            cell.contentView.backgroundColor = [UIColor greenColor];
//            cell.backModelView.backgroundColor = [UIColor blueColor];
//            cell.backOptionView.backgroundColor = [UIColor yellowColor];
//            cell.cellBackView.backgroundColor = [UIColor purpleColor];
        }
    }
//    cell.backOptionView.alpha = 0;
    cell.ysjFile = ysjFile;
    return cell;
}

- (void)swipedToShowOptionView{
    if (!self.backOptionView) {
        return;
    }
    self.backOptionView.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint center = CGPointMake(self.contentView.centerX-self.contentView.width, self.contentView.centerY);
        self.cellBackView.center = center;
    } completion:nil];
}

- (void)swipedToHideOptionView{
    if (!self.backOptionView) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint center = CGPointMake(self.contentView.centerX, self.contentView.centerY);
        self.cellBackView.center = center;
    } completion:^(BOOL finished) {
        self.backOptionView.alpha = 0;
        
    }];
}

- (IBAction)favBtnClicked:(id)sender {
    YSJLog(@"fav btn clicked");
    if ([self.delegate respondsToSelector:@selector(favourateStateChanged:)]) {
         [self.delegate favourateStateChanged:self];
    }
}

- (IBAction)editBtnClicked:(id)sender {
    YSJLog(@"edit btn clicked");
    if ([self.delegate respondsToSelector:@selector(editBtnClicked:)]) {
        [self.delegate editBtnClicked:self];
    }
}

- (IBAction)infoBtnClicked:(id)sender {
    YSJLog(@"info btn clicked");
    if ([self.delegate respondsToSelector:@selector(infoBtnClicked:)]) {
        [self.delegate infoBtnClicked:self];
    }
}

- (IBAction)deleteBtnClicked:(id)sender {
    YSJLog(@"delete btn clicked");
    if ([self.delegate respondsToSelector:@selector(deletaBtnClicked:)]) {
        [self.delegate deletaBtnClicked:self];
    }
}

- (void)updatePlist{
    NSString *path = [YSJPlist pathStringInDocumentationDirectory];
    path = [path stringByAppendingPathComponent:FAVOURITEPLIST];
    
    if (self.ysjFile.isInCollect) {
        NSDictionary *dic = @{FILESIZENUMBER:self.ysjFile.fileSize,
                              FILECREATETIME:self.ysjFile.fileCreationDate,
                              FILEFOLDERPATH:[self.ysjFile.filePath stringByDeletingLastPathComponent]};
        [YSJPlist addDictionary:dic inFilePath:path];
    }else{
        NSMutableArray *favArr = [NSMutableArray arrayWithContentsOfFile:path];
        for (NSDictionary *dic in favArr) {
            if ([dic[FILECREATETIME] isEqualToDate:self.ysjFile.fileCreationDate]
                &&[dic[FILESIZENUMBER] isEqualToNumber:self.ysjFile.fileSize]) {
//                if ([dic[FILECREATETIME] isEqualToDate:self.ysjFile.fileCreationDate]
//                    &&[dic[FILESIZENUMBER] isEqualToNumber:self.ysjFile.fileSize]
//                    && [dic[FILEFOLDERPATH] isEqualToString:[self.ysjFile.filePath stringByDeletingLastPathComponent]]) {
                [favArr removeObject:dic];
                [favArr writeToFile:path atomically:YES];
                break;
            }
        }
    }
}

- (void)updateFavouriteImageState{
    self.favouriteImageView.hidden = self.ysjFile.isInCollect?NO:YES;
}

- (void)setYsjFile:(YSJFile *)ysjFile{
    _ysjFile = ysjFile;
    self.nameLabel.text = ysjFile.fileName;
    self.typeLabel.text = ysjFile.fileType;
    
    NSString *updateTimeStr = [ysjFile.fileModificationDate dateToStringWithDefaultFormatterStr];
    self.updateTimeLabel.text = updateTimeStr;
    self.sizeLabel.text = ysjFile.fileSizeByteStr;
    
    self.imgView.image = ysjFile.fileImage;
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self updateFavouriteImageState];
}

- (CGPoint)backViewCenter{
    return self.cellBackView.center;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
