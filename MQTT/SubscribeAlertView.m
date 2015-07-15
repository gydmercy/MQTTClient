//
//  SubscribeAlertView.m
//  MQTT
//
//  Created by Mercy on 15/7/14.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "SubscribeAlertView.h"

@implementation SubscribeAlertView

- (UIAlertView *)addTopicAlert {
    if (!_addTopicAlert) {
        _addTopicAlert = [[UIAlertView alloc] initWithTitle:@"请输入要添加的主题"
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
        _addTopicAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        // 取出 AlertView 的输入框
        _topicTextField = [_addTopicAlert textFieldAtIndex:0];
        _topicTextField.clearsOnBeginEditing = YES;
        _topicTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _topicTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _topicTextField.returnKeyType = UIReturnKeyDone;
    }
    
    return _addTopicAlert;
}

- (UIAlertView *)failedToDoAlert {
    if (!_failedToDoAlert) {
        _failedToDoAlert = [[UIAlertView alloc] initWithTitle:@"请先开启服务"
                                                     message:nil
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"确定", nil];
    }
    return _failedToDoAlert;
}

- (UIAlertView *)failedSubscribeAlert {
    if (!_failedSubscribeAlert) {
        _failedSubscribeAlert = [[UIAlertView alloc] initWithTitle:@"订阅失败"
                                                           message:nil
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"确定", nil];
    }
    return _failedSubscribeAlert;
}

-(UIAlertView *)failedUnsubscribeAlert {
    if (!_failedUnsubscribeAlert) {
        _failedUnsubscribeAlert = [[UIAlertView alloc] initWithTitle:@"取消订阅失败"
                                                           message:nil
                                                          delegate:nil
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"确定", nil];
    }
    return _failedUnsubscribeAlert;
}


@end
