//
//  BasicTableTableViewController.m
//  YSJFileManager
//
//  Created by ysj on 16/1/27.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "BasicTableTableViewController.h"
#import "TableViewCellGroup.h"
#import "SJTableViewCell.h"
#import "TableViewCellBasicItem.h"
#import "TableViewCellArrowItem.h"

@interface BasicTableTableViewController ()<SJTableViewCellDelegate>

@end

@implementation BasicTableTableViewController

- (instancetype)init{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (instancetype)initWithStyle:(UITableViewStyle)style{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TableViewCellGroup *group = self.dataArr[section];
    return group.itemArr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    TableViewCellGroup *group = self.dataArr[section];
    return group.header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    TableViewCellGroup *group = self.dataArr[section];
    return group.footer;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJTableViewCell *cell = [SJTableViewCell cellWithTableView:tableView];
    TableViewCellGroup *group = self.dataArr[indexPath.section];
    cell.item = group.itemArr[indexPath.row];
    cell.deleagte = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCellGroup *group = self.dataArr[indexPath.section];
    TableViewCellBasicItem *item = group.itemArr[indexPath.row];
    if (item.selectedOption) {
        item.selectedOption();
    }else if ([item isKindOfClass:[TableViewCellArrowItem class]]){
        TableViewCellArrowItem *arrowItem = (TableViewCellArrowItem *)item;
        if (arrowItem.destVcClass) {
            UIViewController *vc = [[arrowItem.destVcClass alloc]init];
            vc.title = item.title;
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)startUserDefault:(SJTableViewCell *)cell switchIsOn:(BOOL)isOn{
    YSJLog(@"代理方法 \"startUserDefault:switchIsOn\" 在 BasicTableViewController 类内成功执行! 请覆写子类同名方法");
}

- (UILabel *)rightLabel:(NSString *)msg{
    UILabel *rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    rightLabel.textAlignment = NSTextAlignmentRight;
    rightLabel.textColor = [UIColor darkGrayColor];
    rightLabel.text = msg;
    return rightLabel;
}

- (UILabel *)centerLabel:(NSString *)msg{
    UILabel *centerLabel = [[UILabel alloc]init];
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.text = msg;
    centerLabel.textColor = [UIColor darkGrayColor];
    return centerLabel;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
