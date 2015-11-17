//
//  NSLayoutConstraintOnePixelLine.m
//  MQTT
//
//  Created by Mercy on 15/11/17.
//  Copyright © 2015年 Mercy. All rights reserved.
//

#import "NSLayoutConstraintOnePixelLine.h"

@implementation NSLayoutConstraintOnePixelLine

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.constant == 1) {
        self.constant = 1 / [UIScreen mainScreen].scale;
    }
}

@end
