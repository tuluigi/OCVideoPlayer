//
//  OCVideoNavBar.h
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/8/5.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCVidePlayerKit.h"



@interface OCVideoNavBar : UINavigationBar
@property(nonatomic,copy)NSString *title;
@property(nonatomic,weak)id<OCVideoControlEventDelegate>controlDelegate;
@end
