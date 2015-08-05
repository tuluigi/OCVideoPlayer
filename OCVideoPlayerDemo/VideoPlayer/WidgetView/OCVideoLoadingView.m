//
//  OCVideoLoadingView.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/27.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "OCVideoLoadingView.h"
#import "Masonry.h"
@interface OCVideoLoadingView ()
@property(nonatomic,strong)UIActivityIndicatorView *indicatorView;
@property(nonatomic,strong)UILabel *speedLable,*messageLable;
@end

@implementation OCVideoLoadingView
+(OCVideoLoadingView *)ocVideoLoadingView{
    OCVideoLoadingView *videoLoadingView=[[OCVideoLoadingView alloc]  init];
    return videoLoadingView;
}
-(BOOL)isDisplay{
    return !self.hidden;
}
-(void)setDisplay:(BOOL)display{
    if (display) {
        [self.indicatorView startAnimating];
        self.hidden=NO;
    }else{
        [self.indicatorView stopAnimating];
        self.hidden=YES;
    }
}


-(void)willMoveToSuperview:(UIView *)newSuperview{

}
-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    __weak OCVideoLoadingView * weakSelf=self;
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.superview);
        make.size.mas_equalTo(CGSizeMake(120, 55.0));
    }];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
-(instancetype)init{
    if (self=[super init]) {
        [self initUI];
    }
    return self;
}
-(void)showErrorMessage:(NSString *)msg{
    self.display=YES;
    self.messageLable.text=msg;
}
-(void)showBufferingMessage:(NSString *)msg bitRate:(CGFloat)bitRate{
    self.display=YES;
    self.bitRate=bitRate;
    self.messageLable.text=msg;
}
-(void)dismiss{
    self.display=NO;
}
-(void)initUI{
    self.backgroundColor=[UIColor blackColor];
    _indicatorView=[[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicatorView.hidesWhenStopped=YES;
    [self addSubview:_indicatorView];
    
    _speedLable=[UILabel new];
    _speedLable.text=@"";
    _speedLable.textColor=[UIColor lightGrayColor];
    _speedLable.font=[UIFont systemFontOfSize:14];
    _speedLable.textAlignment=NSTextAlignmentLeft;
    [self addSubview:_speedLable];
    
    _messageLable=[UILabel new];
    _messageLable.text=@"正在缓冲,请稍后...";
    _messageLable.textColor=[UIColor lightGrayColor];
    _messageLable.font=[UIFont systemFontOfSize:14];
    _messageLable.textAlignment=NSTextAlignmentCenter;
    [self addSubview:_messageLable];
    
    __weak OCVideoLoadingView *weakSelf=self;
    [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [_speedLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_indicatorView.mas_right).offset(3);
        make.top.mas_equalTo(_indicatorView);
        make.right.mas_equalTo(weakSelf).offset(-5);
        make.height.mas_equalTo(20);
    }];
    [_messageLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.mas_equalTo(_indicatorView.mas_bottom).offset(5);
        make.right.mas_equalTo(0);
        make.height.mas_lessThanOrEqualTo(20);
    }];

}
-(void)setBitRate:(CGFloat)bitRate{
    _bitRate=bitRate;
    NSString *rateStr=_speedLable.text;
    if (bitRate>=1000.0*1000) {
        rateStr=[NSString stringWithFormat:@"%.2fMB/s",(bitRate/(1000.0*1000))];
    }else{
        rateStr=[NSString stringWithFormat:@"%.2fKB/s",(bitRate/(1000.0))];
    }
    _speedLable.text=rateStr;
}

/*
 
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
