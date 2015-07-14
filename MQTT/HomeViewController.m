//
//  HomeViewController.m
//  MQTT
//
//  Created by Mercy on 15/7/13.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "HomeViewController.h"
#import "MQTTKit.h"
#import "MBProgressHUD.h"
#import "HomeView.h"
#import "SubscribeViewController.h"
#import "PublishViewController.h"
#import "HistoryViewController.h"

@interface HomeViewController () <UITextFieldDelegate, UIAlertViewDelegate, MBProgressHUDDelegate>


@property (nonatomic, strong) HomeView *homeView; // 主界面View
@property (nonatomic, strong) MBProgressHUD *hud; // 提示框
@property (nonatomic, strong) UIAlertView *configHostAlertView; // 用来设置服务器IP地址
@property (nonatomic, strong) UIAlertView *sureAlertView; // 提示用户是否确定关闭服务
@property (nonatomic, strong) UIAlertView *failedConnectAlertView; // 提示用户开启服务失败
@property (nonatomic, strong) UIAlertView *failedDisConnectAlertView; // 提示用户关闭服务失败
@property (nonatomic, strong) UITextField *ipTextField; // configHostAlertView中输入IP地址的TextField

@property (nonatomic, strong) MQTTClient *client; // 客户端对象
@property (nonatomic, strong) NSString *hostAddress; // 服务器IP地址

@end

@implementation HomeViewController


#pragma mark - Lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:235.0 / 255 green:235.0 / 255 blue:235.0 / 255 alpha:1.0];
    self.title = @"MQTT客户端";
    
    // 设置子ViewController页面的返回按钮显示“返回”
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    _homeView = [[HomeView alloc] initWithFrame:self.view.bounds];
    [self.homeView.switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.homeView.subscirbeButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.homeView.publishButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.homeView.historyButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_homeView];
    
    
}


#pragma mark - getters

- (MQTTClient *)client {
    if (!_client) {
        NSString *clientID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        _client = [[MQTTClient alloc] initWithClientId:clientID];
    }
    return _client;
}


- (UIAlertView *)configHostAlertView {
    if (!_configHostAlertView) {
        _configHostAlertView = [[UIAlertView alloc] initWithTitle:@"请设置服务器IP"
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:@"确定", nil];
        _configHostAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        // 取出 AlertView 的输入框
        _ipTextField = [_configHostAlertView textFieldAtIndex:0];
        _ipTextField.clearsOnBeginEditing = YES;
        _ipTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _ipTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _ipTextField.returnKeyType = UIReturnKeyDone;
        _ipTextField.delegate = self;
    }
    return _configHostAlertView;
}

- (UIAlertView *)sureAlertView {
    if (!_sureAlertView) {
        _sureAlertView = [[UIAlertView alloc] initWithTitle:@"确定要关闭服务吗"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    }
    return _sureAlertView;
}

- (UIAlertView *)failedConnectAlertView {
    if (!_failedConnectAlertView) {
        _failedConnectAlertView = [[UIAlertView alloc] initWithTitle:@"连接失败"
                                                      message:@"开启服务不成功"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"确定", nil];
    }
    return _failedConnectAlertView;
}

- (UIAlertView *)failedDisConnectAlertView {
    if (!_failedDisConnectAlertView) {
        _failedConnectAlertView = [[UIAlertView alloc] initWithTitle:@"断开连接失败"
                                                             message:@"关闭服务不成功"
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:@"确定", nil];
    }
    return _failedDisConnectAlertView;
}


#pragma mark - HUD

- (void)showHUDWithText:(NSString *)text {
    _hud = [MBProgressHUD showHUDAddedTo:self.homeView animated:YES];
    _hud.labelText = text;
    
    UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
    UIImageView *checkmarkView = [[UIImageView alloc] initWithImage:image];
    _hud.customView = checkmarkView;
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.homeView animated:YES];
}


#pragma mark - Connect / Disconnect

// 连接服务器
- (void)connectToHost {
    
    [self showHUDWithText:@"连接中..."];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.client connectToHost:_hostAddress completionHandler:^(MQTTConnectionReturnCode code) {
            if (code == ConnectionAccepted) {
                // 更新 UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.homeView.hostIP.text = _ipTextField.text;
                    
                    // 转换为 CustomView 模式
                    _hud.mode = MBProgressHUDModeCustomView;
                    _hud.labelText = @"连接成功";
                    sleep(2);
                    [self hideHUD];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHUD];
                    [self.homeView.switchButton setOn:NO animated:YES];
                    [self.failedConnectAlertView show];
                });
            }
        }];

    });
    
}

// 断开服务器连接
- (void)disConnectToHost {
    
    [self showHUDWithText:@"断开连接中..."];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.client disconnectWithCompletionHandler:^(NSUInteger code) {
            if (code == ConnectionAccepted) {
                // 更新 UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.homeView.hostIP.text = @"——";
                    
                    // 转换为 CustomView 模式
                    _hud.mode = MBProgressHUDModeCustomView;
                    _hud.labelText = @"断开连接成功";
                    sleep(2);
                    [self hideHUD];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHUD];
                    [self.homeView.switchButton setOn:YES animated:YES];
                    [self.failedDisConnectAlertView show];
                });
            }
        }];
        
    });
}


#pragma mark - Actions
// 滑动开关动作
- (void)switchAction:(id)sender {
    UISwitch *switchButton = (UISwitch *)sender;
    
    if (switchButton.on == YES) {
        [self.configHostAlertView show];
    } else {
        [self.sureAlertView show];
    }
}

- (void)buttonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button == self.homeView.subscirbeButton) {
        SubscribeViewController *svc = [[SubscribeViewController alloc] init];
        [self.navigationController pushViewController:svc animated:YES];
    } else if (button == self.homeView.publishButton) {
        PublishViewController *pvc = [[PublishViewController alloc] init];
        [self.navigationController pushViewController:pvc animated:YES];
    } else if (button == self.homeView.historyButton) {
        HistoryViewController *hvc = [[HistoryViewController alloc] init];
        [self.navigationController pushViewController:hvc animated:YES];

    }
    
}


#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; // 键盘隐藏
    
    return YES;
}


#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.configHostAlertView) {
        
        switch (buttonIndex) {
            // 点击取消，则不开启服务
            case 0:
                [self.homeView.switchButton setOn:NO animated:YES];
                self.homeView.hostIP.text = @"——";
                break;
            // 点击确定，则尝试连接服务器
            case 1:
                _hostAddress = _ipTextField.text;
                [self connectToHost];
                break;
                
        }

    } else if (alertView == self.sureAlertView) {
        
        switch (buttonIndex) {
            // 点击取消，则不关闭服务
            case 0:
                [self.homeView.switchButton setOn:YES animated:YES];
                break;
            // 点击确定，则尝试断开服务器连接
            case 1:
                [self disConnectToHost];
                break;
                
        }
        
    } else if (alertView == self.failedConnectAlertView) {
        
    }
    
}




@end

