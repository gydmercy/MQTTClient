//
//  SubscribeAlertView.h
//  MQTT
//
//  Created by Mercy on 15/7/14.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscribeAlertView : UIView

@property (nonatomic, strong) UIAlertView *addTopicAlert; // 用来输入要添加的主题
@property (nonatomic, strong) UIAlertView *failedAddAlert; // 提示用户要先开启服务
@property (nonatomic, strong) UIAlertView *failedSubscribeAlert; // 提示用户订阅失败
@property (nonatomic, strong) UIAlertView *failedUnsubscribeAlert; // 提示用户取消订阅失败
@property (nonatomic, strong) UITextField *topicTextField; // addTopicAlert中填写主题名称的TextField

@end
