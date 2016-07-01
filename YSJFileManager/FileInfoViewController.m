//
//  FileInfoViewController.m
//  YSJFileManager
//
//  Created by ysj on 16/3/16.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "FileInfoViewController.h"
#import "TableViewCellGroup.h"
#import "TableViewCellViewItem.h"
#import "TableViewCellCenterViewItem.h"
#import "YSJFile.h"
#import "NSDate+YSJ.h"
#import "YSJButton.h"
#import "CreateFolderViewController.h"
#import "FileManagerNavigationController.h"
#import "YSJPlist.h"
#import "MBProgressHUD+YSJ.h"

@interface FileInfoViewController ()
@property (nonatomic, strong) YSJFile *ysjFile;
@property (nonatomic, strong) TableViewCellGroup *group1;
@end

@implementation FileInfoViewController

- (instancetype)initWithYSJFile:(YSJFile *)ysjFile{
    self = [super init];
    self.ysjFile = ysjFile;
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.group1) {
        [self updateGroup1Data];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
}

- (void)initView{
    self.navigationItem.title = @"设置";
    UIImageView *backImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tableview-bg"]];
    backImgView.frame = self.tableView.frame;
    self.tableView.backgroundView = backImgView;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClicked)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)rightBarButtonItemClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initData{
    TableViewCellGroup *group1 = [[TableViewCellGroup alloc]init];
    
    TableViewCellViewItem *item11 = [TableViewCellViewItem itemWithTitle:@"文件名称"];
    item11.rightView = [self rightLabel:self.ysjFile.fileName];
    
    TableViewCellViewItem *item12 = [TableViewCellViewItem itemWithTitle:@"文件类型"];
    item12.rightView = [self rightLabel:self.ysjFile.fileType];
    
    TableViewCellViewItem *item13 = [TableViewCellViewItem itemWithTitle:@"文件大小"];
    item13.rightView = [self rightLabel:self.ysjFile.fileSizeByteStr];
    
    TableViewCellViewItem *item14 = [TableViewCellViewItem itemWithTitle:@"创建时间"];
    NSString *createTimeStr = [[self.ysjFile.fileCreationDate toLocalDate] dateToStringWithDefaultFormatterStr];
    item14.rightView = [self rightLabel:createTimeStr];
    
    TableViewCellViewItem *item15 = [TableViewCellViewItem itemWithTitle:@"修改时间"];
    NSString *modifyTimeStr = [[self.ysjFile.fileModificationDate toLocalDate] dateToStringWithDefaultFormatterStr];
    item15.rightView = [self rightLabel:modifyTimeStr];
    [self.dataArr addObject:group1];
    
    group1.itemArr = @[item11,item12,item13,item14,item15];
    self.group1 = group1;
    
    TableViewCellGroup *group2 = [[TableViewCellGroup alloc]init];
    
    TableViewCellCenterViewItem *item21 = [TableViewCellCenterViewItem itemWithTitle:@""];
    NSString *collectStr = self.ysjFile.isInCollect?@"移出收藏":@"添加至收藏";
    UILabel *centerLabel = [self centerLabel:collectStr];
    item21.centerView = centerLabel;
    item21.selectedOption = ^{
        if (self.ysjFile.isFolder) {
            [MBProgressHUD showMBPMsg:@"文件夹无法收藏" onView:self.view delay:2.0f];
            return;
        }
        self.ysjFile.isInCollect = !self.ysjFile.isInCollect;
        centerLabel.text = self.ysjFile.isInCollect?@"移出收藏":@"添加至收藏";
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFileArrays" object:self userInfo:@{@"YSJFile":self.ysjFile}];
        [self updatePlist];
    };
    
    TableViewCellCenterViewItem *item22 = [TableViewCellCenterViewItem itemWithTitle:@""];
    item22.centerView = [self centerLabel:@"重命名"];
    item22.selectedOption = ^{
        CreateFolderViewController *cfVC = [[CreateFolderViewController alloc]initWithYSJFile:self.ysjFile];
        FileManagerNavigationController *fmNav = [[FileManagerNavigationController alloc]initWithRootViewController:cfVC];
        [self presentViewController:fmNav animated:YES completion:nil];
    };
    
    group2.itemArr = @[item21,item22];
    [self.dataArr addObject:group2];
}

- (void)updatePlist{
    NSString *path = [YSJPlist pathStringInDocumentationDirectory];
    path = [path stringByAppendingPathComponent:FAVOURITEPLIST];
    
    if (self.ysjFile.isInCollect) {
        NSDictionary *dic = @{FILESIZENUMBER:self.ysjFile.fileSize,
                              FILECREATETIME:self.ysjFile.fileCreationDate};
        [YSJPlist addDictionary:dic inFilePath:path];
    }else{
        NSMutableArray *favArr = [NSMutableArray arrayWithContentsOfFile:path];
        for (NSDictionary *dic in favArr) {
            if ([dic[FILECREATETIME] isEqualToDate:self.ysjFile.fileCreationDate] &&
                [dic[FILESIZENUMBER] isEqualToNumber:self.ysjFile.fileSize]) {
                [favArr removeObject:dic];
                [favArr writeToFile:path atomically:YES];
                break;
            }
        }
    }
}

- (void)updateGroup1Data{
    TableViewCellViewItem *item1 = self.group1.itemArr[0];
    UILabel *label1 = (UILabel *)item1.rightView;
    label1.text = self.ysjFile.fileName;
    
    TableViewCellViewItem *item2 = self.group1.itemArr[1];
    UILabel *label2 = (UILabel *)item2.rightView;
    label2.text = self.ysjFile.fileType;
    
    TableViewCellViewItem *item3 = self.group1.itemArr[2];
    UILabel *label3 = (UILabel *)item3.rightView;
    label3.text = self.ysjFile.fileSizeByteStr;
    
    TableViewCellViewItem *item4 = self.group1.itemArr[3];
    UILabel *label4 = (UILabel *)item4.rightView;
    label4.text = [[self.ysjFile.fileCreationDate toLocalDate] dateToStringWithDefaultFormatterStr];
    
    TableViewCellViewItem *item5 = self.group1.itemArr[4];
    UILabel *label5 = (UILabel *)item5.rightView;
    label5.text = [[self.ysjFile.fileModificationDate toLocalDate] dateToStringWithDefaultFormatterStr];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
