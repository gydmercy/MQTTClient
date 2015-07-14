//
//  SubscribeViewController.m
//  MQTT
//
//  Created by Mercy on 15/7/13.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "SubscribeViewController.h"
#import "CustomNavigationController.h"
#import "MBProgressHUD.h"
#import "MQTTKit.h"

@interface SubscribeViewController() <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD *hud; // 提示框
@property (nonatomic, strong) UIAlertView *addTopicAlert; // 用来输入要添加的主题
@property (nonatomic, strong) UIAlertView *failedAddAlert; // 提示用户要先开启服务
@property (nonatomic, strong) UIAlertView *failedSubscribeAlert; // 提示用户订阅失败
@property (nonatomic, strong) UITextField *topicTextField; // addTopicAlert中填写主题名称的TextField

@property (nonatomic, strong) MQTTClient *client; // 客户端对象
@property (nonatomic, strong) NSString *topic; // 当前订阅的主题
@property (nonatomic, strong) NSMutableArray *topicArray; // 可变已订阅主题
@property (nonatomic, strong) NSArray *savedTopicArray; // 持久化已订阅主题

@property (nonatomic, assign) NSString *serviceState; // 服务开启状态
@end

@implementation SubscribeViewController

// cell 标识符
static NSString *const cellIdentifer = @"cellIdentifier";


#pragma mark - Lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"已订主题";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddTopicAlert:)];
    
    self.savedTopicArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscribedTopics"];
    self.topicArray = [self.savedTopicArray mutableCopy];
    [self initTableView];
    
}


#pragma mark - Initialization

- (void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifer];
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
}

- (UIAlertView *)addTopicAlert {
    if (!_addTopicAlert) {
        _addTopicAlert = [[UIAlertView alloc] initWithTitle:@"请输入要添加的主题"
                                                    message:nil
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                           otherButtonTitles:@"确定", nil];
        _addTopicAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        // 取出 AlertView 的输入框
        _topicTextField = [_addTopicAlert textFieldAtIndex:0];
        _topicTextField.clearsOnBeginEditing = YES;
        _topicTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _topicTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _topicTextField.returnKeyType = UIReturnKeyDone;
        _topicTextField.delegate = self;
    }
    
    return _addTopicAlert;
}

- (UIAlertView *)failedAddAlert {
    if (!_failedAddAlert) {
        _failedAddAlert = [[UIAlertView alloc] initWithTitle:@"请先开启服务"
                                                     message:nil
                                                    delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"确定", nil];
    }
    return _failedAddAlert;
}

- (UIAlertView *)failedSubscribeAlert {
    if (!_failedSubscribeAlert) {
        _failedSubscribeAlert = [[UIAlertView alloc] initWithTitle:@"订阅失败"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"确定", nil];
    }
    return _failedSubscribeAlert;
}

- (NSMutableArray *)topicArray {
    if (!_topicArray) {
        _topicArray = [[NSMutableArray alloc] init];
    }
    
    return _topicArray;
}

- (NSArray *)savedTopicArray {
    if (!_savedTopicArray) {
        _savedTopicArray = [[NSArray alloc] init];
    }
    
    return _savedTopicArray;
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


#pragma mark - Subscribe / Unsubscribe

// 订阅某个主题
- (void)subscribeTopic {
    [self showHUDWithText:@"订阅中..."];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_client subscribe:_topic withCompletionHandler:^(NSArray *grantedQos){
            // 更新 UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addTopic];
                
                // 转换为 CustomView 模式
                _hud.mode = MBProgressHUDModeCustomView;
                _hud.labelText = @"连接成功";
                sleep(1);
                [self hideHUD];
            });
        }];
    });
}

// 取消订阅某个主题
- (void)unScribeTopic {
    
}

// 更新主题列表
- (void)addTopic {
    NSString *topic = _topic;
    
    [self.topicArray addObject:topic];
    self.savedTopicArray = [_topicArray mutableCopy];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.savedTopicArray forKey:@"subscribedTopics"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_tableView reloadData];
}


#pragma mark - Actions

- (void)showAddTopicAlert:(id)sender {
    if ([_serviceState isEqualToString:@"Service_ON"]) {
        [self.addTopicAlert show];
    } else {
        [self.failedAddAlert show];
    }
    
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.savedTopicArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscribedTopics"];
    return self.savedTopicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];
    
    self.savedTopicArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"subscribedTopics"];
    cell.textLabel.text = [self.savedTopicArray objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; // 键盘隐藏
    
    return YES;
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView == self.addTopicAlert) {
        
        switch (buttonIndex) {
            // 点击取消，则不增加主题
            case 0:
                break;
            // 点击确定，则尝试增加主题
            case 1:
                _topic = _topicTextField.text;
                [self subscribeTopic];
                break;
                
        }
        
    }
}


@end
