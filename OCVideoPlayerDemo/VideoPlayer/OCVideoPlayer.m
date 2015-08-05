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
#import "OCVideoPlayerControlView.h"
#import "Masonry.h"
NSString * const OCVideoPlayerOrientationDidChangedNotification =@"OCVidePlayerOrientationDidChangedNotification";
NSString * const OCVideoPlayerStateChangedNotification          =@"OCVidePlayerStateChangedNotification";
NSString * const OCVideoPlayerItemStateChangedNotification      =@"OCVideoPlayerItemStateChangedNotification";
NSString * const OCVideoPlayerItemPlayToEndTimeNotification     =@"OCVideoPlayerItemPlayToEndTimeNotification";



NSString * const OCVideoPlayerItemUrlKey                        =@"OCVidePlayerItemUrlKey";
NSString * const OCVideoPlayerQueueItemsCountKey                =@"OCVideoPlayerQueueItemsCountKey";
NSString * const OCVideoPlayerStateKey                          =@"OCVidePlayerStateKey";
NSString * const OCVideoPlayerErrorKey                          =@"OCVideoPlayerErrorKey";



@interface OCVideoPlayer ()<OCVideoPlayerControlViewDelegate>
@property(nonatomic,strong,readwrite)AVQueuePlayer *avPlayer;
@property (nonatomic,strong,readwrite)NSMutableArray *contentURLArray;
@property (nonatomic,strong,readwrite) OCVideoPlayerView *playerView;
@property (nonatomic,strong) OCVideoPlayerControlView *playerControlView;
@property (nonatomic,assign,readwrite)OCVideoPlayerState videoPlayerState;
@property (nonatomic,strong)NSTimer *timer;
@end

