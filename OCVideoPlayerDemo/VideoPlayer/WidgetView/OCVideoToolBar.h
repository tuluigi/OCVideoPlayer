//
//  OCVideoToolBar.h
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/8/5.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCVidePlayerKit.h"
@interface OCVideoToolBar : UIToolbar
@property(nonatomic,weak)id<OCVideoControlEventDelegate>controlDelegate;
/**
 *  设置播放最小和最大时间
 *
 *  @param minValue 最小时间
 *  @param maxValue 最大时间
 */
-(void)setTrackMinValue:(NSTimeInterval)minValue maxVlaue:(NSTimeInterval)maxValue;
-(void)updateTrackCurrentPlayTime:(NSTimeInterval)currentTime;
-(void)updateTrackLoadedTime:(NSTimeInterval)loadedTime;
@end
