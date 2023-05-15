//
//  SettingsManager.m
//  Tomato
//
//  Created by Lin Teng on 1/9/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "SettingsManager.h"
#import "MyGlobal.h"

#if DEBUG_TOMATO
#define POMODORO_DURATION 20
#define BREAK_DURATION 15
#define LONG_BREAK_DURATION 25
#endif

@implementation SettingsManager

+ (SettingsManager*)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static SettingsManager* _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

#pragma mark - timing

- (NSInteger)pomodoroDuration
{
#if DEBUG_TOMATO
    return POMODORO_DURATION;
#endif
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];       
    id value = [defaults objectForKey:@"pomodoro_duration_pref"];
    
    return [((NSNumber*)value) intValue];
}

- (NSInteger)breakDuration
{
    
#if DEBUG_TOMATO
    return BREAK_DURATION;
#endif
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"break_duration_pref"];
    
    return [((NSNumber*)value) intValue];
}

- (NSInteger)longBreakEveryPomodoro
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"long_break_every_pref"];
    
    return [((NSNumber*)value) intValue];
}

- (NSInteger)longBreakDuration
{
#if DEBUG_TOMATO
    return LONG_BREAK_DURATION;
#endif
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"long_break_duration_pref"];
    
    return [((NSNumber*)value) intValue];
}

- (NSInteger)plannedBreakDurationForCompletedPomodoroCount:(NSInteger)pomodoroCount
{    
    if (pomodoroCount%self.longBreakEveryPomodoro != 0) {
        return self.breakDuration;
    }
    else {
        return self.longBreakDuration;
    }
}


#pragma mark - auto

- (BOOL)autoBreak
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"auto_break_pref"];
    
    return [((NSNumber*)value) boolValue];
}

- (BOOL)autoNextPomodoro
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"auto_next_pref"];
    
    return [((NSNumber*)value) boolValue];
}


#pragma mark - sound

- (NSString*)sampleSoundFile
{
    return @"alert_sweet_jingle";
}

- (NSString*)pomodoroStartSoundFile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"pomodoro_start_pref"];
    
    return ((NSString*)value);
}

- (NSString*)pomodoroEndSoundFile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"pomodoro_end_pref"];
    
    return ((NSString*)value);
}

- (NSString*)breakEndSoundFile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"break_end_pref"];
    
    return ((NSString*)value);
}

- (NSString*)tickingSoundFile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"ticking_pref"];
    
    return ((NSString*)value);
}

- (BOOL)ticking
{
    if ([self tickingSoundFile].length > 0 && ![[self tickingSoundFile] isEqualToString:@"empty_sound"]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSString*)pomodoroWarningSoundFile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"pomodoro_warning_sound_pref"];
    
    return ((NSString*)value);
}

- (BOOL)pomodoroWarningBeforeEnd
{
    if ([self pomodoroWarningSoundFile].length > 0 && ![[self pomodoroWarningSoundFile] isEqualToString:@"empty_sound"]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSString*)breakWarningSoundFile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"break_warning_sound_pref"];
    
    return ((NSString*)value);
}

- (BOOL)breakWarningBeforeEnd
{
    if ([self breakWarningSoundFile].length > 0 && ![[self breakWarningSoundFile] isEqualToString:@"empty_sound"]) {
        return YES;
    }
    else {
        return NO;
    }
}


- (BOOL)alarmVibration
{
    //return NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"vibrate_pref"];
    
    return [((NSNumber*)value) boolValue];
}

#pragma mark - screen dimming ?

- (BOOL)screenDimming
{
    //return NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"allow_dimming_pref"];
    
    return [((NSNumber*)value) boolValue];
}

- (BOOL)disableAutolock
{
    //return NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"disable_autolock_pref"];
    
    return [((NSNumber*)value) boolValue];
}

#pragma mark - theme

- (TomatoTheme)theme
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id value = [defaults objectForKey:@"theme_pref"];
    
    return (TomatoTheme)[((NSNumber*)value) intValue];   
}

@end
