//
//  Config.m
//  butterfly
//
//  Created by Luis Flores on 3/11/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "Config.h"

@implementation Config

#pragma mark - Singleton

+ (Config *)sharedInstance {
    static dispatch_once_t pred;
    static Config *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - GVJSONRemoteConfig overrides

- (NSURL *)remoteFileLocation {
    NSString *URLString = @"https://raw.github.com/iguanastudios/json/master/butterfly/config.json";
    return [NSURL URLWithString:URLString];
}

- (void)setupMapping {
    // Analytics
    [self mapRemoteKeyPath:@"googleAnalyticsId" toLocalAttribute:@"googleAnalyticsId" defaultValue:@"UA-48137181-2"];
    [self mapRemoteKeyPath:@"crashlyticsId" toLocalAttribute:@"crashlyticsId" defaultValue:@"db7f2b5ac560a858c853e4eb1c203a987c06fd64"];
}

@end
