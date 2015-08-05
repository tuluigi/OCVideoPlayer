//
//  OCVideoPlayerControlView.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/21.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "OCVideoPlayerControlView.h"
#import "Masonry.h"
#import "OCVideoLoadingView.h"
#import "NSString+OCPlayer.h"

NSString * const OCVidePlayerThumbnailImageKey =@"OCVidePlayerThumbnailImageKey";
@interface OCVideoPlayerControlView ()
@property (nonatomic,strong)UIView  *bottomView,*topView;
@property (nonatomic,strong)UIButton *actionButton,*fullScreenButton,*backButton,*nextButton;
@property (nonatomic,strong)UILabel *timeLable,*fullPlayTimeLable,*titleLable;
@property (nonatomic,strong)UISlider *slider;
@property (nonatomic,strong)UIProgressView *progressView;

@property (nonatomic,strong)UIImageView *thubmImageView;//快进的时候显示的缩略图

@property (nonatomic,strong)NSDateFormatter *dateFormatter;

@property (nonatomic,assign)CGPoint lastTouchPosition;
@property (nonatomic,assign)OCVideoSwipeDirection swipeDirection;

@property (nonatomic,strong)OCVideoLoadingView *loadingView;
@property (nonatomic,strong)NSTimer *timer;

#pragma privateMethod
-(void)play;
-(void)pause;
@end

@implementation OCVideoPlayerControlView
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(instancetype)init{
    if (self=[super init]) {
        [self addSubview:self.bottomView];
        [self addSubview:self.topView];
        __weak OCVideoPlayerControlView *weakSelf=self;
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(weakSelf);
            make.height.equalTo(@40);
        }];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(weakSelf);
            make.height.equalTo(@40);
        }];
        [[NSNotificationCenter defaultCenter]  addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            UIDeviceOrientation orientation= [[UIDevice currentDevice] orientation];
            [weakSelf resetUIWithDeviceOrientation:orientation];
        }];
        [[NSNotificationCenter defaultCenter]  addObserverForName:OCVideoPlayerStateChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf handlerVideoPlayerStateWithUserInfo:note.userInfo];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:OCVideoPlayerItemStateChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [weakSelf handVideoItemStateChangedNotification:note.userInfo];
        }];
    }
    return self;
}
-(void)willMoveToSuperview:(UIView *)newSuperview{
    
}
-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    __weak OCVideoPlayerControlView * weakSelf=self;
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.superview);
    }];
}
#pragma mark -private Selecter
-(void)play{
    self.actionButton.selected=YES;
}
-(void)pause{
    self.actionButton.selected=NO;
}
-(BOOL)isPlaying{
    return !self.actionButton.selected;
}
#pragma mark -public selcter
-(void)handlerActionWithEvent:(OCVideoPlayerControlEvent)event userInfo:(NSDictionary *)userInfo{
    switch (event) {
        case OCVideoPlayerControlEventNext:{

        }break;
        case OCVideoPlayerControlEventPause:{
            self.isShowBufferView=NO;
            [self pause];
        }break;
        case OCVideoPlayerControlEventPlay:{
            [self play];
            self.isShowBufferView=NO;
        }
        default:
            break;
    }
    
}
-(void)handlerVideoPlayerStateWithUserInfo:(NSDictionary *)userInfo{
    OCVideoPlayerState state=[[userInfo objectForKey:OCVideoPlayerStateKey] integerValue];
    switch (state) {
        case OCVideoPlayerStateReadPlay:{
           
        }break;
        case OCVideoPlayerStatePlaying:{
            [self play];
            self.isShowBufferView=NO;
        }break;
        case OCVideoPlayerStatePaused:{
            self.isShowBufferView=NO;
            [self pause];
        }break;
        case OCVideoPlayerStateStalled:{
            [self pause];
            self.isShowBufferView=YES;
        }break;
        case OCVideoPlayerStateError:{
            [self pause];
            self.isShowBufferView=YES;
        }break;
        default:
            break;
    }
}
-(void)handVideoItemStateChangedNotification:(NSDictionary *)userInfo{
    NSInteger itemCount=[[userInfo objectForKey:OCVideoPlayerQueueItemsCountKey] integerValue];
    if (itemCount>1) {
        if (!_nextButton.bounds.size.width) {
            [_nextButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@20);
            }];
            [self setNeedsLayout];
        }
    }else{
        if (_nextButton.bounds.size.width) {
            [_nextButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@0);
            }];
            [self setNeedsLayout];
        }
    }
}
-(void)setTitle:(NSString *)title{
    if (nil==title) {
        self.titleLable.text=@"";
    }else{
        self.titleLable.text=title;
    }
}
-(NSString *)title{
    return self.titleLable.text;
}
-(void)updateBufferBitRate:(CGFloat)bitRate{
    if (self.loadingView.isDisplay) {
        self.loadingView.bitRate=bitRate;
    }
}
-(void)setIsShowBufferView:(BOOL)isShowBufferView{
    if (isShowBufferView) {
        if ([self isPlaying]) {
            [self pause];
        }
    }else{
        if ([self isPlaying]) {
            [self play];
        }
    }
    self.loadingView.display=isShowBufferView;
}
-(BOOL)isShowBufferView{
    return self.loadingView.isDisplay;
}

