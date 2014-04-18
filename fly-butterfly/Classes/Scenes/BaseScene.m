//
//  BaseScene.m
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <ISSpriteKit/ISParallaxLayer.h>
#import "BaseScene.h"

@interface BaseScene ()
@property (strong, nonatomic) ISParallaxNode *parallaxNode;
@property (nonatomic) NSTimeInterval previousTimeInterval;
@end

@implementation BaseScene

+ (void)initialize {
    if ([self class] == [BaseScene class]) {
        CrowSound = [SKAction playSoundFileNamed:@"crow.m4a" waitForCompletion:NO];
        FlapSound = [SKAction playSoundFileNamed:@"flap.aif" waitForCompletion:NO];
    }
}

#pragma mark - Getters and setters

- (SKAction *)crowFly {
    if (!_crowFly) {
        NSTimeInterval duration = self.initialPoint  * 0.005;
        _crowFly = [SKAction moveToX:-CrowWidth duration:duration];
    }
    return _crowFly;
}

#pragma mark - Public methods

+ (SKAction *)crowSound {
    return CrowSound;
}

+ (SKAction *)flapSound {
    return FlapSound;
}

- (CGFloat)crowPositionY {
    // Implemented by subclasses
    return 0.0;
}

- (void)gameOver {
    [self removeAllActions];
    [Utilities flashScene:self];

    [self enumerateChildNodesWithName:@"crow" usingBlock:^(SKNode *node, BOOL *stop){
        [node removeAllActions];
    }];

    if ([self.delegate respondsToSelector:@selector(gameOver)]) {
        [self.delegate gameOver];
    }
}

- (void)enableInteraction {
    self.userInteractionEnabled = YES;
}

#pragma mark - Setup methods

- (void)setup {
    [self setupScene];
    [self setupButterfly];
    [self setupCrows];
    self.crowCounter = 0;
}

- (void)setupScene {
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
    background.anchorPoint = CGPointZero;
    background.position = CGPointMake(0, GoogleBannerHeight);
    [self addChild: background];

    CGRect bodyRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bodyRect];
    self.physicsWorld.contactDelegate = self;
    self.physicsBody.categoryBitMask = BEdgeCategory;
    self.physicsWorld.speed = Speed;

    SKSpriteNode *groundNode = [SKSpriteNode node];
    CGRect groundRect = CGRectMake(0, 0, self.frame.size.width, GoogleBannerHeight);
    groundNode.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:groundRect];
    groundNode.physicsBody.categoryBitMask = BGroundCategory;
    [self addChild:groundNode];

    self.parallaxNode = [[ISParallaxNode alloc] initWithImageNamed:@"Overlap"
                                                         direction:ISScrollDirectionLeft];
    [self addChild:self.parallaxNode];
}

- (void)setupButterfly {
    CGPoint butterflyPosition = CGPointMake(self.size.width - ButterflyPosition,
                                            self.size.height/2);
    self.butterfly = [[Butterfly alloc] initWithPosition:butterflyPosition];
    [self addChild:self.butterfly];
    [self.butterfly setupButterflyTray];
}

- (void)setupCrows {
    // Anchor point is in the middle
    self.initialPoint = self.size.width + CrowWidth / 2;

    for (int iterator = 0; iterator < 10; iterator++) {
        Crow *crow = [[Crow alloc] initWithPosition:CGPointMake(-CrowWidth, 0)];
        [self addChild:crow];
    }
}

#pragma mark - Update

- (void)update:(CFTimeInterval)currentTime {
    [self.parallaxNode update:currentTime];
    [self.butterfly rotate];

    if (self.previousTimeInterval) {
        self.deltaTime = currentTime - self.previousTimeInterval;
    } else {
        self.deltaTime = 0;
    }

    self.previousTimeInterval = currentTime;
}

- (void)updateCrows {
    __block BOOL needForCrows = YES;

    [self enumerateChildNodesWithName:@"crow" usingBlock:^(SKNode *node, BOOL *stop) {
        // Check if crow has passed the screen
        if (node.position.x < -(CrowWidth / 2)) {
            [node removeActionForKey:@"fly"];
        } else if (node.position.x > self.size.width - 150) {
            // Need for a new spawn
            needForCrows = NO;
        }
    }];

    if (needForCrows) {
        __block int crowCounter = 0;
        CGFloat y = [self crowPositionY];

        [self enumerateChildNodesWithName:@"crow" usingBlock:^(SKNode *node, BOOL *stop) {
            if (node.position.x <= 0) {
                Crow *crow = (Crow *)node;

                // Top crow
                if (crowCounter == 0) {
                    crow.position = CGPointMake(self.initialPoint, y);
                } else {
                    crow.position = CGPointMake(self.initialPoint, y - MinSpaceBetweenCrows);
                }

                [crow runAction:self.crowFly withKey:@"fly"];
                crowCounter++;
            }

            if (crowCounter >= 2) {
                *stop = YES;
            }
        }];
    }
}

#pragma mark - TouchesBegan

- (void)touchesBeganGameStateRunning {
    [self runAction:[BaseScene flapSound]];
    [self.butterfly fly];
}

- (void)touchesBeganGameStateOver {
    if ([self.delegate respondsToSelector:@selector(gamePrepare)]) {
        [self.delegate gamePrepare];
    }
}

@end
