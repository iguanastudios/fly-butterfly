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
#import "SingleGameViewController.h"
#import "MultiplayerGameViewController.h"
#import "GameScene.h"
#import "MultiplayerScene.h"

@interface MenuViewController () <ISGameCenterDelegate, ISMultiplayerDelegate>
@property (strong, nonatomic) ButterflyMultiplayerNetworking *networkEngine;
@end

@implementation MenuViewController

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
    MultiplayerGameViewController *multiplayerGameViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MultiplayerGameViewController"];
    MultiplayerScene *multiplayerScene = [[MultiplayerScene alloc] init];
    multiplayerScene.hoster = NO;
    multiplayerScene.networkingEngine = self.networkEngine;
    self.networkEngine.butterflyDelegate = multiplayerScene;
    multiplayerGameViewController.scene = multiplayerScene;
    [self.navigationController pushViewController:multiplayerGameViewController animated:YES];
    return;

    [[ISAudio sharedInstance] playSoundEffect:@"button_press.wav"];
    SingleGameViewController *singleGameViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleGameViewController"];
    [self.navigationController pushViewController:singleGameViewController animated:YES];
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
    MultiplayerGameViewController *multiplayerGameViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MultiplayerGameViewController"];
    MultiplayerScene *multiplayerScene = [[MultiplayerScene alloc] init];
    multiplayerScene.hoster = hoster;
    multiplayerScene.networkingEngine = self.networkEngine;
    self.networkEngine.butterflyDelegate = multiplayerScene;
    multiplayerGameViewController.scene = multiplayerScene;
    [self.navigationController pushViewController:multiplayerGameViewController animated:YES];
}

- (void)multiplayerMatchEnded {
    NSLog(@"multiplayerMatchEnded ERROR");
}

#pragma mark - GVGoogleBannerViewDelegate

- (NSString *)googleBannerViewAdUnitID {
    return @"ca-app-pub-3392553844996186/7755027755";
}

@end