@implementation OCVideoPlayer
@synthesize playerView=_playerView;
@synthesize contentURLArray=_contentURLArray;
#pragma mark init
-(void)dealloc{
    for (AVPlayerItem *item in self.avPlayer.items) {
        [self removeNotificationAndObserverWithAvPlayerItem:item];
    }
    [[self avPlayer] removeObserver:self forKeyPath:@"rate"];
    [[self avPlayer] removeTimeObserver:self];
    
    [self.timer invalidate];
    self.timer=nil;
    [self.avPlayer pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
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
        self.enableFullScreen=YES;
        self.videoPlayerState=OCVideoPlayerStateUnknown;
        self.contentURLArray=[NSMutableArray arrayWithArray:contentUrls];
        
        __weak OCVideoPlayer *weakSelf=self;
        self.avPlayer=[self avQueuePlayerWithUrls:self.contentURLArray fromIndex:0];
        
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.playerView );
        }];
        _backgroundView.backgroundColor=[UIColor blackColor];
        
        [self addNotification];
    }
    return self;
}
-(void)addNotificationAndObserverWithAvPlayerItem:(AVPlayerItem *)item{
    if (item) {
        __weak OCVideoPlayer *weakSelf=self;
        [[NSNotificationCenter defaultCenter]  addObserverForName:AVPlayerItemPlaybackStalledNotification object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            weakSelf.videoPlayerState=OCVideoPlayerStateStalled;
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemFailedToPlayToEndTimeNotification object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            weakSelf.videoPlayerState=OCVideoPlayerStateError;
            if (_delegate&&[_delegate respondsToSelector:@selector(ocVideoPlayer:didFailedPlayItemToEndTime:)]) {
                [_delegate ocVideoPlayer:weakSelf didFailedPlayItemToEndTime:[weakSelf currentPlayerItem]];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf advancedToPlayNextVideo];
        }];
        [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [item addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
}
-(void)removeNotificationAndObserverWithAvPlayerItem:(AVPlayerItem *)item{
    if (item) {
        [[NSNotificationCenter defaultCenter] removeObserver:item];
        [item removeObserver:self forKeyPath:@"status"];
        [item removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [item removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [item removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    }
}
-(void)addNotification{
    __weak OCVideoPlayer *weakSelf=self;
    [[NSNotificationCenter defaultCenter]  addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakSelf.videoPlayerState=OCVideoPlayerStatePaused;
    }];
    [[NSNotificationCenter defaultCenter]  addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakSelf.videoPlayerState=OCVideoPlayerStatePlaying;
    }];
    [[NSNotificationCenter defaultCenter]  addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        //UIDeviceOrientation orientation= [[UIDevice currentDevice] orientation];
        //[weakSelf resetUIWithDeviceOrientation:orientation];
    }];
    
}

#pragma mark -KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *currentItem=[[self avPlayer] currentItem];
    if (object==[self avPlayer]) {
        if ([keyPath isEqualToString:@"rate"]) {
            CGFloat rate=[[self avPlayer] rate];
            if (rate==1) {
                if (self.videoPlayerState!=OCVideoPlayerStatePlaying) {
                    self.videoPlayerState=OCVideoPlayerStatePlaying;
                }
            }else if(rate==0){
                
            }
        }else if ([keyPath isEqualToString:@"status"]){
            AVPlayerStatus status=[[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            if (status==AVPlayerStatusReadyToPlay) {
                self.videoPlayerState=OCVideoPlayerStateReadPlay;
            }else if (status==AVPlayerStatusFailed){
                self.videoPlayerState=OCVideoPlayerStateError;
            }else if (status==AVPlayerStatusUnknown){
                self.videoPlayerState=OCVideoPlayerStateUnknown;
            }
        }
    }else if (object==currentItem){
        if ([keyPath isEqualToString:@"loadedTimeRanges"]){
            NSArray *loadedTimeRanges = [currentItem loadedTimeRanges];
            CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
            NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
            NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
            NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
            [self.playerControlView updateTrackLoadedTime:timeInterval];
        }else if ([keyPath isEqualToString:@"status"]){
            if (currentItem.status==AVPlayerItemStatusReadyToPlay) {
                CGFloat duration=CMTimeGetSeconds(currentItem.duration);
                [self.playerControlView setTrackMinValue:0 maxVlaue:duration];
               
            }else if (currentItem.status==AVPlayerItemStatusFailed){
                self.videoPlayerState=OCVideoPlayerStateError;
            }else if (currentItem.status==AVPlayerItemStatusUnknown){
                self.videoPlayerState=OCVideoPlayerStateUnknown;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:OCVideoPlayerItemStateChangedNotification object:nil userInfo:@{OCVideoPlayerItemUrlKey:[self currentItemURL],OCVideoPlayerQueueItemsCountKey:@(self.avPlayer.items.count)}];
            if (_delegate&&[_delegate respondsToSelector:@selector(ocVideoPlayer:didCurrentPlayerItemStatusChanged:)]) {
                [_delegate ocVideoPlayer:self didCurrentPlayerItemStatusChanged:[self currentPlayerItem]];
            }
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
            if (currentItem.playbackLikelyToKeepUp&&self.videoPlayerState==OCVideoPlayerStateStalled) {
                self.videoPlayerState=OCVideoPlayerStatePlaying;
            }
        }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
            if (currentItem.playbackBufferEmpty&&self.videoPlayerState==OCVideoPlayerStateStalled) {
                
            }
        }
    }
}

#pragma mark -private selecter
//备注： index 从0 开始
-(AVQueuePlayer *)avQueuePlayerWithUrls:(NSArray *)urlsArray fromIndex:(NSInteger)index {
    if (urlsArray.count&&index<urlsArray.count) {
        NSMutableArray *avItems=[NSMutableArray new];
        for (NSInteger i=index; i<urlsArray.count; i++) {
            NSURL *url=[urlsArray objectAtIndex:i];
            AVPlayerItem *item=[[AVPlayerItem alloc]  initWithURL:url];
            [self addNotificationAndObserverWithAvPlayerItem:item];
            [avItems addObject:item];
        }
        if (_avPlayer) {
            self.videoPlayerState=OCVideoPlayerStateFinsihed;
            for (AVPlayerItem *item in self.avPlayer.items) {
                [self removeNotificationAndObserverWithAvPlayerItem:item];
            }
            [self.avPlayer removeAllItems];
            for (AVPlayerItem *aItem in avItems) {
                if ([self.avPlayer canInsertItem:aItem afterItem:nil]) {
                    [self.avPlayer insertItem:aItem afterItem:nil];
                }
            }
        }else{
            
            _avPlayer=[AVQueuePlayer queuePlayerWithItems:avItems];
            _avPlayer.actionAtItemEnd=AVPlayerActionAtItemEndNone;
            [self.playerView setAvPlayer:_avPlayer];
            
            __weak OCVideoPlayer *weakSelf=self;
            [_avPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
            [_avPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];

            [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
                NSTimeInterval currentTime=CMTimeGetSeconds(time);
                [weakSelf.playerControlView updateTrackCurrentPlayTime:currentTime];
            }];
        }
        return self.avPlayer;
    }else{
        return nil;
    }
}

-(void)advancedToPlayNextVideo{
    self.videoPlayerState=OCVideoPlayerStateFinsihed;
    [self removeNotificationAndObserverWithAvPlayerItem:[self currentPlayerItem]];
    if (_delegate&&[_delegate respondsToSelector:@selector(ocVideoPlayer:didFinishedPlayItemToEndTime:)]) {
        [_delegate ocVideoPlayer:self didFinishedPlayItemToEndTime:[self currentPlayerItem]];
    }
    NSInteger itemsCount=self.avPlayer.items.count;
    if (itemsCount==1) {
        
    }else if (itemsCount>1){
        [self.avPlayer advanceToNextItem];
        if (self.avPlayer.items.count==1) {
            _avPlayer.actionAtItemEnd=AVPlayerActionAtItemEndPause;
        }
    }
}
-(void)updatePlayerVolum:(CGFloat)volum{
    if (volum>1) {
        volum=1;
    }else if(volum<0){
        volum=0;
    }
    if ([[self avPlayer] respondsToSelector:@selector(volume)]) {
        [[self avPlayer] setVolume:volum];
    }else{
        AVPlayerItem *mPlayerItem=[[self avPlayer] currentItem];
        NSArray *audioTracks = mPlayerItem.asset.tracks;
        
        NSMutableArray *allAudioParams = [NSMutableArray array];
        for (AVAssetTrack *track in audioTracks) {
            AVMutableAudioMixInputParameters *audioInputParams =[AVMutableAudioMixInputParameters audioMixInputParameters];
            [audioInputParams setVolume:volum atTime:kCMTimeZero];
            [audioInputParams setTrackID:[track trackID]];
            [allAudioParams addObject:audioInputParams];
        }
        AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
        [audioZeroMix setInputParameters:allAudioParams];
        
        [mPlayerItem setAudioMix:audioZeroMix]; // Mute the player item
    }
}
//快进的时候显示缩略图
-(UIImage *)thumbImageAtTime:(NSTimeInterval)currentTime{
    __weak OCVideoPlayer *weakSelf=self;
    __block UIImage *thumbImage;
    AVAsset *asset = [[[weakSelf avPlayer] currentItem] asset];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = CMTimeMake(currentTime, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    thumbImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbImage;
}
/**
 *  是否显示缓冲进度的提示
 *
 *  @param isShow BOOL
 */
-(void)shouldShowBufferLoadingView:(BOOL)isShow{
    if (isShow) {
        [self.timer setFireDate:[NSDate distantPast]];
    }else{
        [self.timer setFireDate:[NSDate distantFuture]];
    }
    self.playerControlView.isShowBufferView=isShow;
}
#pragma mark -- public selcter
- (void)play{
    self.videoPlayerState=OCVideoPlayerStatePlaying;
}
- (void)pause{
    self.videoPlayerState=OCVideoPlayerStatePaused;
}
-(void)playVideoAtInde:(NSInteger)index{
    self.avPlayer=[self avQueuePlayerWithUrls:self.contentURLArray fromIndex:index];
}

-(void)insertContentURL:(NSURL *)url afterIndex:(NSInteger)index{
    AVPlayerItem *playItem=[[AVPlayerItem alloc]  initWithURL:url];
    AVPlayerItem *afterItem=[[self.avPlayer items] objectAtIndex:index];
    if ([self.avPlayer canInsertItem:playItem afterItem:afterItem]) {
        [self.avPlayer insertItem:playItem afterItem:afterItem];
        [self.contentURLArray insertObject:url atIndex:(index+1)];
    }
}
-(void)removeAtIndex:(NSInteger)index{
    AVPlayerItem *afterItem=[[self.avPlayer items] objectAtIndex:index];
    if (afterItem==self.avPlayer.currentItem) {
        [self.avPlayer advanceToNextItem];
    }
    [self removeNotificationAndObserverWithAvPlayerItem:afterItem];
    [self.avPlayer removeItem:afterItem];
    [self.contentURLArray removeObjectAtIndex:index];
}

-(void)removeAllContents{
    if (self.avPlayer&&self.avPlayer.rate) {
        [self.avPlayer pause];
    }
    for (AVPlayerItem *item in self.avPlayer.items) {
        [self removeNotificationAndObserverWithAvPlayerItem:item];
    }
    [self.avPlayer removeAllItems];
    [self.contentURLArray removeAllObjects];
}



#pragma mark -getter and setter
-(void)setPlayerView:(OCVideoPlayerView *)playerView{
    _playerView=playerView;
    [_playerView setAvPlayer:self.avPlayer];
}
-(void)setVideoPlayerState:(OCVideoPlayerState)videoPlayerState{
    NSURL *currentUrl=[self currentItemURL];
    NSDictionary *userInfo;
    if (currentUrl) {
        userInfo=@{OCVideoPlayerStateKey:@(_videoPlayerState),OCVideoPlayerItemUrlKey:[self currentItemURL],OCVideoPlayerQueueItemsCountKey:@(self.avPlayer.items.count)};
    }else{
        userInfo=@{OCVideoPlayerStateKey:@(_videoPlayerState)};
    }
    [self willChangeValueForKey:@"videoPlayerState"];
    if (_delegate&&[_delegate respondsToSelector:@selector(ocVidePlayer:willChangeState:toState:userInfo:)]) {
        [_delegate ocVidePlayer:self willChangeState:_videoPlayerState toState:videoPlayerState userInfo:userInfo];
    }
    _videoPlayerState=videoPlayerState;
    if (currentUrl) {
        userInfo=@{OCVideoPlayerStateKey:@(_videoPlayerState),OCVideoPlayerItemUrlKey:[self currentItemURL],OCVideoPlayerQueueItemsCountKey:@(self.avPlayer.items.count)};
    }else{
        userInfo=@{OCVideoPlayerStateKey:@(_videoPlayerState)};
    }

    [self didChangeValueForKey:@"videoPlayerState"];
    switch (_videoPlayerState) {
        case OCVideoPlayerStateLoading:{
            if ([self isPlayingVideo]) {
                [[self avPlayer] pause];
            }
        }break;
        case OCVideoPlayerStateReadPlay:{
            
        }break;
        case OCVideoPlayerStatePlaying:{
            if (![self isPlayingVideo]) {
                [self.avPlayer play];
            }
        }break;
        case OCVideoPlayerStateStalled:{
            if ([self isPlayingVideo]) {
                [[self avPlayer] pause];
            }
        }break;
        case OCVideoPlayerStatePaused:{
            if ([self isPlayingVideo]) {
                [[self avPlayer] pause];
            }
        }break;
        default:
            break;
    }
    if (_videoPlayerState==OCVideoPlayerStateStalled) {
        [self.timer setFireDate:[NSDate distantPast]];
    }else{
        [self.timer setFireDate:[NSDate distantFuture]];
    }
    if (_delegate&&[_delegate respondsToSelector:@selector(ocVidePlayer:didStateChanged:userInfo:)]) {
        [_delegate ocVidePlayer:self didStateChanged:_videoPlayerState userInfo:userInfo];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:OCVideoPlayerStateChangedNotification object:nil userInfo:userInfo];
}
-(OCVideoPlayerView *)playerView{
    if (nil==_playerView) {
        _playerView=[[OCVideoPlayerView alloc]  init];
        _backgroundView=[[UIView alloc]  init];
        [self.playerView addSubview:_backgroundView];
        [self.playerView sendSubviewToBack:_backgroundView];
        if (nil==_playerControlView) {
            _playerControlView=[[OCVideoPlayerControlView alloc]  init];
            _playerControlView.delegate=self;
        }
        [_playerView addSubview:_playerControlView];
    }
    return _playerView;
}
-(NSMutableArray *)contentURLArray{
    return _contentURLArray;
}
-(void)setContentURLArray:(NSMutableArray *)contentURLArray{
    _contentURLArray=[contentURLArray copy];
}
-(BOOL)isPlayingVideo{
    return ([self avPlayer] && self.avPlayer.rate != 0.0);
}
-(AVPlayerItem *)currentPlayerItem{
    return [[self avPlayer] currentItem];
}
-(NSURL *)currentItemURL{
    AVPlayerItem *item=[self currentPlayerItem];
    AVURLAsset *urlAsset=(AVURLAsset *)[item asset];
    if (urlAsset) {
        return urlAsset.URL;
    }
    return nil;
}
-(NSTimeInterval)currentTime{
    CMTime currentTime=[[self currentPlayerItem] currentTime];
    return CMTimeGetSeconds(currentTime);
}
-(NSTimeInterval)currentItemDuration{
    CMTime durationTime=[[self currentPlayerItem] duration];
    return CMTimeGetSeconds(durationTime);
}
- (CGFloat)currentBitRate {
    CGFloat bitRate= [[self currentPlayerItem].accessLog.events.lastObject observedBitrate];
    return bitRate;
}
-(NSTimer *)timer{
    if (nil==_timer) {
        _timer=[[NSTimer alloc]  initWithFireDate:[NSDate distantFuture] interval:0.5 target:self selector:@selector(handTimer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]  addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}
-(void)handTimer:(NSTimer *)timer{
    if (timer==_timer) {
        if (self.playerControlView.isShowBufferView) {
            [self.playerControlView updateBufferBitRate:[self currentBitRate] ];
        }
    }
}
#pragma mark -OCVideoPlayerControlViewDelegate
-(void)videoPlayerControlViewBeginSwipeWithDirection:(OCVideoSwipeDirection)direction{
    self.videoPlayerState=OCVideoPlayerStatePaused;
}
-(void)videoPlayerControlViewSwipingWithDirection:(OCVideoSwipeDirection)direction value:(CGFloat)value handlerBlock:(ControlViewTrackingBlock)block{
    self.videoPlayerState=OCVideoPlayerStatePaused;
    switch (direction) {
        case OCVideoSwipeDirectionHorizontal:{
            UIImage *image=[self thumbImageAtTime:value];
            if (image) {
                NSDictionary *userInfo=@{OCVidePlayerThumbnailImageKey:image};
                block(userInfo);
            }
        }
            break;
        case OCVideoSwipeDirectionVertical:{
            
        }break;
        default:
            break;
    }
}
-(void)videoPlayerControlViewEndedSwipeWithDirection:(OCVideoSwipeDirection)direction value:(CGFloat)value{
    switch (direction) {
        case OCVideoSwipeDirectionHorizontal:{
            __weak OCVideoPlayer *weakSelf=self;
            [[self avPlayer] seekToTime:CMTimeMakeWithSeconds(value, 1) completionHandler:^(BOOL finished) {
                if (finished) {
                    weakSelf.videoPlayerState=OCVideoPlayerStatePlaying;
                }
            }];
        }
            break;
        case OCVideoSwipeDirectionVertical:{
            
        }break;
        default:
            break;
    }
}

//action handler
-(void)videoPlayerControlViewActionWithEvent:(OCVideoPlayerControlEvent)event userInfo:(NSDictionary *)userInfo{
    switch (event) {
        case OCVideoPlayerControlEventPlay:{
            self.videoPlayerState=OCVideoPlayerStatePlaying;
        }break;
        case OCVideoPlayerControlEventPause:{
            self.videoPlayerState=OCVideoPlayerStatePaused;
        }break;
        case OCVideoPlayerControlEventFullScreen:{
            if (_delegate&&[_delegate respondsToSelector:@selector(ocVidePlayer:didControlByEvent:)]) {
                [_delegate ocVidePlayer:self didControlByEvent:event];
            }
        }break;
        case OCVideoPlayerControlEventNext:{
            [self advancedToPlayNextVideo];
        }break;
        default:
            break;
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
