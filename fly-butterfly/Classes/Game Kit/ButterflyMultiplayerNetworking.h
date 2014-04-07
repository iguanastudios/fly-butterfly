//
//  ButterflyMultiplayerNetworking.h
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "ISMultiplayerNetworking.h"

@protocol ISButterflyMultiplayerDelegate <NSObject>
- (void)butterflyCoordinate:(CGFloat)y rotation:(CGFloat)rotation;
- (void)butterflyBlink;
- (void)butterflyCrash;
- (void)crowPositions:(NSArray *)positions;
- (void)crowsReceived;
@end

@interface ButterflyMultiplayerNetworking : ISMultiplayerNetworking

@property (nonatomic, assign) id<ISButterflyMultiplayerDelegate> butterflyDelegate;

- (void)sendButterflyCoordinate:(CGFloat)y rotation:(CGFloat)rotation;
- (void)sendButterflyBlink;
- (void)sendButterflyCrash;
- (void)sendCrowPositions:(NSArray *)positions;
- (void)sendCrowsReceived;

@end
