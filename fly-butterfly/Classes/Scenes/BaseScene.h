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

static SKAction *CrowSound;
static SKAction *FlapSound;

@interface BaseScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic) CGFloat initialPoint;
@property (nonatomic) CFTimeInterval deltaTime;
@property (nonatomic) NSInteger crowCounter;
@property (strong, nonatomic) Butterfly *butterfly;
@property (strong, nonatomic) id<SceneDelegate> delegate;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) SKAction *movePoint;

+ (SKAction *)crowSound;
+ (SKAction *)flapSound;
- (CGFloat)crowPositionY;
- (void)enableInteraction;
- (void)gameOver;
- (void)setup;
- (void)setupButterfly;
- (void)setupCrows;
- (void)touchesBeganGameStateOver;
- (void)touchesBeganGameStateRunning;
- (void)updateCrows;

@end
