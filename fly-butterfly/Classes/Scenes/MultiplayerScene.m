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
    GameStateButterflyHit,
    GameStateButterflyBlinking,
    GameStateOver
};

@interface MultiplayerScene ()
@property (strong, nonatomic) Butterfly *butterflyMultiplayer;
@property (strong, nonatomic) NSArray *crowPositions;
@property (strong, nonatomic) NSTimer *countdownTimer;
@property (strong, nonatomic) SKLabelNode *statusLabel;
@property (strong, nonatomic) SKLabelNode *timerLabel;
@property (nonatomic) BOOL locked;
@property (nonatomic) CFTimeInterval deltaTime;
@property (nonatomic) CFTimeInterval time;
@property (nonatomic) NSInteger initialPoint;
@property (nonatomic) GameState gameState;
@property (nonatomic) NSInteger countdownTime;
@property (nonatomic) NSInteger countCrows;
@property (nonatomic) NSTimeInterval previousTimeInterval;
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
    self.time = 0.0;

    if (self.hoster) {
        [self setupCrowPositions];
    }

    [self setupCrowPositions];
    [self setupCrows];
    self.gameState = GameStateRunning;
}

- (void)setupButterfly {
    [super setupButterfly];
    self.butterflyMultiplayer = [[Butterfly alloc] initWithPosition:self.butterfly.position];
    [self.butterflyMultiplayer runAction:[SKAction colorizeWithColor:[SKColor blackColor] colorBlendFactor:1.0 duration:0.1]];
    [self addChild:self.butterflyMultiplayer];
    [self.butterflyMultiplayer setupMultiplayerButterflyTray];
}

- (void)setupCrowPositions {
    NSMutableArray *positions = [[NSMutableArray alloc] initWithCapacity:100];
    CGFloat position;

    for (int i = 0; i < 100; i++) {
        position = [Utilities randomPositionAtTopWithScene:self numberOfCrows:i];
        [positions addObject:@(position)];
    }

    [self.networkingEngine sendCrowPositions:positions];
    self.crowPositions = [[NSArray alloc] initWithArray:positions];
}

- (void)setupCrows {
    // Anchor point in the middle
    CGFloat crowWidthDistance = CrowWidth / 2;
    self.initialPoint = self.size.width + crowWidthDistance;

    for (int iterator = 0; iterator < 10; iterator++) {
        Crow *crow = [[Crow alloc] initWithPosition:CGPointMake(-CrowWidth, 0)];
        [self addChild:crow];
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
    if (self.butterfly.position.x > self.butterflyMultiplayer.position.x) {
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

    if (self.previousTimeInterval) {
        self.deltaTime = currentTime - self.previousTimeInterval;
    } else {
        self.deltaTime = 0;
    }

    self.previousTimeInterval = currentTime;

    if (self.gameState != GameStateReady) {
        if (!self.locked) {
            self.time += self.deltaTime;
        }
        [self updateCrows];
    }

    if (self.gameState != GameStateReady && currentTime - self.deltaTime >= 0.1) {
        [self.networkingEngine sendButterflyCoordinate:self.time - self.deltaTime
                                                    y:self.butterfly.position.y
                                            rotation:self.butterfly.zRotation];

    }
}

- (void)updateCrows {
    __block BOOL needForCrows = YES;

    [self enumerateChildNodesWithName:@"crow" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x < -(CrowWidth / 2)) {
            [node removeActionForKey:@"fly"];
        } else if (node.position.x > self.size.width - 150) {
            needForCrows = NO;
        }
    }];

    if (needForCrows) {
        __block int crowCounter = 0;

        [self enumerateChildNodesWithName:@"crow" usingBlock:^(SKNode *node, BOOL *stop) {
            if (node.position.x <= 0) {
                Crow *crow = (Crow *)node;
                NSNumber *y = self.crowPositions[self.countCrows % 100];

                // Top crow
                if (crowCounter == 0) {
                    crow.position = CGPointMake(self.initialPoint, [y intValue]);
                } else {
                    crow.position = CGPointMake(self.initialPoint, [y intValue] - MinSpaceBetweenCrows);
                }

                [crow fly];
                crowCounter++;
            }

            if (crowCounter >= 2) {
                *stop = YES;
            }
        }];

        self.countCrows++;
    }
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
        case GameStateButterflyHit:
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
    self.gameState = GameStateButterflyHit;
    self.butterfly.physicsBody.collisionBitMask = BGroundCategory;
    self.butterfly.physicsBody.contactTestBitMask = BGroundCategory;
    [self butterflyHit];
}

- (void)didBeginContactWithGround {
    // Butterfly hits directly with the ground
    if (self.gameState == GameStateRunning) {
        [self butterflyHit];
    }
}

#pragma mark - ISButterflyMultiplayerDelegate

- (void)butterflyCoordinate:(CGFloat)x y:(CGFloat)y rotation:(CGFloat)rotation {
    CGFloat difference = (self.time - x);
    CGPoint multiplayerPosition = CGPointMake(self.butterfly.position.x - (difference * 40), y);
    self.butterflyMultiplayer.position = multiplayerPosition;
    self.butterflyMultiplayer.zRotation = rotation;
}

- (void)butterflyBlink {
    [self.butterflyMultiplayer runAction:[ISActions blinkWithDuration:2.0 blinkTimes:8] completion:^{
        self.butterflyMultiplayer.hidden = NO;
    }];
}

- (void)crowPositions:(NSArray *)positions {
    self.crowPositions = [[NSArray alloc] initWithArray:positions];
    [self setupTimer];
}

- (void)crowsReceived {
    [self setupTimer];
}

#pragma mark - Private methods

- (void)butterflyHit {
    if (self.gameState == GameStateButterflyBlinking) {
        return;
    }

    [Utilities flashScene:self];
    self.locked = YES;

    SKAction *scaleUp = [SKAction scaleBy:1.4 duration:0.25];
    SKAction *scaleDown = [scaleUp reversedAction];
    SKAction *fullScale = [SKAction sequence:@[scaleUp, scaleDown]];

    SKAction *repeatScale = [SKAction repeatAction:fullScale count:3];
    SKAction *wait = [SKAction waitForDuration:1.5];

    SKAction *groupAction = [SKAction group:@[repeatScale, wait]];

    [self.butterfly runAction:groupAction completion:^{
        self.locked = NO;

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
    }];
}

@end
