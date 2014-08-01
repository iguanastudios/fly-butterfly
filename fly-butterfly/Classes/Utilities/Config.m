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
    NSString *URLString = @"https://raw.github.com/iguanastudios/json/master/fly-butterfly/config.json";
    return [NSURL URLWithString:URLString];
}

- (void)setupMapping {
    [self mapRemoteKeyPath:@"googleAnalyticsId" toLocalAttribute:@"googleAnalyticsId" defaultValue:@""];
}

@end
