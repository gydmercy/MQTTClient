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
#import "HomeAlertViews.h"
#import "SubscribeViewController.h"
#import "PublishViewController.h"
#import "HistoryViewController.h"
#import "AppDelegate.h"
#import "Message.h"


@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView; //!< TableView
@property (nonatomic, strong) UISwitch *switchButton; //!< 服务开启按钮
@property (nonatomic, strong) HomeAlertViews *homeAlertView; //!< 相关AlertView
@property (nonatomic, strong) MBProgressHUD *hud; //!< 提示框

@property (nonatomic, strong) MQTTClient *client; //!< 客户端对象
@property (nonatomic, strong) NSString *hostAddress; //!< 服务器IP地址
@property (nonatomic, assign) NSString *serviceState; //!< 服务开启状态

@property (nonatomic, strong) NSManagedObjectContext *context; //!< Core Data 上下文

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

    [self initHomeAlert];
    [self initTableView];
    
    [self setupMessageHandler];
    
    // 默认服务是关闭状态
    _serviceState = @"Service_Off";
    // 默认服务器IP地址为空
    _hostAddress = @"无";
    
}


#pragma mark - Initialization

- (UISwitch *)switchButton {
    if (!_switchButton) {
        _switchButton = [[UISwitch alloc] init];
        _switchButton.on = NO;
        [_switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchButton;
}

- (void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [self.view addSubview:_tableView];
}

- (void)initHomeAlert {
    _homeAlertView = [[HomeAlertViews alloc] init];
    _homeAlertView.configHostAlert.delegate = self;
    _homeAlertView.sureAlert.delegate = self;
    _homeAlertView.ipTextField.delegate = self;
}

// 获得 NSManagedObjectContext 对象
- (NSManagedObjectContext *)context {
    if (!_context) {
        AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
        _context = appdelegate.managedObjectContext;
    }
    return _context;
}


#pragma mark - HUD

- (void)showHUDWithText:(NSString *)text {
    _hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    _hud.labelText = text;
    
    UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
    UIImageView *checkmarkView = [[UIImageView alloc] initWithImage:image];
    _hud.customView = checkmarkView;
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.view.window animated:YES];
}


#pragma mark - Client & MessageHandler

// 获取客户端对象
- (MQTTClient *)client {
    if (!_client) {
        NSString *clientID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
//        NSLog(@"%@", clientID);
        _client = [[MQTTClient alloc] initWithClientId:clientID];
    }
    return _client;
}

// 设置消息处理
- (void)setupMessageHandler {
    
    __weak typeof(self) sf = self;
    [self.client setMessageHandler:^(MQTTMessage *message) {
        NSString *content = message.payloadString;
//        NSLog(@"text --->> %@",content);
        
        // 存入数据库
        [sf addMessageToDBWithContent:content];
        
        
        UIAlertView *messageReceivedAlert = [[UIAlertView alloc] initWithTitle:@"接收到新消息"
                                                                       message:content
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
                    
                    // 显示服务器IP
                    NSIndexPath *addressIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                    [_tableView reloadRowsAtIndexPaths:@[addressIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                    // 转换为 CustomView 模式
                    _hud.mode = MBProgressHUDModeCustomView;
                    _hud.labelText = @"连接成功";
                    sleep(1);
                    [self hideHUD];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHUD];
                    [self.switchButton setOn:NO animated:YES];
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
                    
                    // 重置服务器IP
                    _hostAddress = @"无";
                    NSIndexPath *addressIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                    [_tableView reloadRowsAtIndexPaths:@[addressIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                    //转换为 CustomView 模式
                    _hud.mode = MBProgressHUDModeCustomView;
                    _hud.labelText = @"断开连接成功";
                    sleep(1);
                    [self hideHUD];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHUD];
                    [self.switchButton setOn:YES animated:YES];
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

// 连接服务器超时触发动作
- (void)connectTimeoutAction {
    [self hideHUD];
    [self.switchButton setOn:NO animated:YES];
    [_homeAlertView.wrongAddressAlert show];
}

// 断开服务器超时触发动作
- (void)disconnectTimeoutAction {
    [self hideHUD];
    [self.switchButton setOn:YES animated:YES];
    [_homeAlertView.failedDisconnectAlert show];
}


#pragma mark - Core Data

- (void)addMessageToDBWithContent:(NSString *)content {
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.context];
    
    message.content = content;
    message.date = [NSDate date];
    message.type = @"接收";
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"存储消息错误，ERROR：%@",error);
    }
    
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
                [self.switchButton setOn:NO animated:YES];
                _hostAddress = @"无";
                break;
            // 点击确定，则尝试连接服务器
            case 1:
                // 隐藏键盘
                [[alertView textFieldAtIndex:0] resignFirstResponder];
                
                _hostAddress = _homeAlertView.ipTextField.text;
                
                // 确保填写的IP非空才连接
                if ([_hostAddress isEqualToString:@""]) {
                    [self.switchButton setOn:NO animated:YES];
                    _hostAddress = @"无";
                } else {
                    [self connectToHost];
                }
                
                break;
                
        }

    } else if (alertView == _homeAlertView.sureAlert) {
        
        switch (buttonIndex) {
            // 点击取消，则不关闭服务
            case 0:
                [self.switchButton setOn:YES animated:YES];
                break;
            // 点击确定，则尝试断开服务器连接
            case 1:
                [self disconnectToHost];
                break;
                
        }
        
    } 
    
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 2;
    } else {
        return 1;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section0_Cell"];
        cell.accessoryView = self.switchButton;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"开启服务";
        
    } else if (indexPath.section == 1) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Section1_Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"服务器IP：";
        cell.detailTextLabel.text = _hostAddress;
        
    } else if (indexPath.section == 2) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section2_Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"主题订阅";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"发布消息";
        }
        
    } else if (indexPath.section == 3) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Section3_Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.text = @"历史消息";
    }
    
    return cell;
}


#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 界面跳转
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            
            SubscribeViewController *svc = [[SubscribeViewController alloc] init];
            [self.navigationController pushViewController:svc animated:YES];
            // 传值
            [svc setValue:_serviceState forKey:@"serviceState"];
            [svc setValue:self.client forKey:@"client"];
            
        } else if (indexPath.row == 1) {
            
//            PublishViewController *pvc = [[PublishViewController alloc] init];
            PublishViewController *pvc = [[PublishViewController alloc] initWithNibName:@"PublishView" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:pvc animated:YES];
            // 传值
            [pvc setValue:_serviceState forKey:@"serviceState"];
            [pvc setValue:self.client forKey:@"client"];
            
        }
    } else if (indexPath.section == 3) {
        HistoryViewController *hvc = [[HistoryViewController alloc] init];
        [self.navigationController pushViewController:hvc animated:YES];
    }
    
    // 取消选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

