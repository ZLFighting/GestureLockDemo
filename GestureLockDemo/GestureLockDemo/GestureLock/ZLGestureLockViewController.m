//
//  ZLGestureLockViewController.m
//  GestureLockDemo
//
//  Created by ZL on 2017/4/5.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "ZLGestureLockViewController.h"
#import "ZLGestureLockView.h"
#import "ZLGestureLockIndicator.h"

#define GesturesPassword @"gesturespassword"

@interface ZLGestureLockViewController () <ZLGestureLockDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) ZLGestureLockView *gestureLockView;
@property (strong, nonatomic) ZLGestureLockIndicator *gestureLockIndicator;

// 手势状态栏提示label
@property (weak, nonatomic) UILabel *statusLabel;

// 账户名
@property (weak, nonatomic) UILabel *nameLabel;
// 账户头像
@property (weak, nonatomic) UIImageView *headIcon;

// 其他账户登录按钮
@property (weak, nonatomic) UIButton *otherAcountBtn;
// 重新绘制按钮
@property (weak, nonatomic) UIButton *resetPswBtn;
// 忘记手势密码按钮
@property (weak, nonatomic) UIButton *forgetPswBtn;

// 创建的手势密码
@property (nonatomic, copy) NSString *lastGesturePsw;

@property (nonatomic) ZLUnlockType unlockType;

@end

@implementation ZLGestureLockViewController

#pragma mark - 类方法

+ (void)deleteGesturesPassword {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:GesturesPassword];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)addGesturesPassword:(NSString *)gesturesPassword {
    [[NSUserDefaults standardUserDefaults] setObject:gesturesPassword forKey:GesturesPassword];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)gesturesPassword {
    return [[NSUserDefaults standardUserDefaults] objectForKey:GesturesPassword];
}

#pragma mark - inint

- (instancetype)initWithUnlockType:(ZLUnlockType)unlockType {
    if (self = [super init]) {
        _unlockType = unlockType;
    }
    return self;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupMainUI];
    
    self.gestureLockView.delegate = self;
    
    self.resetPswBtn.hidden = YES;
    switch (_unlockType) {
        case ZLUnlockTypeCreatePsw:
        {
            self.gestureLockIndicator.hidden = NO;
            self.otherAcountBtn.hidden = self.forgetPswBtn.hidden = self.nameLabel.hidden = self.headIcon.hidden = YES;
        }
            break;
        case ZLUnlockTypeValidatePsw:
        {
            self.gestureLockIndicator.hidden = YES;
            self.otherAcountBtn.hidden = self.forgetPswBtn.hidden = self.nameLabel.hidden = self.headIcon.hidden = NO;
            
        }
            break;
        default:
            break;
    }
    
}

