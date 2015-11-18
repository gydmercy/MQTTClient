//
//  PublishViewController.m
//  MQTT
//
//  Created by Mercy on 15/7/13.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "PublishViewController.h"
#import "TopicViewController.h"
#import "MBProgressHUD.h"
#import "MQTTKit.h"
#import "AppDelegate.h"
#import "Message.h"

@interface PublishViewController() <UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>


@property (nonatomic, strong) UIAlertView *failedPublishAlert;
@property (nonatomic, strong) MBProgressHUD *hud; //!< 提示框

@property (nonatomic, strong) MQTTClient *client; //!< 客户端对象
@property (nonatomic, assign) NSString *serviceState; //!< 服务开启状态

@property (nonatomic, strong) NSManagedObjectContext *context; //!< Core Data 上下文

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView; //!< 输入发布内容的文本框
@property (nonatomic, strong) UISwitch *retainSwitch; //!< 选择消息是否 Retain

@property (nonatomic, strong) NSString *topic; //!< 发布到的主题
@property (nonatomic, strong) NSString *content; //!< 发布的内容
@property (nonatomic, assign) BOOL isRetain; //!< 是否Retain
@property (nonatomic ,assign) MQTTQualityOfService QoS; //!< 发布消息的QoS



@end

@implementation PublishViewController


#pragma mark - Lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发布消息";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(publishButtonAction:)];
    
    [self addNotificationObserver];
    
    [self initTableView];

    // 发布消息选项默认值
    self.topic = @"";
    self.isRetain = NO;
    self.QoS = AtMostOnce;
    
}

- (void)dealloc {
    // 对象销毁前移除 Notification 监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Initialization

- (void)initTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}


- (UISwitch *)retainSwitch {
    if (!_retainSwitch) {
        _retainSwitch = [[UISwitch alloc] init];
        _retainSwitch.on = self.isRetain;
        [_retainSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _retainSwitch;
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
    _hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    _hud.labelText = text;
    
    UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
    UIImageView *checkmarkView = [[UIImageView alloc] initWithImage:image];
    _hud.customView = checkmarkView;
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
}


#pragma mark - Publish
// 发布消息
- (void)publishMessage:(NSString *)content toTopic:(NSString *)topic withQos:(MQTTQualityOfService)QoS retain:(BOOL)isRetain {
    
    [self showHUDWithText:@"发布中..."];
    
    // 创建定时器，控制请求时长
    NSTimer *publishTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(publishTimeoutAction) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:publishTimer forMode:NSDefaultRunLoopMode];
    
    __weak typeof(self) sf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_client publishString:content
                       toTopic:topic
                       withQos:QoS
                        retain:isRetain
             completionHandler:^(int mid){
                 // 移除定时器
                 [publishTimer invalidate];
                 
                 // 存入数据库
                 [sf addMessageToDBWithContent:content];
                 
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

// 滑动开关触发动作
- (void)switchAction:(id)sender {
    UISwitch *switchButton = (UISwitch *)sender;

    if (switchButton.on == YES) {
        self.isRetain = YES;
    } else {
        self.isRetain = NO;
    }
}

- (void)publishButtonAction:(id)sender {
    
    [self.contentTextView resignFirstResponder];
    
    if ([_serviceState isEqualToString:@"Service_ON"]) {
        
        // 主题非空才可以发布消息
        if (![self.topic isEqualToString:@""]) {
            self.content = self.contentTextView.text;
            // 发布消息
            [self publishMessage:self.content toTopic:self.topic withQos:self.QoS retain:self.isRetain];
        }
        
    } else {
        [self.failedPublishAlert show];
    }
}


- (void)publishTimeoutAction {
    [self hideHUD];
    
    UIAlertView *failedPublish = [[UIAlertView alloc] initWithTitle:@"发布失败"
                                                            message:@"请检查网络后重试"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
    [failedPublish show];
}

- (void)keyboardWillShowAction:(NSNotification *)sender {
    NSValue *keyboardFrameValue = [sender.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue]; // 获得键盘的frame
    float keyboardHeight = keyboardFrame.size.height; // 获得键盘的高度
    
    // View 上移
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(0, - keyboardHeight, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
}

- (void)keyboardWillHideAction:(NSNotification *)sender {
    // View 返回原来的位置
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}


#pragma mark - Core Data

- (void)addMessageToDBWithContent:(NSString *)content {
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.context];
    
    message.content = content;
    message.date = [NSDate date];
    message.type = @"发布";
    
    NSError *error = nil;
    if (![self.context save:&error]) {
        NSLog(@"存储消息错误，ERROR：%@",error);
    }
    
}


#pragma mark - Others

// 添加 Notification 监听
- (void)addNotificationObserver {
    
    // 添加 Notificaiton 监听键盘弹出
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShowAction:)
                                                name:UIKeyboardWillShowNotification
                                              object:nil];
    // 添加 Notificaiton 监听键盘隐藏
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHideAction:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
}


// 特定行取消打钩
- (void)tableView:(UITableView *)tableView uncheckRowAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSIndexPath *indexPath = nil;
    for (indexPath in indexPaths) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}


#pragma mark - <UITextViewDelegate>

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Topic_Cell"];
        cell.textLabel.text = @"主题：";
        cell.detailTextLabel.text = self.topic;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else if (indexPath.section == 1) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Retain_Cell"];
        cell.textLabel.text = @"Retain";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = self.retainSwitch;
        
    } else if (indexPath.section == 2) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QoS_Cell"];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"QoS=0";
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                break;
            case 1:
                cell.textLabel.text = @"QoS=1";
                break;
            case 2:
                cell.textLabel.text = @"QoS=2";
                break;
            default:
                break;
        }
        
    }
    
    return cell;
}


#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 输入主题
    if (indexPath.section == 0) {
        TopicViewController *tvc = [[TopicViewController alloc] init];
        [self.navigationController pushViewController:tvc animated:YES];
        
        // 接收传递的“主题”值
        tvc.passTopicBlock = ^(NSString *string) {
            self.topic = string;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        };
    }
    // 选择 QoS 等级
    else if (indexPath.section == 2) {
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            // 选中当前行
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            // 取消打钩其他两行
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:1 inSection:indexPath.section];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:2 inSection:indexPath.section];
            [self tableView:tableView uncheckRowAtIndexPaths:@[indexPath1, indexPath2]];
            
            // 设置QoS
            self.QoS = AtMostOnce;
            
        } else if (indexPath.row == 1) {
            
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:2 inSection:indexPath.section];
            [self tableView:tableView uncheckRowAtIndexPaths:@[indexPath1, indexPath2]];
            
            self.QoS = AtLeastOnce;
            
        } else if (indexPath.row == 2) {
            
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:1 inSection:indexPath.section];
            [self tableView:tableView uncheckRowAtIndexPaths:@[indexPath1, indexPath2]];
            
            self.QoS = ExactlyOnce;
            
        }
    }
    
    // 取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
