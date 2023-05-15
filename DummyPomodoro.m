//
//  DummyPomodoro.m
//  Tomato
//
//  Created by Teng Lin on 13-1-13.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import "DummyPomodoro.h"
#import "SettingsManager.h"

#define KPStartDate      @"pStartDate"
#define KPDuration      @"pDuration"
#define KPEndDate      @"pEndDate"
#define KPInterrupted      @"pInterrupted"

#define KBStartDate      @"bStartDate"
#define KBDuration      @"bDuration"
#define KBEndDate      @"bEndDate"
#define KBInterrupted      @"bInterrupted"


@implementation DummyPomodoro

+ (DummyPomodoro*)createInstanceAfterCountOfToday:(NSInteger)countOfToday
{
    DummyPomodoro *object = [[DummyPomodoro alloc] init];    
    object.pDuration = [SettingsManager sharedInstance].pomodoroDuration;    
    if ((countOfToday+1)%[SettingsManager sharedInstance].longBreakEveryPomodoro == 0) {
        object.bDuration = [SettingsManager sharedInstance].longBreakDuration;
    }
    else {
        object.bDuration = [SettingsManager sharedInstance].breakDuration;
    }
    object.pInterrupted = NO;
    object.bInterrupted = NO;
    return object;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        [self setPStartDate:[aDecoder decodeObjectForKey:KPStartDate]];
        [self setPDuration:[aDecoder decodeIntForKey:KPDuration]];
        [self setPEndDate:[aDecoder decodeObjectForKey:KPEndDate]];
        [self setPInterrupted:[aDecoder decodeBoolForKey:KPInterrupted]];
        
        [self setBStartDate:[aDecoder decodeObjectForKey:KBStartDate]];
        [self setBDuration:[aDecoder decodeIntForKey:KBDuration]];
        [self setBEndDate:[aDecoder decodeObjectForKey:KBEndDate]];
        [self setBInterrupted:[aDecoder decodeBoolForKey:KBInterrupted]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.pStartDate forKey:KPStartDate];
    [aCoder encodeInt:self.pDuration forKey:KPDuration];
    [aCoder encodeObject:self.pEndDate forKey:KPEndDate];
    [aCoder encodeBool:self.pInterrupted forKey:KPInterrupted];
    
    [aCoder encodeObject:self.bStartDate forKey:KBStartDate];
    [aCoder encodeInt:self.bDuration forKey:KBDuration];
    [aCoder encodeObject:self.bEndDate forKey:KBEndDate];
    [aCoder encodeBool:self.bInterrupted forKey:KBInterrupted];
    
}

@end
