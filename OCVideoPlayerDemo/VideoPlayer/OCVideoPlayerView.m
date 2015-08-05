//
//  OCVideoPlayerView.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/22.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "OCVideoPlayerView.h"
@interface OCVideoPlayerView ()
@end

@implementation OCVideoPlayerView

#pragma mark init
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

#pragma setter getter
- (void)setAvPlayer:(AVPlayer *)avPlayer{
    [(AVPlayerLayer *)[self layer] setPlayer:avPlayer];
}



@end