#pragma mark - sliderVlaue
-(void)updateTrackCurrentPlayTime:(NSTimeInterval)currentTime{
    if (currentTime>self.slider.maximumValue) {
        currentTime=self.slider.maximumValue;
    }else if (currentTime<=self.slider.minimumValue){
        currentTime=self.slider.minimumValue;
    }
    [self.slider setValue:currentTime animated:YES];
    if ((!self.thubmImageView.hidden)&&(![self isWidgetViewHidden])) {
        CGRect trackRect = [self.slider trackRectForBounds:self.slider.bounds];
        CGRect thumbRect = [self.slider thumbRectForBounds:self.slider.bounds
                                                 trackRect:trackRect
                                                     value:self.slider.value];
        
        CGFloat offx=thumbRect.origin.x+thumbRect.size.width/2+self.slider.frame.origin.x-CGRectGetWidth(_thubmImageView.bounds)/2;
        [self.thubmImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(offx);
        }];
        [self layoutIfNeeded];
    }
    self.timeLable.text=[self convertVideoSeconds:self.slider.maximumValue];
    self.fullPlayTimeLable.text=[self convertVideoSeconds:self.slider.value];
    //    UIDeviceOrientation orientation=[[UIDevice currentDevice] orientation];
    //    [self resetUIWithDeviceOrientation:orientation];
}
-(void)resetUIWithDeviceOrientation:(UIDeviceOrientation)orientation{
    
    if (orientation==UIDeviceOrientationPortrait||orientation==UIDeviceOrientationPortraitUpsideDown) {
        /*
         self.fullPlayTimeLable.text=@"";
         self.timeLable.text=[NSString stringWithFormat:@"%@/%@",[self convertVideoSeconds:self.slider.value],[self convertVideoSeconds:self.slider.maximumValue] ];
         */
        [_nextButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@0);
        }];
        
    }else if(orientation==UIDeviceOrientationLandscapeLeft||orientation==UIDeviceOrientationLandscapeRight){
        /*
         self.timeLable.text=[self convertVideoSeconds:self.slider.maximumValue];
         self.fullPlayTimeLable.text=[self convertVideoSeconds:self.slider.value];
         */
        
        [_nextButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@20);
        }];
    }
    [self setNeedsLayout];
    
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
/**
 *  设置播放最小和最大时间
 *
 *  @param minValue 最小时间
 *  @param maxValue 最大时间
 */
-(void)setTrackMinValue:(NSTimeInterval)minValue maxVlaue:(NSTimeInterval)maxValue{
    self.slider.minimumValue=minValue;
    self.slider.maximumValue=maxValue;
    self.slider.value=0;
    [self updateTrackCurrentPlayTime:self.slider.value];
}


#pragma mark - Slider Action
#pragma mark -sliderAction
-(void)didSliderValueChaged:(UISlider *)slider{
    [self updateTrackCurrentPlayTime:slider.value];
    self.thubmImageView.hidden=NO;
    __weak OCVideoPlayerControlView *weakSelf=self;
    if (_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControlViewSwipingWithDirection:value:handlerBlock:)]) {
        [_delegate videoPlayerControlViewSwipingWithDirection:OCVideoSwipeDirectionHorizontal value:weakSelf.slider.value handlerBlock:^(NSDictionary *userInfo) {
            if (userInfo) {
                weakSelf.thubmImageView.image=[userInfo objectForKey:OCVidePlayerThumbnailImageKey];
            }
        }];
    }
}
-(void)didSliderTouchUpInSide:(UISlider *)slider{
    self.thubmImageView.image=nil;
    self.thubmImageView.hidden=YES;
    __weak OCVideoPlayerControlView *weakSelf=self;
    if (_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControlViewEndedSwipeWithDirection:value:)]) {
        [_delegate videoPlayerControlViewEndedSwipeWithDirection:OCVideoSwipeDirectionHorizontal value:weakSelf.slider.value];
    }
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
    }else if (sender==_backButton){
        controlEvent=OCVideoPlayerControlEventBack;
    }else if (sender==_nextButton){
        controlEvent=OCVideoPlayerControlEventNext;
    }
    if (_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControlViewActionWithEvent:userInfo:)]) {
        [_delegate videoPlayerControlViewActionWithEvent:controlEvent userInfo:nil];
    }
}

