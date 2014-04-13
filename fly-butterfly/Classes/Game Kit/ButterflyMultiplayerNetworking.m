//
//  ButterflyMultiplayerNetworking.m
//  butterfly
//
//  Created by Luis Flores on 3/30/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "ButterflyMultiplayerNetworking.h"

typedef NS_ENUM(int, ButterflyMessageType) {
    ButterflyMessageTypeButterflyCoordinate = 3,
    ButterflyMessageTypeButterflyBlink,
    ButterflyMessageTypeButterflyCrash,
    ButterflyMessageTypeCrowPositions,
    ButterflyMessageTypeCrowsReceived,
};

typedef struct {
    ButterflyMessageType messageType;
} ButterflyMessage;

typedef struct {
    ButterflyMessage message;
    float y;
    float z;
} ButterflyMessageCoordinate;

typedef struct {
    ButterflyMessage message;
    float positions[100];
} ButterflyMessageCrowPositions;

@implementation ButterflyMultiplayerNetworking

#pragma mark - Public methods

- (void)sendButterflyCoordinate:(CGFloat)y rotation:(CGFloat)rotation {
    ButterflyMessageCoordinate message;
    message.message.messageType = ButterflyMessageTypeButterflyCoordinate;
    message.y = y;
    message.z = rotation;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(ButterflyMessageCoordinate)];
    [self sendUnreliableData:data];
}

- (void)sendButterflyBlink {
    [self sendDataWithMessageType:ButterflyMessageTypeButterflyBlink];
}

- (void)sendButterflyCrash {
    [self sendDataWithMessageType:ButterflyMessageTypeButterflyCrash];
}

- (void)sendCrowPositions:(NSArray *)positions {
    ButterflyMessageCrowPositions message;
    message.message.messageType = ButterflyMessageTypeCrowPositions;

    for (int position = 0; position < 100; position++) {
        NSNumber *positionY = [positions objectAtIndex:position];
        message.positions[position] = [positionY floatValue];
    }

    NSData *data = [NSData dataWithBytes:&message length:sizeof(ButterflyMessageCrowPositions)];
    [self sendReliableData:data];
}

- (void)sendCrowsReceived {
    [self sendDataWithMessageType:ButterflyMessageTypeCrowsReceived];
}

- (void)sendDataWithMessageType:(ButterflyMessageType)butterflyMessageType {
    ButterflyMessage message;
    message.messageType = butterflyMessageType;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(ButterflyMessage)];
    [self sendReliableData:data];
}

#pragma mark - Private methods

- (void)butterflyCoordinate:(NSData *)data {
    ButterflyMessageCoordinate *message = (ButterflyMessageCoordinate*)[data bytes];
    CGFloat y = message->y;
    CGFloat z = message->z;

    if ([self.butterflyDelegate respondsToSelector:@selector(butterflyCoordinate:rotation:)]) {
        [self.butterflyDelegate butterflyCoordinate:y rotation:z];
    }
}

- (void)butterflyBlink {
    [self.butterflyDelegate butterflyBlink];
}

- (void)butterflyCrash {
    [self.butterflyDelegate butterflyCrash];
}

- (void)crowPositions:(NSData *)data {
    [self sendCrowsReceived];
    ButterflyMessageCrowPositions *message = (ButterflyMessageCrowPositions*)[data bytes];
    NSMutableArray *positions = [[NSMutableArray alloc] initWithCapacity:100];

    for (int i = 0; i < 100; i++) {
        [positions addObject:@(message->positions[i])];
    }

    [self.butterflyDelegate crowPositions:positions];
}

- (void)crowsReceived {
    [self.butterflyDelegate crowsReceived];
}

#pragma mark - ISMultiplayerNetworking

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerId {
    ButterflyMessage *message = (ButterflyMessage*)[data bytes];

    switch (message->messageType) {
        case ButterflyMessageTypeButterflyCoordinate:
            [self butterflyCoordinate:data];
            break;

        case ButterflyMessageTypeButterflyBlink:
            [self butterflyBlink];
            break;

        case ButterflyMessageTypeButterflyCrash:
            [self butterflyCrash];
            break;

        case ButterflyMessageTypeCrowPositions:
            [self crowPositions:data];
            break;

        case ButterflyMessageTypeCrowsReceived:
            [self crowsReceived];
            break;

        default:
            [super match:match didReceiveData:data fromPlayer:playerId];
            break;
    }
}

@end
