//
//  GameViewController.m
//  butterfly
//
//  Created by Luis Flores on 3/4/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "Constants.h"
#import "ISMultiplayerNetworking.h"
#import "ButterflyMultiplayerNetworking.h"

@interface GameViewController () <SceneDelegate>
@property (weak, nonatomic) IBOutlet SKView *gameView;
@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (weak, nonatomic) IBOutlet UILabel *highscoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *tapLabel;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation GameViewController

#pragma mark - View lifecycle

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self track:@"Start"];

    self.highscoreLabel.font = [UIFont fontWithName:ScoreLabelFont size:18];
    self.tapLabel.font = [UIFont fontWithName:ScoreLabelFont size:24];

    NSString *highscore = [NSString stringWithFormat:@"TOP: %ld", (long)UserDefaults.highscore];
    self.highscoreLabel.text = highscore;

    [self presentGameScene];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - SceneDelegate

- (void)gameStart {
    self.gameOverView.hidden = YES;
}

- (void)gamePrepare {
    self.gameOverView.hidden = YES;
    [self.timer invalidate];
    self.scene = [[GameScene alloc] init];
    [self presentGameScene];
}

- (void)gameOver {
    NSString *highscore = [NSString stringWithFormat:@"TOP: %ld", (long)UserDefaults.highscore];
    self.highscoreLabel.text = highscore;
    [self shakeFrame];
    self.gameOverView.hidden = NO;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(toggleLabelAlpha)
                                                userInfo:nil
                                                 repeats:YES];
}

#pragma mark - Private Methods

- (void)toggleLabelAlpha {
    [self.tapLabel setHidden:(!self.tapLabel.hidden)];
}

- (void)presentGameScene {
    [self track:@"Game"];

    self.gameOverView.hidden = YES;

    self.scene.size = self.gameView.bounds.size;
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene.delegate = self;
    [self.scene setup];

    self.gameView.showsFPS = YES;
    self.gameView.showsNodeCount = YES;
    [self.gameView presentScene:self.scene];
}

- (void)shakeFrame {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:4];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([self.view  center].x - 4.0f, [self.view center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([self.view  center].x + 4.0f, [self.view center].y)]];
    [[self.view layer] addAnimation:animation forKey:@"position"];
}

#pragma mark - GVGoogleBannerViewDelegate

- (NSString *)googleBannerViewAdUnitID {
    return @"";
}

@end
