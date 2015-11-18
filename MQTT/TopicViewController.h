//
//  TopicViewController.h
//  MQTT
//
//  Created by Mercy on 15/11/18.
//  Copyright © 2015年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicViewController : UIViewController

typedef void (^PassTopicBlock)(NSString *string);
@property (nonatomic, strong) PassTopicBlock passTopicBlock; //!< 用来传递 主题

@end
