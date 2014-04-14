//
//  BaseScene.h
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

@import SpriteKit;

#import <ISGameCenter/ISGameCenter.h>
#import "Butterfly.h"
#import "Crow.h"
#import "Utilities.h"

@protocol SceneDelegate <NSObject>

@required
- (void)gameStart;
- (void)gameOver;

@optional
- (void)gamePrepare;

@end

@interface BaseScene : SKScene <SKPhysicsContactDelegate>

@property (strong, nonatomic) id<SceneDelegate> delegate;
@property (strong, nonatomic) SKAction *crowSound;
@property (strong, nonatomic) SKAction *flapSound;
@property (strong, nonatomic) SKAction *moveCrow;
@property (strong, nonatomic) Butterfly *butterfly;
@property (assign, nonatomic) CGFloat crowTopPosition;
@property (assign, nonatomic) CGFloat crowBottomPosition;
@property (assign, nonatomic) NSInteger crowCounter;
@property (strong, nonatomic) NSTimer *timer;

- (void)setup;
- (void)setupButterfly;
- (void)touchesBeganGameStateRunning;
- (void)touchesBeganGameStateOver;
- (void)gameOver;
- (void)enableInteraction;

@end
