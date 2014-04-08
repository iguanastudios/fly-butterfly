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
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSUInteger crows;
@end

@implementation GameScene {
    SKLabelNode *_scoreLabel;
    NSInteger _currentScore;
}

#pragma mark - Initialization

-(void)setup {
    [super setup];
    [self setupScore];
}

- (void)setupScore {
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:ScoreLabelFont];
    _scoreLabel.fontSize = ScoreLabelSize;
    _scoreLabel.text = @"0";
    _scoreLabel.position = CGPointMake(self.size.width / 2, self.size.height - 50);
    _scoreLabel.zPosition = 1;
    _currentScore = 0;

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
    self.crowTopPosition = [Utilities randomPositionAtTopWithScene:self numberOfCrows:self.crows];
    self.crowBottomPosition = self.crowTopPosition - MinSpaceBetweenBombs;

    Crow *crowTop = [[Crow alloc] initWithPosition:CGPointMake(x, self.crowTopPosition)];
    [crowTop runAction:self.moveCrow completion:^{
        [crowTop removeFromParent];
    }];

    [self addChild:crowTop];

    Crow *crowBottom = [[Crow alloc] initWithPosition:CGPointMake(x, self.crowBottomPosition)];
    [crowBottom runAction:self.moveCrow completion:^{
        [crowBottom removeFromParent];
    }];

    [self addChild:crowBottom];

    self.crows++;

    SKSpriteNode *crowEdge = [SKSpriteNode node];
    crowEdge.size = CGSizeMake(1, self.size.height);
    crowEdge.position = CGPointMake(x + 10, self.size.height / 2);
    crowEdge.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:crowEdge.size];
    crowEdge.physicsBody.dynamic = NO;
    crowEdge.physicsBody.categoryBitMask = BCrowEdgeCategory;
    [crowEdge runAction:self.moveCrow];
    [self addChild:crowEdge];
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if(self.gameOver) {
        return;
    }

    SKPhysicsBody *body = (contact.bodyA.categoryBitMask == BButterflyCategory ? contact.bodyB : contact.bodyA);

    if (body.categoryBitMask == BCrowEdgeCategory) {
        _currentScore += 1;
        _scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)_currentScore];
        return;
    }

    [Utilities flashScene:self];
    [self removeAllActions];
    
    if (body.categoryBitMask == BCrowCategory) {
        [self runAction:self.crowSound];
        SKEmitterNode *emitter = [SKEmitterNode emitterNamed:@"CrowSmash"];
        emitter.targetNode = self.parent;
        [emitter runAction:[SKAction removeFromParentAfterDelay:1.0]];
        [body.node addChild:emitter];
    }

//    if (self.multiplayerMatch) {
//        [self.networkingEngine sendGameOverMessage];
//    }

    // Hack to solve the overlap bug
    self.userInteractionEnabled = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(enableInteraction)
                                                userInfo:nil
                                                 repeats:NO];

    self.gameOver = YES;
    [self.butterfly dead];

    [self enumerateChildNodesWithName:@"crow"
                                usingBlock:^(SKNode *node, BOOL *stop){
                                    Crow* crow = (Crow*) node;
                                    [crow removeAllActions];
                                }
     ];
    
    UserDefaults.highscore = MAX(UserDefaults.highscore, _currentScore);
    [self reportAchievements];
    [self reportHighscore];
    
    if ([self.delegate respondsToSelector:@selector(gameOver)]) {
        [self.delegate gameOver];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.gameOver) {
        if (!self.matchReady) {
            self.matchReady = YES;
            [self setupCrows];

            if ([self.delegate respondsToSelector:@selector(gameStart)]) {
                [self.delegate gameStart];
            }
        }

        [self runAction:self.flapSound];
        [self.butterfly fly];
    } else {
        if ([self.delegate respondsToSelector:@selector(gamePrepare)]) {
            [self.delegate gamePrepare];
        }
    }
}

#pragma mark - Private methods

-(void)reportAchievements {
    NSArray *achievements = [AchievementsHelper achievementsForCrows:_currentScore];
    [[ISGameCenter sharedISGameCenter] reportAchievements:achievements];
}

-(void)reportHighscore {
    [[ISGameCenter sharedISGameCenter] reportScore:UserDefaults.highscore
                             leaderboardIdentifier:@"io.iguanastudios.butterfly.highscores"];
}

- (void)enableInteraction {
    self.userInteractionEnabled = YES;
}

@end
