//
//  HomeTableViewController.m
//  GestureLockDemo
//
//  Created by ZL on 2017/4/5.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "HomeTableViewController.h"
#import "ZLGestureLockViewController.h"

@interface HomeTableViewController ()

@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"手势解锁";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; // 取消cell选中效果
        
        // 中间分割线
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithRed:(243)/255.0 green:(243)/255.0 blue:(243)/255.0 alpha:1.0];
        line.frame = CGRectMake(0, 43, [UIScreen mainScreen].bounds.size.width, 1);
        [cell.contentView addSubview:line];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"创建手势密码";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"校验手势密码";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"删除手势密码";
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) { // 创建手势密码
        NSLog(@"点击了---创建手势密码");
        
        ZLGestureLockViewController *vc = [[ZLGestureLockViewController alloc] initWithUnlockType:ZLUnlockTypeCreatePsw];
        [self presentViewController:vc animated:YES completion:nil];
    } else if (indexPath.row == 1) { // 校验手势密码
        NSLog(@"点击了---校验手势密码");
        
        if ([ZLGestureLockViewController gesturesPassword].length > 0) {
            
            ZLGestureLockViewController *vc = [[ZLGestureLockViewController alloc] initWithUnlockType:ZLUnlockTypeValidatePsw];
            [self presentViewController:vc animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"还没有设置手势密码" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [alertView show];
        }
    } else if (indexPath.row == 2) { // 删除手势密码
        NSLog(@"点击了---删除手势密码");
        
        [ZLGestureLockViewController deleteGesturesPassword];
    }
}


@end
