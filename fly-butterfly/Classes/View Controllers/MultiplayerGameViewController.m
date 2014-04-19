//
//  MultiplayerGameViewController.m
//  fly-butterfly
//
//  Created by Luis Flores on 4/13/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "MultiplayerGameViewController.h"
#import "MultiplayerScene.h"

@implementation MultiplayerGameViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self track:@"Multiplayer Game"];
    [self presentScene];
    self.running = YES;
    [[AdManager sharedInstance] countGame];
}

- (void)gameOver {
    [super gameOver];
    self.running = NO;
}

@end
