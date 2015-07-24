//
//  NSString+OCPlayer.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/22.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "NSString+OCPlayer.h"

@implementation NSString (OCPlayer)
-(NSString *)ocVideoImageName{
    if (self) {
          NSString *imageName=[@"OCPlayer.bundle/" stringByAppendingString:self];
        return imageName;
    }
    return @"";
}
@end
