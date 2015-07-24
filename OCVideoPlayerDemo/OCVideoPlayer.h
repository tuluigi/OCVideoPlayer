//
//  OCVideoPlayer.h
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/16.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCVideoPlayerView.h"
#import "OCVidePlayerKit.h"
@interface OCVideoPlayer : NSObject

@property (nonatomic,strong,readonly) UIView *backgroundView;
@property (nonatomic,strong) OCVideoPlayerView *playerView;
@property (nonatomic,strong)NSMutableArray *contentURLArray;
@property (nonatomic,assign)OCVideoPlayerState videoPlayerState;
@property (nonatomic,assign)OCVideoPlayerControlEvent videoPlayerControlEnvent;


#pragma mark --init
-(instancetype)initWithContentUrls:(NSArray *)contentUrls;

#pragma mark - play
-(void)playVideoAtInde:(NSInteger)index;
-(void)playVideoWithContentUrl:(NSURL *)url;



- (void)play;
- (void)stop;
- (void)pause;
@end
