//
//  FileManagerViewController.m
//  YSJFileManager
//
//  Created by ysj on 16/1/26.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "FileManagerViewController.h"
#import "UIView+YSJ.h"
#import "ActionCell.h"
#import "ActionGroup.h"
#import "FileTableViewCell.h"
#import "NSDate+YSJ.h"
#import "YSJFile.h"
#import "FileCollectionViewCell.h"
#import <QuickLook/QuickLook.h>
#import "DirectoryWatcher.h"
#import "CreateFolderViewController.h"
#import "FileManagerNavigationController.h"
#import "FileCollectionHeadView.h"
#import "FileTableViewController.h"
#import "YSJPlist.h"
#import "YSJFileSearcher.h"
#import "LockViewViewController.h"
#import "FileInfoViewController.h"
#import "YSJButton.h"
#import "PhotoChooseTableViewController.h"
#import "CreateFileViewController.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+YSJ.h"

#define SORTTYPE @"SortType"
#define TOPBUTTONSHEIGHT 40
typedef enum{
    SortByName = 1,
    SortByTime = 2,
    SortBySize = 3,
    SortDefault = 4,
    SortCancel = 5
}SortType;

@interface FileManagerViewController ()<
UIScrollViewDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
UITableViewDelegate,
QLPreviewControllerDataSource,
QLPreviewControllerDelegate,
UIDocumentInteractionControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
DirectoryWatcherDelegate,
UIAlertViewDelegate,
UISearchBarDelegate,
UISearchResultsUpdating,
FileTableViewCellDelegate,
FileTableViewControllerDelegate,
FileCollectionHeadViewDelegate>


@property (nonatomic, strong) ActionGroup *actionGroupAdd;
@property (nonatomic, strong) ActionGroup *actionGroupSort;
@property (nonatomic, strong) UITableView *fileTableView;
@property (nonatomic, strong) UICollectionView *fileCollectionView;
@property (nonatomic, strong) NSMutableArray *fileArray;
@property (nonatomic, strong) NSMutableArray *defaultSortFileArray;
@property (nonatomic, strong) NSMutableArray *deleteFileArray;
@property (nonatomic, strong) NSMutableArray *searchFileArray;
@property (nonatomic, strong) NSMutableArray *allFileArray;
@property (nonatomic, strong) QLPreviewController *qlPreviewController;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) UIView *topButtonsView;
@property (nonatomic, strong) UIButton *deleteFileBtn;
@property (nonatomic, strong) DirectoryWatcher *docWatcher;
@property (nonatomic, copy) NSString *homeDirectoryPathString;
@property (nonatomic, strong) UISearchController *searchCtrl;
@property (nonatomic, strong) FileCollectionHeadView *headView;
@property (nonatomic, strong) FileTableViewController *fileSearchTableView;
@property (nonatomic, assign) BOOL isClickFromSearchVC;
@property (nonatomic, strong) YSJFile *searchedFile;
@property (nonatomic, assign) NSInteger selectedRow;

@end

@implementation FileManagerViewController

- (instancetype)init{
    if (self = [super init]) {
        self.homeDirectoryPathString = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.navigationItem.title = @"我的文件";
    }
    return self;
}

- (instancetype)initWithDirectoryPathString:(NSString *)pathString{
    if (self = [super init]) {
        self.homeDirectoryPathString = pathString;
        self.navigationItem.title = [pathString lastPathComponent];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadDocumentData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initViews];
    [self initNotification];
}

- (void)showLockViewController{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault boolForKey:LockScreen] && [userDefault objectForKey:UserPWD] && self.shouldLock) {
        [self presentViewController:[[LockViewViewController alloc] initWithMsg:@"请输入手势密码" startMode:startInputPWD] animated:NO completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getAllFileData" object:nil userInfo:@{@"allFileArray":self.allFileArray, @"fileArray":self.fileArray}];
    [self swipedToHideCellOptionViewExceptIndexPath:nil];
    [self searchBarCancelButtonClicked:self.searchCtrl.searchBar];
}

- (void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDirectionChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFileArrays:) name:@"updateFileArrays" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateModifyTxtYSJFile:) name:@"updateModifyTxtYSJFile" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addData:) name:@"addData" object:nil];
}

- (void)initViews{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = YES;//default is YES useless?
    self.definesPresentationContext = YES;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.editButtonItem.title = @"编辑";
//    [[UINavigationBar appearance] setBarTintColor:[UIColor orangeColor]];
    
    UIView *topButtonsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, TOPBUTTONSHEIGHT)];
    topButtonsView.backgroundColor = RGBA(220, 220, 220, 1);
    NSArray *imgNameArr = @[@"add-option", @"sort-button", @"grid-mode", @"search-option"];
    CGFloat btnWidth = topButtonsView.width/imgNameArr.count;
    for (int i = 0; i < imgNameArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:imgNameArr[i]] forState:UIControlStateNormal];
        btn.tag = i;
        btn.frame = CGRectMake(i*btnWidth, 0, btnWidth, TOPBUTTONSHEIGHT);
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [topButtonsView addSubview:btn];
    }
    
    self.topButtonsView = topButtonsView;
    
//    UITableView *tableView= [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-NavigationBarHeight-StatusBarHeight+20) style:UITableViewStylePlain];
    UITableView *tableView= [[UITableView alloc]init];
    
    //height+20是为了避免搜索模式时底部的留白
//    tableView.contentInset = UIEdgeInsetsMake(0, 0, TabBarHeight+20, 0);
    //启用以下cell注册会使cell自动重用，无法进入自定义cell类内(!cell)的判断
