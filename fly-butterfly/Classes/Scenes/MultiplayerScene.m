//
//  MultiplayerScene.m
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "MultiplayerScene.h"
#import "ISActions.h"

typedef NS_ENUM(NSInteger, GameState) {
    GameStateReady,
    GameStateRunning,
    GameStateButterflyHitCrow,
    GameStateButterflyBlinking,
    GameStateOver
};

@interface MultiplayerScene ()
@property (assign, nonatomic) NSTimeInterval previousTimeInterval;
@property (strong, nonatomic) Butterfly *butterflyMultiplayerNode;
@property (strong, nonatomic) NSArray *crowPositions;
@property (strong, nonatomic) SKLabelNode *timerLabel;
@property (strong, nonatomic) SKLabelNode *statusLabel;
@property (strong, nonatomic) NSTimer *countdownTimer;
@property (assign, nonatomic) NSInteger countdownTime;
@property (assign, nonatomic) GameState gameState;
@property (assign, nonatomic) BOOL locked;
@end

@implementation MultiplayerScene

#pragma mark - Getters and setters

- (SKLabelNode *)timerLabel {
    if (!_timerLabel) {
        _timerLabel = [SKLabelNode labelNodeWithFontNamed:LabelFont];
        _timerLabel.fontSize = 48;
        _timerLabel.text = [NSString stringWithFormat:@"%ld", (long)self.countdownTime];
    }

    return _timerLabel;
}

- (SKLabelNode *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [SKLabelNode labelNodeWithFontNamed:LabelFont];
        _statusLabel.fontSize = 48;
        _statusLabel.position = CGPointMake(self.size.width / 2, self.size.height / 2 + 50);
    }

    return _statusLabel;
}
#pragma mark - Public methods

-(void)setup {
    [super setup];
    self.gameState = GameStateReady;
    self.locked = YES;

    if (self.hoster) {
        [self prepareCrows];
    }
}

- (void)setupButterfly {
    [super setupButterfly];
    CGPoint butterflyPosition = CGPointMake(self.size.width - ButterflyPosition,
                                            self.size.height / 2);
    self.butterflyMultiplayerNode = [[Butterfly alloc] initWithPosition:butterflyPosition];
    [self.butterflyMultiplayerNode runAction:[SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:1.0 duration:0.1]];
    [self addChild:self.butterflyMultiplayerNode];
    [self.butterflyMultiplayerNode setupMultiplayerButterflyTray];
}

- (void)prepareCrows {
    NSMutableArray *positions = [[NSMutableArray alloc] initWithCapacity:100];
    int crows = 0;
    CGFloat position;

    for (int i = 0; i < 100; i++) {
        position = [Utilities randomPositionAtTopWithScene:self numberOfCrows:crows++];
        [positions addObject:@(position)];
    }

    [self.networkingEngine sendCrowPositions:positions];
    self.crowPositions = [[NSArray alloc] initWithArray:positions];
}

- (void)setupCrows {
    CGFloat crowWidthDistance = CrowWidth / 2;
    for (int iterator = 0; iterator < [self.crowPositions count]; iterator++) {
        CGFloat x = self.size.width + crowWidthDistance + (iterator * 180);
        NSNumber *y = [self.crowPositions objectAtIndex:iterator];

        self.crowTopPosition = [y floatValue];
        self.crowBottomPosition = self.crowTopPosition - MinSpaceBetweenBombs;

        Crow *crowTop = [[Crow alloc] initWithPosition:CGPointMake(x, self.crowTopPosition)];
        [crowTop fly];

        [self addChild:crowTop];

        Crow *crowBottom = [[Crow alloc] initWithPosition:CGPointMake(x, self.crowBottomPosition)];
        [crowBottom fly];
        
        [self addChild:crowBottom];
    }
}

- (void)setupTimer {
    self.countdownTime = 3;
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateLabel)
                                                         userInfo:nil
                                                          repeats:YES];
    self.timerLabel.position = CGPointMake(self.size.width / 2, self.size.height / 2 + 50);
    [self addChild:self.timerLabel];
}

