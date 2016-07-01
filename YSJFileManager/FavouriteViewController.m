//
//  FavouriteViewController.m
//  YSJFileManager
//
//  Created by ysj on 16/1/26.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "FavouriteViewController.h"
#import "UIView+YSJ.h"
#import "YSJFile.h"
#import "FileTableViewCell.h"
#import "YSJPlist.h"
#import "DirectoryWatcher.h"
#import <QuickLook/QuickLook.h>
#import "FileInfoViewController.h"
#import "FileManagerNavigationController.h"
#import "CreateFolderViewController.h"


@interface FavouriteViewController ()<
UITableViewDataSource,
UITableViewDelegate,
QLPreviewControllerDataSource,
QLPreviewControllerDelegate,
DirectoryWatcherDelegate,
FileTableViewCellDelegate,
UIActionSheetDelegate>


@property (nonatomic, strong) UITableView *favTableView;
@property (nonatomic, copy) NSMutableArray *favFileArray;
@property (nonatomic, strong) QLPreviewController *qlPreviewController;
@property (nonatomic, copy) NSArray *allFileArray;
@property (nonatomic, copy) NSArray *fileArray;
@property (nonatomic, strong) DirectoryWatcher *dirWatcher;
@property (nonatomic, strong) YSJFile *deleteFile;

@end

@implementation FavouriteViewController

- (instancetype)init{
    self = [super init];
    [self initNotification];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initConstraint];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allFileData:) name:@"getAllFileData" object:nil];
}
- (void)allFileData:(NSNotification *)notification{
    self.allFileArray = [notification.userInfo objectForKey:@"allFileArray"];
    self.fileArray = [notification.userInfo objectForKey:@"fileArray"];
}

- (void)refreshData{
    NSString *plistPath = [YSJPlist pathStringInDocumentationDirectory];
    plistPath = [plistPath stringByAppendingPathComponent:FAVOURITEPLIST];
    NSArray *plistArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    [self.favFileArray removeAllObjects];
    for (int i = 0; i < plistArray.count; i++) {
        NSDictionary *dic = plistArray[i];
        NSDate *date = dic[FILECREATETIME];
        NSNumber *number = dic[FILESIZENUMBER];
        NSString *folderPath = dic[FILEFOLDERPATH];
        for (YSJFile *ysjFile in self.allFileArray) {
//            if ([ysjFile.fileSize isEqualToNumber:number] &&
//                [ysjFile.fileCreationDate isEqualToDate:date] && [[ysjFile.filePath stringByDeletingLastPathComponent] isEqualToString:folderPath]) {
//                [ysjFile setValue:[NSNumber numberWithBool:YES] forKey:@"isInCollect"];
//                [self.favFileArray addObject:ysjFile];
//                break;
//            }
            if ([ysjFile.fileSize isEqualToNumber:number] &&
                [ysjFile.fileCreationDate isEqualToDate:date]) {
                [ysjFile setValue:[NSNumber numberWithBool:YES] forKey:@"isInCollect"];
                [self.favFileArray addObject:ysjFile];
                break;
            }
        }
    }
    [self initQLPreviewController];
    [self.favTableView reloadData];
}

- (void)initViews{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"我的收藏";
    
    UITableView *favTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-NavigationBarHeight-TabBarHeight-StatusBarHeight) style:UITableViewStylePlain];
    favTableView.delegate = self;
    favTableView.dataSource = self;
    favTableView.tableFooterView = [[UIView alloc]init];
    self.favTableView = favTableView;
    [self.view addSubview:favTableView];
    
    DirectoryWatcher *dirWatcher = [DirectoryWatcher watchFolderWithPath:[YSJPlist pathStringInDocumentationDirectory] delegate:self];
    self.dirWatcher = dirWatcher;
    [self initQLPreviewController];
}

- (void)initQLPreviewController{
    self.qlPreviewController = nil;
    QLPreviewController *qlPreviewController = [[QLPreviewController alloc]init];
    qlPreviewController.edgesForExtendedLayout = UIRectEdgeNone;
    qlPreviewController.view.backgroundColor = [UIColor whiteColor];
    qlPreviewController.dataSource = self;
    qlPreviewController.delegate = self;
    self.qlPreviewController = qlPreviewController;
}

