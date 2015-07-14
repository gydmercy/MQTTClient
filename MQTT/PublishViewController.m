//
//  PublishViewController.m
//  MQTT
//
//  Created by Mercy on 15/7/13.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "PublishViewController.h"
#import "PublishView.h"
#import "MBProgressHUD.h"
#import "MQTTKit.h"

@interface PublishViewController() <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) PublishView *publishView;
@property (nonatomic, strong) UIAlertView *failedPublishAlert;
@property (nonatomic, strong) MBProgressHUD *hud; // 提示框

@property (nonatomic, strong) MQTTClient *client; // 客户端对象
@property (nonatomic, assign) NSString *serviceState; // 服务开启状态

@end

@implementation PublishViewController


#pragma mark - Lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发布消息";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(publishAction:)];
    
    [self initPublishView];

}


#pragma mark - Initialization

- (void)initPublishView {
    _publishView = [[PublishView alloc] initWithFrame:self.view.bounds];
    _publishView.topicTextField.delegate = self;
    _publishView.contentText.delegate = self;
    [self.view addSubview:_publishView];
}

- (UIAlertView *)failedPublishAlert {
    if (!_failedPublishAlert) {
        _failedPublishAlert = [[UIAlertView alloc] initWithTitle:@"请先开启服务"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"确定", nil];
    }
    return _failedPublishAlert;
}


#pragma mark - HUD

- (void)showHUDWithText:(NSString *)text {
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText = text;
    
    UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
    UIImageView *checkmarkView = [[UIImageView alloc] initWithImage:image];
    _hud.customView = checkmarkView;
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


#pragma mark - Publish

- (void)publishMessage:(NSString *)message toTopic:(NSString *)topic {
    [self showHUDWithText:@"发布中..."];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_client publishString:message
                        toTopic:topic
                        withQos:AtMostOnce
                        retain:YES
             completionHandler:^(int mid){
                 // 更新 UI
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     // 转换为 CustomView 模式
                     _hud.mode = MBProgressHUDModeCustomView;
                     _hud.labelText = @"发布成功";
                     sleep(1);
                     [self hideHUD];
                 });
        
             }];
    });
}


#pragma mark - Actions

- (void)publishAction:(id)sender {
    if ([_serviceState isEqualToString:@"Service_ON"]) {
        
        NSString *topic = _publishView.topicTextField.text;
        NSString *content = _publishView.contentText.text;
        [self publishMessage:content toTopic:topic];
        
    } else {
        [self.failedPublishAlert show];
    }
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; // 键盘隐藏
    
    return YES;
}




@end
