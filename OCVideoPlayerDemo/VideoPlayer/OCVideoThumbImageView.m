//
//  OCVideoThumbImageView.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/8/7.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "OCVideoThumbImageView.h"
#import "Masonry.h"
@interface OCVideoThumbImageView ()
@property(nonatomic,strong)UIImageView *thumbImageView;
@property(nonatomic,strong)UILabel *timeLable;
@property (nonatomic,strong)UIActivityIndicatorView *indicatorView;
@end

@implementation OCVideoThumbImageView
+(OCVideoThumbImageView *)videoThumbView{
    OCVideoThumbImageView *thumbImageView=[[OCVideoThumbImageView alloc]  init];
    return thumbImageView;
}
-(instancetype)init{
    if ([self initWithFrame:CGRectZero]) {
        [self onInitUI];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self onInitUI];
    }
    return self;
}
-(void)willMoveToSuperview:(UIView *)newSuperview{

}
-(void)didMoveToSuperview{

}
-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if (hidden) {
        [self setThumbImage:nil atTime:nil];
    }
}
-(void)onInitUI{
    self.backgroundColor=[UIColor blackColor];
    _thumbImageView=[[UIImageView alloc]  init];
    _thumbImageView.backgroundColor=[UIColor clearColor];
    [self addSubview:_thumbImageView];
    
    _timeLable=[[UILabel alloc]  init];
    _timeLable.textAlignment=NSTextAlignmentCenter;
    _timeLable.font=[UIFont systemFontOfSize:12];
    _timeLable.textColor=[UIColor whiteColor];
    [self addSubview:_timeLable];
    
    _indicatorView=[[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicatorView.hidesWhenStopped=YES;
    [_thumbImageView addSubview:_indicatorView];
    
    __weak OCVideoThumbImageView *weakSelf=self;
    [_timeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.right.mas_equalTo(weakSelf);
        make.bottom.mas_equalTo(weakSelf.thumbImageView.mas_top);
        make.height.mas_equalTo(15.0);
    }];
    [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.timeLable.mas_bottom);
    }];
    [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(_thumbImageView.center);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}
-(void)setThumbImage:(UIImage *)image atTime:(NSString *)time{
    if (image) {
        [self.indicatorView stopAnimating];
        self.thumbImageView.image=image;
    }else{
        [self.indicatorView startAnimating];
        self.thumbImageView.image=nil;
    }
    if (time) {
            self.timeLable.text=time;
    }else{
        self.timeLable.text=@"";
    }

}
@end
