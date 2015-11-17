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
#import "AppDelegate.h"
#import "Message.h"

@interface PublishViewController() <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) PublishView *publishView;
@property (nonatomic, strong) UIAlertView *failedPublishAlert;
@property (nonatomic, strong) MBProgressHUD *hud; // 提示框

@property (nonatomic, strong) MQTTClient *client; // 客户端对象
@property (nonatomic, assign) NSString *serviceState; // 服务开启状态

@property (nonatomic, strong) NSManagedObjectContext *context; // Core Data 上下文

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
// 发布消息
- (void)publishMessage:(NSString *)content toTopic:(NSString *)topic {
    [self showHUDWithText:@"发布中..."];
    
    // 创建定时器，控制请求时长
    NSTimer *publishTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(publishTimeoutAction) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:publishTimer forMode:NSDefaultRunLoopMode];
    
    __weak typeof(self) sf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_client publishString:content
                        toTopic:topic
                        withQos:AtMostOnce
                        retain:NO
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

- (void)publishButtonAction:(id)sender {
    if ([_serviceState isEqualToString:@"Service_ON"]) {
        
        NSString *topic = _publishView.topicTextField.text;
        NSString *content = _publishView.contentText.text;
        [self publishMessage:content toTopic:topic];
        
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
// 键盘隐藏
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


@end
