//
//  HistoryTableViewCell.h
//  MQTT
//
//  Created by Mercy on 15/11/17.
//  Copyright © 2015年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


@end
