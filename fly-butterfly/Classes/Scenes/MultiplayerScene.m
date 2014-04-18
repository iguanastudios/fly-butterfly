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
@property (strong, nonatomic) SKSpriteNode *rightArrow;
@property (strong, nonatomic) SKSpriteNode *leftArrow;
@property (strong, nonatomic) SKAction *scale;
@property (nonatomic) CFTimeInterval time;
@property (nonatomic) GameState gameState;
@property (nonatomic) NSInteger countdownTime;
@property (nonatomic) BOOL isLabelTimer;
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

- (SKAction *)scale {
    if (!_scale) {
        SKAction *scaleUp = [SKAction scaleBy:1.3 duration:0.25];
        SKAction *scaleDown = [scaleUp reversedAction];
        SKAction *fullScale = [SKAction sequence:@[scaleUp, scaleDown]];
        _scale = [SKAction repeatAction:fullScale count:2];
    }

    return _scale;
}

#pragma mark - Public methods

- (CGFloat)crowPositionY {
    return [self.crowPositions[self.crowCounter++ % [self.crowPositions count]] floatValue];
}

#pragma mark - Setup methods

-(void)setup {
    [super setup];
    self.gameState = GameStateReady;
    self.time = 0.0;

    if (self.hoster) {
        [self setupCrowPositions];
    }

    self.leftArrow = [SKSpriteNode spriteNodeWithImageNamed:@"left-arrow"];
    self.leftArrow.anchorPoint = CGPointMake(0.0, 0.5);

    self.rightArrow = [SKSpriteNode spriteNodeWithImageNamed:@"right-arrow"];
    self.rightArrow.anchorPoint = CGPointMake(1.0, 0.5);

    self.leftArrow.position = CGPointMake(-self.leftArrow.size.width, 0);
    self.rightArrow.position = CGPointMake(-self.rightArrow.size.width, 0);

    [self addChild:self.leftArrow];
    [self addChild:self.rightArrow];
}

- (void)setupButterfly {
    [super setupButterfly];

    // Setup multiplayer butterfly
    self.butterflyMultiplayer = [[Butterfly alloc] initWithPosition:self.butterfly.position];
    [self.butterflyMultiplayer runAction:[SKAction colorizeWithColor:[SKColor blackColor] colorBlendFactor:1.0 duration:0.1]];
    [self addChild:self.butterflyMultiplayer];
    // Setup tray after being added to the scene
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

        if (!self.isLabelTimer) {
            self.isLabelTimer = YES;
            self.timerLabel.text = @"Fly!";

            [NSTimer scheduledTimerWithTimeInterval:0.3
                                             target:self
                                           selector:@selector(initialCounter)
                                           userInfo:nil
                                            repeats:NO];

            [self setupCrows];
            self.gameState = GameStateRunning;
            [self runAction:[BaseScene flapSound]];
            [self.butterfly fly];
        } else {
            [self gameOver];
        }
    }
}

- (void)initialCounter {
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

    [self.butterflyMultiplayer removeFromParent];
    [self.butterfly removeFromParent];

    [self.networkingEngine sendGameOverMessage];
}

#pragma mark - Update

- (void)update:(CFTimeInterval)currentTime {
    [super update:currentTime];

    switch (self.gameState) {
        case GameStateRunning:
            [self.butterfly rotate];
        case GameStateButterflyBlinking:
            [self updateGameStateRunning];
        case GameStateButterflyHit:
            [self updateGameStateDefault:currentTime];
            break;
        default:
            break;
    }
}

- (void)updateGameStateRunning {
    self.time += self.deltaTime;
}

- (void)updateGameStateDefault:(CFTimeInterval)currentTime {
//    if (currentTime - self.deltaTime >= 0.1) {
        [self.networkingEngine sendButterflyCoordinate:self.time - self.deltaTime
                                                     y:self.butterfly.position.y
                                              rotation:self.butterfly.zRotation];

//    }

    [self updateCrows];
}

#pragma mark - TouchesBegan

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (self.gameState) {
        case GameStateRunning:
            [self touchesBeganGameStateRunning];
            break;

        case GameStateButterflyBlinking:
            [self touchesBeganGameStateBlinking];
            break;

        case GameStateOver:
        case GameStateReady:
        case GameStateButterflyHit:
        default:
            break;
    }
}

- (void)touchesBeganGameStateBlinking {
    [self.butterfly removeActionForKey:@"MoveUp"];
    self.butterfly.physicsBody.affectedByGravity = YES;
    [self runAction:[BaseScene flapSound]];
    [self.butterfly fly];
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *body = (contact.bodyA.categoryBitMask == BButterflyCategory ? contact.bodyB : contact.bodyA);

    switch (body.categoryBitMask) {
        case BCrowCategory:
            [self didBeginContactWithCrow];
            break;
        case BGroundCategory:
            [self didBeginContactWithGround];
            break;
        default:
            break;
    }
}