- (void)initConstraint{
    self.favTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *favTVLeading = [NSLayoutConstraint constraintWithItem:self.favTableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *favTVTailing = [NSLayoutConstraint constraintWithItem:self.favTableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *favTVTop = [NSLayoutConstraint constraintWithItem:self.favTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *favTVBottom = [NSLayoutConstraint constraintWithItem:self.favTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
    
    
    if (IOS_VERSION < 8) {
        [self.view addConstraint:favTVBottom];
        [self.view addConstraint:favTVLeading];
        [self.view addConstraint:favTVTailing];
        [self.view addConstraint:favTVTop];
    }else{
        favTVBottom.active = YES;
        favTVLeading.active = YES;
        favTVTailing.active = YES;
        favTVTop.active = YES;
    }
}

#pragma mark - QLPreviewController Delegate & Datasour
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    if (self.favFileArray.count > 0) {
        YSJFile *ysjFile = self.favFileArray[index];
        return [NSURL fileURLWithPath:ysjFile.filePath];
    }
    return nil;
}


#pragma mark - DirectoryWatcher Delegate

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher{
    [self refreshData];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.favFileArray.count == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return self.favFileArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YSJFile *ysjFile = self.favFileArray[indexPath.row];
    FileTableViewCell *cell = [FileTableViewCell cellWithTableView:tableView YSJFile:ysjFile delegate:self];
    [cell addObserver:self forKeyPath:@"contentView.center" options:NSKeyValueObservingOptionNew context:nil];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell backViewCenter].x < 0) {//若cell为拉开状态，return
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    self.qlPreviewController.currentPreviewItemIndex = indexPath.row;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:self.qlPreviewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - FileTableViewCell  Delegate

- (void)deletaBtnClicked:(FileTableViewCell *)cell{
    self.deleteFile = cell.ysjFile;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定删除" otherButtonTitles: nil];
    actionSheet.tag = 2;
    [actionSheet showInView:self.view];
}

- (void)infoBtnClicked:(FileTableViewCell *)cell{
    FileInfoViewController *infoVC = [[FileInfoViewController alloc]initWithYSJFile:cell.ysjFile];
    
    FileManagerNavigationController *fmNav = [[FileManagerNavigationController alloc]initWithRootViewController:infoVC];
    fmNav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:fmNav animated:YES completion:^{
        [self swipedToHideCellOptionViewExceptIndexPath:nil];
    }];
}

- (void)editBtnClicked:(FileTableViewCell *)cell{
    CreateFolderViewController *cfVC = [[CreateFolderViewController alloc]initWithYSJFile:cell.ysjFile];
    FileManagerNavigationController *fmNav = [[FileManagerNavigationController alloc]initWithRootViewController:cfVC];
    [self presentViewController:fmNav animated:YES completion:^{
        [self swipedToHideCellOptionViewExceptIndexPath:nil];
    }];
}

- (void)fileTableViewCellSwipedFromRight:(UISwipeGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationInView:self.favTableView];
    NSIndexPath *indexPath = [self.favTableView indexPathForRowAtPoint:point];
    FileTableViewCell *cell = [self.favTableView cellForRowAtIndexPath:indexPath];
    [cell swipedToShowOptionView];
    
    [self swipedToHideCellOptionViewExceptIndexPath:indexPath];
}

- (void)fileTableViewCellSwipedFromLeft:(UISwipeGestureRecognizer *)recognizer{
    if (self.editing) {
        return;
    }
    CGPoint point = [recognizer locationInView:self.favTableView];
    NSIndexPath *indexPath = [self.favTableView indexPathForRowAtPoint:point];
    FileTableViewCell *cell = [self.favTableView cellForRowAtIndexPath:indexPath];
    [cell swipedToHideOptionView];
}

- (void)favourateStateChanged:(FileTableViewCell *)cell{
    cell.ysjFile.isInCollect = !cell.ysjFile.isInCollect;
    [self.favFileArray removeObject:cell.ysjFile];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFileArrays" object:self userInfo:@{@"YSJFile":cell.ysjFile}];
    [cell updateFavouriteImageState];
    [cell updatePlist];
    [cell swipedToHideOptionView];
}

- (void)swipedToHideCellOptionViewExceptIndexPath:(NSIndexPath *)indexPath{
    if (indexPath != nil) {
        for (FileTableViewCell *visibleCell in [self.favTableView visibleCells]) {
            NSIndexPath *visibleIndexPath = [self.favTableView indexPathForCell:visibleCell];
            if (![visibleIndexPath isEqual:indexPath]) {
                [visibleCell swipedToHideOptionView];
            }
        }
    }else{
        for (FileTableViewCell *visibleCell in [self.favTableView visibleCells]) {
            [visibleCell swipedToHideOptionView];
        }
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [self removeFile];
    }else{
        [self setEditing:NO animated:YES];
    }
}

- (void)removeFile{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *path = [YSJPlist pathStringInDocumentationDirectory];
    path = [path stringByAppendingPathComponent:FAVOURITEPLIST];
    NSMutableArray *favArr = [NSMutableArray arrayWithContentsOfFile:path];
    
    [fm removeItemAtPath:self.deleteFile.filePath error:nil];
    for (NSDictionary *dic in favArr) {
        if ([dic[FILECREATETIME] isEqualToDate:self.deleteFile.fileCreationDate] &&
            [dic[FILESIZENUMBER] isEqualToNumber:self.deleteFile.fileSize]) {
            [favArr removeObject:dic];
            break;
        }
    }
    [favArr writeToFile:path atomically:YES];
    [self setEditing:NO animated:YES];
}

- (NSMutableArray *)favFileArray{
    if (!_favFileArray) {
        _favFileArray = [NSMutableArray array];
    }
    return _favFileArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
