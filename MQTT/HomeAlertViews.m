//
//  HomeAlertViews.m
//  MQTT
//
//  Created by Mercy on 15/7/14.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "HomeAlertViews.h"

@implementation HomeAlertViews


- (UIAlertView *)configHostAlert {
    if (!_configHostAlert) {
        _configHostAlert = [[UIAlertView alloc] initWithTitle:@"请设置服务器IP"
                                                      message:nil
                                                     delegate:nil
                                            cancelButtonTitle:@"取消"
                                            otherButtonTitles:@"确定", nil];
        _configHostAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        // 取出 AlertView 的输入框
        _ipTextField = [_configHostAlert textFieldAtIndex:0];
        _ipTextField.clearsOnBeginEditing = YES;
        _ipTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _ipTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _ipTextField.returnKeyType = UIReturnKeyDone;
    }
    return _configHostAlert;
}

- (UIAlertView *)sureAlert {
    if (!_sureAlert) {
        _sureAlert = [[UIAlertView alloc] initWithTitle:@"确定要关闭服务吗"
                                                message:nil
                                               delegate:nil
                                      cancelButtonTitle:@"取消"
                                      otherButtonTitles:@"确定", nil];
    }
    return _sureAlert;
}

- (UIAlertView *)failedConnectAlert {
    if (!_failedConnectAlert) {
        _failedConnectAlert = [[UIAlertView alloc] initWithTitle:@"连接失败"
                                                         message:@"开启服务不成功"
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"确定", nil];
    }
    return _failedConnectAlert;
}

- (UIAlertView *)wrongAddressAlert {
    if (!_wrongAddressAlert) {
        _wrongAddressAlert = [[UIAlertView alloc] initWithTitle:@"连接失败"
                                                         message:@"请检查服务器地址后重试"
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"确定", nil];
    }
    return _wrongAddressAlert;
}


- (UIAlertView *)failedDisconnectAlert {
    if (!_failedDisconnectAlert) {
        _failedDisconnectAlert = [[UIAlertView alloc] initWithTitle:@"断开连接失败"
                                                            message:@"关闭服务不成功"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
    }
    return _failedDisconnectAlert;
}



@end
