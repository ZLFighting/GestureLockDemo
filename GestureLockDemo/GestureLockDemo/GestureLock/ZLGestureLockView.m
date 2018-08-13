//
//  ZLGestureLockView.m
//  GestureLockDemo
//
//  Created by ZL on 2017/4/5.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "ZLGestureLockView.h"

@interface ZLGestureLockView ()

@property (strong, nonatomic) NSMutableArray *selectBtns;
@property (nonatomic, strong) NSMutableArray *errorBtns;//错误的按钮数组
@property(nonatomic, assign)BOOL finished;//是否完成
@property (nonatomic, assign) CGPoint currentPoint;//当前触摸点
@property (nonatomic, assign) ResultKindType resultType;//学生端结果

@end

@implementation ZLGestureLockView

#pragma mark - getter

- (NSMutableArray *)selectBtns {
    if (!_selectBtns) {
        _selectBtns = [NSMutableArray array];
    }
    return _selectBtns;
}

#pragma mark - initializer

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self initSubviews];
    }
    return self;
}

// 子视图初始化
- (void)initSubviews {
    self.backgroundColor = [UIColor clearColor];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    // 创建九宫格 9个按钮
    for (NSInteger i = 0; i < 9; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.userInteractionEnabled = NO;
        [btn setImage:[UIImage imageNamed:@"灰色椭圆"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"橙色椭圆"] forState:UIControlStateSelected];
        [self addSubview:btn];
        btn.tag = i + 1;
    }
}

//为什么要在这个方法中布局子控件，因为只调用这个方法，就表示父控件的尺寸确定
- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSUInteger count = self.subviews.count;
    
    int cols = 3;//总列数
    
    CGFloat x = 0,y = 0,w = 0,h = 0;
    
    if (Screen_Width == 320) {
        w = 50;
        h = 50;
    } else {
        w = 58;
        h = 58;
    }
    
    CGFloat margin = (self.bounds.size.width - cols * w) / (cols + 1);//间距
    
    CGFloat col = 0;
    CGFloat row = 0;
    for (int i = 0; i < count; i++) {
        
        col = i % cols;
        row = i / cols;
        
        x = margin + (w+margin)*col;
        
        y = margin + (w+margin)*row;
        if (Screen_Height == 480) { // 适配4寸屏幕
            y = (w + margin) * row;
        }else {
            y = margin +(w + margin) * row;
        }
        
        UIButton *btn = self.subviews[i];
        btn.frame = CGRectMake(x, y, w, h);
    }
}

// 只要调用这个方法就会把之前绘制的东西清空 重新绘制
- (void)drawRect:(CGRect)rect {
    
    if (_selectBtns.count == 0) return;
    
    // 把所有选中按钮中心点连线
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < self.selectBtns.count; i ++) {
        UIButton *btn = self.selectBtns[i];
        if (i == 0) {
            [path moveToPoint:btn.center]; // 设置起点
        } else {
            [path addLineToPoint:btn.center];
        }
    }
    
    //判断是否松开手指
    if (self.finished) {
        //松开手
        NSMutableString *pwd = [self transferGestureResult];//传递创建的密码
        [[UIColor colorWithRed:94/255.0 green:195/255.0 blue:49/255.0 alpha:0.8] set];
        if ([self.delegate respondsToSelector:@selector(gestureLockView:drawRectFinished:)]) {
            [self.delegate gestureLockView:self drawRectFinished:pwd];
        }
        
        switch (self.resultType) {
            case ResultKindTypeTrue:
            {
                //正确
                [[UIColor clearColor] set];
            }
                break;
            case ResultKindTypeFalse:
            {
                //错误
                [[UIColor redColor] set];
                for (int i = 0; i < self.errorBtns.count; i++) {
                    UIButton *btn =  [self.errorBtns objectAtIndex:i];
                    [btn setImage:[UIImage imageNamed:@"红色椭圆"] forState:UIControlStateNormal];
                }
                break;
            case ResultKindTypeNoEnough:
                {
                    [[UIColor clearColor] set];
                }
                break;
            case ResultKindTypeClear:
                {
                    
                }
                break;
            default:
                break;
            }
        }
    } else {
        [path addLineToPoint:self.currentPoint];
        [[UIColor orangeColor] set];
    }
    
    //  设置路径属性
    path.lineWidth = 6;
    path.lineJoinStyle = kCGLineCapRound;
    path.lineCapStyle = kCGLineCapRound;
    //  渲染
    [path stroke];
}

#pragma mark - action pan

#pragma mark 手势
- (void)pan:(UIPanGestureRecognizer *)pan {
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        for (UIButton *btn in _errorBtns) {
            [btn setImage:[UIImage imageNamed:@"灰色椭圆"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"橙色椭圆"] forState:UIControlStateSelected];
        }
        [self.errorBtns removeAllObjects];
    }
    _currentPoint = [pan locationInView:self];
    
    for (UIButton *button in self.subviews) {
        if (CGRectContainsPoint(button.frame, _currentPoint)) {
            if (button.selected == NO) {
                //点在按钮上
                button.selected = YES;//设置为选中
                [self.selectBtns addObject:button];
            } else {
                
            }
        }
    }
    
    // 重绘
    [self setNeedsDisplay];
    //监听手指松开
    if (pan.state == UIGestureRecognizerStateEnded) {
        self.finished = YES;
    }
    
//    [self layoutIfNeeded];
//
//    if (pan.state == UIGestureRecognizerStateEnded) {
//
//        // 保存输入密码
//        // 注意：我们在密码判定过程中是通过根据先前布局按钮的时候定义的按钮tag值进行字符串拼接，密码传值是通过代理实现。
//        NSMutableString *gesturePwd = @"".mutableCopy;
//        for (UIButton *button in self.selectBtns) {
//            [gesturePwd appendFormat:@"%ld",button.tag-1];
//            button.selected = NO;
//        }
//        [self.selectBtns removeAllObjects];
//
//        // 手势密码绘制完成后回调
//        if ([self.delegate respondsToSelector:@selector(gestureLockView:drawRectFinished:)]) {
//            [self.delegate gestureLockView:self drawRectFinished:gesturePwd];
//        }
//
//    }
}

//传递设置的手势密码
- (NSMutableString *)transferGestureResult {
    //创建可变字符串
    NSMutableString *result = [NSMutableString string];
    for (UIButton *btn in self.selectBtns) {
        [result appendFormat:@"%ld", btn.tag - 1];
    }
    return result;
}

//清除
- (void)clearLockView {
    self.finished = NO;
    //遍历所有选中的按钮
    for (UIButton *btn in self.selectBtns) {
        //取消选中状态
        btn.selected = NO;
    }
    [self.selectBtns removeAllObjects];
    //
    [self setNeedsDisplay];
}
//检验密码正误
- (void)checkPwdResult:(ResultKindType)resultType {
    self.resultType = resultType;
    switch (resultType) {
        case ResultKindTypeFalse:
            _errorBtns = [NSMutableArray arrayWithArray:self.selectBtns];
            break;
        case ResultKindTypeTrue:
            break;
        case ResultKindTypeNoEnough:
            break;
        case ResultKindTypeClear:
        {
            [[UIColor clearColor] set];
            for (int i = 0; i < self.errorBtns.count; i++) {
                UIButton *btn =  [self.errorBtns objectAtIndex:i];
                [btn setImage:[UIImage imageNamed:@"灰色椭圆"] forState:UIControlStateNormal];
            }
            [self.errorBtns removeAllObjects];
        }
            break;
        default:
            break;
    }
    [self clearLockView];
}

@end
