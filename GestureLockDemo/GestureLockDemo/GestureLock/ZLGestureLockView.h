//
//  ZLGestureLockView.h
//  GestureLockDemo
//
//  Created by ZL on 2017/4/5.
//  Copyright © 2017年 ZL. All rights reserved.
//  九宫格 手势密码页面

#import <UIKit/UIKit.h>
@class ZLGestureLockView;

//检测手势密码答案情况 对/错/不够4个数字
typedef NS_ENUM(NSUInteger, ResultKindType) {
    ResultKindTypeTrue,
    ResultKindTypeFalse,
    ResultKindTypeNoEnough,
    ResultKindTypeClear
};

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

@protocol ZLGestureLockDelegate <NSObject>

- (void)gestureLockView:(ZLGestureLockView *)lockView drawRectFinished:(NSMutableString *)gesturePassword;

@end

@interface ZLGestureLockView : UIView

@property (assign, nonatomic) id<ZLGestureLockDelegate> delegate;

- (void)clearLockView;//清除布局 重新开始

- (void)checkPwdResult:(ResultKindType)resultType;

@end
