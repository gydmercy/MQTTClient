//
//  HomeView.m
//  MQTT
//
//  Created by Mercy on 15/7/13.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "HomeView.h"

@interface HomeView()

@end

@implementation HomeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        
        // 开启服务底部View
        UIView *startView = [[UIView alloc] initWithFrame:CGRectMake(0, 84, self.frame.size.width, 50)];
        startView.backgroundColor = [UIColor whiteColor];
        [self addSubview:startView];
        
        // 开启服务Label
        UILabel *startLabel;startLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 94, 80, 30)];
        startLabel.text = @"开启服务:";
        [self addSubview:startLabel];
        
        // 开启服务Switch
        _switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(300, 94, 20, 10)];
        _switchButton.on = NO;
        [self addSubview:_switchButton];
        
        
        // IP地址底部View
        UIView *ipView = [[UIView alloc] initWithFrame:CGRectMake(0, 154, self.frame.size.width, 50)];
        ipView.backgroundColor = [UIColor whiteColor];
        [self addSubview:ipView];
        
        // IP地址Label
        UILabel *ipLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 164, 80, 30)];
        ipLabel.text = @"服务器IP:";
        [self addSubview:ipLabel];
        
        // 服务器IP地址Label
        _hostIP = [[UILabel alloc] initWithFrame:CGRectMake(140, 164, 210, 30)];
        _hostIP.textAlignment = NSTextAlignmentRight;
        _hostIP.text = @"——";
        [self addSubview:_hostIP];
        
        
        // 主题订阅Button
        _subscirbeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 224, self.frame.size.width, 50)];
        _subscirbeButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:_subscirbeButton];
        
        // 主题订阅的Label
        UILabel *subscribeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 234, 80, 30)];
        subscribeLabel.text = @"主题订阅";
        [self addSubview:subscribeLabel];
        
        // 小箭头
        UIImageView *subscribeIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicatorArrow"]];
        subscribeIndicator.frame = CGRectMake(340, 242, 10, 15);
        [self addSubview:subscribeIndicator];
        
        
        // 分割线
        UIView *partitionLine = [[UIView alloc] initWithFrame:CGRectMake(0, 274, self.frame.size.width, 0.3f)];
        partitionLine.backgroundColor = [UIColor colorWithRed:218.0f / 255.0 green:218.0f / 255.0 blue:218.0f / 255.0 alpha:1];
        [self addSubview:partitionLine];
        
        
        // 发布消息的Button
        _publishButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 275, self.frame.size.width, 50)];
        _publishButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:_publishButton];
        
        // 发布消息的Label
        UILabel *publishLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 285, 80, 30)];
        publishLabel.text = @"发布消息";
        [self addSubview:publishLabel];
        
        // 小箭头
        UIImageView *publishIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicatorArrow"]];
        publishIndicator.frame = CGRectMake(340, 293, 10, 15);
        [self addSubview:publishIndicator];
        
        
        // 查看历史记录的Button
        _historyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 345, self.frame.size.width, 50)];
        _historyButton.backgroundColor = [UIColor whiteColor];
//        _historyButton.showsTouchWhenHighlighted = YES;
        [self addSubview:_historyButton];
        
        // 查看历史消息的Label
        UILabel *historyLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 355, 80, 30)];
        historyLabel.text = @"历史消息";
        [self addSubview:historyLabel];
        
        // 小箭头
        UIImageView *historyIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicatorArrow"]];
        historyIndicator.frame = CGRectMake(340, 363, 10, 15);
        [self addSubview:historyIndicator];

    }
    
    return self;
}


@end
