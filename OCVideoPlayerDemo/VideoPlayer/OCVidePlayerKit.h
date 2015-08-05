//
//  OCVidePlayerKit.h
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/22.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#ifndef OCVideoPlayerDemo_OCVidePlayerKit_h
#define OCVideoPlayerDemo_OCVidePlayerKit_h
typedef NS_ENUM(NSInteger, OCVideoPlayerState)  {
    OCVideoPlayerStateUnknown   ,
    OCVideoPlayerStateLoading   ,
    OCVideoPlayerStateReadPlay  ,
    OCVideoPlayerStatePlaying   ,
    OCVideoPlayerStatePaused   ,
    OCVideoPlayerStateStalled   ,
    OCVideoPlayerStateFinsihed  ,
    OCVideoPlayerStateDismissed ,
    OCVideoPlayerStateError     ,
} ;

typedef NS_ENUM(NSInteger, OCVideoPlayerItemState)  {
    OCVideoPlayerItemStateUnknown   ,
    OCVideoPlayerItemStateReadPlay  ,
    OCVideoPlayerItemStateFiled     ,
} ;

typedef NS_ENUM(NSInteger, OCVideoPlayerControlEvent) {
    OCVideoPlayerControlEventUnKnown        ,
    OCVideoPlayerControlEventPlay           ,
    OCVideoPlayerControlEventPause          ,
    OCVideoPlayerControlEventNext           ,
    OCVideoPlayerControlEventPrevious       ,
    OCVideoPlayerControlEventFullScreen     ,
    OCVideoPlayerControlEventBack           ,
};



extern NSString * const OCVideoPlayerOrientationDidChangedNotification;
extern NSString * const OCVideoPlayerStateChangedNotification;

extern NSString * const OCVideoPlayerItemStateChangedNotification;
extern NSString * const OCVideoPlayerItemPlayToEndTimeNotification;

extern NSString * const OCVideoPlayerItemUrlKey;
extern NSString * const OCVideoPlayerStateKey;
extern NSString * const OCVideoPlayerQueueItemsCountKey;
extern NSString * const OCVideoPlayerErrorKey;


@protocol OCVideoControlEventDelegate <NSObject>
-(void)didOcVideoPlayerHandleActionWithControlEvent:(OCVideoPlayerControlEvent)event userInfo:(NSDictionary *)userInfo;
@end
#endif
