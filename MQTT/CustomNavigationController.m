//
//  CustomNavigationController.m
//  MQTT
//
//  Created by Mercy on 15/7/14.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "CustomNavigationController.h"

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UINavigationBar *bar = self.navigationBar;
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:[UIColor whiteColor] }];
    
}

// 设置白色状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
