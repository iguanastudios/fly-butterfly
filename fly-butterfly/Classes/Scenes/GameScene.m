//
//  MainScene.m
//  butterfly
//
//  Created by Luis Flores on 2/23/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <ISSpriteKit/ISAudio.h>
#import <ISSpriteKit/ISUtils.h>
#import <ISSpriteKit/SKEmitterNode+ISExtras.h>
#import "AchievementsHelper.h"
#import "GameScene.h"
#import "SKAction+ISExtras.h"

typedef NS_ENUM(NSInteger, GameState) {
    GameStateReady,
    GameStateRunning,
    GameStateOver
};

@interface GameScene()
@property (nonatomic) GameState gameState;
@property (nonatomic) NSUInteger currentScore;
@property (strong, nonatomic) SKLabelNode *scoreLabel;
@property (strong, nonatomic) SKSpriteNode *handNode;
@property (strong, nonatomic) SKSpriteNode *rightArrow;
@property (strong, nonatomic) SKSpriteNode *leftArrow;
@end

@implementation GameScene

#pragma mark - Getters and setters

- (SKLabelNode *)scoreLabel {
    if (!_scoreLabel) {
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:LabelFont];
        _scoreLabel.fontSize = 48;
        _scoreLabel.position = CGPointMake(self.size.width / 2, self.size.height - 50);
        _scoreLabel.zPosition = 1;
    }

    return _scoreLabel;
}

#pragma mark - Public methods

- (CGFloat)crowPositionY {
    SKSpriteNode *pointEdge = [SKSpriteNode node];
    pointEdge.name = @"point";
    pointEdge.size = CGSizeMake(1, self.size.height);
    pointEdge.position = CGPointMake(self.initialPoint + 10, self.size.height / 2);
    pointEdge.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pointEdge.size];
    pointEdge.physicsBody.dynamic = NO;
    pointEdge.physicsBody.categoryBitMask = BPointCategory;
    [pointEdge runAction:self.movePoint completion:^{
        [pointEdge removeFromParent];
    }];

    [self addChild:pointEdge];

    return [Utilities randomPositionAtTopWithScene:self numberOfCrows:self.crowCounter++];
}

- (void)gameOver {
    UserDefaults.highscore = MAX(UserDefaults.highscore, self.currentScore);
    self.gameState = GameStateOver;

    [super gameOver];
    [self enumerateChildNodesWithName:@"point" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeAllActions];
    }];

    // Hack to solve the overlap bug
    self.userInteractionEnabled = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(enableInteraction)
                                                userInfo:nil
                                                 repeats:NO];

    [self.butterfly dead];
    [self reportAchievements];
    [self reportHighscore];
}

- (void)enableInteraction {
    self.userInteractionEnabled = YES;
}

#pragma mark - Setup methods

-(void)setup {
    [super setup];
    [self setupScore];
    self.gameState = GameStateReady;

    self.handNode = [SKSpriteNode spriteNodeWithImageNamed:@"Hand"];
    self.handNode.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self addChild:self.handNode];
}

- (void)setupScore {
    self.scoreLabel.text = @"0";
    self.currentScore = 0;
    [self addChild:_scoreLabel];
}

#pragma mark - Update

- (void)update:(NSTimeInterval)currentTime {
    [super update:currentTime];
    [self.butterfly rotate];

    if (self.gameState != GameStateReady) {
        [self updateCrows];
    }
}

#pragma mark - TouchesBegan

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (self.gameState) {
        case GameStateReady:
            [self touchesBeganGameStateReady];
        case GameStateRunning:
            [self touchesBeganGameStateRunning];
            break;
        case GameStateOver:
        default:
            [self touchesBeganGameStateOver];
        break;
    }
}

- (void)touchesBeganGameStateReady {
    if ([self.delegate respondsToSelector:@selector(gameStart)]) {
        [self.delegate gameStart];
    }

    [self.handNode removeFromParent];
    self.gameState = GameStateRunning;
}

- (void)touchesBeganGameStateOver {
    if ([self.delegate respondsToSelector:@selector(gamePrepare)]) {
        [self.delegate gamePrepare];
    }
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if (self.gameState == GameStateOver) {
        return;
    }

    SKPhysicsBody *body =
        (contact.bodyA.categoryBitMask == BButterflyCategory ? contact.bodyB : contact.bodyA);

    switch (body.categoryBitMask) {
        case BPointCategory:
            [self didBeginContactWithPoint];
            break;

        case BGroundCategory:
            [self didBeginContactWithGround];
        break;

        case BCrowCategory:
            [self didBeginContactWithCrow:body];
            break;

        default:
            break;
    }
}

- (void)didBeginContactWithPoint {
    self.currentScore += 1;
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)_currentScore];
}

- (void)didBeginContactWithCrow:(SKPhysicsBody *)body {
    [self gameOver];
    [self runAction:[BaseScene crowSound]];
    SKEmitterNode *emitter = [SKEmitterNode emitterNamed:@"CrowSmash"];
    emitter.targetNode = self.parent;
    [emitter runAction:[SKAction removeFromParentAfterDelay:1.0]];
    [body.node addChild:emitter];
}

- (void)didBeginContactWithGround {
    [self gameOver];
}

#pragma mark - Private methods

-(void)reportAchievements {
    NSArray *achievements = [AchievementsHelper achievementsForCrows:self.currentScore];
    [[ISGameCenter sharedISGameCenter] reportAchievements:achievements];
}

-(void)reportHighscore {
    [[ISGameCenter sharedISGameCenter] reportScore:UserDefaults.highscore
                             leaderboardIdentifier:@"io.iguanastudios.flybutterfly.highscores"];
}

@end
