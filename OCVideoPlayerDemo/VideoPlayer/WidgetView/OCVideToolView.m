//
//  OCVideToolView.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/8/5.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "OCVideToolView.h"
#import "NSString+OCPlayer.h"
#import "Masonry.h"
@interface OCVideToolView ()
@property (nonatomic,strong)UILabel *timeLable,*fullPlayTimeLable,*titleLable;
@property (nonatomic,strong)UISlider *slider;
@property (nonatomic,strong)UIProgressView *progressView;
@property (nonatomic,strong)NSDateFormatter *dateFormatter;
@property (nonatomic,strong)UIButton *actionButton,*fullScreenButton,*nextButton;
@end

@implementation OCVideToolView
-(instancetype)init{
    if (self=[super initWithFrame:CGRectZero]) {
        [self onInitItems];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self onInitItems];
    }
    return self;
}
#pragma mark -public
-(void)setPlay:(BOOL)play{
    _actionButton.selected=play;
}
-(BOOL)isPlay{
    return !_actionButton.selected;
}
-(CGFloat)sliderThumbImagePointX{
    CGRect trackRect = [self.slider trackRectForBounds:self.progressView.bounds];
    CGRect thumbRect = [self.slider thumbRectForBounds:self.slider.bounds
                                             trackRect:trackRect
                                                 value:self.currentTime];
    
    CGFloat offx=thumbRect.origin.x+thumbRect.size.width/2+self.slider.frame.origin.x;
    return  offx;
}
-(void)setTrackMinValue:(NSTimeInterval)minValue maxVlaue:(NSTimeInterval)maxValue{
    self.slider.minimumValue=minValue;
    self.slider.maximumValue=maxValue;
    self.slider.value=0;
    [self updateTrackCurrentPlayTime:self.slider.value];
}
-(void)updateTrackCurrentPlayTime:(NSTimeInterval)currentTime{
    if (currentTime>self.slider.maximumValue) {
        currentTime=self.slider.maximumValue;
    }else if (currentTime<=self.slider.minimumValue){
        currentTime=self.slider.minimumValue;
    }
   
    self.timeLable.text=[self convertVideoSeconds:self.slider.maximumValue];
    self.fullPlayTimeLable.text=[self convertVideoSeconds:self.slider.value];
    
}
-(void)updateTrackLoadedTime:(NSTimeInterval)loadedTime{
    CGFloat progress=0;
    if (self.slider.maximumValue) {//maxvalue may be =0;
        progress= loadedTime/self.slider.maximumValue;
    }
    if (progress>1) {
        progress=1;
    }
    if(progress<0){
        progress=0;
    }
    self.progressView.progress=progress;
}
-(void)didSliderTouched:(UISlider *)slder{

}
-(void)didSliderValueChaged:(UISlider *)slider{
    [self updateTrackCurrentPlayTime:slider.value];
    if (_delegate&&[_delegate respondsToSelector:@selector(didTrackValueChanging:)]) {
        [_delegate didTrackValueChanging:slider.value];
    }
}
-(void)didSliderTouchUpInSide:(UISlider *)slider{
    if (_delegate&&[_delegate respondsToSelector:@selector(didTrackValueEndedChang:)]) {
        [_delegate didTrackValueEndedChang:slider.value];
    }
}

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
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}
-(void)didActionButtonClicked:(UIButton *)sender{
    OCVideoPlayerControlEvent controlEvent=OCVideoPlayerControlEventUnKnown;
    if (sender==_actionButton) {
        sender.selected=!sender.selected;
        if (sender.selected) {
            controlEvent=OCVideoPlayerControlEventPlay;
        }else{
            controlEvent=OCVideoPlayerControlEventPause;
        }
    }else if (sender==_fullScreenButton){
        controlEvent=OCVideoPlayerControlEventFullScreen;
    }else if (sender==_nextButton){
        controlEvent=OCVideoPlayerControlEventNext;
    }
    if (_controlDelegate&&[_controlDelegate respondsToSelector:@selector(didOcVideoPlayerHandleActionWithControlEvent:userInfo:)]) {
        [_controlDelegate didOcVideoPlayerHandleActionWithControlEvent:controlEvent userInfo:nil];
    }

}
-(NSTimeInterval)maxTime{
    return self.slider.maximumValue;
}
-(NSTimeInterval)minTime{
    return self.slider.minimumValue;
}
-(void)setCurrentTime:(NSTimeInterval)currentTime{
    [self.slider setValue:currentTime animated:YES];
    [self updateTrackCurrentPlayTime:currentTime];
}

