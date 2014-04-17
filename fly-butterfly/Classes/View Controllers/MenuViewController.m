//
//  MenuViewController.m
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <ISGameCenter/ISGameCenter.h>
#import <Google-Mobile-Ads-SDK/GADInterstitial.h>
#import <GVGoogleBannerView/GVGoogleBannerView.h>
#import "MenuViewController.h"
#import "GameViewController.h"
#import "SingleGameViewController.h"
#import "MultiplayerGameViewController.h"
#import "GameScene.h"
#import "MultiplayerScene.h"

@interface MenuViewController () <ISGameCenterDelegate, ISMultiplayerDelegate, GADInterstitialDelegate>
@property (strong, nonatomic) SingleGameViewController *singleGameViewController;
@property (strong, nonatomic) MultiplayerGameViewController *multiplayerGameViewController;
@property (strong, nonatomic) ButterflyMultiplayerNetworking *networkEngine;
@property (strong, nonatomic) GADInterstitial *interstitial;
@end

@implementation MenuViewController

#pragma mark - Getters and setters

- (SingleGameViewController *)singleGameViewController {
    if (!_singleGameViewController) {
        _singleGameViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleGameViewController"];
    }

    return _singleGameViewController;
}

- (MultiplayerGameViewController *)multiplayerGameViewController {
    if (!_multiplayerGameViewController) {
        _multiplayerGameViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MultiplayerGameViewController"];
    }

    return _multiplayerGameViewController;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self track:@"Game Launched"];

    self.interstitial = [[GADInterstitial alloc] init];
    self.interstitial.delegate = self;
    self.interstitial.adUnitID = @"ca-app-pub-3392553844996186/2623164155";

    GADRequest *request = [GADRequest request];
    request.testDevices = @[GAD_SIMULATOR_ID,
                            @"9d7eada80bc22149b0c33df66f0957d0",
                            @"4f671bf723d90741f66b2fa9a13a497c"];

    [self.interstitial loadRequest:request];

    [[ISGameCenter sharedISGameCenter] authenticateLocalPlayer];
    [ISGameCenter sharedISGameCenter].delegate = self;
    [[SKTextureAtlas atlasNamed:@"sprites"] preloadWithCompletionHandler:^{}];
}

#pragma mark - IBAction

- (IBAction)playPressed {
    [[ISAudio sharedInstance] playSoundEffect:@"button_press.wav"];
    self.singleGameViewController.scene = [[GameScene alloc] init];
    [self.navigationController pushViewController:self.singleGameViewController animated:YES];
}

- (IBAction)highscorePressed {
    MultiplayerScene *multiplayerScene = [[MultiplayerScene alloc] init];
    multiplayerScene.hoster = YES;
    multiplayerScene.networkingEngine = self.networkEngine;
    self.networkEngine.butterflyDelegate = multiplayerScene;
    self.multiplayerGameViewController.scene = multiplayerScene;
    [self.navigationController pushViewController:self.multiplayerGameViewController animated:YES];
    return;

    [[ISAudio sharedInstance] playSoundEffect:@"button_press.wav"];
    [[ISGameCenter sharedISGameCenter] showGameCenterViewController:self];
}

- (IBAction)multiplayerPressed {
    [[ISAudio sharedInstance] playSoundEffect:@"button_press.wav"];
    self.networkEngine = [[ButterflyMultiplayerNetworking alloc] init];
    self.networkEngine.delegate = self;
    [[ISGameCenter sharedISGameCenter] findMatchWithMinPlayers:2
                                                    maxPlayers:2
                                      presentingViewController:self];
    [ISGameCenter sharedISGameCenter].networkingDelegate = self.networkEngine;
}

#pragma mark - ISGameCenterDelegate

- (void)presentAuthenticationViewController {
    ISGameCenter *gameKitHelper = [ISGameCenter sharedISGameCenter];
    [self presentViewController:gameKitHelper.authenticationViewController
                       animated:YES
                     completion:nil];
}

#pragma mark - ISMultiplayerDelegate

- (void)multiplayerMatchStarted:(BOOL)hoster {
    MultiplayerScene *multiplayerScene = [[MultiplayerScene alloc] init];
    multiplayerScene.hoster = hoster;
    multiplayerScene.networkingEngine = self.networkEngine;
    self.networkEngine.butterflyDelegate = multiplayerScene;
    self.multiplayerGameViewController.scene = multiplayerScene;
    [self.navigationController pushViewController:self.multiplayerGameViewController animated:YES];
}

- (void)multiplayerMatchEnded {
    NSLog(@"multiplayerMatchEnded ERROR");
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    [self.interstitial presentFromRootViewController:self];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%@", error);
}

#pragma mark - GVGoogleBannerViewDelegate

- (NSString *)googleBannerViewAdUnitID {
    return @"ca-app-pub-3392553844996186/7755027755";
}

@end
