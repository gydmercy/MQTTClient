//
//  HistoryTableViewCell.h
//  MQTT
//
//  Created by Mercy on 15/7/16.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *typeLabel; // 消息类型：发布/接收
@property (nonatomic, strong) UILabel *dateLabel; // 时间
@property (nonatomic, strong) UILabel *contentLabel; // 消息内容

@end
