//
//  MenuViewController.m
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <ISGameCenter/ISGameCenter.h>
#import <GVGoogleBannerView/GVGoogleBannerView.h>
#import "MenuViewController.h"
#import "GameViewController.h"
#import "GameScene.h"
#import "MultiplayerScene.h"

@interface MenuViewController () <ISGameCenterDelegate, ISMultiplayerDelegate>
@property (strong, nonatomic) GameViewController *gameViewController;
@property (strong, nonatomic) ButterflyMultiplayerNetworking *networkEngine;
@property (strong, nonatomic) MultiplayerScene *multiplayerScene;
@end

@implementation MenuViewController

#pragma mark - Getters and setters

- (GameViewController *)gameViewController {
    if (!_gameViewController) {
        _gameViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameViewController"];
    }
    return _gameViewController;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self track:@"Game Launched"];
    [[ISGameCenter sharedISGameCenter] authenticateLocalPlayer];
    [ISGameCenter sharedISGameCenter].delegate = self;
    [[SKTextureAtlas atlasNamed:@"sprites"] preloadWithCompletionHandler:^{
        NSLog(@"Atlas preload");
    }];
}

#pragma mark - IBAction

- (IBAction)playPressed {
    [[ISAudio sharedInstance] playSoundEffect:@"button_press.wav"];
    self.gameViewController.scene = [[GameScene alloc] init];
    [self.navigationController pushViewController:self.gameViewController animated:YES];
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
    self.multiplayerScene = [[MultiplayerScene alloc] init];
    self.multiplayerScene.hoster = hoster;
    self.multiplayerScene.networkingEngine = self.networkEngine;
    self.networkEngine.butterflyDelegate = self.multiplayerScene;
    self.gameViewController.scene = self.multiplayerScene;
    [self.navigationController pushViewController:self.gameViewController animated:YES];
}

- (void)multiplayerMatchEnded {
    NSLog(@"multiplayerMatchEnded ERROR");
}

#pragma mark - GVGoogleBannerViewDelegate

- (NSString *)googleBannerViewAdUnitID {
    return @"ca-app-pub-3392553844996186/7755027755";
}

@end
