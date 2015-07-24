//
//  UIImage+OCVideoPlayer.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/22.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "UIImage+OCVideoPlayer.h"

@implementation UIImage (OCVideoPlayer)
+(UIImage *)ocv_imageNamed:(NSString *)aImageName{
    NSString *imageName=[@"OCPlayer.bundle/" stringByAppendingString:aImageName];
    return [UIImage imageNamed:imageName];
}
@end
