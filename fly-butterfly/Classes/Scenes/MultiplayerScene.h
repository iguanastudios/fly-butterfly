//
//  MultiplayerScene.h
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ISMultiplayerNetworking.h"
#import "ButterflyMultiplayerNetworking.h"
#import "BaseScene.h"

@interface MultiplayerScene : BaseScene <ISButterflyMultiplayerDelegate>

@property (strong, nonatomic) ButterflyMultiplayerNetworking *networkingEngine;
@property (assign, nonatomic) BOOL hoster;

- (void)setup;

@end