//    UINib *nib = [UINib nibWithNibName:NSStringFromClass([FileTableViewCell class]) bundle:nil];
//    [tableView registerNib:nib forCellReuseIdentifier:@"FileTableViewCell"];
    tableView.tableFooterView = [[UIView alloc]init];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    tableView.tableHeaderView = topButtonsView;
    self.fileTableView = tableView;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:tableView.frame collectionViewLayout:layout];
//    UICollectionView *collectionView = [[UICollectionView alloc]init];
//    collectionView.collectionViewLayout = layout;
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, TabBarHeight+20, 0);
    [collectionView registerClass:[FileCollectionViewCell class] forCellWithReuseIdentifier:FILECOLLECTIONVIEWCELL];
    [collectionView registerClass:[FileCollectionHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:FILECOLLECTIONHEADVIEW];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.allowsMultipleSelection = YES;
    self.fileCollectionView = collectionView;
    [self.view addSubview:collectionView];
    //showType为true，列表显示 开  collection默认隐藏；
    collectionView.hidden = [[NSUserDefaults standardUserDefaults] boolForKey:ShowType];
    
    UIButton *deleteFileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteFileBtn setBackgroundColor:[UIColor redColor]];
    [deleteFileBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteFileBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.deleteFileBtn = deleteFileBtn;
    deleteFileBtn.alpha = 0;
    [self.view addSubview:deleteFileBtn];
    
    FileTableViewController *fileTVC = [[FileTableViewController alloc]initWithStyle:UITableViewStylePlain fileArray:self.searchFileArray];
    self.fileSearchTableView = fileTVC;
    fileTVC.delegate = self;
    UISearchController *searchCtrl = [[UISearchController alloc]initWithSearchResultsController:fileTVC];
    searchCtrl.searchResultsUpdater = self;
    searchCtrl.searchBar.delegate = self;
    searchCtrl.searchBar.placeholder = @"请输入搜索内容";
    [searchCtrl.searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
    searchCtrl.searchBar.scopeButtonTitles = @[@"所有文件",@"当前目录"];
    searchCtrl.dimsBackgroundDuringPresentation = YES;
    searchCtrl.hidesNavigationBarDuringPresentation = YES;
    searchCtrl.searchBar.frame = topButtonsView.frame;
    searchCtrl.searchBar.alpha = 0;
    [self.view addSubview:searchCtrl.searchBar];
    self.searchCtrl = searchCtrl;
    
    [self initConstraint];
    [self initQLPreviewController];
}

- (void)initConstraint{
    self.fileTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *tableViewLeading = [NSLayoutConstraint constraintWithItem:self.fileTableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *tableViewTailing = [NSLayoutConstraint constraintWithItem:self.fileTableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *tableViewTop = [NSLayoutConstraint constraintWithItem:self.fileTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *tableViewHeight = [NSLayoutConstraint constraintWithItem:self.fileTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
    
    
    if (IOS_VERSION < 8) {
        [self.view addConstraint:tableViewLeading];
        [self.view addConstraint:tableViewTailing];
        [self.view addConstraint:tableViewTop];
        [self.view addConstraint:tableViewHeight];
    }else{
        tableViewLeading.active = YES;
        tableViewTailing.active = YES;
        tableViewTop.active = YES;
        tableViewHeight.active = YES;
    }
    
    self.fileCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *collectionViewLeading = [NSLayoutConstraint constraintWithItem:self.fileCollectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *collectionViewTailing = [NSLayoutConstraint constraintWithItem:self.fileCollectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *collectionViewTop = [NSLayoutConstraint constraintWithItem:self.fileCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *collectionViewHeight = [NSLayoutConstraint constraintWithItem:self.fileCollectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
    
    if (IOS_VERSION < 8) {
        [self.view addConstraint:collectionViewLeading];
        [self.view addConstraint:collectionViewTailing];
        [self.view addConstraint:collectionViewTop];
        [self.view addConstraint:collectionViewHeight];
    }else{
        collectionViewLeading.active = YES;
        collectionViewTailing.active = YES;
        collectionViewTop.active = YES;
        collectionViewHeight.active = YES;
    }
    
    
//    deleteFileBtn.frame = CGRectMake(0, collectionView.bottom-deleBtnH-TabBarHeight-20, tableView.width, deleBtnH);
    
    self.deleteFileBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *deleteBtnCenterX = [NSLayoutConstraint constraintWithItem:self.deleteFileBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *deleteBtnWidth = [NSLayoutConstraint constraintWithItem:self.deleteFileBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *deleteBtnBottom = [NSLayoutConstraint constraintWithItem:self.deleteFileBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.fileCollectionView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *deleteBtnHeight = [NSLayoutConstraint constraintWithItem:self.deleteFileBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:40.0f];
    
    if (IOS_VERSION < 8) {
        [self.view addConstraint:deleteBtnCenterX];
        [self.view addConstraint:deleteBtnWidth];
        [self.view addConstraint:deleteBtnBottom];
        [self.view addConstraint:deleteBtnHeight];
    }else{
        deleteBtnCenterX.active = YES;
        deleteBtnWidth.active = YES;
        deleteBtnBottom.active = YES;
        deleteBtnHeight.active = YES;
    }
}

- (void)initQLPreviewController{
    QLPreviewController *qlPreviewController = [[QLPreviewController alloc]init];
    qlPreviewController.edgesForExtendedLayout = UIRectEdgeNone;
    qlPreviewController.dataSource = self;
    qlPreviewController.delegate = self;
    self.qlPreviewController = qlPreviewController;
}

- (void)initData{
    ActionGroup *group0 = [[ActionGroup alloc]init];
    group0.groupName = @"添加";
    
    ActionCell *cell00 = [ActionCell actionCellWithName:@"创建文件夹"];
    cell00.option = ^{
        CreateFolderViewController *createFolderVC = [[CreateFolderViewController alloc]initWithDirectoryPathString:self.homeDirectoryPathString];
        FileManagerNavigationController *nav = [[FileManagerNavigationController alloc]initWithRootViewController:createFolderVC];
        nav.orietation = UIInterfaceOrientationMaskPortrait;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    };
    ActionCell *cell01 = [ActionCell actionCellWithName:@"添加照片/视频"];
    cell01.option = ^{
        PhotoChooseTableViewController *photoTVC = [[PhotoChooseTableViewController alloc]init];
        FileManagerNavigationController *fmnc = [[FileManagerNavigationController alloc]initWithRootViewController:photoTVC];
        [self presentViewController:fmnc animated:YES completion:nil];
    };
    ActionCell *cell02 = [ActionCell actionCellWithName:@"新建文本文档"];
    cell02.option = ^{
        CreateFileViewController *cfvc = [[CreateFileViewController alloc]initWithDirectoryPathString:self.homeDirectoryPathString];
        FileManagerNavigationController *nav = [[FileManagerNavigationController alloc]initWithRootViewController:cfvc];
        [self presentViewController:nav animated:YES completion:nil];
    };
    group0.actionCellArr = @[cell00, cell01, cell02];
    self.actionGroupAdd = group0;
    
    
    ActionGroup *group1 = [[ActionGroup alloc]init];
    group1.groupName = @"排序";
    
    ActionCell *cell11 = [ActionCell actionCellWithName:@"日期"];
    cell11.option = ^{
        SortType sortType = SortByTime;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:sortType] forKey:SORTTYPE];
        [self sortFileWithSortType:sortType];
    };
    ActionCell *cell12 = [ActionCell actionCellWithName:@"大小"];
    cell12.option = ^{
        SortType sortType = SortBySize;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:sortType] forKey:SORTTYPE];
        [self sortFileWithSortType:sortType];
    };
    ActionCell *cell13 = [ActionCell actionCellWithName:@"默认"];
    cell13.option = ^{
        SortType sortType = SortDefault;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:sortType] forKey:SORTTYPE];
        [self sortFileWithSortType:sortType];
    };
    group1.actionCellArr = @[cell11, cell12, cell13];
    self.actionGroupSort = group1;
    
    DirectoryWatcher *docWatcher = [DirectoryWatcher watchFolderWithPath:self.homeDirectoryPathString delegate:self];
    self.docWatcher = docWatcher;
    
    self.isClickFromSearchVC = NO;
    
    [self directoryDidChange:docWatcher];
}

- (void)loadDocumentData{
    NSString *documentPath = self.homeDirectoryPathString;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileNameArr = [fileManager contentsOfDirectoryAtPath:documentPath error:&error];
    YSJLog(@"%@",documentPath);
    YSJLog(@"%@",fileNameArr);
    [self.fileArray removeAllObjects];
    [self.defaultSortFileArray removeAllObjects];
    
    for (NSString * fileName in fileNameArr) {
        NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
        YSJLog(@"%@",fileName);
        YSJFile *ysjFile = [self checkFileInPath:filePath fileName:fileName];
        [self.fileArray addObject:ysjFile];
        [self.defaultSortFileArray addObject:ysjFile];
    }
    
    SortType sortType;
    switch ([[[NSUserDefaults standardUserDefaults] objectForKey:SORTTYPE] integerValue]) {
        case 1://SortByTime
            sortType = SortByTime;
            break;
        case 2://SortBySize
            sortType = SortBySize;
            break;
        case 3://SortDefault
            sortType = SortDefault;
            break;
        case 4://SortCancel
            sortType = SortCancel;
            break;
        default:
            break;
    }
    [self sortFileWithSortType:sortType];
    
    [self.fileTableView reloadData];
    [self.fileCollectionView reloadData];
    [self initQLPreviewController];
}

- (YSJFile *)checkFileInPath:(NSString *)filePath fileName:(NSString *)fileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    NSError *error = nil;
    NSString *sizeStr;
    NSString *fileType;
    UIImage *typeImg = nil;
    NSNumber *isFolder = [NSNumber numberWithBool:NO];
    NSNumber *isFavourite = [NSNumber numberWithBool:NO];
    //日期改为字符串显示
    NSDictionary *attributeDic = [fileManager attributesOfItemAtPath:filePath error:&error];
    NSDate *updateTimeDate = [attributeDic objectForKey:NSFileModificationDate];
    NSDate *createTimeDate = [attributeDic objectForKey:NSFileCreationDate];
    NSNumber *fileSizeNumber = [attributeDic objectForKey:NSFileSize];
    
    if (isDir) {
        //is folder
        NSArray *fileNameList = [fileManager contentsOfDirectoryAtPath:filePath error:NULL];
        //计算文件夹内文件数量
        sizeStr = [NSString stringWithFormat:@"%lu file",(unsigned long)fileNameList.count];
        //设置类型
        fileType = @"文件夹";
        // 文件类型图片设置
        typeImg = [UIImage imageNamed:@"folder-share-icon"];
        //isFolder设置为yes
        isFolder = [NSNumber numberWithBool:YES];
    }else{
        //is file
        //设置类型
        fileType = [NSString stringWithFormat:@"%@文件",[self checkFileType:fileName]];
        // 文件类型图片获取
        [self setDocumentInteractionControllerWithURL:[NSURL fileURLWithPath:filePath]];
        if (self.documentInteractionController.icons.count > 0) {
            typeImg = self.documentInteractionController.icons[0];
        }
        //计算文件大小之和
        NSInteger fileSize = [[attributeDic objectForKey:NSFileSize] integerValue];
        sizeStr = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
        NSString *path = [[YSJPlist pathStringInDocumentationDirectory] stringByAppendingPathComponent:FAVOURITEPLIST];
        isFavourite = [NSNumber numberWithBool:[self checkFavouriteState:path fileSizeNum:fileSizeNumber createDate:createTimeDate filePath:filePath]];
    }
    
    NSDictionary *param = @{@"fileName":fileName,
                            @"fileModificationDate":updateTimeDate,
                            @"fileCreationDate":createTimeDate,
                            @"fileSizeByteStr":sizeStr,
                            @"fileSize":fileSizeNumber,
                            @"fileType":fileType,
                            @"filePath":filePath,
                            @"isInCollect":isFavourite,
                            @"isFolder":isFolder};
    YSJFile *ysjFile = [YSJFile fileWithAttributeDic:param fileImage:typeImg];
    return ysjFile;
}

- (BOOL)checkFavouriteState:(NSString *)path fileSizeNum:(NSNumber *)fileSizeNum createDate:(NSDate *)createDate filePath:(NSString *)filePath{
    
    NSMutableArray *favArr = [NSMutableArray arrayWithContentsOfFile:path];
    for (NSDictionary *dic in favArr) {
//        if ([dic[FILECREATETIME] isEqualToDate:createDate] &&
//            [dic[FILESIZENUMBER] isEqualToNumber:fileSizeNum] &&
//            [dic[FILEFOLDERPATH] isEqualToString:[filePath stringByDeletingLastPathComponent]]) {
//            return YES;
//        }
        if ([dic[FILECREATETIME] isEqualToDate:createDate] &&
            [dic[FILESIZENUMBER] isEqualToNumber:fileSizeNum]) {
            return YES;
        }
    }
    return NO;
}

- (void)sortFileWithSortType:(SortType)sortType{
    if (sortType == SortCancel) {
        return;
    }else if (sortType == SortDefault) {
        self.fileArray = [NSMutableArray arrayWithArray:self.defaultSortFileArray];
    }else if (sortType == SortBySize) {
        for (int i = 0; i < self.fileArray.count; i++) {
            for (int j = i+1; j < self.fileArray.count; j++) {
                YSJFile *fileA = self.fileArray[i];
                YSJFile *fileB = self.fileArray[j];
                if (fileA.fileSize < fileB.fileSize) {
                    [self.fileArray exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
        }
    }else if (sortType == SortByTime){
        for (int i = 0; i < self.fileArray.count; i++) {
            for (int j = i+1; j < self.fileArray.count; j++) {
                YSJFile *fileA = self.fileArray[i];
                YSJFile *fileB = self.fileArray[j];
                if ([fileA.fileModificationDate compareTimeToAnotherDate:fileB.fileModificationDate] < 0) {
                    [self.fileArray exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
        }
    }
    
    [self.fileTableView reloadData];
    [self.fileCollectionView reloadData];
    [self initQLPreviewController];
}

- (NSString *)checkFileType:(NSString *)fileName{
    if (IOS_VERSION < 8.0) {
        if ([fileName rangeOfString:@"."].location == NSNotFound) {
            return @"未知类型";
        }
    }else{
        if (![fileName containsString:@"."]) {
            return @"未知类型";
        }
    }
    NSRange markRange = [fileName rangeOfString:@"." options:NSBackwardsSearch];
    if (fileName.length <= markRange.location+1) {
        return(@"未知类型");
    }
    return [fileName substringFromIndex:markRange.location+1];
}

- (void)setDocumentInteractionControllerWithURL:(NSURL *)url{
    if (self.documentInteractionController) {
        self.documentInteractionController.URL = url;
    }else{
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.documentInteractionController.delegate = self;
    }
}

- (void)reSizeTopButtonViewWithIsVertical:(BOOL)isVertical{
    //screenWidth 会随着转屏而改变
//    self.fileCollectionView.width = ScreenWidth;
//    self.fileTableView.width = ScreenWidth;
    //tableView header
//    self.topButtonsView.frame = CGRectMake(0, 0, ScreenWidth, TOPBUTTONSHEIGHT);
    self.fileTableView.contentInset = UIEdgeInsetsZero;
    self.fileCollectionView.contentInset = UIEdgeInsetsZero;
    
    CGFloat btnWidth = ScreenWidth/self.topButtonsView.subviews.count;
    for (UIButton *btn in self.topButtonsView.subviews) {
        btn.frame = CGRectMake(btn.tag*btnWidth, 0, btnWidth, TOPBUTTONSHEIGHT);
    }
    //collectionView header
//    self.headView.frame = CGRectMake(0, 0, ScreenWidth, TOPBUTTONSHEIGHT);
//    [self.headView topButtonsView].frame = CGRectMake(0, 0, ScreenWidth, TOPBUTTONSHEIGHT);
    for (UIButton *btn in [[self.headView topButtonsView] subviews]) {
        btn.frame = CGRectMake(btn.tag*btnWidth, 0, btnWidth, TOPBUTTONSHEIGHT);
    }
}

- (void)removeFile{
    if (self.deleteFileArray.count == 0) {
        return;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *path = [YSJPlist pathStringInDocumentationDirectory];
    path = [path stringByAppendingPathComponent:FAVOURITEPLIST];
    NSMutableArray *favArr = [NSMutableArray arrayWithContentsOfFile:path];
    
    for (YSJFile *ysjFile in self.deleteFileArray) {
        [fm removeItemAtPath:ysjFile.filePath error:nil];
        for (NSDictionary *dic in favArr) {
            if ([dic[FILECREATETIME] isEqualToDate:ysjFile.fileCreationDate] &&
                [dic[FILESIZENUMBER] isEqualToNumber:ysjFile.fileSize]) {
                [favArr removeObject:dic];
                break;
            }
        }
    }
    [favArr writeToFile:path atomically:YES];
    [self.deleteFileArray removeAllObjects];
    [self setEditing:NO animated:YES];
    [self swipedToHideCellOptionViewExceptIndexPath:nil];
}

- (void)setCollectionViewItemsSelectedMarkHidden:(BOOL)hidden{
    for (int i = 0; i < self.fileArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        FileCollectionViewCell *cell = (FileCollectionViewCell *)[self.fileCollectionView cellForItemAtIndexPath:indexPath];
        [cell setSelectedMarkHidden:hidden];
    }
}

- (void)pushIntoDetailOrFolder:(YSJFile *)file indexPath:(NSIndexPath *)indexPath{
    if (file.isFolder) {
        NSString *folderPath = [self.homeDirectoryPathString stringByAppendingPathComponent:file.fileName];
        FileManagerViewController *childFolderVC = [[FileManagerViewController alloc]initWithDirectoryPathString:folderPath];
        [self.navigationController pushViewController:childFolderVC animated:YES];
    }else{
        self.selectedRow = indexPath.row;
        self.qlPreviewController.currentPreviewItemIndex = indexPath.row;
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:self.qlPreviewController animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
}

- (void)pushIntoSearchDeatilOrFolder:(YSJFile *)file{
    if (file.isFolder) {
        FileManagerViewController *childFolderVC = [[FileManagerViewController alloc]initWithDirectoryPathString:file.filePath];
        [self.navigationController pushViewController:childFolderVC animated:YES];
    }else{
        self.qlPreviewController.currentPreviewItemIndex = self.qlPreviewController.currentPreviewItemIndex + 1;
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:self.qlPreviewController animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
}


- (void)updatePlist:(YSJFile *)ysjFile{
    if (!ysjFile.isInCollect) {
        return;
    }
    NSString *path = [YSJPlist pathStringInDocumentationDirectory];
    path = [path stringByAppendingPathComponent:FAVOURITEPLIST];
    
    NSMutableArray *favArr = [NSMutableArray arrayWithContentsOfFile:path];
    for (NSDictionary *dic in favArr) {
        if ([dic[FILECREATETIME] isEqualToDate:ysjFile.lastModifyDate]
            &&[dic[FILESIZENUMBER] isEqualToNumber:ysjFile.oldFileSize]) {
            //                if ([dic[FILECREATETIME] isEqualToDate:self.ysjFile.fileCreationDate]
            //                    &&[dic[FILESIZENUMBER] isEqualToNumber:self.ysjFile.oldFileSize]
            //                    && [dic[FILEFOLDERPATH] isEqualToString:[self.ysjFile.filePath stringByDeletingLastPathComponent]]) {
            
            NSDictionary *newDic = @{FILESIZENUMBER:ysjFile.fileSize,
                                  FILECREATETIME:ysjFile.fileCreationDate,
                                  FILEFOLDERPATH:[ysjFile.filePath stringByDeletingLastPathComponent]};
            [favArr removeObject:dic];
            [favArr addObject:newDic];
            [favArr writeToFile:path atomically:YES];
            break;
        }
    }
}

#pragma mark - NotificationCenter selecter
- (void)addData:(NSNotification *)notification{
//    [tempArr addObject:@{@"type":@"image",
//                         @"metadata":dic,
//                         @"filename":filename,
//                         @"img":img}];
    
//    [tempArr addObject:@{@"type":@"video",
//                         @"filename":filename,
//                         @"videoData":data}];
    NSMutableArray *imgArr = notification.userInfo[@"data"];
    for (NSDictionary *dic in imgArr) {
        if ([dic[@"type"] isEqualToString:@"image"]) {
            NSData *data = UIImagePNGRepresentation((UIImage *)dic[@"img"]);
            NSString *path = [self.homeDirectoryPathString stringByAppendingPathComponent:dic[@"filename"]];
            [data writeToFile:path atomically:YES];
        }else if ([dic[@"type"] isEqualToString:@"video"]){
            NSData *data = dic[@"videoData"];
            NSString *path = [self.homeDirectoryPathString stringByAppendingPathComponent:dic[@"filename"]];
            [data writeToFile:path atomically:YES];
        }
    }
}

- (void)updateFileArrays:(NSNotification *)notification{
    YSJFile *ysjFile = notification.userInfo[@"YSJFile"];
    [YSJFileSearcher updateYSJFile:ysjFile inFileArray:self.fileArray];
    [YSJFileSearcher updateYSJFile:ysjFile inFileArray:self.allFileArray];
    [self.fileTableView reloadData];
}

- (void)updateModifyTxtYSJFile:(NSNotification *)notification{
    YSJFile *ysjFile = notification.userInfo[@"YSJFile"];
    [YSJFileSearcher updateModifyTxtYSJFile :ysjFile inFileArray:self.fileArray];
    [YSJFileSearcher updateModifyTxtYSJFile:ysjFile inFileArray:self.allFileArray];
    [self updatePlist:ysjFile];
    [self.fileTableView reloadData];
}

- (void)screenDirectionChanged:(NSNotification *)notification{
    UIDevice *device = [UIDevice currentDevice];
    switch (device.orientation) {
        case UIDeviceOrientationPortrait://home botton on the buttom
            [self reSizeTopButtonViewWithIsVertical:YES];
            break;
        case UIDeviceOrientationLandscapeLeft://home button on the right
        case UIDeviceOrientationLandscapeRight://home button on the left
            [self reSizeTopButtonViewWithIsVertical:NO];
            break;
        default:
            break;
    }
}

#pragma mark - FileCollectionHeadViewDelegate
- (void)collectionHeadViewBtnClicked:(NSInteger)btnTag{
    if(self.editing){
        return;
    }
    [self btnClickedWithTag:btnTag];
}

#pragma mark - DirectoryWatcherDelegate
- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher{
    [self loadDocumentData];
    [self refreshAllFileData];
}

#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}

#pragma mark - QLPreviewController
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    if (self.isClickFromSearchVC) {
//        [self checkFilePathEncouding:self.fileArray[index]];
        return [NSURL fileURLWithPath:self.searchedFile.filePath];
    }
    if (self.fileArray.count > 0) {
        YSJFile *file;
        if (IOS_VERSION > 8.0) {
            file = self.fileArray[index];
        }else{
            file = self.fileArray[self.selectedRow];
        }
//        [self checkFilePathEncouding:file];
        return [NSURL fileURLWithPath:file.filePath];
    }
    return nil;
}

- (void)checkFilePathEncouding:(YSJFile *)file{
    //处理txt格式内容显示有乱码的情况
    NSData *fileData = [NSData dataWithContentsOfFile:file.filePath];
    //判断是UNICODE编码
    NSString *isUNICODE = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    //还是ANSI编码（-2147483623，-2147482591，-2147482062，-2147481296）encoding 任选一个就可以了
    NSString *isANSI = [[NSString alloc] initWithData:fileData encoding:-2147483623];
    NSString *testStr = [[NSString alloc]initWithData:fileData encoding:NSUTF16StringEncoding];
    if (isUNICODE) {
        NSString *retStr = [[NSString alloc]initWithCString:[isUNICODE UTF8String] encoding:NSUTF8StringEncoding];
        NSData *data = [retStr dataUsingEncoding:NSUTF16StringEncoding];
        [data writeToFile:file.filePath atomically:YES];
    }else if(testStr){
        NSData *data = [testStr dataUsingEncoding:NSUTF16StringEncoding];
//        NSData *data = [isANSI dataUsingEncoding:NSUTF16StringEncoding];
        [data writeToFile:file.filePath atomically:YES];
    }
}

#pragma mark - collectionVieDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.fileArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FileCollectionViewCell *cell = [FileCollectionViewCell cellWithCollectionView:collectionView indexPath:indexPath];
    cell.ysjFile = self.fileArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    YSJFile *ysjFile = [self.fileArray objectAtIndex:indexPath.row];
    if (self.editing) {
        FileCollectionViewCell *cell = (FileCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell setSelected:YES];
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        
        [self.fileTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        [self.deleteFileArray addObject:ysjFile];
        return;
    }
    [self pushIntoDetailOrFolder:ysjFile indexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    FileCollectionViewCell *cell = (FileCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setSelected:NO];
    [self.fileTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YSJFile *ysjFile = [self.fileArray objectAtIndex:indexPath.row];
    [self.deleteFileArray removeObject:ysjFile];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        FileCollectionHeadView *headView = [FileCollectionHeadView headViewWithCollectionView:collectionView indexPath:indexPath];
        headView.delegate = self;
        self.headView = headView;
        return headView;
    }else{
        return nil;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(70, 70);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.topButtonsView.width, self.topButtonsView.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 20;
}

//横向item(每个的）间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 40;
}

#pragma mark - FileTableViewControllerDelegate
- (void)searchFileClicked:(YSJFile *)ysjFile{
    self.searchedFile = ysjFile;
    self.isClickFromSearchVC = YES;
    [self pushIntoSearchDeatilOrFolder:ysjFile];
    self.isClickFromSearchVC = NO;
    
    [self searchBarCancelButtonClicked:self.searchCtrl.searchBar];
    self.searchCtrl.active = NO;
}



#pragma mark - UISearchResultsUpdating
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self updateSearchResultsForSearchController:self.searchCtrl];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchStr = self.searchCtrl.searchBar.text;
    [self.searchFileArray removeAllObjects];
    if (self.searchCtrl.searchBar.selectedScopeButtonIndex == 0) {
        //所有文件
        for (YSJFile *file in self.allFileArray) {
            if (IOS_VERSION < 8.0) {
                if ([file.fileName rangeOfString:@"searchStr"].location != NSNotFound) {
                    [self.searchFileArray addObject:file];
                }
            }else{
                if ([file.fileName containsString:searchStr]) {
                    [self.searchFileArray addObject:file];
                }
            }
        }
    }else if(self.searchCtrl.searchBar.selectedScopeButtonIndex == 1){
        //当前目录
        for (YSJFile *file in self.fileArray) {
            if (IOS_VERSION < 8.0) {
                if ([file.fileName rangeOfString:searchStr].location != NSNotFound) {
                    [self.searchFileArray addObject:file];
                }
            }else{
                if ([file.fileName containsString:searchStr]) {
                    [self.searchFileArray addObject:file];
                }
            }
        }
    }
    [self.fileSearchTableView setFileArray:self.searchFileArray];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self searchBarTextDidEndEditing:searchBar];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    searchBar.alpha = 0;
}

#pragma  mark - FileTableViewCellDelegate
- (void)favourateStateChanged:(FileTableViewCell *)cell{
    if (cell.ysjFile.isFolder) {
        [MBProgressHUD showMBPMsg:@"文件夹无法收藏" onView:self.view delay:2.0f];
        [cell swipedToHideOptionView];
        return;
    }
    cell.ysjFile.isInCollect = !cell.ysjFile.isInCollect;
    [YSJFileSearcher updateYSJFile:cell.ysjFile inFileArray:self.allFileArray];
    [cell updateFavouriteImageState];
    [cell updatePlist];
    [cell swipedToHideOptionView];
}

- (void)deletaBtnClicked:(FileTableViewCell *)cell{
    [self.deleteFileArray removeAllObjects];
    [self.deleteFileArray addObject:cell.ysjFile];
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
    if ([cell.ysjFile.fileType isEqualToString:@"txt文件"]) {
        CreateFileViewController *cfVC = [[CreateFileViewController alloc]initWithModifyFile:cell.ysjFile];
        FileManagerNavigationController *fmNav = [[FileManagerNavigationController alloc]initWithRootViewController:cfVC];
        [self presentViewController:fmNav animated:YES completion:^{
            [self swipedToHideCellOptionViewExceptIndexPath:nil];
        }];
        return;
    }
    CreateFolderViewController *cfVC = [[CreateFolderViewController alloc]initWithYSJFile:cell.ysjFile];
    FileManagerNavigationController *fmNav = [[FileManagerNavigationController alloc]initWithRootViewController:cfVC];
    [self presentViewController:fmNav animated:YES completion:^{
        [self swipedToHideCellOptionViewExceptIndexPath:nil];
    }];
}

- (void)fileTableViewCellSwipedFromLeft:(UISwipeGestureRecognizer *)recognizer{
    if (self.editing) {
        return;
    }
    CGPoint point = [recognizer locationInView:self.fileTableView];
    NSIndexPath *indexPath = [self.fileTableView indexPathForRowAtPoint:point];
    FileTableViewCell *cell = [self.fileTableView cellForRowAtIndexPath:indexPath];
    [cell swipedToHideOptionView];
}

- (void)fileTableViewCellSwipedFromRight:(UISwipeGestureRecognizer *)recognizer{
    if (self.editing) {
        return;
    }
    CGPoint point = [recognizer locationInView:self.fileTableView];
    NSIndexPath *indexPath = [self.fileTableView indexPathForRowAtPoint:point];
    FileTableViewCell *cell = [self.fileTableView cellForRowAtIndexPath:indexPath];
    [cell swipedToShowOptionView];
    
    [self swipedToHideCellOptionViewExceptIndexPath:indexPath];
}

- (void)swipedToHideCellOptionViewExceptIndexPath:(NSIndexPath *)indexPath{
    if (indexPath != nil) {
        for (FileTableViewCell *visibleCell in [self.fileTableView visibleCells]) {
            NSIndexPath *visibleIndexPath = [self.fileTableView indexPathForCell:visibleCell];
            if (![visibleIndexPath isEqual:indexPath]) {
                [visibleCell swipedToHideOptionView];
            }
        }
    }else{
        for (FileTableViewCell *visibleCell in [self.fileTableView visibleCells]) {
            [visibleCell swipedToHideOptionView];
        }
    }
}

#pragma mark - tableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    [self.fileArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.fileArray.count == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return self.fileArray.count;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FileTableViewCell *cell = [FileTableViewCell cellWithTableView:tableView YSJFile:self.fileArray[indexPath.row] delegate:self];
    cell.showsReorderControl = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell backViewCenter].x < 0) {//若cell为拉开状态，return
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    YSJFile *file = [self.fileArray objectAtIndex:indexPath.row];
    if (self.fileTableView.editing) {
        [self.deleteFileArray addObject:file];
        [self.fileCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        return;
    }
    [self swipedToHideCellOptionViewExceptIndexPath:nil];
    [self pushIntoDetailOrFolder:file indexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.fileCollectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.deleteFileArray removeObject:[self.fileArray objectAtIndex:indexPath.row]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//    return UITableViewCellEditingStyleDelete;
}

//设置可以滑动删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//editingStyleForRowAtIndexPath 返回不为复合类型时被启用
//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        NSFileManager *fileManager = [NSFileManager defaultManager];
////        [fileManager removeItemAtPath:<#(nonnull NSString *)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>]
//    }];
//    
//    UITableViewRowAction *renameAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"重命名" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        
//    }];
//    return @[deleteAction,renameAction];
//}


#pragma mark - btnClicked
//删除按钮
- (void)deleteBtnClicked:(UIButton *)btn{
    if (self.deleteFileArray.count == 0) {
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定删除" otherButtonTitles: nil];
    actionSheet.tag = 2;
    [actionSheet showInView:self.view];
}

//顶部btnClicked
- (void)btnClicked:(UIButton *)btn{
    if(self.editing){
        return;
    }
    [self btnClickedWithTag:btn.tag];
}
- (void)btnClickedWithTag:(NSInteger)btnTag{
    if (btnTag == 3) {
        // search btn
        self.searchCtrl.searchBar.alpha = 1;
        [self.searchCtrl.searchBar becomeFirstResponder];
        [self refreshAllFileData];
        [self swipedToHideCellOptionViewExceptIndexPath:nil];
    }else if (btnTag == 2){
        // tableView/collectionView btn
        self.fileCollectionView.hidden = !self.fileCollectionView.hidden;
        [self swipedToHideCellOptionViewExceptIndexPath:nil];
    }else if (btnTag == 1){
        NSArray *actionCellArr = self.actionGroupSort.actionCellArr;
        NSMutableArray *nameArr = [NSMutableArray array];
        for (int i = 0; i < actionCellArr.count; i++) {
            ActionCell *cell = actionCellArr[i];
            [nameArr addObject:cell.name];
        }
#warning 此处只能通过事先知道的有3个元素来直接填充  设计合理性有待商榷
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nameArr[0], nameArr[1], nameArr[2], nil];
        sheet.tag = btnTag;
        [sheet showInView:self.view];
    }else{
        NSArray *actionCellArr = self.actionGroupAdd.actionCellArr;
        
        NSMutableArray *nameArr = [NSMutableArray array];
        for (int i = 0; i < actionCellArr.count; i++) {
            ActionCell *cell = actionCellArr[i];
            [nameArr addObject:cell.name];
        }
#warning 此处只能通过事先知道的有3个元素来直接填充  设计合理性有待商榷
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nameArr[0], nameArr[1], nameArr[2], nil];
        sheet.tag = btnTag;
        [sheet showInView:self.view];
    }
}

- (void)refreshAllFileData{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:path];
    NSString *secondPath;
    [self.allFileArray removeAllObjects];
    while ((secondPath = [enumerator nextObject]) != nil) {
        NSString *filePath = [path stringByAppendingPathComponent:secondPath];
        YSJFile *file = [self checkFileInPath:filePath fileName:[secondPath lastPathComponent]];
        [self.allFileArray addObject:file];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 0) {
        // add btn actionSheet
        if (buttonIndex >= self.actionGroupAdd.actionCellArr.count) {
            return;
        }
        ActionCell *actionCell = self.actionGroupAdd.actionCellArr[buttonIndex];
        actionCell.option();
    }else if (actionSheet.tag == 1){
        //sort btn actionSheet
        if (buttonIndex >= self.actionGroupSort.actionCellArr.count) {
            return;
        }
        ActionCell *actionCell = self.actionGroupSort.actionCellArr[buttonIndex];
        actionCell.option();
    }else if (actionSheet.tag == 2){
        //deleteFile action
        if(buttonIndex == 0){
           [self removeFile];
        }else{
            [self setEditing:NO animated:YES];
        }
    }
}

#pragma mark - UIScrollDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    //velocity 速度参数
    //targetContentOffset 停止后最终会抵达的点
//    YSJLog(@"%lf",targetContentOffset->y);
//    targetContentOffset->y = targetContentOffset->y < TOPBUTTONSHEIGHT/2?0:TOPBUTTONSHEIGHT;
//    YSJLog(@"%lf",targetContentOffset->y);
    
//    [scrollView setContentOffset:*targetContentOffset animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat y;
//    YSJLog(@"%lf",scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < TOPBUTTONSHEIGHT/2) {
        y = 0;
        [scrollView setContentOffset:CGPointMake(0, y) animated:YES];
    }else if (scrollView.contentOffset.y > TOPBUTTONSHEIGHT/2 && scrollView.contentOffset.y < TOPBUTTONSHEIGHT){
        y = TOPBUTTONSHEIGHT;
        [scrollView setContentOffset:CGPointMake(0, y) animated:YES];
    }
}

#pragma mark - editBtnClicked
- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    if (editing) {
        self.editButtonItem.title = @"完成";
        //swipedToHideCellOptionViewExceptIndexPath 对contentview的center进行了居中操作，必须放在self.fileTableView setEditing之前，以免覆盖self.fileTableView setEditing的center位移操作
        [self swipedToHideCellOptionViewExceptIndexPath:nil];
        [self.fileTableView setEditing:YES animated:YES];
        [self setCollectionViewItemsSelectedMarkHidden:NO];
        [UIView animateWithDuration:0.2 animations:^{
            self.deleteFileBtn.alpha = 1;
        } completion:nil];
    }else {
        self.editButtonItem.title = @"编辑";
        [self.fileTableView setEditing:NO animated:YES];
        [self setCollectionViewItemsSelectedMarkHidden:YES];
        [self.deleteFileArray removeAllObjects];
        [UIView animateWithDuration:0.2 animations:^{
            self.deleteFileBtn.alpha = 0;
        } completion:nil];
    }
}

#pragma mark - 初始化方法

- (NSMutableArray *)fileArray{
    if (!_fileArray) {
        _fileArray = [NSMutableArray array];
    }
    return _fileArray;
}

- (NSMutableArray *)defaultSortFileArray{
    if (!_defaultSortFileArray) {
        _defaultSortFileArray = [NSMutableArray array];
    }
    return _defaultSortFileArray;
}

- (NSMutableArray *)deleteFileArray{
    if (!_deleteFileArray) {
        _deleteFileArray = [NSMutableArray array];
    }
    return _deleteFileArray;
}

- (NSMutableArray *)searchFileArray{
    if (!_searchFileArray) {
        _searchFileArray = [NSMutableArray array];
    }
    return _searchFileArray;
}

- (NSMutableArray *)allFileArray{
    if (!_allFileArray) {
        _allFileArray = [NSMutableArray array];
    }
    return _allFileArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
