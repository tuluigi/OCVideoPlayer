//
//  OCVideoPlayerViewController.m
//  OCVideoPlayerDemo
//
//  Created by Luigi on 15/8/3.
//  Copyright (c) 2015年 Luigi. All rights reserved.
//

#import "OCVideoPlayerViewController.h"
#import "OCVideoPlayer.h"
#import "Masonry.h"
@interface OCVideoPlayerViewController ()<OCVideoPlayerDelegate>
@property(nonatomic,readwrite)OCVideoPlayer * videoPlayer;
@end

@implementation OCVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(instancetype)initWithContentUrls:(NSArray *)contentUrls{
    if (self=[super init]) {
        _videoPlayer=[[OCVideoPlayer alloc] initWithContentUrls:contentUrls];
        _videoPlayer.delegate=self;
        [self.view addSubview:_videoPlayer.playerView];
        __weak OCVideoPlayerViewController *weakSelf=self;
        [_videoPlayer.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.view);
        }];
    }
    return self;
}


#pragma mark -ocvidePlayerDelegate
-(void)ocVidePlayer:(OCVideoPlayer *)videoPlayer didControlByEvent:(OCVideoPlayerControlEvent)event{
    switch (event) {
        case OCVideoPlayerControlEventFullScreen:
        {
//            [[UIDevice currentDevice] setValue:
//             [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight]
//                                        forKey:@"orientation"];
            
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
            self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
            CGRect frame = [UIScreen mainScreen].applicationFrame;
            self.view.bounds = CGRectMake(0, 0, frame.size.height, frame.size.width);
            [self.view setNeedsLayout];
        }
            break;
            
        default:
            break;
    }
}
-(void)ocVidePlayer:(OCVideoPlayer *)videoPlayer finsihedPlayContentUrl:(NSURL *)url nextContentUrl:(NSURL *)nextUrl{
//    NSInteger index=[self.videoPlayer.contentURLArray indexOfObject:url];
//    NSInteger nextIndex=[self.videoPlayer.contentURLArray indexOfObject:nextUrl];
    
    
}
#pragma mark - Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (self.videoPlayer.enableFullScreen) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return NO;
    }
}
#ifdef __IPHONE_6_0
- (BOOL)shouldAutorotate {
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait|UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight|UIInterfaceOrientationPortraitUpsideDown;

}
#endif
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
