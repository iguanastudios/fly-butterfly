//
//  Butterfly.m
//  butterfly
//
//  Created by Luis Flores on 3/4/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "Butterfly.h"
#import "Constants.h"

@implementation Butterfly

#pragma mark - Initialization

- (instancetype)initWithPosition:(CGPoint)position {
    if (self = [super initWithPosition:position]) {
        self.facingSideAnimation = [Butterfly createAnimationForeverWithPrefix:@"butterfly" frames:6];
        self.name = @"butterfly";

        CGFloat minDiam = MIN(self.size.width, self.size.height);
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:minDiam/2.0 - 1];
        self.physicsBody.categoryBitMask = BButterflyCategory;
        self.physicsBody.collisionBitMask = BEdgeCategory | BCrowCategory | BGroundCategory;
        self.physicsBody.contactTestBitMask = BGroundCategory | BCrowCategory | BCrowEdgeCategory;
        self.physicsBody.dynamic = NO;

        [self runAction:self.facingSideAnimation];
    }

    return self;
}

#pragma mark - Override AnimatingSprite

+ (SKTexture *)generateTexture {
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"butterfly"];
        texture = [atlas textureNamed:@"butterfly1"];
    });

    return texture;
}

+ (SKAction*)createAnimationForeverWithPrefix:(NSString *)prefix frames:(NSInteger)frames {
    static SKAction *animation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animation = [super createAnimationForeverWithPrefix:prefix frames:frames atlas:@"butterfly"];
    });

    return animation;
}

#pragma mark - Public Methods

- (void)dead {
    [self removeAllActions];
    self.physicsBody.collisionBitMask = 0;
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
    [self setZRotation:rotation - M_1_PI / 2];
}

@end