- (void)updateLabel {
    self.countdownTime -= 1;
    self.timerLabel.text = [NSString stringWithFormat:@"%ld", (long)self.countdownTime];

    if (self.countdownTime <= 0) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;

        if (self.gameState == GameStateReady) {
            self.timerLabel.text = @"Fly!";
            [NSTimer scheduledTimerWithTimeInterval:0.3
                                             target:self
                                           selector:@selector(removeLabel)
                                           userInfo:nil
                                            repeats:NO];
            [self setupCrows];
            self.gameState = GameStateRunning;
            self.locked = NO;
        } else {
            [self gameOver];
        }
    }
}

- (void)removeLabel {
    self.timerLabel.text = @"60";
    self.timerLabel.position = CGPointMake(20, self.scene.frame.size.height - 50);
    self.countdownTime = 60;
    self.timerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateLabel)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)gameOver {
    [super gameOver];
    self.gameState = GameStateOver;
    [self.timerLabel removeFromParent];
    if (self.butterfly.position.x < self.butterflyMultiplayerNode.position.x) {
        self.statusLabel.text = @"YOU WON!";
    } else {
        self.statusLabel.text = @"YOU LOST!";
    }
    [self addChild:self.statusLabel];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                  target:self
                                                selector:@selector(enableInteraction)
                                                userInfo:nil
                                                 repeats:NO];
}

#pragma mark - Update

- (void)update:(CFTimeInterval)currentTime {
    [super update:currentTime];

    if (self.gameState != GameStateReady) {
        [self.networkingEngine sendButterflyCoordinate:self.butterfly.position.y
                                              rotation:self.butterfly.zRotation];
    }

//    if (!self.previousTimeInterval) {
//        self.previousTimeInterval = currentTime;
//    }
//    if (currentTime - _previousTimeInterval >= 0.1) {
//    }
}

- (void)spawnCrows {
    CGFloat x = self.size.width + CrowWidth / 2;
    NSNumber *y = [self.crowPositions objectAtIndex:self.crowCounter];
    self.crowTopPosition = [y floatValue];
    self.crowBottomPosition = self.crowTopPosition - MinSpaceBetweenBombs;

    Crow *crowTop = [[Crow alloc] initWithPosition:CGPointMake(x, self.crowTopPosition)];
    [crowTop fly];

    [self addChild:crowTop];

    Crow *crowBottom = [[Crow alloc] initWithPosition:CGPointMake(x, self.crowBottomPosition)];
    [crowBottom fly];

    [self addChild:crowBottom];
    self.crowCounter++;
}

#pragma mark - TouchesBegan

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (self.gameState) {
        case GameStateRunning:
            [self touchesBeganGameStateRunning];
            break;
        case GameStateOver:
            [self touchesBeganGameStateOver];
            break;

        case GameStateButterflyBlinking:
            [self touchesBeganGameStateBlinking];
            break;
        case GameStateReady:
        case GameStateButterflyHitCrow:
        default:
            break;
    }
}

- (void)touchesBeganGameStateBlinking {
    [self.butterfly removeActionForKey:@"MoveUp"];
    self.butterfly.physicsBody.affectedByGravity = YES;
    [self runAction:self.flapSound];
    [self.butterfly fly];
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *body = (contact.bodyA.categoryBitMask == BButterflyCategory ? contact.bodyB : contact.bodyA);
    if (body.categoryBitMask == BCrowCategory) {
        [self didBeginContactWithCrow];
    } else if (body.categoryBitMask == BGroundCategory) {
        [self didBeginContactWithGround];
    }
}

- (void)didBeginContactWithCrow {
    [self runAction:self.crowSound];
    self.gameState = GameStateButterflyHitCrow;
    self.butterfly.physicsBody.collisionBitMask = BGroundCategory;
    self.butterfly.physicsBody.contactTestBitMask = BGroundCategory;
    [self butterflyHit];
}

