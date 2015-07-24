//
//  OCVideoPlayerView.h
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/22.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "OCVidePlayerKit.h"
@protocol OCVideoPlayerViewDelegate <NSObject>

-(void)didOCVideoPlayerStateChanged:(OCVideoPlayerState)playerState;

@end

@interface OCVideoPlayerView : UIView
@property (nonatomic,assign)OCVideoPlayerState videoPlayerState;
@property (nonatomic,assign)OCVideoPlayerControlEvent videoPlayerControlEnvent;
@property(nonatomic,weak)id<OCVideoPlayerViewDelegate>delegate;
- (void)setAvPlayer:(AVPlayer *)avPlayer;
@end
