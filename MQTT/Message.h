//
//  Message.h
//  MQTT
//
//  Created by Mercy on 15/7/16.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *type;

@end