#pragma mark -UITouch
#pragma mark -touch event
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *aTouch=  (UITouch *)[touches anyObject];
    if (aTouch.view==self) {
        self.swipeDirection=OCVideoSwipeDirectionUnknown;
        self.lastTouchPosition=[aTouch locationInView:self];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *aTouch=  (UITouch *)[touches anyObject];
    if (![self isWidgetViewHidden]) {
        if (aTouch.view==self) {
            CGPoint  currentTouchPosition=[aTouch locationInView:self];
            CGPoint tempPoint=CGPointMake(currentTouchPosition.x-self.lastTouchPosition.x, currentTouchPosition.y-self.lastTouchPosition.y);
            
            if (CGPointEqualToPoint(tempPoint, CGPointZero)) {
                return;
            }else if (fabs(tempPoint.x)>=fabs(tempPoint.y)){
                if (OCVideoSwipeDirectionUnknown==self.swipeDirection) {
                    self.swipeDirection=OCVideoSwipeDirectionHorizontal;
                    if (_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControlViewBeginSwipeWithDirection:)]) {
                        self.thubmImageView.hidden=NO;
                        [_delegate videoPlayerControlViewBeginSwipeWithDirection:self.swipeDirection];
                    }
                }
            }else{
                if (OCVideoSwipeDirectionUnknown==self.swipeDirection) {
                    self.swipeDirection=OCVideoSwipeDirectionVertical;
                    if (_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControlViewBeginSwipeWithDirection:)]) {
                        [_delegate videoPlayerControlViewBeginSwipeWithDirection:self.swipeDirection];
                    }
                }
            }
            [self handleSwipeWithDirection:self.swipeDirection offsetPoint:tempPoint];
            self.lastTouchPosition=currentTouchPosition;
        }
    }else{
        [self handleTouchEvent:aTouch];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *aTouch=  (UITouch *)[touches anyObject];
    if (OCVideoSwipeDirectionUnknown==self.swipeDirection) {
        if (aTouch.view==self) {
            if (aTouch.tapCount==1) {
                [self performSelector:@selector(handleTouchEvent:) withObject:aTouch afterDelay:0.5];
            }else if(aTouch.tapCount==2){
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTouchEvent:) object:aTouch ];
            }
        }
    }else{//快进结束
        self.thubmImageView.image=nil;
        self.thubmImageView.hidden=YES;
        if (_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControlViewEndedSwipeWithDirection:value:)]) {
            CGFloat value=0;
            if ( self.swipeDirection==OCVideoSwipeDirectionVertical) {
                
            }else if(self.swipeDirection==OCVideoSwipeDirectionHorizontal){
                value=self.slider.value;
            }
            [_delegate videoPlayerControlViewEndedSwipeWithDirection:self.swipeDirection value:value];
        }
    }
    self.swipeDirection=OCVideoSwipeDirectionUnknown;
    self.lastTouchPosition = CGPointZero;
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    self.lastTouchPosition = CGPointZero;
    self.swipeDirection=OCVideoSwipeDirectionUnknown;
}
-(void)handleSwipeWithDirection:(OCVideoSwipeDirection)direction offsetPoint:(CGPoint)offsetPoint{
    switch (direction) {
        case OCVideoSwipeDirectionHorizontal:{
            NSTimeInterval timeValue=self.slider.value+(offsetPoint.x>0?1:-1);
            [self updateTrackCurrentPlayTime:timeValue];
        }
            break;
        case OCVideoSwipeDirectionVertical:{
            //            CGFloat volum=[[self avPlayer] volume] -point.y/CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds);
            //            [self updatePlayerVolum:volum];
        }
        default:
            break;
    }
    __weak OCVideoPlayerControlView *weakSelf=self;
    if (_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControlViewSwipingWithDirection:value:handlerBlock:)]) {
        [_delegate videoPlayerControlViewSwipingWithDirection:self.swipeDirection value:self.slider.value handlerBlock:^(NSDictionary *userInfo) {
            if (userInfo&&direction==OCVideoSwipeDirectionHorizontal&&!weakSelf.thubmImageView.hidden&&![weakSelf isWidgetViewHidden]) {
                weakSelf.thubmImageView.image=[userInfo objectForKey:OCVidePlayerThumbnailImageKey];
            }
        }];
    }
}
-(void)handleTouchEvent:(UITouch *)aTouch{
    //    if (aTouch.tapCount==1) {
    __weak OCVideoPlayerControlView *weakSelf=self;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.topView.hidden=weakSelf.bottomView.hidden=!weakSelf.bottomView.hidden;
    } completion:^(BOOL finished) {
        
    }];
    //    }
}

