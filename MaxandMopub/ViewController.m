//
//  ViewController.m
//  MaxandMopub
//
//  Created by game team on 2020/8/28.
//  Copyright © 2020 yjg. All rights reserved.
//

#import "ViewController.h"
//add
#import <AppLovinSDK/AppLovinSDK.h>
#import <MPMoPubConfiguration.h>
#import <MoPub.h>


@interface ViewController ()<MAAdDelegate,MARewardedAdDelegate,MPRewardedVideoDelegate>
@property (nonatomic, strong) MAInterstitialAd *interstitialAd;
@property (nonatomic, assign) NSInteger interRetryAttempt;
@property (nonatomic, strong) MARewardedAd *rewardedAd;
@property (nonatomic, assign) NSInteger rewardRetryAttempt;
@end

NSString *mMaxInterID=@"e161529271a72201";
NSString *mMaxRewardID=@"ee5718df87bc32dc";

NSString *mMopubInterID=@"";
NSString *mMopubRewardID=@"bfc6450f13c348debabe2348ab61e871";

NSString *UnionSwitch = @"0";//1 max;0 mopoub

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //激励显示按钮
    UIButton *buttonRewardShow = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonRewardShow setTitle:@"激励显示" forState:UIControlStateNormal];
    [buttonRewardShow setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    
    buttonRewardShow.frame = CGRectMake(50, 200, 100, 100);
    //注册点击事件
    [buttonRewardShow addTarget:self action:@selector(showHwRewardAd) forControlEvents:UIControlEventTouchUpInside];
    //把动态创建的按钮添加到控制器所管理的那个view中
    [self.view addSubview:buttonRewardShow];
    
    
    //插屏显示按钮
    UIButton *buttonInterShow = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonInterShow setTitle:@"插屏显示" forState:UIControlStateNormal];
    [buttonInterShow setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    
    buttonInterShow.frame = CGRectMake(50, 400, 100, 100);
    //注册点击事件
    [buttonInterShow addTarget:self action:@selector(showHwInterAd) forControlEvents:UIControlEventTouchUpInside];
    //把动态创建的按钮添加到控制器所管理的那个view中
    [self.view addSubview:buttonInterShow];
    
    
    //第一步调用初始化SDK
    if(UnionSwitch == @"1"){
        [self initMax];
    }else{
        [self initMopub];
    }
}

- (void)showHwInterAd{
    NSLog(@"call ShowInterAd 11111111111111");
//    [[HwAds instance] showInter];
}

- (BOOL)isHwInterAdLoaded{
    NSLog(@"call isInterLoaded");
//    return [[HwAds instance] isInterLoad];
    return true;
}


- (void)hwFbEvent:(NSString *)category
                   action:(NSString *)action
                   label:(NSString *)label{
    NSLog(@"Facebook event category:%@ action:%@ label:%@",category,action,label);
    NSDictionary *params =
    @{
      action : label,
      @"ACTION_EVENT" : action
      };
//    [FBSDKAppEvents
//     logEvent:category
//     parameters:params];
}

- (void)showHwRewardAd{
    char * tag = @"test";
    NSLog(@"call showRewardedVideo");
//    [[HwAds instance] showReward:[NSString stringWithUTF8String:tag]];
    
    if(UnionSwitch == @"1"){
        NSLog(@"显示max 激励");
        [self showMaxReward];
    }else{
        NSLog(@"显示mopub 激励");
        [self mopubShowReward];
    }
    
}


- (void)initMax{
    [ALSdk shared].mediationProvider = @"max";
    [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {
        //AppLovin SDK 初始化成功，可以开始加载广告
        [self loadMaxReward];
    }];
}

- (void)loadMaxInter{
    if(self.interstitialAd == nil){
        self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier: mMaxInterID];
        self.interstitialAd.delegate = self;
    }
    
    [self.interstitialAd loadAd];
}

- (void)showMaxInter{
    if ([self.interstitialAd isReady])
    {
        [self.interstitialAd showAd];
    }
}

