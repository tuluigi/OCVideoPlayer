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
@interface ViewController ()
@property(nonatomic,strong)OCVideoPlayer *videoPlayer;
@end

@implementation ViewController
-(OCVideoPlayer *)videoPlayer{
    if (nil==_videoPlayer) {
//        _videoPlayer=[[OCVideoPlayer alloc]  initWithContentUrls:[NSArray arrayWithObject:[NSURL URLWithString:@"http://mov.bn.netease.com/mobilev/2012/6/C/3/S82UN73C3.mp4"]]];
         _videoPlayer=[[OCVideoPlayer alloc]  initWithContentUrls:[NSArray arrayWithObject:[NSURL URLWithString:@"http://mov.bn.netease.com/mobilev/2013/1/Q/0/S8L2FGOQ0.mp4"]]];
    }
    return _videoPlayer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.videoPlayer.playerView];
    __weak ViewController *weakSelf=self;
    [self.videoPlayer.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.view);
    }];

    [self.videoPlayer playVideoAtInde:0];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
