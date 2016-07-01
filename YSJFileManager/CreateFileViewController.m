//
//  CreateFileViewController.m
//  YSJFileManager
//
//  Created by ysj on 16/3/24.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "CreateFileViewController.h"
#import "YSJFile.h"
#import "MBProgressHUD+YSJ.h"

@interface CreateFileViewController ()<UITextViewDelegate>
@property (nonatomic, strong) UITextField *titleTF;
@property (nonatomic, strong) UITextView *contentTV;
@property (nonatomic, copy) NSString *directory;
@property (nonatomic, strong) YSJFile *modifyFile;
@end

@implementation CreateFileViewController

- (instancetype)initWithDirectoryPathString:(NSString *)directory{
    if (self = [super init]) {
        self.directory = directory;
        self.editType = EditTypeCreateFile;
    }
    return self;
}

- (instancetype)initWithModifyFile:(YSJFile *)ysjFile{
    if (self = [super init]) {
        self.directory = ysjFile.filePath;
        self.editType = EditTypeModifyFile;
        self.modifyFile = ysjFile;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initConstraint];
    if (self.editType == EditTypeModifyFile) {
        [self initModify];
    }
}

- (void)initModify{
    NSString *contentStr = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:self.modifyFile.filePath] encoding:NSUTF16StringEncoding error:nil];
    self.contentTV.text = contentStr;
    if ([contentStr isEqualToString:@""]) {
        self.contentTV.textColor = [self.titleTF valueForKeyPath:@"_placeholderLabel.textColor"];
    }else{
        self.contentTV.textColor = [UIColor blackColor];
    }
    
    NSString *fileName = [self.modifyFile.fileName stringByReplacingCharactersInRange:NSMakeRange(self.modifyFile.fileName.length-4, 4) withString:@""];
    self.titleTF.text = fileName;
}

- (void)initConstraint{
    self.titleTF.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentTV.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *titleLeading = [NSLayoutConstraint constraintWithItem:self.titleTF attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:5.0f];
    
    NSLayoutConstraint *titleTailing = [NSLayoutConstraint constraintWithItem:self.titleTF attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-5.0f];
    
    NSLayoutConstraint *titleTop = [NSLayoutConstraint constraintWithItem:self.titleTF attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:5.0f];
    
    NSLayoutConstraint *titleHeight = [NSLayoutConstraint constraintWithItem:self.titleTF attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.0f constant:40];
    
    if (IOS_VERSION < 8) {
        [self.view addConstraint:titleHeight];
        [self.view addConstraint:titleLeading];
        [self.view addConstraint:titleTailing];
        [self.view addConstraint:titleTop];
    }else{
        titleHeight.active = YES;
        titleLeading.active = YES;
        titleTailing.active = YES;
        titleTop.active = YES;
    }
    
    NSLayoutConstraint *contentLeading = [NSLayoutConstraint constraintWithItem:self.contentTV attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:5.0f];
    
    NSLayoutConstraint *contentTailing = [NSLayoutConstraint constraintWithItem:self.contentTV attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-5.0f];
    
    NSLayoutConstraint *contentTop = [NSLayoutConstraint constraintWithItem:self.contentTV attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleTF attribute:NSLayoutAttributeBottom multiplier:1.0f constant:5.0f];
    
    NSLayoutConstraint *contentBottom = [NSLayoutConstraint constraintWithItem:self.contentTV attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-5.0f];
    
    if (IOS_VERSION < 8) {
        [self.view addConstraint:contentBottom];
        [self.view addConstraint:contentLeading];
        [self.view addConstraint:contentTailing];
        [self.view addConstraint:contentTop];
    }else{
        contentBottom.active = YES;
        contentLeading.active = YES;
        contentTailing.active = YES;
        contentTop.active = YES;
    }
}

