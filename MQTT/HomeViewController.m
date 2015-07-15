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
#import "HomeAlertViews.h"
#import "SubscribeViewController.h"
#import "PublishViewController.h"
#import "HistoryViewController.h"


@interface HomeViewController () <UITextFieldDelegate, UIAlertViewDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) HomeView *homeView; // 主界面View
@property (nonatomic, strong) HomeAlertViews *homeAlertView; // 相关AlertView
@property (nonatomic, strong) MBProgressHUD *hud; // 提示框

@property (nonatomic, strong) MQTTClient *client; // 客户端对象
@property (nonatomic, strong) NSString *hostAddress; // 服务器IP地址
@property (nonatomic, assign) NSString *serviceState; // 服务开启状态

@end

@implementation HomeViewController


#pragma mark - Lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"MQTT客户端";
    // 设置子ViewController页面的返回按钮显示“返回”
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;

    [self initHomeView];
    [self initHomeAlert];
    
    [self setupMessageHandler];
    
    // 默认服务是关闭状态
    _serviceState = @"Service_Off";
    
    
}


#pragma mark - Initialization

- (void)initHomeView {
    _homeView = [[HomeView alloc] initWithFrame:self.view.bounds];
    [_homeView.switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [_homeView.subscirbeButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_homeView.publishButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_homeView.historyButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_homeView];
}

- (void)initHomeAlert {
    _homeAlertView = [[HomeAlertViews alloc] init];
    _homeAlertView.configHostAlert.delegate = self;
    _homeAlertView.sureAlert.delegate = self;
    _homeAlertView.ipTextField.delegate = self;
}


#pragma mark - HUD

- (void)showHUDWithText:(NSString *)text {
    _hud = [MBProgressHUD showHUDAddedTo:_homeView animated:YES];
    _hud.labelText = text;
    
    UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
    UIImageView *checkmarkView = [[UIImageView alloc] initWithImage:image];
    _hud.customView = checkmarkView;
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:_homeView animated:YES];
}


#pragma mark - Client & MessageHandler

// 获取客户端对象
- (MQTTClient *)client {
    if (!_client) {
        NSString *clientID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        _client = [[MQTTClient alloc] initWithClientId:clientID];
    }
    return _client;
}

// 设置消息处理
- (void)setupMessageHandler {
    
    [self.client setMessageHandler:^(MQTTMessage *message) {
        NSString *text = message.payloadString;
//        NSLog(@"text --->> %@",text);
        
        UIAlertView *messageReceivedAlert = [[UIAlertView alloc] initWithTitle:@"接收到新消息"
                                                                       message:text
                                                                      delegate:nil
                                                             cancelButtonTitle:nil
                                                             otherButtonTitles:@"确定", nil];
        // 主线程弹框
        dispatch_async(dispatch_get_main_queue(), ^{
            [messageReceivedAlert show];
        });
        
    }];
}


#pragma mark - Connect / Disconnect

// 连接服务器
- (void)connectToHost {
    
    [self showHUDWithText:@"连接中..."];
    
    // 创建定时器，控制请求时长
    NSTimer *connectTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(connectTimeoutAction) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:connectTimer forMode:NSDefaultRunLoopMode];
    
    // 异步连接服务器
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.client connectToHost:_hostAddress completionHandler:^(MQTTConnectionReturnCode code) {
            // 连接成功
            if (code == ConnectionAccepted) {
                
                // 清空已订阅列表
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"subscribedTopics"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                _serviceState = @"Service_ON";
                
                // 更新 UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 移除定时器
                    [connectTimer invalidate];
                    
                    _homeView.hostIP.text = _homeAlertView.ipTextField.text;
                    
                    // 转换为 CustomView 模式
                    _hud.mode = MBProgressHUDModeCustomView;
                    _hud.labelText = @"连接成功";
                    sleep(1);
                    [self hideHUD];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHUD];
                    [_homeView.switchButton setOn:NO animated:YES];
                    [_homeAlertView.failedConnectAlert show];
                });
            }
        }];

    });
    
}

// 断开服务器连接
- (void)disconnectToHost {
    
    [self showHUDWithText:@"断开连接中..."];
    
    // 创建定时器，控制请求时长
    NSTimer *disconnectTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(disconnectTimeoutAction) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:disconnectTimer forMode:NSDefaultRunLoopMode];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.client disconnectWithCompletionHandler:^(NSUInteger code) {
            if (code == ConnectionAccepted) {
                
                // 清空已订阅列表
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"subscribedTopics"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                _serviceState = @"Service_Off";
                
                // 更新 UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 移除定时器
                    [disconnectTimer invalidate];
                    
                    _homeView.hostIP.text = @"——";
                    
                    //转换为 CustomView 模式
                    _hud.mode = MBProgressHUDModeCustomView;
                    _hud.labelText = @"断开连接成功";
                    sleep(1);
                    [self hideHUD];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHUD];
                    [_homeView.switchButton setOn:YES animated:YES];
                    [_homeAlertView.failedDisconnectAlert show];
                });
            }
        }];
        
    });
}


#pragma mark - Actions
// 滑动开关触发动作
- (void)switchAction:(id)sender {
    UISwitch *switchButton = (UISwitch *)sender;
    
    if (switchButton.on == YES) {
        [_homeAlertView.configHostAlert show];
    } else {
        [_homeAlertView.sureAlert show];
    }
}

// 相关按钮触发动作
- (void)buttonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button == self.homeView.subscirbeButton) {
        SubscribeViewController *svc = [[SubscribeViewController alloc] init];
        // 传值
        [svc setValue:_serviceState forKey:@"serviceState"];
        [svc setValue:self.client forKey:@"client"];
        [self.navigationController pushViewController:svc animated:YES];
    } else if (button == self.homeView.publishButton) {
        PublishViewController *pvc = [[PublishViewController alloc] init];
        // 传值
        [pvc setValue:_serviceState forKey:@"serviceState"];
        [pvc setValue:self.client forKey:@"client"];
        [self.navigationController pushViewController:pvc animated:YES];
    } else if (button == self.homeView.historyButton) {
        HistoryViewController *hvc = [[HistoryViewController alloc] init];
        [self.navigationController pushViewController:hvc animated:YES];

    }
    
}

// 连接服务器超时触发动作
- (void)connectTimeoutAction {
    [self hideHUD];
    [_homeView.switchButton setOn:NO animated:YES];
    [_homeAlertView.wrongAddressAlert show];
}

// 断开服务器超时触发动作
- (void)disconnectTimeoutAction {
    [self hideHUD];
    [_homeView.switchButton setOn:YES animated:YES];
    [_homeAlertView.failedDisconnectAlert show];
}


#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; // 键盘隐藏
    
    return YES;
}


#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == _homeAlertView.configHostAlert) {
        
        switch (buttonIndex) {
            // 点击取消，则不开启服务
            case 0:
                [_homeView.switchButton setOn:NO animated:YES];
                _homeView.hostIP.text = @"——";
                break;
            // 点击确定，则尝试连接服务器
            case 1:
                _hostAddress = _homeAlertView.ipTextField.text;
                [self connectToHost];
                break;
                
        }

    } else if (alertView == _homeAlertView.sureAlert) {
        
        switch (buttonIndex) {
            // 点击取消，则不关闭服务
            case 0:
                [_homeView.switchButton setOn:YES animated:YES];
                break;
            // 点击确定，则尝试断开服务器连接
            case 1:
                [self disconnectToHost];
                break;
                
        }
        
    } 
    
}




@end

