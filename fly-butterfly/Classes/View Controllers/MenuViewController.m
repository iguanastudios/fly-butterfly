//
//  MenuViewController.m
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <ISGameCenter/ISGameCenter.h>
#import "MenuViewController.h"
#import "BaseGameViewController.h"
#import "SingleGameViewController.h"
#import "MultiplayerGameViewController.h"
#import "GameScene.h"
#import "MultiplayerScene.h"

@interface MenuViewController () <ISGameCenterDelegate, ISMultiplayerDelegate>
@property (strong, nonatomic) SingleGameViewController *singleGameViewController;
@property (strong, nonatomic) MultiplayerGameViewController *multiplayerGameViewController;
@property (strong, nonatomic) ButterflyMultiplayerNetworking *networkEngine;
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

    [[AdManager sharedInstance] prepareInterstitial];
    [[ISGameCenter sharedISGameCenter] authenticateLocalPlayer];
    [ISGameCenter sharedISGameCenter].delegate = self;
    [[SKTextureAtlas atlasNamed:@"sprites"] preloadWithCompletionHandler:^{}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[AdManager sharedInstance] presentInterstitial:self];
}

#pragma mark - IBAction

- (IBAction)ratePressed {
    [[ISAudio sharedInstance] playSoundEffect:@"button_press.wav"];
    NSURL *rateURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/857838948"];
    [[UIApplication sharedApplication] openURL:rateURL];
}

- (IBAction)playPressed {
    [[ISAudio sharedInstance] playSoundEffect:@"button_press.wav"];
    self.singleGameViewController.scene = [[GameScene alloc] init];
    [self.navigationController pushViewController:self.singleGameViewController animated:YES];
}

- (IBAction)highscorePressed {
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

- (void)multiplayerMatchEnded:(NSError *)error {
    if (error) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Connection lost, try again!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - GVGoogleBannerViewDelegate

- (NSString *)googleBannerViewAdUnitID {
    return @"ca-app-pub-3392553844996186/7755027755";
}

@end
