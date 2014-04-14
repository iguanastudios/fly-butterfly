//
//  SingleGameViewController.m
//  fly-butterfly
//
//  Created by Luis Flores on 4/13/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "SingleGameViewController.h"
#import "GameScene.h"

@interface SingleGameViewController ()
@property (weak, nonatomic) IBOutlet UILabel *highscoreLabel;
@end

@implementation SingleGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scene = [[GameScene alloc] init];
    self.highscoreLabel.font = [UIFont fontWithName:LabelFont size:18];
}

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
}

#pragma mark - GVGoogleBannerViewDelegate

- (NSString *)googleBannerViewAdUnitID {
    return @"";
}

@end
