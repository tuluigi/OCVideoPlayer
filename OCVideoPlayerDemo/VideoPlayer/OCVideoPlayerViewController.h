//
//  OCVideoPlayerViewController.h
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/8/3.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OCVideoPlayer;
@interface OCVideoPlayerViewController : UIViewController
-(instancetype)initWithContentUrls:(NSArray *)contentUrls;
@property(nonatomic,readonly)OCVideoPlayer *videoPlayer;
@end
