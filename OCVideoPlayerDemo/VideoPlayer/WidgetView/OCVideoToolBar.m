//
//  OCVideoToolBar.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/8/5.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "OCVideoToolBar.h"
#import "NSString+OCPlayer.h"
#import "Masonry.h"
@interface OCVideoToolBar ()
@property(nonatomic ,strong)UIButton *actionButton;
@property(nonatomic,strong)UIBarButtonItem *playBarButtonItem,*spaceBarButtonItem,*nextBarButton,*fullScreenBarButtonItem;
@property(nonatomic,strong)UIView *trackView;
@property (nonatomic,strong)UILabel *timeLable,*fullPlayTimeLable,*titleLable;
@property (nonatomic,strong)UISlider *slider;
@property (nonatomic,strong)UIProgressView *progressView;
@property (nonatomic,strong)NSDateFormatter *dateFormatter;
@end

@implementation OCVideoToolBar
-(instancetype)init{
    if (self=[super init]) {
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

-(void)onInitItems{
    self.barStyle=UIBarStyleBlack;
//    _actionButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    _actionButton.selected=YES;
//    [_actionButton addTarget:self action:@selector(didBarButtoItemClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [_actionButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_play" ocVideoImageName]] forState:UIControlStateNormal];
//    [_actionButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_pause" ocVideoImageName]] forState:UIControlStateSelected];
//
//    _playBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:_actionButton];
    
    _playBarButtonItem=[[UIBarButtonItem alloc]  initWithImage:[UIImage imageNamed:[@"fullplayer_icon_play" ocVideoImageName]] style:UIBarButtonItemStylePlain target:self action:@selector(didBarButtoItemClicked:)];
//    [_playBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_play" ocVideoImageName]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//     [_playBarButtonItem setBackButtonBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_pause" ocVideoImageName]] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    _nextBarButton=[[UIBarButtonItem alloc]  initWithImage:[UIImage imageNamed:[@"fullplayer_icon_next" ocVideoImageName]] style:UIBarButtonItemStylePlain target:self action:@selector(didBarButtoItemClicked:)];

    
    _spaceBarButtonItem=[[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:@selector(didBarButtoItemClicked:)];
    _spaceBarButtonItem.customView=self.trackView;
//    [_spaceBarButtonItem.customView addSubview:self.trackView];
//    _spaceBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:self.trackView];
    

    _fullScreenBarButtonItem=[[UIBarButtonItem alloc]  initWithImage:[UIImage imageNamed:[@"smallScreen_zoom" ocVideoImageName]] style:UIBarButtonItemStylePlain target:self action:@selector(didBarButtoItemClicked:)];
    NSArray *buttonItems=@[_playBarButtonItem,_nextBarButton,_spaceBarButtonItem,_fullScreenBarButtonItem];
    
    [self setItems:buttonItems animated:YES];
    
    UIView *spaceView=[_spaceBarButtonItem valueForKey:@"view"];
    
//    __weak OCVideoToolBar *weakSelf=self;
//    [self.trackView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(weakSelf.trackView.superview);
//        make.left.mas_equalTo(_playBarButtonItem.customView.mas_right);
//        make.right.mas_equalTo(_playBarButtonItem.customView.mas_left);
//    }];
}
-(void)didBarButtoItemClicked:(id)sender{
    OCVideoPlayerControlEvent event=OCVideoPlayerControlEventUnKnown;
    if (sender==_actionButton) {
        _actionButton.selected=!_actionButton.selected;
        if (_actionButton.selected) {
            event=OCVideoPlayerControlEventPlay;
        }else{
            event=OCVideoPlayerControlEventPause;
        }
    }else if (sender==_nextBarButton){
        event=OCVideoPlayerControlEventNext;
    }else if (sender==_fullScreenBarButtonItem){
        event=OCVideoPlayerControlEventFullScreen;
    }
    if (_controlDelegate&&[_controlDelegate respondsToSelector:@selector(didOcVideoPlayerHandleActionWithControlEvent:userInfo:)]) {
        [_controlDelegate didOcVideoPlayerHandleActionWithControlEvent:event userInfo:nil];
    }
}

#pragma mark -public 
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
    [self.slider setValue:currentTime animated:YES];
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
-(void)didSliderValueChaged:(UISlider *)slider{
    [self updateTrackCurrentPlayTime:slider.value];
   
}
-(void)didSliderTouchUpInSide:(UISlider *)slider{
   
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
-(UIView *)trackView{
    if (nil==_trackView) {
        _trackView=[[UIView alloc] init];
        _fullPlayTimeLable=[[UILabel alloc]  init];
        _fullPlayTimeLable.font=[UIFont systemFontOfSize:10];
        _fullPlayTimeLable.textColor=[UIColor whiteColor];
        _fullPlayTimeLable.textAlignment=NSTextAlignmentCenter;
        _fullPlayTimeLable.text=@"00:00";
        [_trackView addSubview:_fullPlayTimeLable];
        
        _progressView=[[UIProgressView alloc]  initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progress=0;
        [_trackView addSubview:_progressView];
        
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
        [_trackView addSubview:_slider];

        
        _timeLable=[[UILabel alloc]  init];
        _timeLable.font=[UIFont systemFontOfSize:10];
        _timeLable.textColor=[UIColor whiteColor];
        _timeLable.textAlignment=NSTextAlignmentCenter;
        _timeLable.text=@"00:00";
        [_trackView addSubview:_timeLable];
        __weak OCVideoToolBar *weakSelf=self;
        [_fullPlayTimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.progressView.mas_left).offset(-5);
            make.centerY.mas_equalTo(_trackView);
            make.left.equalTo(_trackView).offset(5);
            make.width.mas_lessThanOrEqualTo(45);
        }];
        [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_fullPlayTimeLable.mas_right).offset(5);
            make.right.equalTo(_timeLable.mas_left).offset(-5);
            make.centerY.mas_equalTo(_trackView);
            make.height.equalTo(@2);
        }];
        [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_progressView);
        }];
        
        [_timeLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_trackView);
            make.left.equalTo(_progressView.mas_right).offset(5);
        }];
    }
    return _trackView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
