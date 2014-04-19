//
//  MultiplayerGameViewController.m
//  fly-butterfly
//
//  Created by Luis Flores on 4/13/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "MultiplayerGameViewController.h"
#import "MultiplayerScene.h"

@interface MultiplayerGameViewController ()
@property (nonatomic) NSInteger gameCounter;
@end

@implementation MultiplayerGameViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameCounter = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self presentScene];
    [self track:@"Multiplayer Game"];

    if (self.gameCounter % 3 == 0) {
        [[AdManager sharedInstance] prepareInterstitial];
    }

    self.gameCounter++;
}

@end
