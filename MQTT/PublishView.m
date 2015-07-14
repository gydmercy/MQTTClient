//
//  PublishView.m
//  MQTT
//
//  Created by Mercy on 15/7/14.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "PublishView.h"

@implementation PublishView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 设置背景色
        self.backgroundColor = [UIColor colorWithRed:235.0 / 255 green:235.0 / 255 blue:235.0 / 255 alpha:1.0];
        
        UILabel *topicLabel;
        topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 94, 80, 30)];
        topicLabel.text = @"主题:";
        [self addSubview:topicLabel];
        
        // 服务器IP地址Label
        _topicTextField = [[UITextField alloc] initWithFrame:CGRectMake(90, 94, 240, 30)];
        _topicTextField.placeholder = @" 请输入主题";
        _topicTextField.clearsOnBeginEditing = YES;
        _topicTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _topicTextField.returnKeyType = UIReturnKeyDone;
        _topicTextField.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:_topicTextField];
    }
    return self;
}

@end
