//
//  PublishViewController.m
//  MQTT
//
//  Created by Mercy on 15/7/13.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "PublishViewController.h"
#import "PublishView.h"

@interface PublishViewController() <UITextFieldDelegate>

@property (nonatomic, strong) PublishView *publishView;

@end

@implementation PublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发布消息";
    
    _publishView = [[PublishView alloc] initWithFrame:self.view.bounds];
    _publishView.topicTextField.delegate = self;
    [self.view addSubview:_publishView];
}






#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; // 键盘隐藏
    
    return YES;
}




@end