// 创建界面
- (void)setupMainUI {
    
    CGFloat maginX = 15;
    CGFloat magin = 5;
    CGFloat btnW = ([UIScreen mainScreen].bounds.size.width - maginX * 2 - magin * 2) / 3;
    CGFloat btnH = 30;
    
    // 账户头像
    UIImageView *headIcon = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 56) * 0.5, 30, 56, 56)];
    headIcon.image = [UIImage imageNamed:@"gesture_headIcon"];
    [self.view addSubview:headIcon];
    
    // 账户名
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 100) * 0.5, 90, 100, 20)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = @"smile丽";
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.textColor = [UIColor orangeColor];
    [self.view addSubview:nameLabel];
    self.statusLabel = nameLabel;
    
    // 九宫格指示器 小图
    ZLGestureLockIndicator *gestureLockIndicator = [[ZLGestureLockIndicator alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 60) * 0.5, 110, 60, 60)];
    [self.view addSubview:gestureLockIndicator];
    self.gestureLockIndicator = gestureLockIndicator;
    
    // 手势状态栏提示label
    UILabel *statusLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 200) * 0.5, 160, 200, 30)];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.text = @"请绘制手势密码";
    statusLabel.font = [UIFont systemFontOfSize:12];
    statusLabel.textColor = [UIColor redColor];
    [self.view addSubview:statusLabel];
    self.statusLabel = statusLabel;
    
    // 九宫格 手势密码页面
    ZLGestureLockView *gestureLockView = [[ZLGestureLockView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - self.view.frame.size.width - 60 - btnH, self.view.frame.size.width, self.view.frame.size.width)];
    gestureLockView.delegate = self;
    [self.view addSubview:gestureLockView];
    self.gestureLockView = gestureLockView;
    
    // 底部三个按钮
    // 其他账户登录按钮
    UIButton *otherAcountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    otherAcountBtn.frame = CGRectMake(maginX, self.view.frame.size.height - 20 - btnH, btnW, btnH);
    otherAcountBtn.backgroundColor = [UIColor clearColor];
    [otherAcountBtn setTitle:@"其他账户" forState:UIControlStateNormal];
    otherAcountBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [otherAcountBtn setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
    [otherAcountBtn addTarget:self action:@selector(otherAccountLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherAcountBtn];
    self.otherAcountBtn = otherAcountBtn;
    
    // 重新绘制按钮
    UIButton *resetPswBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resetPswBtn.frame = CGRectMake(CGRectGetMaxX(otherAcountBtn.frame) + magin, otherAcountBtn.frame.origin.y, btnW, btnH);
    resetPswBtn.backgroundColor = otherAcountBtn.backgroundColor;
    [resetPswBtn setTitle:@"重新绘制" forState:UIControlStateNormal];
    resetPswBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [resetPswBtn setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
    [resetPswBtn addTarget:self action:@selector(resetGesturePassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetPswBtn];
    self.resetPswBtn = resetPswBtn;
    
    // 忘记手势密码按钮
    UIButton *forgetPswBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetPswBtn.frame = CGRectMake(CGRectGetMaxX(resetPswBtn.frame) + magin, otherAcountBtn.frame.origin.y, btnW, btnH);
    forgetPswBtn.backgroundColor = otherAcountBtn.backgroundColor;
    [forgetPswBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    forgetPswBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [forgetPswBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [forgetPswBtn addTarget:self action:@selector(forgetGesturesPassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetPswBtn];
    self.forgetPswBtn = forgetPswBtn;
}

#pragma mark - private

//  创建手势密码
- (void)createGesturesPassword:(NSMutableString *)gesturesPassword {
    
    if (self.lastGesturePsw.length == 0) {
        
        if (gesturesPassword.length < 4) {
            self.statusLabel.text = @"至少连接四个点，请重新输入";
            [self shakeAnimationForView:self.statusLabel];
            return;
        }
        
        if (self.resetPswBtn.hidden == YES) {
            self.resetPswBtn.hidden = NO;
        }
        
        self.lastGesturePsw = gesturesPassword;
        [self.gestureLockIndicator setGesturePassword:gesturesPassword];
        self.statusLabel.text = @"请再次绘制手势密码";
        return;
    }
    
    if ([self.lastGesturePsw isEqualToString:gesturesPassword]) { // 绘制成功
        
        [self dismissViewControllerAnimated:YES completion:^{
            // 保存手势密码
            [ZLGestureLockViewController addGesturesPassword:gesturesPassword];
        }];
        
    }else {
        self.statusLabel.text = @"与上一次绘制不一致，请重新绘制";
        [self shakeAnimationForView:self.statusLabel];
    }
    
    
}

// 验证手势密码
- (void)validateGesturesPassword:(NSMutableString *)gesturesPassword {
    
    static NSInteger errorCount = 5;
    
    if ([gesturesPassword isEqualToString:[ZLGestureLockViewController gesturesPassword]]) {
        
        [self dismissViewControllerAnimated:YES completion:^{
            errorCount = 5;
        }];
    } else {
        
        if (errorCount - 1 == 0) { // 你已经输错五次了！ 退出重新登陆！
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"手势密码已失效" message:@"请重新登陆" delegate:self cancelButtonTitle:nil otherButtonTitles:@"重新登陆", nil];
            [alertView show];
            errorCount = 5;
            return;
        }
        
        self.statusLabel.text = [NSString stringWithFormat:@"密码错误，还可以再输入%ld次",--errorCount];
        [self shakeAnimationForView:self.statusLabel];
    }
}

// 抖动动画
- (void)shakeAnimationForView:(UIView *)view {
    
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint left = CGPointMake(position.x - 10, position.y);
    CGPoint right = CGPointMake(position.x + 10, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:left]];
    [animation setToValue:[NSValue valueWithCGPoint:right]];
    [animation setAutoreverses:YES]; // 平滑结束
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    
    [viewLayer addAnimation:animation forKey:nil];
}

#pragma mark - 按钮点击事件 Anction

// 点击其他账号登陆按钮
- (void)otherAccountLogin:(id)sender {
    NSLog(@"%s",__FUNCTION__);
}

// 点击重新绘制按钮
- (void)resetGesturePassword:(id)sender {
    NSLog(@"%s",__FUNCTION__);
    
    self.lastGesturePsw = nil;
    self.statusLabel.text = @"请绘制手势密码";
    self.resetPswBtn.hidden = YES;
    [self.gestureLockIndicator setGesturePassword:@""];
}

// 点击忘记手势密码按钮
- (void)forgetGesturesPassword:(id)sender {
    NSLog(@"%s",__FUNCTION__);
}


#pragma mark - ZLgestureLockViewDelegate

- (void)gestureLockView:(ZLGestureLockView *)lockView drawRectFinished:(NSMutableString *)gesturePassword {
    
    switch (_unlockType) {
        case ZLUnlockTypeCreatePsw: // 创建手势密码
        {
            [self createGesturesPassword:gesturePassword];
        }
            break;
        case ZLUnlockTypeValidatePsw: // 校验手势密码
        {
            [self validateGesturesPassword:gesturePassword];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 重新登陆
    NSLog(@"重新登陆");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
