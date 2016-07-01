//
//  CreateFolderViewController.m
//  YSJFileManager
//
//  Created by ysj on 16/2/24.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "CreateFolderViewController.h"
#import "FileManagerNavigationController.h"
#import "YSJFile.h"
#import "MBProgressHUD+YSJ.h"

@interface CreateFolderViewController ()
@property (nonatomic, strong) UITextField *folderNameTF;
@property (nonatomic, strong) NSString *homeDirectoryPathString;
@property (nonatomic, assign) InputMode inputMode;
@property (nonatomic, strong) YSJFile *ysjFile;
@end

@implementation CreateFolderViewController

- (instancetype)init{
    if (self = [super init]) {
        self.homeDirectoryPathString = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        self.inputMode = inputModeCreateFolder;
    }
    return self;
}

- (instancetype)initWithYSJFile:(YSJFile*)ysjFile{
    if (self = [super init]) {
        self.ysjFile = ysjFile;
        self.inputMode = inputModeRename;
    }
    return self;
}

- (instancetype)initWithDirectoryPathString:(NSString *)pathString{
    if (self = [super init]) {
        self.homeDirectoryPathString = pathString;
        self.inputMode = inputModeCreateFolder;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)initViews{
    self.view.backgroundColor = RGBA(220, 220, 220, 1);
    if (self.inputMode == inputModeCreateFolder) {
        self.navigationItem.title = @"创建文件夹";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addFolder)];
    }else if (self.inputMode == inputModeRename){
        self.navigationItem.title = @"重命名";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(renameFile)];
    }
//    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14],NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnClicked)];
//    [cancelItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14],NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    UIImageView *folderImg = [[UIImageView alloc]init];
    if (self.inputMode == inputModeCreateFolder) {
        folderImg.image = [UIImage imageNamed:@"folder-share-icon"];
    }else if(self.inputMode == inputModeRename){
        folderImg.image = [UIImage imageNamed:@"fileRename"];
    }
    folderImg.contentMode = UIViewContentModeScaleAspectFit;
    folderImg.frame = CGRectMake(15, 100, 50, 50);
    [self.view addSubview:folderImg];
    
    UITextField *folderNameTF = [[UITextField alloc]init];
    folderNameTF.textAlignment = NSTextAlignmentNatural;
    folderNameTF.layer.cornerRadius = 7;
    folderNameTF.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    folderNameTF.layer.borderWidth = 1;
    folderNameTF.font = [UIFont systemFontOfSize:20];
    folderNameTF.backgroundColor = [UIColor whiteColor];
    folderNameTF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    [folderNameTF becomeFirstResponder];
    [folderNameTF addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    self.folderNameTF = folderNameTF;
    [self.view addSubview:folderNameTF];
    if (self.inputMode == inputModeRename) {
        folderNameTF.text = self.ysjFile.fileName;
        folderNameTF.placeholder = @"请输入新名称";
    }else if (self.inputMode == inputModeCreateFolder) {
        folderNameTF.placeholder = @"请输入文件夹名称";
    }
    
    folderNameTF.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *textFieldLeadingConstraint = [NSLayoutConstraint constraintWithItem:folderNameTF attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:folderImg attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:15.0f];
    
    NSLayoutConstraint *textFieldTailingConstraint = [NSLayoutConstraint constraintWithItem:folderNameTF attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-15.0f];
    
    NSLayoutConstraint *textFieldCenterYConstraint = [NSLayoutConstraint constraintWithItem:folderNameTF attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:folderImg attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *textFieldHeightConstraint = [NSLayoutConstraint constraintWithItem:folderNameTF attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:folderImg attribute:NSLayoutAttributeHeight multiplier:0.0f constant:40.0f];
    
    if (IOS_VERSION < 8) {
        [self.view addConstraint:textFieldLeadingConstraint];
        [self.view addConstraint:textFieldTailingConstraint];
        [self.view addConstraint:textFieldCenterYConstraint];
        [self.view addConstraint:textFieldHeightConstraint];
    }else{
        textFieldLeadingConstraint.active = YES;
        textFieldTailingConstraint.active = YES;
        textFieldCenterYConstraint.active = YES;
        textFieldHeightConstraint.active = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    UITextView *textView = object;
    CGFloat topCorrect = (textView.bounds.size.height - textView.contentSize.height*textView.zoomScale)/2;
    topCorrect = topCorrect<0?0:topCorrect;
    textView.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    [textView setContentInset:UIEdgeInsetsMake(topCorrect,0,0,0)];
}

- (void)renameFile{
    if ([self.folderNameTF.text isEqualToString:@""]) {
        return;
    }
    NSString *newPath = [[self.ysjFile.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:self.folderNameTF.text];
    NSError *error;
    if ([self canRename:newPath]) {
        BOOL result = [[NSFileManager defaultManager] moveItemAtPath:self.ysjFile.filePath toPath:newPath error:&error];
        if (result) {
            [self updateYSJFile:newPath];
            [self cancelBtnClicked];
            return;
        }else{
            [MBProgressHUD showMBPMsg:@"重命名文件失败" onView:self.view delay:2.0f];
        }
    }
}

- (void)updateYSJFile:(NSString *)newPath{
    //name
    self.ysjFile.fileName = self.folderNameTF.text;
    //modifyDate
    NSDictionary *attributeDic = [[NSFileManager defaultManager] attributesOfItemAtPath:newPath error:nil];
    self.ysjFile.fileModificationDate = [attributeDic objectForKey:NSFileModificationDate];
    //sizeStr&sizeNum
    NSNumber *fileSize = [attributeDic objectForKey:NSFileSize];
    self.ysjFile.fileSize = fileSize;
    self.ysjFile.fileSizeByteStr = [NSByteCountFormatter stringFromByteCount:[fileSize integerValue] countStyle:NSByteCountFormatterCountStyleFile];
    //fileType
    if (!self.ysjFile.isFolder) {
        self.ysjFile.fileType = [NSString stringWithFormat:@"%@文件",[self checkFileType:self.folderNameTF.text]];
    }
    //filePath
    self.ysjFile.filePath = newPath;
}

- (void)addFolder{
    if ([self.folderNameTF.text isEqualToString:@""]) {
        return;
    }
    NSString *folderPath;
    for (int i = 0; ; i++) {
        if (i == 0) {
            folderPath = [self.homeDirectoryPathString stringByAppendingPathComponent:self.folderNameTF.text];
        }else{
            folderPath = [self.homeDirectoryPathString stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d",self.folderNameTF.text,i]];
        }
        if ([self canCreateFolder:folderPath]) {
            break;
        }
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    [self cancelBtnClicked];
}

- (BOOL)canCreateFolder:(NSString *)folderPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL isExisted = [fileManager fileExistsAtPath:folderPath isDirectory:&isDirectory];
    if (isExisted && isDirectory) {
        return NO;
    }
    return YES;
}

- (BOOL)canRename:(NSString *)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL isExisted = [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (isExisted) {
        return NO;
    }
    return YES;
}

- (void)cancelBtnClicked{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self.folderNameTF removeObserver:self forKeyPath:@"contentSize"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