-(NSTimeInterval)currentTime{
    return self.slider.value;
}
-(void)setLoadedTime:(NSTimeInterval)loadedTime{
    [self updateTrackLoadedTime:loadedTime];
}
-(NSTimeInterval)loadedTime{
    return self.maxTime*self.progressView.progress;
}

-(void)onInitItems{
    self.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:[@"progress_bg01" ocVideoImageName]]];
    self.userInteractionEnabled=YES;
    __weak OCVideToolView *weakSelf=self;
    _actionButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _actionButton.selected=YES;
    [_actionButton addTarget:self action:@selector(didActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_actionButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_play" ocVideoImageName]] forState:UIControlStateNormal];
    [_actionButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_pause" ocVideoImageName]] forState:UIControlStateSelected];
    [self addSubview:_actionButton];
    
    
    _nextButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_nextButton addTarget:self action:@selector(didActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_nextButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_next" ocVideoImageName]] forState:UIControlStateNormal];
    [_nextButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_next" ocVideoImageName]] forState:UIControlStateSelected];
    [self addSubview:_nextButton];

    _fullPlayTimeLable=[[UILabel alloc]  init];
    _fullPlayTimeLable.font=[UIFont systemFontOfSize:10];
    _fullPlayTimeLable.textColor=[UIColor whiteColor];
    _fullPlayTimeLable.textAlignment=NSTextAlignmentCenter;
    _fullPlayTimeLable.text=@"00:00";
    [self addSubview:_fullPlayTimeLable];
    
    _progressView=[[UIProgressView alloc]  initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.progress=0;
    _progressView.userInteractionEnabled=YES;
    [self addSubview:_progressView];
    
    _slider=[[UISlider alloc]  init];
    _slider.userInteractionEnabled=YES;
    _slider.value=0.0;
    _slider.maximumValue=0.0;
    _slider.minimumValue=0.0;
    _slider.continuous=YES;
    [self.slider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [_slider setThumbImage:[UIImage imageNamed:[@"progress_button" ocVideoImageName]] forState:UIControlStateNormal];
    [_slider addTarget:self action:@selector(didSliderValueChaged:) forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(didSliderTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchDragOutside|UIControlEventTouchDragExit];
    _slider.backgroundColor=[UIColor clearColor];
    [_progressView addSubview:_slider];
    
    
    _timeLable=[[UILabel alloc]  init];
    _timeLable.font=[UIFont systemFontOfSize:10];
    _timeLable.textColor=[UIColor whiteColor];
    _timeLable.textAlignment=NSTextAlignmentCenter;
    _timeLable.text=@"00:00";
    [self addSubview:_timeLable];
    _fullScreenButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_fullScreenButton addTarget:self action:@selector(didActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_fullScreenButton setBackgroundImage:[UIImage imageNamed:[@"smallScreen_zoom" ocVideoImageName]] forState:UIControlStateNormal];
    [self addSubview:_fullScreenButton];
    
    
    [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.mas_centerY);
        make.left.equalTo(weakSelf).offset(10);
        make.width.equalTo(@20);
    }];
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_actionButton);
        make.width.equalTo(@20);
        make.left.mas_equalTo(_actionButton.mas_right).offset(5);
    }];
    [_fullPlayTimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.progressView.mas_left).offset(-5);
        make.centerY.mas_equalTo(weakSelf);
        make.left.mas_equalTo(_nextButton.mas_right).offset(5);
        make.width.mas_lessThanOrEqualTo(45);
    }];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_fullPlayTimeLable.mas_right).offset(5);
        make.right.equalTo(_timeLable.mas_left).offset(-5);
        make.centerY.mas_equalTo(weakSelf);
        make.height.equalTo(@3);
    }];
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_progressView);
    }];
    
    [_timeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf);
        make.left.equalTo(_progressView.mas_right).offset(5);
    }];
    [_fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_timeLable.mas_right).offset(5);
        make.right.equalTo(weakSelf).offset(-10);
        make.centerY.mas_equalTo(_actionButton);
        make.width.equalTo(@30);
    }];


}
@end
