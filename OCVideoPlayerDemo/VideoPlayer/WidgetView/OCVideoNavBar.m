//
//  OCVideoNavBar.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/8/5.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "OCVideoNavBar.h"
#import "NSString+OCPlayer.h"
@interface OCVideoNavBar ()
@property (nonatomic,strong)UIBarButtonItem *backBarButtonItem,*doneBarButtonItem;
@end

@implementation OCVideoNavBar
-(instancetype)init{
    if (self=[super init]) {
        [self onInitItems];
    }
    return self;
}
-(void)setTitle:(NSString *)title{
    self.topItem.title=title;
}
-(NSString *)title{
    return self.topItem.title;
}
-(void)onInitItems{
    self.tintColor=[UIColor whiteColor];
    _backBarButtonItem=[[UIBarButtonItem alloc]  initWithImage:[UIImage imageNamed:[@"fullplayer_icon_back" ocVideoImageName]] style:UIBarButtonItemStylePlain target:self action:@selector(didNavBarButtonItemClicked:)];
   
    _doneBarButtonItem=[[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didNavBarButtonItemClicked:)];
    UINavigationItem *navItem=[[UINavigationItem alloc]  init];
    [navItem setLeftBarButtonItem:_backBarButtonItem animated:YES];
    [navItem setRightBarButtonItem:_doneBarButtonItem  animated:YES];
    [self setItems:@[navItem] animated:NO];
}

-(void)didNavBarButtonItemClicked:(UIBarButtonItem *)sender{
    OCVideoPlayerControlEvent event=OCVideoPlayerControlEventUnKnown;
    if (sender==_backBarButtonItem) {
        event=OCVideoPlayerControlEventBack;
    }else if (sender==_doneBarButtonItem){
    
    }
    if (_controlDelegate&&[_controlDelegate respondsToSelector:@selector(didOcVideoPlayerHandleActionWithControlEvent:userInfo:)]) {
        [_controlDelegate didOcVideoPlayerHandleActionWithControlEvent:event userInfo:nil];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
