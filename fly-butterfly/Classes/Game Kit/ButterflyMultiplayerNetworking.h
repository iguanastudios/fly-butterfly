//
//  ButterflyMultiplayerNetworking.h
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "ISMultiplayerNetworking.h"

@protocol ISButterflyMultiplayerDelegate <NSObject>
@required
- (void)butterflyCoordinate:(CGFloat)x y:(CGFloat)y rotation:(CGFloat)rotation;
- (void)butterflyBlink;
- (void)crowPositions:(NSArray *)positions;
- (void)crowsReceived;
@end

@interface ButterflyMultiplayerNetworking : ISMultiplayerNetworking

@property (weak, nonatomic) id<ISButterflyMultiplayerDelegate> butterflyDelegate;

- (void)sendButterflyCoordinate:(CGFloat)x y:(CGFloat)y rotation:(CGFloat)rotation;
- (void)sendButterflyBlink;
- (void)sendCrowPositions:(NSArray *)positions;
- (void)sendCrowsReceived;

@end
