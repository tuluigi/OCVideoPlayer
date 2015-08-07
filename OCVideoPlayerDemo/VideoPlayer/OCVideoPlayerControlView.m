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
#import "OCVideToolView.h"
#import "OCVideoNavBar.h"
#import "OCVideoThumbImageView.h"
NSString * const OCVidePlayerThumbnailImageKey =@"OCVidePlayerThumbnailImageKey";
@interface OCVideoPlayerControlView ()<OCVideoToolViewDelegate,OCVideoControlEventDelegate>
@property (nonatomic,strong)UIView  *bottomView,*topView;
@property (nonatomic,strong)OCVideoNavBar   *navBar;
@property (nonatomic,strong)OCVideToolView  *toolView;
@property (nonatomic,strong)OCVideoThumbImageView *thumbView;

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
        __weak OCVideoPlayerControlView *weakSelf=self;
        [self addSubview:self.navBar];
        [self addSubview:self.toolView];
        
        [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(weakSelf);
            make.height.equalTo(@40);
        }];
        [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    self.toolView.play=YES;
}
-(void)pause{
    self.toolView.play=NO;
}
-(BOOL)isPlaying{
    return self.toolView.isPlay;
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
        case OCVideoPlayerStateFinsihed:{
            [self pause];
            [self.toolView setTrackMinValue:0 maxVlaue:0];
            self.toolView.currentTime=0;
            self.toolView.loadedTime=0;
        }break;
        default:
            break;
    }
}
-(void)handVideoItemStateChangedNotification:(NSDictionary *)userInfo{
    NSInteger itemCount=[[userInfo objectForKey:OCVideoPlayerQueueItemsCountKey] integerValue];
    if (itemCount>1) {
       
    }
}
-(void)setTitle:(NSString *)title{
    if (nil==title) {
        [self.navBar setTitle:@""];
    }else{
        [self.navBar setTitle:title];
    }
}
-(NSString *)title{
    return self.navBar.title ;
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

-(void)setTrackMinValue:(NSTimeInterval)minValue maxVlaue:(NSTimeInterval)maxValue{
    [self.toolView setTrackMinValue:minValue maxVlaue:maxValue];
}
-(void)updateTrackCurrentPlayTime:(NSTimeInterval)currentTime{
    self.toolView.currentTime=currentTime;
    [self updateThumbImagePosition];
       //    UIDeviceOrientation orientation=[[UIDevice currentDevice] orientation];
    //    [self resetUIWithDeviceOrientation:orientation];
}
-(void)updateThumbImagePosition{
    if ((!self.thumbView.hidden)&&(![self isWidgetViewHidden])) {
        CGFloat offx=self.toolView.sliderThumbImagePointX-CGRectGetWidth(_thumbView.bounds)/2;
        [self.thumbView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(offx);
        }];
        [self layoutIfNeeded];
    }
}
-(void)updateTrackLoadedTime:(NSTimeInterval)loadedTime{
    self.toolView.loadedTime=loadedTime;
}
-(void)resetUIWithDeviceOrientation:(UIDeviceOrientation)orientation{
    if (orientation==UIDeviceOrientationPortrait||orientation==UIDeviceOrientationPortraitUpsideDown) {
    }else if(orientation==UIDeviceOrientationLandscapeLeft||orientation==UIDeviceOrientationLandscapeRight){
        
    }
}
#pragma mark -UITouch
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
                        self.thumbView.hidden=NO;
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
        self.thumbView.hidden=YES;
        if (_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControlViewEndedSwipeWithDirection:value:)]) {
            CGFloat value=0;
            if ( self.swipeDirection==OCVideoSwipeDirectionVertical) {
                
            }else if(self.swipeDirection==OCVideoSwipeDirectionHorizontal){
                value=self.toolView.currentTime;
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
            NSTimeInterval timeValue=self.toolView.currentTime+(offsetPoint.x>0?1:-1);
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
//        [self.thumbView setThumbImage:nil atTime:[self.toolView playTimeStr]];
        [_delegate videoPlayerControlViewSwipingWithDirection:self.swipeDirection value:self.toolView.currentTime handlerBlock:^(NSDictionary *userInfo) {
            if (userInfo&&direction==OCVideoSwipeDirectionHorizontal&&!weakSelf.thumbView.hidden&&![weakSelf isWidgetViewHidden]) {
                UIImage *thumbImage=[userInfo objectForKey:OCVidePlayerThumbnailImageKey];
                     [weakSelf.thumbView setThumbImage:thumbImage atTime:[weakSelf.toolView playTimeStr]];
            }
        }];
    }
}
-(void)handleTouchEvent:(UITouch *)aTouch{
    //    if (aTouch.tapCount==1) {
    __weak OCVideoPlayerControlView *weakSelf=self;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
         weakSelf.navBar.hidden=weakSelf.toolView.hidden=!weakSelf.toolView.hidden;
    } completion:^(BOOL finished) {
        
    }];
    //    }
}