#pragma mark -getter
-(BOOL)isWidgetViewHidden{
    return _bottomView.hidden&&_topView.hidden;
}
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}
-(OCVideoLoadingView *)loadingView{
    if (nil==_loadingView) {
        _loadingView=[OCVideoLoadingView ocVideoLoadingView];
        [self addSubview:_loadingView];
    }
    return _loadingView;
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
        _titleLable= [[UILabel alloc]  init];
        _titleLable.textAlignment=NSTextAlignmentCenter;
        _titleLable.font=[UIFont systemFontOfSize:20];
        _titleLable.textColor=[UIColor whiteColor];
        [_topView addSubview:_titleLable];
        
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_topView.mas_centerY);
            make.left.equalTo(_topView).offset(5);
            make.width.equalTo(@25);
        }];
        
        [_titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.centerX.mas_equalTo(_topView);
            make.size.mas_equalTo(CGSizeMake(120.0, 25.0));
        }];
        
        
        
    }
    return _topView;
}
-(UIImageView *)thubmImageView{
    if (nil==_thubmImageView) {
        _thubmImageView=[UIImageView new];
        _thubmImageView.backgroundColor=[UIColor blackColor];
        _thubmImageView.hidden=YES;
        [self addSubview:_thubmImageView];
        __weak OCVideoPlayerControlView *weakSelf=self;
        [_thubmImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(weakSelf.slider.mas_top).offset(-10);
            make.size.mas_equalTo(CGSizeMake(100, 80));
        }];
    }
    return _thubmImageView;
}
-(UIView *)bottomView{
    if (nil==_bottomView) {
        _bottomView=[[UIView alloc]  init];
        _bottomView.userInteractionEnabled=YES;
        _bottomView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:[@"progress_bg01" ocVideoImageName]]];
        __weak OCVideoPlayerControlView *weakSelf=self;
        _actionButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.selected=YES;
        [_actionButton addTarget:self action:@selector(didActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_actionButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_play" ocVideoImageName]] forState:UIControlStateNormal];
        [_actionButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_pause" ocVideoImageName]] forState:UIControlStateSelected];
        [_bottomView addSubview:_actionButton];
        
        
        _nextButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton addTarget:self action:@selector(didActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_nextButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_next" ocVideoImageName]] forState:UIControlStateNormal];
        [_nextButton setBackgroundImage:[UIImage imageNamed:[@"fullplayer_icon_next" ocVideoImageName]] forState:UIControlStateSelected];
        [_bottomView addSubview:_nextButton];
        
        _fullPlayTimeLable=[[UILabel alloc]  init];
        _fullPlayTimeLable.font=[UIFont systemFontOfSize:10];
        _fullPlayTimeLable.textColor=[UIColor whiteColor];
        _fullPlayTimeLable.textAlignment=NSTextAlignmentCenter;
        _fullPlayTimeLable.text=@"00:00";
        [_bottomView addSubview:_fullPlayTimeLable];
        
        
        _progressView=[[UIProgressView alloc]  initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progress=0;
        [_bottomView addSubview:_progressView];
        //                _progressView.progressImage=[UIImage imageNamed:[@"progress_bg02" ocVideoImageName]];
        //                _progressView.trackImage=[UIImage imageNamed:[@"progress_bg03" ocVideoImageName]];
        
        
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
        [_bottomView addSubview:_slider];
        
        
        
        _timeLable=[[UILabel alloc]  init];
        _timeLable.font=[UIFont systemFontOfSize:10];
        _timeLable.textColor=[UIColor whiteColor];
        _timeLable.textAlignment=NSTextAlignmentCenter;
        _timeLable.text=@"00:00";
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
        [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_actionButton);
            make.width.equalTo(@20);
            make.left.mas_equalTo(_actionButton.mas_right).offset(5);
        }];
        
        [_fullPlayTimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.progressView.mas_left).offset(-5);
            make.centerY.mas_equalTo(_actionButton);
            make.left.equalTo(_nextButton.mas_right).offset(5);
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


@end
