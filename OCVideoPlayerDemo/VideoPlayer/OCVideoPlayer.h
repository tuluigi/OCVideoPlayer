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
#pragma mark - Notification


@class OCVideoPlayer;
@protocol OCVideoPlayerDelegate <NSObject>
@optional
#pragma mark -AVQueuePlayer
-(void)ocVidePlayer:(OCVideoPlayer *)videoPlayer willChangeState:(OCVideoPlayerState)state toState:(OCVideoPlayerState)toState userInfo:(NSDictionary *)userInfo;
-(void)ocVidePlayer:(OCVideoPlayer *)videoPlayer didStateChanged:(OCVideoPlayerState)state userInfo:(NSDictionary *)userInfo;
-(void)ocVidePlayer:(OCVideoPlayer *)videoPlayer didControlByEvent:(OCVideoPlayerControlEvent)event;

#pragma mark -AVPlayerItem
-(void)ocVideoPlayer:(OCVideoPlayer *)videoPlayer  didCurrentPlayerItemStatusChanged:(AVPlayerItem *)item;
-(void)ocVideoPlayer:(OCVideoPlayer *)videoPlayer  didFinishedPlayItemToEndTime:(AVPlayerItem *)item;
-(void)ocVideoPlayer:(OCVideoPlayer *)videoPlayer  didFailedPlayItemToEndTime:(AVPlayerItem *)item;
@end


@interface OCVideoPlayer : NSObject
/**
 *  playerView backgrouView, default is blackCorlor
 */
@property (nonatomic,strong,readonly) UIView *backgroundView;
@property (nonatomic,strong,readonly) OCVideoPlayerView *playerView;

@property (nonatomic,strong,readonly) AVQueuePlayer *avPlayer;

@property (nonatomic,strong,readonly) NSMutableArray *contentURLArray;


/**
 * can user kvo to observer ocvideoplayer state changed
 */
@property (nonatomic,assign,readonly) OCVideoPlayerState videoPlayerState;

@property(nonatomic,assign)BOOL enableFullScreen;
@property(nonatomic,weak)id<OCVideoPlayerDelegate>delegate;
#pragma mark --init
-(instancetype)initWithContentUrls:(NSArray *)contentUrls;

#pragma mark - play
-(void)playVideoAtInde:(NSInteger)index;

-(void)insertContentURL:(NSURL *)url afterIndex:(NSInteger)index;
-(void)removeAtIndex:(NSInteger)index;
-(void)removeAllContents;

- (void)play;
- (void)pause;
@end


