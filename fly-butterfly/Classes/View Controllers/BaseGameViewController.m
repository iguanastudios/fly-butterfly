//
//  GameViewController.m
//  butterfly
//
//  Created by Luis Flores on 3/4/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "BaseGameViewController.h"

@implementation BaseGameViewController

#pragma mark - IBActions

- (IBAction)backButtonPressed {
    [self.gameView presentScene:nil];
    [[ISAudio sharedInstance] pauseBackgroundMusic];
    [[ISAudio sharedInstance] playSoundEffect:@"button_press.wav"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Private Methods

- (void)presentScene {
    self.gameOverView.hidden = YES;
    self.scene.size = self.gameView.bounds.size;
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene.delegate = self;
    [self.scene setup];

#ifdef DEBUG
    self.gameView.showsFPS = YES;
    self.gameView.showsNodeCount = YES;
//    self.gameView.showsPhysics = YES;
#endif
    
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

#pragma mark - SceneDelegate

- (void)gameStart {
    self.gameOverView.hidden = YES;
}

- (void)gameOver {
    [self shakeFrame];
    self.gameOverView.hidden = NO;
}

@end
