//
//  SingleGameViewController.m
//  fly-butterfly
//
//  Created by Luis Flores on 4/13/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <ISSpriteKit/ISAudio.h>
#import "SingleGameViewController.h"
#import "GameScene.h"

@interface SingleGameViewController ()
@property (weak, nonatomic) IBOutlet UILabel *highscoreLabel;
@end

@implementation SingleGameViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.highscoreLabel.font = [UIFont fontWithName:LabelFont size:18];
    self.tapLabel.font = [UIFont fontWithName:LabelFont size:24];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ISAudio sharedInstance] playBackgroundMusic:@"background_music.mp3"];
    self.scene = [[GameScene alloc] init];
    [self presentScene];
}

#pragma mark - Public methods

- (void)presentScene {
    [super presentScene];
    [self track:@"Single Game"];

    [[AdManager sharedInstance] presentInterstitial:self];
    [[AdManager sharedInstance] countGame];
}

#pragma mark - SceneDelegate

- (void)gamePrepare {
    self.gameOverView.hidden = YES;
    [self.timer invalidate];
    self.scene = [[GameScene alloc] init];
    [self presentScene];
}

- (void)gameOver {
    [super gameOver];
    NSString *highscore = [NSString stringWithFormat:@"TOP: %ld", (long)UserDefaults.highscore];
    self.highscoreLabel.text = highscore;

    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(toggleLabelAlpha)
                                                userInfo:nil
                                                 repeats:YES];
}

#pragma mark - Private methods

- (void)toggleLabelAlpha {
    [self.tapLabel setHidden:(!self.tapLabel.hidden)];
}

#pragma mark - GVGoogleBannerViewDelegate

- (NSString *)googleBannerViewAdUnitID {
    return @"ca-app-pub-3392553844996186/8351640152";
}

@end
