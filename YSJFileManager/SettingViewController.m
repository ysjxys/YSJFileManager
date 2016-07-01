//
//  SettingViewController.m
//  YSJFileManager
//
//  Created by ysj on 16/1/26.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "SettingViewController.h"
#import "TableViewCellGroup.h"
#import "TableViewCellBasicItem.h"
#import "TableViewCellArrowItem.h"
#import "TableViewCellSwitchItem.h"
#import "TableViewCellViewItem.h"
#import "AboutUSViewController.h"
#import "SJTableViewCell.h"
#import "LockViewViewController.h"
#import "TableViewCellCenterViewItem.h"

@interface SettingViewController ()<SJTableViewCellDelegate>
@property (nonatomic, strong) UILabel *rightFreeSizeLabel;
@property (nonatomic, strong) SJTableViewCell *switchedCell;
@property (nonatomic, assign) BOOL switchIsOn;
@end

@implementation SettingViewController

- (void)viewWillAppear:(BOOL)animated{
    if (self.rightFreeSizeLabel) {
        [self updateFreeSizeNumber];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    [self initNotification];
}

- (void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCreatePWD:) name:@"cancelCreatePWD" object:nil];
}

- (void)initView{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = @"设置";
    UIImageView *backImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tableview-bg"]];
    backImgView.frame = self.tableView.frame;
    self.tableView.backgroundView = backImgView;
}

- (void)initData{
    TableViewCellGroup *group1 = [[TableViewCellGroup alloc]init];
//    group1.header = @"安全";
    
    TableViewCellBasicItem *item11 = [TableViewCellSwitchItem itemWithTitle:@"开启锁屏"];
    item11.userDefaultKey = LockScreen;
    TableViewCellBasicItem *item12 = [TableViewCellArrowItem itemWithTitle:@"修改密码" icon:nil destVcClass:[AboutUSViewController class]];
    item12.selectedOption = ^{
         [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:UserPWD]) {
            [self presentViewController:[[LockViewViewController alloc] initWithMsg:@"请输入原密码" startMode:startModifyPWD] animated:YES completion:nil];
        }else{
            [self presentViewController:[[LockViewViewController alloc] initWithMsg:@"请输入手势创建密码" startMode:startCreatePWD] animated:YES completion:nil];
        }
    };
    TableViewCellBasicItem *item13 = [TableViewCellSwitchItem itemWithTitle:@"列表显示"];
    item13.userDefaultKey = ShowType;
    
    
    group1.itemArr = @[item11, item12, item13];
    
    [self.dataArr addObject:group1];
    
    
    TableViewCellGroup *group2 = [[TableViewCellGroup alloc]init];
//    group2.header = @"系统";
    
    TableViewCellViewItem *item21 = [TableViewCellViewItem itemWithTitle:@"剩余容量"];
    self.rightFreeSizeLabel = [self rightLabel:nil];
    item21.rightView = self.rightFreeSizeLabel;
    
//    TableViewCellViewItem *item22 = [TableViewCellViewItem itemWithTitle:@"当前版本"];
//    NSDictionary *info= [[NSBundle mainBundle] infoDictionary];
//    info[@"CFBundleShortVersionString"]; //Version
//    info[@"CFBundleVersion"]; // Build
//    item22.rightView = [self rightLabel:info[@"CFBundleShortVersionString"]];
    
    group2.itemArr = @[item21];
    
    [self.dataArr addObject:group2];
    
    TableViewCellGroup *group3 = [[TableViewCellGroup alloc] init];
//    group3.header = @"介绍";
    
    TableViewCellBasicItem *item31 = [TableViewCellArrowItem itemWithTitle:@"关于我们" icon:nil destVcClass:[AboutUSViewController class]];
    
    group3.itemArr = @[item31];
    [self.dataArr addObject:group3];
}

- (void)cancelCreatePWD:(NSNotification *)notification{
    if (self.switchedCell) {
        [self.switchedCell setSwitchState:!self.switchIsOn];
    }
    self.switchedCell = nil;
}

- (void)updateFreeSizeNumber{
    NSDictionary *dicc = [[NSFileManager defaultManager] fileSystemAttributesAtPath:NSHomeDirectory()];
    long long freeSizeFloat = [[dicc objectForKey:NSFileSystemFreeSize] longLongValue];
    long freeGB = freeSizeFloat/1024.0f/1024.0f/1024.0f;
    float freeMB = [[NSString stringWithFormat:@"%lld", freeSizeFloat%(1024*1024*1024)] floatValue]/1024.0f/1024.0f;
    if (freeGB < 1) {
        self.rightFreeSizeLabel.text = [NSString stringWithFormat:@"%.1fMB",freeMB];
    }else{
        self.rightFreeSizeLabel.text = [NSString stringWithFormat:@"%.0ldGB %.1fMB",freeGB, freeMB];
    }
}

- (void)startUserDefault:(SJTableViewCell *)cell switchIsOn:(BOOL)isOn{
    if ([cell.item.userDefaultKey isEqualToString:LockScreen]) {
        LockViewViewController *lockVC = [[LockViewViewController alloc]initWithMsg:@"请输入手势创建密码" startMode:startCreatePWD];
        self.switchedCell = cell;
        self.switchIsOn = isOn;
        [self presentViewController:lockVC animated:YES completion:nil];
    }else if ([cell.item.userDefaultKey isEqualToString:ShowType]){
        [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:cell.item.userDefaultKey];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