- (void)initView{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"新建文本文档";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(sureBtnClicked)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnClicked)];
    
    UITextField *titleTF = [[UITextField alloc]init];
    titleTF.placeholder = @"请输入文件标题";
    titleTF.backgroundColor = [UIColor whiteColor];
    titleTF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    titleTF.layer.cornerRadius = 3;
    titleTF.layer.borderWidth = 1;
    titleTF.layer.borderColor= [[UIColor grayColor] CGColor];
    self.titleTF = titleTF;
    [self.view addSubview:titleTF];
    [titleTF becomeFirstResponder];
    
    UITextView *contentView = [[UITextView alloc]init];
    contentView.layer.cornerRadius = 3;
    contentView.layer.borderWidth = 1;
    contentView.font = [UIFont systemFontOfSize:15];
    contentView.layer.borderColor= [[UIColor grayColor] CGColor];
    contentView.delegate = self;
    self.contentTV = contentView;
    [self.view addSubview:contentView];
    [self textViewDidEndEditing:contentView];
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

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"请输入正文"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"请输入正文";
        textView.textColor = [self.titleTF valueForKeyPath:@"_placeholderLabel.textColor"];
    }
}


- (void)sureBtnClicked{
    if ([self.titleTF.text isEqualToString:@""]) {
        [MBProgressHUD showMBPMsg:@"请输入标题" onView:self.view delay:2.0f];
        return;
    }
    if (!self.directory) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result;
    NSError *error;
    if (self.editType == EditTypeCreateFile) {
        result = [fileManager createFileAtPath:[self.directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",self.titleTF.text]] contents:[self.contentTV.text dataUsingEncoding:NSUTF16StringEncoding] attributes:nil];
        if (result) {
            [self cancelBtnClicked];
        }else{
            [MBProgressHUD showMBPMsg:@"创建文件失败" onView:self.view delay:2.0f];
        }
    }else if (self.editType == EditTypeModifyFile){
        NSString *titleTFName = [NSString stringWithFormat:@"%@.txt",self.titleTF.text];
        NSString *newPath = [[self.directory stringByDeletingLastPathComponent] stringByAppendingPathComponent:titleTFName];
        
        if (![titleTFName isEqualToString:self.modifyFile.fileName]) {
            //需重命名文件
            if (![self canRename:newPath]) {
                [MBProgressHUD showMBPMsg:@"文件重名，请重新输入文件名" onView:self.view delay:2.0f];
                return;
            }
            
            result = [[NSFileManager defaultManager] moveItemAtPath:self.modifyFile.filePath toPath:newPath error:&error];
            if (!result) {
                [MBProgressHUD showMBPMsg:@"文件改名失败" onView:self.view delay:2.0f];
                return;
            }
        }
        
//        result = [self.contentTV.text writeToFile:newPath atomically:YES encoding:NSUTF16StringEncoding error:&error];
//        if (!result) {
//            [MBProgressHUD showMBPMsg:@"文件写入内容失败" onView:self.view delay:2.0f];
//            return;
//        }
//        [self updateYSJFile:newPath];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateModifyTxtYSJFile" object:self userInfo:@{@"YSJFile":self.modifyFile}];
//        [self cancelBtnClicked];
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:newPath];
        [fileHandle seekToFileOffset:0];
        [fileHandle writeData:[self.contentTV.text dataUsingEncoding:NSUTF16StringEncoding]];
        [fileHandle closeFile];
        [self cancelBtnClicked];
    }
}

- (void)updateYSJFile:(NSString *)newPath{
    //name
    self.modifyFile.fileName = [NSString stringWithFormat:@"%@.txt",self.titleTF.text];
    //modifyDate
    NSDictionary *attributeDic = [[NSFileManager defaultManager] attributesOfItemAtPath:newPath error:nil];
    self.modifyFile.lastModifyDate = self.modifyFile.fileModificationDate;
    self.modifyFile.fileModificationDate = [attributeDic objectForKey:NSFileModificationDate];
    //createData  have to...
    self.modifyFile.fileCreationDate = [attributeDic objectForKey:NSFileCreationDate];
    //filePath
    self.modifyFile.filePath = newPath;
    //oldFileSize
    self.modifyFile.oldFileSize = self.modifyFile.fileSize;
    //sizeStr&sizeNum
    NSNumber *fileSize = [attributeDic objectForKey:NSFileSize];
    self.modifyFile.fileSize = fileSize;
    self.modifyFile.fileSizeByteStr = [NSByteCountFormatter stringFromByteCount:[fileSize integerValue] countStyle:NSByteCountFormatterCountStyleFile];
}

- (void)cancelBtnClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
