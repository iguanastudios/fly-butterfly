//
//  Config.h
//  butterfly
//
//  Created by Luis Flores on 3/11/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "GVJSONRemoteConfig.h"

@interface Config : GVJSONRemoteConfig

// Analytics
@property (strong, nonatomic) NSString *googleAnalyticsId;
@property (strong, nonatomic) NSString *crashlyticsId;

+ (Config *)sharedInstance;

@end
