//
//  OCVideoThumbImageView.h
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/8/7.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OCVideoThumbImageView : UIView
+(OCVideoThumbImageView *)videoThumbView;
@property(nonatomic,copy)NSString *playTime;
@property(nonatomic,strong)UIImage *thumbImage;
-(void)setThumbImage:(UIImage *)image atTime:(NSString *)time;
@end
