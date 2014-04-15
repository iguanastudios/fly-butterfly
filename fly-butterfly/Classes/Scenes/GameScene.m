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
@property (assign, nonatomic) GameState gameState;
@property (strong, nonatomic) SKSpriteNode *handNode;
@property (strong, nonatomic) SKLabelNode *scoreLabel;
@property (assign, nonatomic) NSUInteger currentScore;
@property (assign, nonatomic) CFTimeInterval time;
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

#pragma mark - Initialization

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

- (void)setupCrows {
    SKAction *wait = [SKAction waitForDuration:CrowDefaultInterval];
    SKAction *spawnCrowActions = [SKAction performSelector:@selector(spawnCrows)
                                                  onTarget:self];
    SKAction *sequenceCrows = [SKAction sequence: @[spawnCrowActions, wait]];
    [self runAction: [SKAction repeatActionForever: sequenceCrows]];
}

- (void)spawnCrows {
    CGFloat x = self.size.width + CrowWidth / 2;
    self.crowTopPosition = [Utilities randomPositionAtTopWithScene:self numberOfCrows:self.crowCounter];
    self.crowBottomPosition = self.crowTopPosition - MinSpaceBetweenBombs;

    Crow *crowTop = [[Crow alloc] initWithPosition:CGPointMake(x, self.crowTopPosition)];
    [crowTop animate];
    [crowTop runAction:self.moveCrow completion:^{
        [crowTop removeFromParent];
    }];

    [self addChild:crowTop];

    Crow *crowBottom = [[Crow alloc] initWithPosition:CGPointMake(x, self.crowBottomPosition)];
    [crowBottom animate];
    [crowBottom runAction:self.moveCrow completion:^{
        [crowBottom removeFromParent];
    }];

    [self addChild:crowBottom];

    self.crowCounter++;
    SKSpriteNode *pointEdge = [SKSpriteNode node];
    pointEdge.size = CGSizeMake(1, self.size.height);
    pointEdge.position = CGPointMake(x + 10, self.size.height / 2);
    pointEdge.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pointEdge.size];
    pointEdge.physicsBody.dynamic = NO;
    pointEdge.physicsBody.categoryBitMask = BPointCategory;
    [pointEdge runAction:self.moveCrow completion:^{
        [pointEdge removeFromParent];
    }];
    [self addChild:pointEdge];
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
    [self setupCrows];

    if ([self.delegate respondsToSelector:@selector(gameStart)]) {
        [self.delegate gameStart];
    }

    [self.handNode removeFromParent];
    self.gameState = GameStateRunning;
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

        case BCrowCategory:
        default:
            [self didBeginContactWithCrow:body];
            break;
    }
}

- (void)didBeginContactWithPoint{
    self.currentScore += 1;
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)_currentScore];
}

- (void)didBeginContactWithCrow:(SKPhysicsBody *)body {
    [self gameOver];
    self.gameState = GameStateOver;

    [self runAction:self.crowSound];
    SKEmitterNode *emitter = [SKEmitterNode emitterNamed:@"CrowSmash"];
    emitter.targetNode = self.parent;
    [emitter runAction:[SKAction removeFromParentAfterDelay:1.0]];
    [body.node addChild:emitter];

    // Hack to solve the overlap bug
    self.userInteractionEnabled = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(enableInteraction)
                                                userInfo:nil
                                                 repeats:NO];

    [self.butterfly dead];

    UserDefaults.highscore = MAX(UserDefaults.highscore, self.currentScore);
    [self reportAchievements];
    [self reportHighscore];
}

#pragma mark - Private methods

-(void)reportAchievements {
    NSArray *achievements = [AchievementsHelper achievementsForCrows:_currentScore];
    [[ISGameCenter sharedISGameCenter] reportAchievements:achievements];
}

-(void)reportHighscore {
    [[ISGameCenter sharedISGameCenter] reportScore:UserDefaults.highscore
                             leaderboardIdentifier:@"io.iguanastudios.flybutterfly.highscores"];
}

@end
