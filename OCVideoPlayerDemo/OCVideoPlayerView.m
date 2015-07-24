//
//  OCVideoPlayerView.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/22.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "OCVideoPlayerView.h"
#import "Masonry.h"
#import "NSString+OCPlayer.h"
@interface OCVideoPlayerView ()
@property (nonatomic,strong)UIView  *bottomView,*topView;
@property (nonatomic,strong)UIButton *actionButton,*fullScreenButton,*backButton;
@property (nonatomic,strong)UILabel *timeLable,*fullPlayTimeLable,*titleLable;
@property (nonatomic,strong)UISlider *slider;
@property (nonatomic,strong)UIProgressView *progressView;

@property (nonatomic,strong)NSDateFormatter *dateFormatter;

@end

@implementation OCVideoPlayerView
#pragma mark init
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
-(instancetype)init{
    self=[self initWithFrame:CGRectZero];
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        __weak OCVideoPlayerView *weakSelf=self;
        [self addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(weakSelf);
            make.height.equalTo(@50);
        }];
        
        [self addSubview:self.topView];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(weakSelf);
            make.height.equalTo(@50);
        }];
        [[NSNotificationCenter defaultCenter]  addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            weakSelf.videoPlayerState=OCVideoPlayerStatePaused;
        }];
        [[NSNotificationCenter defaultCenter]  addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            weakSelf.videoPlayerState=OCVideoPlayerStatePlaying;
        }];
        [[NSNotificationCenter defaultCenter]  addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            UIDeviceOrientation orientation= [[UIDevice currentDevice] orientation];
            [weakSelf resetUIWithDeviceOrientation:orientation];
        }];
    }
    return self;
}

#pragma mark- play pause
- (NSString *)convertVideoSeconds:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [self.dateFormatter setDateFormat:@"HH:mm:ss"];
    } else {
        [self.dateFormatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [self.dateFormatter stringFromDate:d];
    return showtimeNew;
}
#pragma mark -selecter
-(void)resetUIWithDeviceOrientation:(UIDeviceOrientation)orientation{
    if (orientation==UIDeviceOrientationPortrait||orientation==UIDeviceOrientationPortraitUpsideDown) {
        [_fullPlayTimeLable mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_lessThanOrEqualTo(0);
        }];
    }else if(orientation==UIDeviceOrientationLandscapeLeft||orientation==UIDeviceOrientationLandscapeRight){
        [_fullPlayTimeLable mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_lessThanOrEqualTo(45);
        }];
    }
    [self updateSliderValue];
    [self layoutIfNeeded];
}
-(void)didActionButtonClicked:(UIButton *)sender{
    if (sender==_actionButton) {
        if (sender.selected) {
            self.videoPlayerState=OCVideoPlayerStatePaused;
        }else{
            self.videoPlayerState=OCVideoPlayerStatePlaying;
        }
    }else if (sender==_fullScreenButton){
        
    }else if (sender==_backButton){
        
    }
}
#pragma mark -sliderAction
-(void)didSliderValueChaged:(UISlider *)slider{
    if (slider.continuous) {
        self.videoPlayerState=OCVideoPlayerStatePaused;
        slider.continuous=NO;
    }else{
        __weak OCVideoPlayerView *weakSelf=self;
        slider.continuous=YES;
        [[self avPlayer] seekToTime:CMTimeMakeWithSeconds(slider.value, 30) completionHandler:^(BOOL finished) {
            if (finished) {
                weakSelf.videoPlayerState=OCVideoPlayerStatePlaying;
            }
        }];
    }
}
-(void)updateSliderValue{
    NSTimeInterval  currentTime=CMTimeGetSeconds([[self avPlayer] currentTime]);
    [self.slider setValue:currentTime animated:YES];
    UIDeviceOrientation orientation=[[UIDevice currentDevice] orientation];
    if (orientation==UIDeviceOrientationPortrait||orientation==UIDeviceOrientationPortraitUpsideDown) {
        self.fullPlayTimeLable.text=@"";
        self.timeLable.text=[NSString stringWithFormat:@"%@/%@",[self convertVideoSeconds:currentTime],[self convertVideoSeconds:self.slider.maximumValue] ];
    }else if(orientation==UIDeviceOrientationLandscapeLeft||orientation==UIDeviceOrientationLandscapeRight){
        self.timeLable.text=[self convertVideoSeconds:self.slider.maximumValue];
        self.fullPlayTimeLable.text=[self convertVideoSeconds:currentTime];
    }
}
#pragma mark -KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *currentItem=[[self avPlayer] currentItem];
    if (object==[self avPlayer]) {
        if ([keyPath isEqualToString:@"rate"]) {
            if ([[self avPlayer] rate]==1) {
               
            }
        }
    }else if (object==currentItem){
        if ([keyPath isEqualToString:@"loadedTimeRanges"]){
            NSArray *loadedTimeRanges = [currentItem loadedTimeRanges];
            CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
            float startSeconds = CMTimeGetSeconds(timeRange.start);
            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
            NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
            
            CMTime duration = currentItem.duration;
            CGFloat totalDuration = CMTimeGetSeconds(duration);
            [self.progressView setProgress:timeInterval / totalDuration animated:YES];
            
        }else if ([keyPath isEqualToString:@"status"]){
            if (currentItem.status==AVPlayerItemStatusReadyToPlay) {
               // [self updateSliderValue];
                CGFloat duration=CMTimeGetSeconds(currentItem.duration);
                self.slider.maximumValue=duration;
                self.timeLable.text=[NSString stringWithFormat:@"%@/%@",[self convertVideoSeconds:self.slider.value],[self convertVideoSeconds:self.slider.maximumValue] ];
            }else if (currentItem.status==AVPlayerItemStatusFailed){
                NSLog(@"播放失败");
            }else if (currentItem.status==AVPlayerItemStatusUnknown){
                
            }
        }
    }
}


