//
//  HomeAlertViews.h
//  MQTT
//
//  Created by Mercy on 15/7/14.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeAlertViews : UIView

@property (nonatomic, strong) UIAlertView *configHostAlert; // 用来设置服务器IP地址
@property (nonatomic, strong) UIAlertView *sureAlert; // 提示用户是否确定关闭服务
@property (nonatomic, strong) UIAlertView *failedConnectAlert; // 提示用户开启服务失败
@property (nonatomic, strong) UIAlertView *wrongAddressAlert; // 提示用户检查服务器地址
@property (nonatomic, strong) UIAlertView *failedDisconnectAlert; // 提示用户关闭服务失败
@property (nonatomic, strong) UITextField *ipTextField; // configHostAlertView中输入IP地址的TextField
@property (nonatomic, strong) UITextField *portTextField; // configHostAlertView中输入端口号的TextField

@end
