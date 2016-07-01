//
//  PhotoChooseViewController.m
//  YSJFileManager
//
//  Created by ysj on 16/3/22.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "PhotoChooseViewController.h"
#import "UIView+YSJ.h"
#import "PhotoCollectionViewCell.h"


@interface PhotoChooseViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *assArr;
@property (nonatomic, strong) NSMutableArray *indexPathArr;
@end

@implementation PhotoChooseViewController

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(sureBtnClicked)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnClicked)];
//    self.navigationItem.hidesBackButton = YES;
    
    
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)cancelBtnClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sureBtnClicked{
    NSMutableArray *tempArr = [NSMutableArray array];
    if (self.indexPathArr.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    for (NSIndexPath *indexPath in self.indexPathArr) {
        ALAsset *asset = self.assArr[indexPath.row];
        if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
            ALAssetRepresentation *imageRepresentation = [asset defaultRepresentation];
            NSDictionary *dic = [[asset defaultRepresentation] metadata];
            NSString *filename = [[asset defaultRepresentation] filename];
            UIImage *img = [UIImage imageWithCGImage:[imageRepresentation fullScreenImage]];
            [tempArr addObject:@{@"type":@"image",
                                 @"metadata":dic,
                                 @"filename":filename,
                                 @"img":img}];
        }else if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
            ALAssetRepresentation *videoRepresentation = [asset defaultRepresentation];
            NSString *filename = [[asset defaultRepresentation] filename];
            Byte *buffer = (Byte*)malloc((NSUInteger)videoRepresentation.size);
            NSUInteger buffered = [videoRepresentation getBytes:buffer fromOffset:0.0 length:(NSUInteger)videoRepresentation.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            [tempArr addObject:@{@"type":@"video",
                                 @"filename":filename,
                                 @"videoData":data}];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addData" object:nil userInfo:@{@"data":tempArr}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.asset = self.assArr[indexPath.row];
    cell.selectedView.hidden = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.selectedView.hidden) {
        cell.selectedView.hidden = NO;
        [self.indexPathArr addObject:indexPath];
    }else {
        cell.selectedView.hidden = YES;
        [self.indexPathArr removeObject:indexPath];
    }
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup{
    _assetsGroup = assetsGroup;
    self.navigationItem.title = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    if (self.assArr) {
        [self.assArr removeAllObjects];
    }else{
        self.assArr = [NSMutableArray array];
    }
    ALAssetsGroupEnumerationResultsBlock block = ^(ALAsset *asset, NSUInteger index, BOOL *stop){
        if (asset) {
            [self.assArr addObject:asset];
        }else{
            [self.collectionView reloadData];
        }
    };
    [_assetsGroup enumerateAssetsUsingBlock:block];
}

- (NSMutableArray *)indexPathArr{
    if (!_indexPathArr) {
        _indexPathArr = [NSMutableArray array];
    }
    return _indexPathArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