- (void)didBeginContactWithGround {
    // Butterfly hits directly with the ground
    if (self.gameState == GameStateRunning) {
        [self butterflyHit];
    }

    self.gameState = GameStateButterflyBlinking;
    [self.networkingEngine sendButterflyBlink];

    self.butterfly.physicsBody.collisionBitMask = BEdgeCategory | BGroundCategory;
    self.butterfly.physicsBody.contactTestBitMask = BEdgeCategory | BGroundCategory;
    self.butterfly.physicsBody.affectedByGravity = NO;

    SKAction *moveUp = [SKAction moveToY:(self.size.height + GoogleBannerHeight) / 2
                                duration:2];
    [self.butterfly runAction:moveUp withKey:@"MoveUp"];

    SKAction *blink = [ISActions blinkWithDuration:2.0 blinkTimes:8];

    [self.butterfly runAction:blink completion:^{
        self.gameState = GameStateRunning;
        self.butterfly.physicsBody.affectedByGravity = YES;
        self.butterfly.physicsBody.collisionBitMask = BEdgeCategory | BGroundCategory;
        self.butterfly.physicsBody.contactTestBitMask = BCrowCategory | BEdgeCategory | BGroundCategory;
        self.butterfly.hidden = NO;
    }];
}

#pragma mark - ISButterflyMultiplayerDelegate

- (void)butterflyCoordinate:(CGFloat)y rotation:(CGFloat)rotation {
    CGPoint multiplayerPosition = CGPointMake(self.butterflyMultiplayerNode.position.x, y);
    self.butterflyMultiplayerNode.position = multiplayerPosition;
    self.butterflyMultiplayerNode.zRotation = rotation;
}

- (void)butterflyBlink {
    [self.butterflyMultiplayerNode runAction:[ISActions blinkWithDuration:2.0 blinkTimes:8] completion:^{
        self.butterflyMultiplayerNode.hidden = NO;
    }];
}

- (void)butterflyCrash {
    [self.butterflyMultiplayerNode runAction:[SKAction moveByX:-100 y:0 duration:2]];
}

- (void)crowPositions:(NSArray *)positions {
    self.crowPositions = [[NSArray alloc] initWithArray:positions];
    [self setupTimer];
}

- (void)crowsReceived {
    [self setupTimer];
}

#pragma mark - Private methods

- (void)moveCrows:(float)top bottom:(float)bottom {
    CGPoint crowTopPosition = CGPointMake(self.size.width + CrowWidth / 2, top);
    Crow *crowTop = [[Crow alloc] initWithPosition:crowTopPosition];
    [self addChild:crowTop];
    [crowTop fly];

    CGPoint crowBottomPosition = CGPointMake(self.size.width + CrowWidth / 2, bottom);
    Crow *crowBottom = [[Crow alloc] initWithPosition:crowBottomPosition];
    [self addChild:crowBottom];
    [crowTop fly];
}

- (void)butterflyHit {
    [Utilities flashScene:self];
    [self.networkingEngine sendButterflyCrash];
    self.locked = YES;
    [self.butterflyMultiplayerNode runAction:[SKAction moveByX:100 y:0 duration:2] completion:^{
        self.locked = NO;
    }];

    [self enumerateChildNodesWithName:@"crow"
                           usingBlock:^(SKNode *node, BOOL *stop) {
                               if (node.position.x < 0) {
                                   [node removeFromParent];
                               } else {
                                   [node removeAllActions];
                               }
                           }];

    SKAction *wait = [SKAction waitForDuration:2.0];

    [self runAction:wait completion:^{
        [self enumerateChildNodesWithName:@"crow"
                               usingBlock:^(SKNode *node, BOOL *stop) {
                                   if (node.position.x < 0) {
                                       [node removeFromParent];
                                   } else {
                                       Crow *crow = (Crow *)node;
                                       [crow fly];
                                   }
                               }];
    }];
}

@end
