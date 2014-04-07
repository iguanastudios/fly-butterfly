//
//  BaseScene.m
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "BaseScene.h"
#import "Constants.h"
#import "ISParallaxNode.h"
#import "Crow.h"
#import "Utilities.h"

@interface BaseScene ()
@property (strong, nonatomic) ISParallaxNode *parallaxNode;
@end

@implementation BaseScene

#pragma mark - Getters and setters

- (SKAction *)crowSound {
    if (!_crowSound) {
        _crowSound = [SKAction playSoundFileNamed:@"crow.m4a" waitForCompletion:NO];
    }
    return _crowSound;
}

- (SKAction *)flapSound {
    if (!_flapSound) {
        _flapSound = [SKAction playSoundFileNamed:@"flap.aif" waitForCompletion:NO];
    }
    return _flapSound;
}

- (SKAction *)moveCrow {
    if (!_moveCrow) {
        NSTimeInterval duration = (self.scene.frame.size.width + CrowWidth) * 0.004;
        _moveCrow = [SKAction moveByX: - self.scene.frame.size.width - CrowWidth y:0 duration:duration];
    }
    return _moveCrow;
}

#pragma mark - Public methods

- (void)setup {
    [self setupScene];
    [self setupButterfly];
}

- (void)setupButterfly {
    CGPoint butterflyPosition = CGPointMake(self.size.width - ButterflyPosition,
                                            self.size.height/2);
    self.butterfly = [[Butterfly alloc] initWithPosition:butterflyPosition];
    [self addChild:self.butterfly];
}

#pragma mark - Update

- (void)update:(CFTimeInterval)currentTime {
    [self.parallaxNode update:currentTime];
    [self.butterfly rotate];
}

#pragma mark - Private methods

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

    self.parallaxNode = [[ISParallaxNode alloc] initWithImageNamed:@"Overlap" direction:ISScrollDirectionLeft];
    [self addChild:self.parallaxNode];

    self.matchReady = NO;
}

@end