#pragma mark -getter
-(BOOL)isWidgetViewHidden{
    return _toolView.hidden&&_navBar.hidden;
}
-(OCVideoLoadingView *)loadingView{
    if (nil==_loadingView) {
        _loadingView=[OCVideoLoadingView ocVideoLoadingView];
        [self addSubview:_loadingView];
    }
    return _loadingView;
}

-(OCVideoNavBar *)navBar{
    if (nil==_navBar) {
        _navBar=[[OCVideoNavBar alloc]  init];
        _navBar.barStyle=UIBarStyleBlackOpaque;
        _navBar.controlDelegate=self;
    }
    return _navBar;
}


-(OCVideoThumbImageView *)thumbView{
    if (nil==_thumbView) {
        _thumbView=[OCVideoThumbImageView videoThumbView];
        _thumbView.hidden=YES;
        [self addSubview:_thumbView];
        __weak OCVideoPlayerControlView *weakSelf=self;
        [_thumbView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(weakSelf.toolView.mas_top).offset(5);
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];
    }
    return _thumbView;
}
-(OCVideToolView *)toolView{
    if (nil==_toolView) {
        _toolView=[[OCVideToolView alloc]  init];
        _toolView.userInteractionEnabled=YES;
        
        _toolView.delegate=self;
        _toolView.controlDelegate=self;
    }
    return _toolView;
}


#pragma mark -delegate
-(void)didOcVideoPlayerHandleActionWithControlEvent:(OCVideoPlayerControlEvent)event userInfo:(NSDictionary *)userInfo{
    if (_controlDelegate&&[_controlDelegate respondsToSelector:@selector(didOcVideoPlayerHandleActionWithControlEvent:userInfo:)]) {
        [_controlDelegate didOcVideoPlayerHandleActionWithControlEvent:event userInfo:userInfo];
    }
}
#pragma mark - ToolViewDelegate
-(void)didTrackValueChanging:(CGFloat)value{
    self.thumbView.hidden=NO;
    [self updateThumbImagePosition];
    __weak OCVideoPlayerControlView *weakSelf=self;
    if (_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControlViewSwipingWithDirection:value:handlerBlock:)]) {
//         [self.thumbView setThumbImage:nil atTime:[self.toolView playTimeStr]];
        [_delegate videoPlayerControlViewSwipingWithDirection:OCVideoSwipeDirectionHorizontal value:value handlerBlock:^(NSDictionary *userInfo) {
            if (userInfo) {
                [weakSelf.thumbView setThumbImage:[userInfo objectForKey:OCVidePlayerThumbnailImageKey] atTime:[weakSelf.toolView playTimeStr]];
            }
        }];
    }
    
}
-(void)didTrackValueEndedChang:(CGFloat)value{
    [self.thumbView setThumbImage:nil atTime:nil];
    self.thumbView.hidden=YES;
    if (_delegate&&[_delegate respondsToSelector:@selector(videoPlayerControlViewEndedSwipeWithDirection:value:)]) {
        [_delegate videoPlayerControlViewEndedSwipeWithDirection:OCVideoSwipeDirectionHorizontal value:value];
    }

}
@end
