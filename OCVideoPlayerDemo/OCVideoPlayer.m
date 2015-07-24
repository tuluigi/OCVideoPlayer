//
//  OCVideoPlayer.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/16.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "OCVideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "OCVideoPlayerControlView.h"
#import "Masonry.h"

@interface OCVideoPlayer ()<OCVideoPlayerViewDelegate>
@property(nonatomic,strong)AVQueuePlayer *avPlayer;
@property(nonatomic,strong)NSMutableArray *playerItemsArray;
@end

@implementation OCVideoPlayer
@synthesize contentURLArray=_contentURLArray;
-(void)dealloc{
    [self.avPlayer pause];
    [self.avPlayer removeObserver:self forKeyPath:@"statu" context:nil];
    [self.avPlayer removeObserver:self forKeyPath:@"rate" context:nil];
}
#pragma mark init
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
-(instancetype)init{
    self=[self initWithContentUrls:nil];
    return self;
}
#pragma mark --init
-(instancetype)initWithContentUrls:(NSArray *)contentUrls{
    if (self=[super init]) {
        self.videoPlayerState=OCVideoPlayerStateUnknown;
        self.contentURLArray=[NSMutableArray arrayWithArray:contentUrls];
        
        
        __weak OCVideoPlayer *weakSelf=self;
        _backgroundView=[[UIView alloc]  init];
        [self.playerView addSubview:_backgroundView];
        [self.playerView sendSubviewToBack:_backgroundView];
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.playerView );
        }];
        _backgroundView.backgroundColor=[UIColor blackColor];
        //MPMoviePlayerController
    }
    return self;
}
#pragma mark -reset
-(void)resetPlayer{
    [self.avPlayer pause];
    [self.avPlayer removeObserver:self forKeyPath:@"statu" context:nil];
    [self.avPlayer removeObserver:self forKeyPath:@"rate" context:nil];

}
#pragma mark - play
-(void)playVideoAtInde:(NSInteger)index{
    if (index<=self.playerItemsArray.count) {
         AVPlayerItem *item=[self.playerItemsArray objectAtIndex:index];
        if (self.avPlayer) {
            [self.avPlayer replaceCurrentItemWithPlayerItem:item];
        }else{
            self.avPlayer=[AVPlayer playerWithPlayerItem:item];
            /*
            [self.avPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
            [self.avPlayer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
              __weak OCVideoPlayer *weakSelf=self;
            [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
                NSTimeInterval  durationTime=CMTimeGetSeconds(time);
                
                NSTimeInterval currentTime=CMTimeGetSeconds(time);
            }];
             */
        }
        [self.playerView setAvPlayer:self.avPlayer];
    }
}
-(void)playVideoWithContentUrl:(NSURL *)url{
    NSInteger index=[self.contentURLArray indexOfObject:url];
    [self playVideoAtInde:index];
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object==self.avPlayer) {
        if ([keyPath isEqualToString:@"rate"]) {
   
        }else if ([keyPath isEqualToString:@"state"]){
            
        }
    }
}
#pragma mark -delegate
-(void)didOCVideoPlayerStateChanged:(OCVideoPlayerState)playerState{
    switch (playerState) {
        case OCVideoPlayerStatePlaying:{
            [self.avPlayer play];
        }break;
        case OCVideoPlayerStatePaused:{
            [self.avPlayer pause];
        }break;
        default:
            break;
    }
}

#pragma mark -getter and setter
-(OCVideoPlayerView *)playerView{
    if (nil==_playerView) {
        _playerView=[[OCVideoPlayerView alloc]  init];
        _playerView.delegate=self;
    }
    return _playerView;
}

-(NSMutableArray *)playerItemsArray{
    if (nil==_playerItemsArray) {
        _playerItemsArray=[NSMutableArray new];
    }
    return _playerItemsArray;
}
-(NSMutableArray *)contentURLArray{
    return _contentURLArray;
}
-(void)setContentURLArray:(NSMutableArray *)contentURLArray{
    _contentURLArray=contentURLArray;
    for (NSURL *url in _contentURLArray) {
        AVPlayerItem *item=[[AVPlayerItem alloc]  initWithURL:url];
        [self.playerItemsArray addObject:item];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
