//
//  LockViewViewController.m
//  YSJFileManager
//
//  Created by ysj on 16/3/14.
//  Copyright © 2016年 Harry. All rights reserved.
//

#import "LockViewViewController.h"
#import "LockView.h"

@interface LockViewViewController ()<LockViewDelegate>
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *shouldConfirmedPWD;
@property (nonatomic, copy) NSString *originalPWD;
@end

@implementation LockViewViewController

- (instancetype)initWithMsg:(NSString *)msg startMode:(StartMode)startMode{
    if (self = [super init]) {
        self.msg = msg;
        self.startMode = startMode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)initViews{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    backImageView.image = [UIImage imageNamed:@"Home_refresh_bg"];
    [self.view addSubview:backImageView];
    
    UILabel *msgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 40)];
    msgLabel.text = self.msg;
    msgLabel.textColor = [UIColor whiteColor];
    [msgLabel setTextAlignment:NSTextAlignmentCenter];
    self.msgLabel = msgLabel;
    [self.view addSubview:msgLabel];
    
    if (self.startMode == startCreatePWD || self.startMode == startModifyPWD) {
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(10, 20, 50, 30);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelBtn];
    }
    
    LockView *lock = [[LockView alloc]initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 400)];
    lock.delegate = self;
    [self.view addSubview:lock];
}

- (void)cancelBtnClicked{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelCreatePWD" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - lockView Delegate
- (void)lockView:(LockView *)lockView didFinishedPath:(NSString *)path{
    YSJLog(@"%@",path);
    switch (self.startMode) {
        case startCreatePWD:
            [self createPWD:path];
            break;
        case startInputPWD:
            [self inputPWD:path];
            break;
        case startModifyPWD:
            [self modifyPWD:path];
            break;
        default:
            break;
    }
}

- (void)createPWD:(NSString *)inputPWD{
    if (!self.shouldConfirmedPWD) {
        //第一次输入
        if (inputPWD.length < 3) {
            self.msgLabel.text = @"密码不能小于3位";
            return;
        }
        self.shouldConfirmedPWD = inputPWD;
        self.msgLabel.text = @"请再次输入确认";
        YSJLog(@"第一次输入成功");
    }else if([self.shouldConfirmedPWD isEqualToString:inputPWD]){
        //第二次输入且前后一致
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:inputPWD forKey:UserPWD];
        [user setObject:@(YES) forKey:LockScreen];
        YSJLog(@"保存密码成功");
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        //第二次输入但前后不一致
        self.shouldConfirmedPWD = nil;
        self.msgLabel.text = @"前后密码不一致，请重新输入";
        YSJLog(@"前后密码不一致，需重新输入");
    }
}

- (void)inputPWD:(NSString *)inputPWD{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:UserPWD]isEqualToString:inputPWD]) {
        YSJLog(@"密码正确，进入界面");
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        YSJLog(@"密码不正确，请重新输入");
        self.msgLabel.text = @"密码不正确，请重新输入";
    }
}

- (void)modifyPWD:(NSString *)inputPWD{
    if (!self.originalPWD) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:UserPWD]isEqualToString:inputPWD]) {
            YSJLog(@"原始密码输入成功");
            self.originalPWD = inputPWD;
            self.msgLabel.text = @"请输入新密码";
        }else {
            YSJLog(@"原始密码输入错误");
            self.msgLabel.text = @"原始密码错误，请重新输入";
        }
    }else{
        if (!self.shouldConfirmedPWD) {
            if ([inputPWD isEqualToString:self.originalPWD]) {
                YSJLog(@"新密码不能与旧密码一样");
                return;
            }
            if (inputPWD.length < 3) {
                self.msgLabel.text = @"密码不能小于3位";
                return;
            }
            //第一次输入
            self.shouldConfirmedPWD = inputPWD;
            self.msgLabel.text = @"请再次输入确认";
            YSJLog(@"第一次输入成功");
        }else if([self.shouldConfirmedPWD isEqualToString:inputPWD]){
            //第二次输入且前后一致
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:inputPWD forKey:UserPWD];
            [user setObject:@(YES) forKey:LockScreen];
            YSJLog(@"保存密码成功");
            [self dismissViewControllerAnimated:YES completion:nil];
        }else {
            //第二次输入但前后不一致
            self.shouldConfirmedPWD = nil;
            self.msgLabel.text = @"前后密码不一致，请重新输入";
            YSJLog(@"前后密码不一致，需重新输入");
        }
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
