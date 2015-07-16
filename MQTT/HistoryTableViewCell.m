//
//  HistoryTableViewCell.m
//  MQTT
//
//  Created by Mercy on 15/7/16.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "HistoryTableViewCell.h"

@implementation HistoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 50, 20)];
        _typeLabel.font = [UIFont systemFontOfSize:16];
        _typeLabel.textColor = [UIColor colorWithRed:100.0 / 255 green:100.0 / 255 blue:100.0 / 255 alpha:1.0];
        [self.contentView addSubview:_typeLabel];
        
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 5, 160, 20)];
        _dateLabel.font = [UIFont systemFontOfSize:16];
        _dateLabel.textColor = [UIColor colorWithRed:100.0 / 255 green:100.0 / 255 blue:100.0 / 255 alpha:1.0];
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:_dateLabel];
        
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, 335, 20)];
        _contentLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_contentLabel];
        
        
    }
    return self;
}

@end
