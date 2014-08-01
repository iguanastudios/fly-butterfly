//
//  Butterfly.m
//  butterfly
//
//  Created by Luis Flores on 3/4/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <ISSpriteKit/SKEmitterNode+ISExtras.h>
#import "Butterfly.h"

@implementation Butterfly

#pragma mark - Initialization

- (instancetype)initWithPosition:(CGPoint)position {
    if (self = [super initWithPosition:position]) {
        self.facingSideAnimation = [Butterfly createAnimationForeverWithPrefix:@"butterfly" frames:6];
        self.name = @"butterfly";

        CGFloat minDiam = MIN(self.size.width, self.size.height);
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:minDiam/2.0 - 1];
        self.physicsBody.categoryBitMask = BButterflyCategory;
        self.physicsBody.collisionBitMask = BEdgeCategory | BGroundCategory;
        self.physicsBody.contactTestBitMask = BGroundCategory | BCrowCategory | BPointCategory;
        self.physicsBody.dynamic = NO;

        [self runAction:self.facingSideAnimation];
    }

    return self;
}

#pragma mark - AnimatingSprite

+ (SKTexture *)generateTexture {
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"sprites"];
        texture = [atlas textureNamed:@"butterfly1"];
    });

    return texture;
}

+ (SKAction*)createAnimationForeverWithPrefix:(NSString *)prefix frames:(NSInteger)frames {
    static SKAction *animation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animation = [super createAnimationForeverWithPrefix:prefix frames:frames atlas:@"sprites"];
    });

    return animation;
}

#pragma mark - Public Methods

- (void)setupButterflyTray {
    self.zPosition = 100;
    [self addButterflyTrail:[SKEmitterNode emitterNamed:@"ButterflyTrail"]];
}

- (void)setupMultiplayerButterflyTray {
    self.zPosition = 50;
    [self addButterflyTrail:[SKEmitterNode emitterNamed:@"MultiplayerButterflyTrail"]];
}

- (void)dead {
    [self removeAllActions];
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = 0;
}

- (void)fly {
    if (!self.physicsBody.dynamic) {
        self.physicsBody.dynamic = YES;
    }

    self.physicsBody.velocity = CGVectorMake(0, 0);
    [self.physicsBody applyImpulse: CGVectorMake(0, JumpImpulse)];
    [self runAction:self.facingSideAnimation];
}

- (void)rotate {
    // Rotate butterfly on fly / fall down
    CGFloat rotation = ((self.physicsBody.velocity.dy + 400) / (2 * 400)) * M_2_PI;
    self.zRotation =  rotation - M_1_PI / 2;
}

#pragma mark - Private methods

- (void) addButterflyTrail:(SKEmitterNode *)trailEmmiter {
    [self addChild:trailEmmiter];
    trailEmmiter.targetNode = self.parent;
    trailEmmiter.position = CGPointMake(-10, 0);
    trailEmmiter.zPosition = self.zPosition - 1;
}

@end
