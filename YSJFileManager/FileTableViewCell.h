//
//  FileTableViewCell.h
//  YSJFileManager
//
//  Created by ysj on 16/2/1.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FILESIZENUMBER @"fileSizeNumber"
#define FILECREATETIME @"fileCreateTime"
#define FAVOURITEPLIST @"favourite.plist"
#define FILEFOLDERPATH @"fileFolderPath"

@class YSJFile;
@class FileTableViewCell;
@protocol FileTableViewCellDelegate <NSObject>
@optional
- (void)fileTableViewCellSwipedFromLeft:(UISwipeGestureRecognizer *)recognizer;
- (void)fileTableViewCellSwipedFromRight:(UISwipeGestureRecognizer *)recognizer;
- (void)favourateStateChanged:(FileTableViewCell *)cell;
- (void)deletaBtnClicked:(FileTableViewCell *)cell;
- (void)infoBtnClicked:(FileTableViewCell *)cell;
- (void)editBtnClicked:(FileTableViewCell *)cell;
@end

@interface FileTableViewCell : UITableViewCell
@property (nonatomic, weak) id<FileTableViewCellDelegate> delegate;
@property (nonatomic, strong) YSJFile *ysjFile;

+ (instancetype)cellWithTableView:(UITableView *)tableView YSJFile:(YSJFile *)ysjFile  delegate:(id)delegate;

- (void)swipedToShowOptionView;
- (void)swipedToHideOptionView;
- (CGPoint)backViewCenter;
- (void)updateFavouriteImageState;
- (void)updatePlist;

@end
