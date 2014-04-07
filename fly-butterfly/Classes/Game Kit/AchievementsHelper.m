//
//  AchievementsHelper.m
//  butterfly
//
//  Created by Luis Flores on 3/23/14.
//  Copyright (c) 2014 Iguana Studios. All rights reserved.
//

#import "AchievementsHelper.h"

static NSString* const kAchievementId50 = @"io.iguanastudios.flybutterfly.amateursurvival";
static NSString* const kAchievementId100 = @"io.iguanastudios.flybutterfly.intermediatesurvival";
static NSString* const kAchievementId150 = @"io.iguanastudios.flybutterfly.professionalsurvival";
static NSString* const kAchievementId250 = @"io.iguanastudios.flybutterfly.grandmastersurvival";

@implementation AchievementsHelper

+ (NSArray *)achievementsForCrows:(NSInteger)totalCrows {
    NSMutableArray *achievementsArray = [NSMutableArray array];
    GKAchievement *achievement;

    achievement = [self checkCrows:totalCrows expected:50];
    if (achievement) {
        [achievementsArray addObject:achievement];
    }

    achievement = [self checkCrows:totalCrows expected:100];
    if (achievement) {
        [achievementsArray addObject:achievement];
    }

    achievement = [self checkCrows:totalCrows expected:150];
    if (achievement) {
        [achievementsArray addObject:achievement];
    }

    achievement = [self checkCrows:totalCrows expected:250];
    if (achievement) {
        [achievementsArray addObject:achievement];
    }

    return achievementsArray;
}

#pragma mark - Private methods

+ (GKAchievement *)checkCrows:(NSUInteger)crows expected:(NSUInteger)total {
    NSString *achievementIdentifier;

    if (total == 50) {
        achievementIdentifier = kAchievementId50;
    } else if(total == 100) {
        achievementIdentifier = kAchievementId100;
    } else if(total == 150) {
        achievementIdentifier = kAchievementId150;
    } else {
        achievementIdentifier = kAchievementId250;
    }

    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
    CGFloat percent = (crows/total) * 100;
    achievement.percentComplete = percent;
    achievement.showsCompletionBanner = YES;
    return achievement;
}

@end
