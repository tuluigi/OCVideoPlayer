//
//  OCVideToolView.h
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/8/5.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCVidePlayerKit.h"

@protocol OCVideoToolViewDelegate <NSObject>

-(void)didTrackValueChanging:(CGFloat)value;
-(void)didTrackValueEndedChang:(CGFloat)value;

@end


@interface OCVideToolView : UIView
@property(nonatomic,assign,readonly) NSTimeInterval minTime,maxTime;
@property(nonatomic,assign) NSTimeInterval currentTime;
@property(nonatomic,copy,readonly)NSString *playTimeStr;
@property(nonatomic,assign) NSTimeInterval loadedTime;


@property(nonatomic,assign)CGFloat sliderThumbImagePointX;

@property (nonatomic,weak)id <OCVideoToolViewDelegate>delegate;
@property(nonatomic,weak)id<OCVideoControlEventDelegate>controlDelegate;




@property(nonatomic,assign,getter=isPlay) BOOL play;




/**
 *  设置播放最小和最大时间
 *
 *  @param minValue 最小时间
 *  @param maxValue 最大时间
 */
-(void)setTrackMinValue:(NSTimeInterval)minValue maxVlaue:(NSTimeInterval)maxValue;


@end
