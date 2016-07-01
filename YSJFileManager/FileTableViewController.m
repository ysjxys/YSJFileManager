//
//  FileTableViewController.m
//  YSJFileManager
//
//  Created by ysj on 16/2/29.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "FileTableViewController.h"
#import "YSJFile.h"
#import "FileTableViewCell.h"

@interface FileTableViewController ()
@property (nonatomic, strong) NSMutableArray *fileArray;
@end

@implementation FileTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style fileArray:(NSMutableArray *)fileArray{
    self = [super initWithStyle:style];
    self.fileArray = fileArray;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setFileArray:(NSMutableArray *)fileArray{
    _fileArray = fileArray;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YSJFile *ysjFile = self.fileArray[indexPath.row];
    FileTableViewCell *cell = [FileTableViewCell cellWithTableView:tableView YSJFile:ysjFile delegate:self];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YSJFile *ysjFile = self.fileArray[indexPath.row];
    [self.delegate searchFileClicked:ysjFile];
}

@end
