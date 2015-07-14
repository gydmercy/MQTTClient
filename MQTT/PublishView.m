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
        
        // 主题的Label
        UILabel *topicLabel;
        topicLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 94, 80, 30)];
        topicLabel.text = @"主题:";
        [self addSubview:topicLabel];
        
        // 主题的TextField
        _topicTextField = [[UITextField alloc] initWithFrame:CGRectMake(96, 94, 240, 30)];
        _topicTextField.placeholder = @" 请输入主题";
        _topicTextField.clearsOnBeginEditing = YES;
        _topicTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _topicTextField.returnKeyType = UIReturnKeyDone;
        _topicTextField.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:_topicTextField];
        
        // 内容的Label
        UILabel *contentLabel;
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 144, 80, 30)];
        contentLabel.text = @"内容:";
        [self addSubview:contentLabel];
        
        // 内容输入的TextView
        _contentText = [[UITextView alloc] initWithFrame:CGRectMake(37, 184, 300, 350)];
        _contentText.center = CGPointMake(self.center.x, _contentText.center.y);
        _contentText.backgroundColor = [UIColor whiteColor];
        _contentText.font = [UIFont systemFontOfSize:16];
        [self addSubview:_contentText];
    
    }
    return self;
}

@end
