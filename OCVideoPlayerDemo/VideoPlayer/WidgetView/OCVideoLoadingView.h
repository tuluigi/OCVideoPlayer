//
//  OCVideoLoadingView.h
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/27.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OCVideoLoadingView : UIView
@property(nonatomic,assign,getter=isDisplay)BOOL display;
@property (nonatomic,assign) CGFloat bitRate;
+(OCVideoLoadingView *)ocVideoLoadingView;
-(void)showErrorMessage:(NSString *)msg;
-(void)showBufferingMessage:(NSString *)msg bitRate:(CGFloat)bitRate;
-(void)dismiss;
@end