- (void)loadMaxReward{
    if(self.rewardedAd == nil){
        self.rewardedAd = [MARewardedAd sharedWithAdUnitIdentifier: mMaxRewardID];
        self.rewardedAd.delegate = self;
    }
    [self.rewardedAd loadAd];
}

- (void)showMaxReward{
    if([self.rewardedAd isReady]){
        [self.rewardedAd showAd];
    }
}

#pragma mark - MAAdDelegate Protocol

- (void)didLoadAd:(MAAd *)ad{
    //插屏加载好了， [self.interstitialAd isReady] 会返回true
    self.interRetryAttempt = 0;
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withErrorCode:(NSInteger)errorCode{
    //插屏加载失败，这里做幂级数增加时间点方式延时加载
    self.interRetryAttempt++;
    NSInteger delaySec = pow(2, MIN(6,self.interRetryAttempt));
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delaySec * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.interstitialAd loadAd];
    });
}

- (void)didDisplayAd:(MAAd *)ad {}

- (void)didClickAd:(MAAd *)ad {}

- (void)didHideAd:(MAAd *)ad
{
    // Interstitial ad is hidden. Pre-load the next ad
    [self.interstitialAd loadAd];
}

- (void)didFailToDisplayAd:(MAAd *)ad withErrorCode:(NSInteger)errorCode
{
    // Interstitial ad failed to display. We recommend loading the next ad
    [self.interstitialAd loadAd];
}

#pragma mark - MARewardedAdDelegate Protocol

- (void)didStartRewardedVideoForAd:(MAAd *)ad {}

- (void)didCompleteRewardedVideoForAd:(MAAd *)ad {}

- (void)didRewardUserForAd:(MAAd *)ad withReward:(MAReward *)reward
{
    // Rewarded ad was displayed and user should receive the reward
}


- (void)initMopub{
    MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:mMopubRewardID];

    sdkConfig.globalMediationSettings = @[];
    sdkConfig.loggingLevel = MPBLogLevelInfo;
    
    
    [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
        NSLog(@"SDK initialization complete");
        [self mopubLoadReward];
    }];
}

- (void)mopubLoadReward{
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:mMopubRewardID withMediationSettings:nil];
    [MPRewardedVideo setDelegate:self forAdUnitId:mMopubRewardID];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:mMopubRewardID keywords:nil userDataKeywords:nil location:nil customerId:nil mediationSettings:@[]];
    
}

- (void)mopubShowReward{
    if ([MPRewardedVideo hasAdAvailableForAdUnitID:mMopubRewardID]) {
        NSArray * rewards = [MPRewardedVideo availableRewardsForAdUnitID:mMopubRewardID];
        MPRewardedVideoReward * reward = rewards[0];
        [MPRewardedVideo presentRewardedVideoAdForAdUnitID:mMopubRewardID fromViewController:self withReward:reward customData:nil];
    }
}

# pragma mopubreward callback
- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID{
    NSLog(@"激励加载");
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error{
    NSLog(@"激励加载失败");
}

- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error{
    NSLog(@"激励播放失败");
}

// Called when a rewarded video starts playing.
- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID{
    NSLog(@"激励即将展示");
}


- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID{
    NSLog(@"激励展示");
}

- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID{
    NSLog(@"激励即将消失");
}

// Called when a rewarded video is closed. At this point your application should resume.
- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID{
    NSLog(@"激励消失");
}

// Called when a rewarded video is completed and the user should be rewarded.
- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward{
    NSLog(@"激励看完，给奖励");
}

// Called when a rewarded video is expired.
- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID{
    NSLog(@"激励缓存超时，失效，需要重新加载广告");
}


- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID{
    NSLog(@"激励被点击");
}

- (void)rewardedVideoAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID{
    NSLog(@"按了home键");
}

/**
 Called when an impression is fired on a Rewarded Video. Includes information about the impression if applicable.

 @param adUnitID The ad unit ID of the rewarded video that fired the impression.
 @param impressionData Information about the impression, or @c nil if the server didn't return any information.
 */
- (void)didTrackImpressionWithAdUnitID:(NSString *)adUnitID impressionData:(MPImpressionData *)impressionData{
    
}

@end
