//
//  OCVideoPlayerControlView.h
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/21.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCVidePlayerKit.h"
typedef NS_ENUM(NSInteger, OCVideoSwipeDirection) {
    OCVideoSwipeDirectionUnknown,
    OCVideoSwipeDirectionHorizontal,
    OCVideoSwipeDirectionVertical,
};

typedef void(^ControlViewTrackingBlock)(NSDictionary *userInfo);
@protocol OCVideoPlayerControlViewDelegate <NSObject>

//滑动
-(void)videoPlayerControlViewBeginSwipeWithDirection:(OCVideoSwipeDirection)direction;
-(void)videoPlayerControlViewSwipingWithDirection:(OCVideoSwipeDirection)direction value:(CGFloat)value handlerBlock:(ControlViewTrackingBlock) block;
-(void)videoPlayerControlViewEndedSwipeWithDirection:(OCVideoSwipeDirection)direction value:(CGFloat)value;

//事件操作
-(void)videoPlayerControlViewActionWithEvent:(OCVideoPlayerControlEvent)event userInfo:(NSDictionary *)userInfo;

@end

UIKIT_EXTERN NSString * const OCVidePlayerThumbnailImageKey ;

@interface OCVideoPlayerControlView : UIView

@property(nonatomic,weak)id<OCVideoControlEventDelegate>controlDelegate;

@property(nonatomic,weak)id<OCVideoPlayerControlViewDelegate>delegate;

#pragma mark -Title
@property(nonatomic,copy)NSString *title;

#pragma mark - bufferRate
@property(nonatomic,assign)BOOL isShowBufferView;
-(void)updateBufferBitRate:(CGFloat)bitRate;


#pragma mark - sliderVlaue
/**
 *  设置播放最小和最大时间
 *
 *  @param minValue 最小时间
 *  @param maxValue 最大时间
 */
-(void)setTrackMinValue:(NSTimeInterval)minValue maxVlaue:(NSTimeInterval)maxValue;
-(void)updateTrackCurrentPlayTime:(NSTimeInterval)currentTime;
-(void)updateTrackLoadedTime:(NSTimeInterval)loadedTime;

#pragma mark -Hand Event
-(void)handlerActionWithEvent:(OCVideoPlayerControlEvent)event userInfo:(NSDictionary *)userInfo;

//-(void)handlerAvPlyaerItem:(AVPlayerItemStatus)status;

@end