#pragma setter getter
- (void)setAvPlayer:(AVPlayer *)avPlayer{
    [(AVPlayerLayer *)[self layer] setPlayer:avPlayer];
    self.videoPlayerState=OCVideoPlayerStateLoading;
    [avPlayer addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [avPlayer.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];//loadedTimeRanges
    [avPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];//status
    
    __weak OCVideoPlayerView *weakSelf=self;
    [avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf updateSliderValue];
    }];
}

-(void)setVideoPlayerState:(OCVideoPlayerState)videoPlayerState{
    __weak OCVideoPlayerView *weakSelf=self;
    _videoPlayerState=videoPlayerState;
    switch (_videoPlayerState) {
        case OCVideoPlayerStateLoading:{
            _actionButton.selected=YES;
        }break;
        case OCVideoPlayerStatePlaying:{
            [[weakSelf avPlayer] play];
            _actionButton.selected=YES;
        }break;
        case OCVideoPlayerStatePaused:{
            [[weakSelf avPlayer] pause];
            _actionButton.selected=NO;
        }break;
        default:
            break;
    }
    if (_delegate&&[_delegate respondsToSelector:@selector(didOCVideoPlayerStateChanged:)]) {
        [_delegate didOCVideoPlayerStateChanged:self.videoPlayerState];
    }
}



- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}
-(AVPlayer *)avPlayer{
    return  [(AVPlayerLayer *)[self layer] player];
}
-(UIView *)bottomView{
    if (nil==_bottomView) {
        _bottomView=[[UIView alloc]  init];
        _bottomView.userInteractionEnabled=YES;
        _bottomView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:[@"progress_bg01" ocVideoImageName]]];
        __weak OCVideoPlayerView *weakSelf=self;
        _actionButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_actionButton addTarget:self action:@selector(didActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_actionButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_play" ocVideoImageName]] forState:UIControlStateNormal];
        [_actionButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_pause" ocVideoImageName]] forState:UIControlStateSelected];
        [_bottomView addSubview:_actionButton];
        
        
        _fullPlayTimeLable=[[UILabel alloc]  init];
        _fullPlayTimeLable.font=[UIFont systemFontOfSize:10];
        _fullPlayTimeLable.textColor=[UIColor whiteColor];
        _fullPlayTimeLable.textAlignment=NSTextAlignmentCenter;
        _fullPlayTimeLable.text=@"00:00/00:00";
        [_bottomView addSubview:_fullPlayTimeLable];
        
        
        _progressView=[[UIProgressView alloc]  initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_bottomView addSubview:_progressView];
        //        _progressView.progressImage=[UIImage imageNamed:[@"progress_bg02" ocVideoImageName]];
        //        _progressView.trackImage=[UIImage imageNamed:[@"progress_bg03" ocVideoImageName]];
        
        
        _slider=[[UISlider alloc]  init];
        _slider.userInteractionEnabled=YES;
        _slider.value=0.0;
        _slider.maximumValue=0.0;
        _slider.minimumValue=0.0;
        _slider.continuous=NO;
        [self.slider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
        [self.slider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
        [_slider setThumbImage:[UIImage imageNamed:[@"progress_button" ocVideoImageName]] forState:UIControlStateNormal];
        [_slider addTarget:self action:@selector(didSliderValueChaged:) forControlEvents:UIControlEventValueChanged];
        _slider.backgroundColor=[UIColor clearColor];
        [_bottomView addSubview:_slider];
        
        
        
        _timeLable=[[UILabel alloc]  init];
        _timeLable.font=[UIFont systemFontOfSize:10];
        _timeLable.textColor=[UIColor whiteColor];
        _timeLable.textAlignment=NSTextAlignmentCenter;
        _timeLable.text=@"00:00/00:00";
        [_bottomView addSubview:_timeLable];
        
        
        _fullScreenButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton addTarget:self action:@selector(didActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_fullScreenButton setBackgroundImage:[UIImage imageNamed:[@"smallScreen_zoom" ocVideoImageName]] forState:UIControlStateNormal];
        [_bottomView addSubview:_fullScreenButton];
        
        
        [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_bottomView.mas_centerY);
            make.left.equalTo(_bottomView).offset(10);
            make.width.equalTo(@20);
        }];
        [_fullPlayTimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.progressView.mas_left).offset(-5);
            make.centerY.mas_equalTo(_actionButton);
            make.left.equalTo(_actionButton.mas_right).offset(5);
            make.width.mas_lessThanOrEqualTo(45);
        }];
        [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_fullPlayTimeLable.mas_right).offset(5);
            make.right.equalTo(_timeLable.mas_left).offset(-5);
            make.centerY.mas_equalTo(_actionButton);
            make.height.equalTo(@2);
        }];
        [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_progressView);
        }];
        
        [_timeLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_actionButton);
            make.left.equalTo(_progressView.mas_right).offset(5);
        }];
        [_fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_timeLable.mas_right).offset(5);
            make.right.equalTo(_bottomView).offset(-10);
            make.centerY.mas_equalTo(_actionButton);
            make.width.equalTo(@30);
        }];
        
    }
    return _bottomView;
}
-(UIView *)topView{
    if (nil==_topView) {
        _topView=[[UIView alloc]  init];
        _topView.userInteractionEnabled=YES;
        _topView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:[@"progress_bg01" ocVideoImageName]]];
        _backButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton addTarget:self action:@selector(didActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_back" ocVideoImageName]] forState:UIControlStateNormal];
        
        [_topView addSubview:_backButton];
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_topView.mas_centerY);
            make.left.equalTo(_topView).offset(5);
            make.width.equalTo(@25);
        }];
    }
    return _topView;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *aTouch=  (UITouch *)[touches anyObject];
    UIView *backGroundView=[[self subviews] objectAtIndex:0];
    if (aTouch.view==backGroundView) {
        if (aTouch.tapCount==1) {
            [self performSelector:@selector(handleTouchEvent:) withObject:aTouch afterDelay:0.5];
        }else if(aTouch.tapCount==2){
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTouchEvent:) object:aTouch ];
        }
    }
}
-(void)handleTouchEvent:(UITouch *)aTouch{
    if (aTouch.tapCount==1) {
        _topView.hidden=_bottomView.hidden=!_bottomView.hidden;
    }
}
@end