- (void)didBeginContactWithCrow {
    [self runAction:CrowSound];
    self.butterfly.physicsBody.collisionBitMask = BGroundCategory;
    self.butterfly.physicsBody.contactTestBitMask = BGroundCategory;
    [self butterflyHit];
}

- (void)didBeginContactWithGround {
    // Butterfly hits directly with the ground
    if (self.gameState == GameStateRunning) {
        [self butterflyHit];
    } else {
        [self.butterfly removeActionForKey:@"MoveUp"];
        SKAction *moveUp = [SKAction moveToY:(self.size.height + GoogleBannerHeight) / 2
                                    duration:2];
        [self.butterfly runAction:moveUp withKey:@"MoveUp"];
    }
}

#pragma mark - ISButterflyMultiplayerDelegate

- (void)butterflyCoordinate:(CGFloat)x y:(CGFloat)y rotation:(CGFloat)rotation {
    CGFloat difference = (self.time - x);
    CGFloat pointsPerSecond = HitDelay / FlySecondsPerPoint;
    CGFloat newX = self.butterfly.position.x - (difference * pointsPerSecond);

    if (newX < -self.butterflyMultiplayer.size.width) {
        self.leftArrow.position = CGPointMake(5, y);
    } else if (newX > self.size.width + self.butterflyMultiplayer.size.width) {
        self.rightArrow.position = CGPointMake(self.size.width - 5.0, y);
    } else {
        self.leftArrow.position = CGPointMake(-self.leftArrow.size.width, 0);
        self.rightArrow.position = CGPointMake(-self.rightArrow.size.width, 0);

        CGPoint multiplayerPosition = CGPointMake(newX, y);
        self.butterflyMultiplayer.position = multiplayerPosition;
        self.butterflyMultiplayer.zRotation = rotation;
    }
}

- (void)butterflyBlink {
    CGFloat x = self.butterflyMultiplayer.position.x;
    if (x < -self.butterflyMultiplayer.size.width / 2) {
        [self.leftArrow runAction:[ISActions blinkWithDuration:2.0 blinkTimes:8] completion:^{
            self.butterflyMultiplayer.hidden = NO;
        }];
    } else if (x > self.size.width + self.butterflyMultiplayer.size.width) {
        [self.rightArrow runAction:[ISActions blinkWithDuration:2.0 blinkTimes:8] completion:^{
            self.butterflyMultiplayer.hidden = NO;
        }];
    } else {
        [self.butterflyMultiplayer runAction:[ISActions blinkWithDuration:2.0 blinkTimes:8] completion:^{
            self.butterflyMultiplayer.hidden = NO;
        }];
    }
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

    self.gameState = GameStateButterflyHit;
    [Utilities flashScene:self];

    SKAction *wait = [SKAction waitForDuration:HitDelay];
    SKAction *groupAction = [SKAction group:@[self.scale, wait]];

    [self enumerateChildNodesWithName:@"crow" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeActionForKey:@"fly"];
    }];

    [self.butterfly runAction:groupAction completion:^{
        self.gameState = GameStateButterflyBlinking;
        [self.networkingEngine sendButterflyBlink];

        [self enumerateChildNodesWithName:@"crow" usingBlock:^(SKNode *node, BOOL *stop){
            Crow *crow = (Crow *)node;
            [crow fly];
        }];

        self.butterfly.physicsBody.collisionBitMask = BEdgeCategory | BGroundCategory;
        self.butterfly.physicsBody.contactTestBitMask = BEdgeCategory | BGroundCategory;
        self.butterfly.physicsBody.affectedByGravity = NO;

        SKAction *moveUp = [SKAction moveToY:(self.size.height + GoogleBannerHeight) / 2
                                    duration:2];
        [self.butterfly runAction:moveUp withKey:@"MoveUp"];
        self.butterfly.zRotation =  M_1_PI;

        SKAction *blink = [ISActions blinkWithDuration:2.0 blinkTimes:8];

        [self.butterfly runAction:blink completion:^{
            self.gameState = GameStateRunning;
            [self.butterfly removeActionForKey:@"MoveUp"];
            self.butterfly.physicsBody.affectedByGravity = YES;
            self.butterfly.physicsBody.collisionBitMask = BEdgeCategory | BGroundCategory;
            self.butterfly.physicsBody.contactTestBitMask = BCrowCategory | BEdgeCategory | BGroundCategory;
            self.butterfly.hidden = NO;
        }];
    }];
}

- (void)test {
    [self butterflyHit];
}

@end
