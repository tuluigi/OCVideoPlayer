//
//  ViewController.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/7/16.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "ViewController.h"
#import "OCVideoPlayer.h"
#import "Masonry.h"
#import <MediaPlayer/MediaPlayer.h>
#import "OCVideoPlayerViewController.h"

#define VideoPlayerHeight 200

@interface ViewController ()
@property(nonatomic,strong)OCVideoPlayer *videoPlayer;
@property(nonatomic,strong)OCVideoPlayerViewController *playerController;
@end

@implementation ViewController
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(NSArray *)contentUrls{
    return @[
             [NSURL URLWithString:@"http://mov.bn.netease.com/mobilev/open/nos/mp4/2014/11/19/SAAG6ERRO_sd.mp4"],
             [NSURL URLWithString:@"http://mov.bn.netease.com/mobilev/2012/6/C/3/S82UN73C3.mp4"],
             [NSURL URLWithString:@"http://mov.bn.netease.com/movie/2012/5/J/D/S81QUQFJD.mp4"],
             [NSURL URLWithString:@"http://mov.bn.netease.com/mobilev/open/nos/mp4/2015/05/22/SAP9VVGKA_sd.mp4"],
             [NSURL URLWithString:@"http://mov.bn.netease.com/movie/2012/5/0/5/S81QUQT05.mp4"],
             [NSURL URLWithString:@"http://mov.bn.netease.com/movie/2012/5/A/9/S81R6LTA9.mp4"],
             [NSURL URLWithString:@"http://mov.bn.netease.com/movie/2012/5/A/D/S81R64GAD.mp4"],
             [NSURL URLWithString:@"http://mov.bn.netease.com/movie/2012/5/P/L/S81R5NUPL.mp4"],
             ];
}
-(OCVideoPlayer *)videoPlayer{
    if (nil==_videoPlayer) {
        //http://mov.bn.netease.com/movie/2012/5/J/D/S81QUQFJD.mp4
        NSArray *urlsArray= [self contentUrls];
        _videoPlayer=[[OCVideoPlayer alloc]  initWithContentUrls:urlsArray];
        
    }
    return _videoPlayer;
}
-(OCVideoPlayerViewController *)playerController{
    if (nil==_playerController) {
        _playerController=[[OCVideoPlayerViewController alloc]  initWithContentUrls:[self contentUrls]];
    }
    return _playerController;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    __weak ViewController *weakSelf=self;
    
    /*
     [self.view addSubview:self.videoPlayer.playerView];
     [self.videoPlayer.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.edges.mas_equalTo(weakSelf.view);
     }];
     */
    [self onInitUIWithContentUrls:[self contentUrls]];
    [[NSNotificationCenter defaultCenter] addObserverForName:OCVideoPlayerStateChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [weakSelf handlerOCVideoStateChangedNotifcation:note];
    }];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)handlerOCVideoStateChangedNotifcation:(NSNotification *)note{
    NSDictionary *userInfo=[note userInfo];
    OCVideoPlayerState state=[[userInfo objectForKey:OCVideoPlayerStateKey] integerValue];
    NSURL *url=[userInfo objectForKey:OCVideoPlayerItemUrlKey];
    UIButton *button=(UIButton *)[self.view viewWithTag:([[self contentUrls] indexOfObject:url]+1000)];
    switch (state) {
        case OCVideoPlayerStateReadPlay:
        {
            button.selected=YES;
        } break;
        case OCVideoPlayerStateFinsihed:{
            button.selected=NO;
        }break;
        default:
            break;
    }
}
-(void)onInitUIWithContentUrls:(NSArray *)contentUrl{
     __weak ViewController *weakSelf=self;
    [self.view addSubview:self.playerController.view];
    [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf.view);
        make.height.mas_equalTo(VideoPlayerHeight);
    }];

    NSInteger colum=5;
    CGFloat padding=10.0f;
    CGFloat width=(CGRectGetWidth(self.view.bounds)-(colum+1)*padding)/colum;
    for (NSInteger i=0; i<contentUrl.count; i++) {
        NSInteger offx,offy;
        offx=i%colum;
        offy=i/colum;
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        if (i==0) {
            button.selected=YES;
        }
        button.tag=i+1000;
        [button setTitle:[NSString stringWithFormat:@"%ld",i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        button.titleLabel.font=[UIFont boldSystemFontOfSize:20];
        button.frame=CGRectMake((padding+width)*offx+padding, (padding+width)*offy+padding+VideoPlayerHeight, width, width);
        button.layer.borderColor=[UIColor lightGrayColor].CGColor;
        button.layer.borderWidth=1.0;
        [button addTarget:self action:@selector(didMenuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}
-(void)didMenuButtonClicked:(UIButton *)sender{
    sender.selected=!sender.selected;
    [self.playerController.videoPlayer playVideoAtInde:(sender.tag-1000)];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
