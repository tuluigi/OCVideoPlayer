//
//  OCVideoPlayerControlView.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/21.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "OCVideoPlayerControlView.h"
#import "Masonry.h"
@interface OCVideoPlayerControlView ()
@property (nonatomic,strong)UIView  *bottomView;
@property (nonatomic,strong)UIButton *actionButton;
@end

@implementation OCVideoPlayerControlView
-(instancetype)init{
    if (self=[super init]) {
        [self addSubview:self.bottomView];
        __weak OCVideoPlayerControlView *weakSelf=self;
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(weakSelf);
            make.height.equalTo(@40);
        }];
    }
    return self;
}
#pragma setter getter
-(UIView *)bottomView{
    if (nil==_bottomView) {
        _bottomView=[[UIView alloc]  init];
        _bottomView.backgroundColor=[UIColor redColor];
        _actionButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_actionButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_actionButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    }
    return _bottomView;
}

#pragma mark -selecter
-(void)didActionButtonClicked:(UIButton *)sender{
    sender.selected=!sender.selected;
}
@end
