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
    OCVideoPlayerStateSuspend   ,
    OCVideoPlayerStateDismissed ,
    OCVideoPlayerStateError     ,
} ;

typedef NS_ENUM(NSInteger, OCVideoPlayerControlEvent) {
    OCVideoPlayerControlEventTapPlayerView,
    OCVideoPlayerControlEventTapNext,
    OCVideoPlayerControlEventTapPrevious,
    OCVideoPlayerControlEventTapDone,
    OCVideoPlayerControlEventTapFullScreen,
    OCVideoPlayerControlEventTapCaption,
    OCVideoPlayerControlEventTapVideoQuality,
    OCVideoPlayerControlEventSwipeNext,
    OCVideoPlayerControlEventSwipePrevious,
} ;

#endif
