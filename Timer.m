//
//  Timer.m
//  Tomato
//
//  Created by Lin Teng on 1/5/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "Timer.h"
#import "AlertManager.h"
#import "TomatoManager.h"
#import "DataManager.h"
#import "SettingsManager.h"

typedef enum {
    TimerStatusInited,    
    TimerStatusDelaying,
    TimerStatusDelayingPaused, //not really paused(we can't pause the delaying), but indicate use want to pause the whole timer during delaying
    TimerStatusDelayFinished,
    TimerStatusDelayFinishedPaused,
    TimerStatusRunning,
    TimerStatusRunningPaused,
    TimerStatusStoped
} TomatoTimerStatus;

@interface Timer()
{   
   
}

#warning target shoulb be weak?
@property (nonatomic, weak) id<TimerDelegate> delegate;
@property (nonatomic) TomatoTimerStatus timerStatus;
@property (nonatomic, strong) NSTimer* nsCountDownTimer;

//@property (nonatomic) NSTimeInterval duration;  // no use currently
@property (nonatomic) NSInteger lastRemainDurationInteger;  // update the ui only by 1 sec, 2 sec, 3 sec,  not by 0.1 sec, 0.2 sec, 0.3 sec
// evertime start or resume the timer, means a section; sectionRemainDuration should be same as remainDuration , so skip define it.
@property (nonatomic) NSTimeInterval sectionDuration;
@property (nonatomic, strong) NSDate *sectionStartingTime;
@property (nonatomic) NSTimeInterval sectionElapsedDuration;

@end

@implementation Timer
@synthesize isPaused = _isPaused;

+ (id)initTimer:(NSTimeInterval)duration on:(NSObject<TimerDelegate>*)delegate
{
    Timer* timer = [[Timer alloc] init];
    timer.delegate = delegate;        
    timer.remainDuration = duration;
    timer.lastRemainDurationInteger = -1;
    timer.timerStatus = TimerStatusInited;
    [delegate remainingTimeDidChange:[NSNumber numberWithInt:duration]];
    return timer;
}

+ (id)startWithDuration:(NSTimeInterval)duration andCallWhenEnded:(SEL)selector on:(NSObject<TimerDelegate>*)delegate
{
    Timer* timer = [Timer initTimer:duration on:delegate];
    timer.warningSelector = nil;
    timer.endSelector = selector;
    [timer timerRunningForRemainDuration];
    timer.timerStatus = TimerStatusRunning;
    return timer;
}

+ (id)startWithDuration:(NSTimeInterval)duration andCallWhenEnded:(SEL)selector on:(NSObject<TimerDelegate>*)delegate afterDelay:(NSTimeInterval)delay
{
    Timer* timer = [Timer initTimer:duration on:delegate];
    timer.warningSelector = nil;
    timer.endSelector = selector;
    [timer performSelector:@selector(timerRunningForRemainDurationAfterDelay) withObject:nil afterDelay:delay];
    timer.timerStatus = TimerStatusDelaying;
    return timer;
}

+ (id)startWithDuration:(NSTimeInterval)duration andCallWhenWarning:(SEL)warningSelector andCallWhenEnded:(SEL)endSelector on:(NSObject<TimerDelegate>*)delegate afterDelay:(NSTimeInterval)delay
{
    Timer* timer = [Timer initTimer:duration on:delegate];
    timer.warningSelector = warningSelector;
    timer.endSelector = endSelector;
    timer.playWarningSound = [NSNumber numberWithBool:YES];
    [timer performSelector:@selector(timerRunningForRemainDurationAfterDelay) withObject:nil afterDelay:delay];
    timer.timerStatus = TimerStatusDelaying;
    return timer;
}

- (void)timerRunningForRemainDuration
{
    self.timerStatus = TimerStatusRunning;
    self.sectionDuration = self.remainDuration;
    self.sectionStartingTime = [NSDate date];
    self.nsCountDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkRemainDuration) userInfo:nil repeats:YES];
    [self scheduleTicking];
}

- (void)timerRunningForRemainDurationAfterDelay
{        
    switch (self.timerStatus) {
        case TimerStatusInited:
            break;        
        case TimerStatusDelaying:
            self.timerStatus = TimerStatusDelayFinished;
            break;
        case TimerStatusDelayingPaused:
            self.timerStatus = TimerStatusDelayFinishedPaused;
            break;
        case TimerStatusDelayFinished:            
            break;
        case TimerStatusDelayFinishedPaused:
            break;
        case TimerStatusRunning:
            break;
        case TimerStatusRunningPaused:
            break;
        case TimerStatusStoped:
            break;
        default:
            break;
    }    
    if (self.timerStatus == TimerStatusDelayFinished) {
        [self timerRunningForRemainDuration];
    }    
}

- (void)pause
{
    [self pauseWithoutStopTicking];
    [self stopTicking];    
}

-(void)pauseWithoutStopTicking
{
    ClawVerbose(@"status is %d", self.timerStatus);    
    switch (self.timerStatus) {
        case TimerStatusInited:            
            break;        
        case TimerStatusDelaying:
            self.timerStatus = TimerStatusDelayingPaused;
            break;
        case TimerStatusDelayingPaused:
            break;
        case TimerStatusDelayFinished:
            self.timerStatus = TimerStatusDelayFinishedPaused;
            break;
        case TimerStatusDelayFinishedPaused:
            break;
        case TimerStatusRunning:
            self.timerStatus = TimerStatusRunningPaused;
            // remove the timer, remain time should have been saved.
            [self.nsCountDownTimer invalidate];
            break;
        case TimerStatusRunningPaused:
            break;
        case TimerStatusStoped:
            break;
        default:
            break;
    }
}

- (void)resume
{
    ClawVerbose(@"status is %d", self.timerStatus);
    switch (self.timerStatus) {
        case TimerStatusInited:            
            break;        
        case TimerStatusDelaying:
            break;
        case TimerStatusDelayingPaused:
            self.timerStatus = TimerStatusDelaying;
            break;
        case TimerStatusDelayFinished:
            break;
        case TimerStatusDelayFinishedPaused:
            [self timerRunningForRemainDuration];
            break;
        case TimerStatusRunning:
            break;
        case TimerStatusRunningPaused:
            [self timerRunningForRemainDuration];
            break;
        case TimerStatusStoped:
            break;
        default:
            break;
    }        
}

- (void)stop
{    
    [self stopWithoutStopTicking];
    [self stopTicking];
}

- (void)stopWithoutStopTicking
{
    self.timerStatus = TimerStatusStoped;
    self.remainDuration = 0;
    if (self.nsCountDownTimer) {
        [self.nsCountDownTimer invalidate];
    }    
}

- (void)checkRemainDuration
{
    NSDate* nowDate = [NSDate date];
    
    self.sectionElapsedDuration = [nowDate timeIntervalSinceDate:self.sectionStartingTime];
    self.remainDuration = self.sectionDuration - self.sectionElapsedDuration;
    
    if (self.remainDuration < 0) {
        self.remainDuration = 0;
    }
    NSInteger remainDurationInteger = (NSInteger)self.remainDuration;   
    
    if (self.lastRemainDurationInteger != remainDurationInteger) {
        self.lastRemainDurationInteger = remainDurationInteger;
        [self.delegate remainingTimeDidChange:[NSNumber numberWithInt:remainDurationInteger]];
    }       

    if (self.warningSelector && remainDurationInteger <= WARNING_BEFORE_END_SECONDS && remainDurationInteger > 2) {
        if (![self.playWarningSound boolValue] || remainDurationInteger < WARNING_BEFORE_END_SECONDS - 2 ) {
            // means we have delayed 2sec to run warningSelector for some reason,
            // most because we were in background then enterbackground now
            // so we don't play the sound, but only play UI
            self.playWarningSound = [NSNumber numberWithBool:NO];
        }
        else {
            // WARNING_BEFORE_END_SECONDS -2 <= remainDurationInteger <= WARNING_BEFORE_END_SECONDS
            // so play sound and UI
            self.playWarningSound = [NSNumber numberWithBool:YES];
        }
        [self.delegate performSelector:self.warningSelector withObject:self.playWarningSound];

        //self.warningSelector = nil;
        self.playWarningSound = [NSNumber numberWithBool:NO];
    }
    
    if (remainDurationInteger == 0) {
        [self stopWithoutStopTicking];
        [self.delegate remainingTimeDidChange:[NSNumber numberWithInt:0]];
        if (self.endSelector) {
            [self.delegate performSelector:self.endSelector];
        }
        [self stopTicking];
    }
}

#pragma mark - getter

- (BOOL)isPaused
{
    switch (self.timerStatus) {
        case TimerStatusInited:
            return NO;        
        case TimerStatusDelaying:
            return NO;
        case TimerStatusDelayingPaused:
            return YES;
        case TimerStatusDelayFinished:
            return NO;
        case TimerStatusDelayFinishedPaused:
            return YES;
        case TimerStatusRunning:
            return NO;
        case TimerStatusRunningPaused:
            return YES;        
        case TimerStatusStoped:
            return NO;
        default:
            return NO;
    }
}

- (BOOL)isRunning
{
    switch (self.timerStatus) {
        case TimerStatusInited:
            return NO;        
        case TimerStatusDelaying:
            return NO;
        case TimerStatusDelayingPaused:
            return NO;
        case TimerStatusDelayFinished:
            return NO;
        case TimerStatusDelayFinishedPaused:
            return NO;
        case TimerStatusRunning:
            return YES;
        case TimerStatusRunningPaused:
            return NO;
        case TimerStatusStoped:
            return NO;
        default:
            return NO;
    }
}

- (void)scheduleTicking
{
    if (![self isRunning]) {
        return;
    }
    NSTimeInterval duration = self.remainDuration;        
    // check auto break and auto next pomodoro
    NSInteger pomodoroCount = [[DataManager sharedInstance] todayPomodoroCount];
    if ([[TomatoManager sharedInstance] isPomodoroRunningStatus]) {
        pomodoroCount ++;
        if ([SettingsManager sharedInstance].autoBreak) {            
            duration += [[SettingsManager sharedInstance] plannedBreakDurationForCompletedPomodoroCount:pomodoroCount];
            if ([SettingsManager sharedInstance].autoNextPomodoro) {
                // batch notification
                duration += [self scheduleTickingDurationForPomodoroAndBreakCount:(MAX_LOC_NOTIFICATION + 1) basedOnPomodoroCount:pomodoroCount];
            }
        }
    }        
    else if ([[TomatoManager sharedInstance] isBreakRunningStatus]) {
        if ([SettingsManager sharedInstance].autoNextPomodoro) {
            duration += [SettingsManager sharedInstance].pomodoroDuration;
            pomodoroCount ++;
            if ([SettingsManager sharedInstance].autoBreak) {                
                duration += [[SettingsManager sharedInstance] plannedBreakDurationForCompletedPomodoroCount:pomodoroCount];
                duration += [self scheduleTickingDurationForPomodoroAndBreakCount:MAX_LOC_NOTIFICATION basedOnPomodoroCount:pomodoroCount];
            }
        }
    }    
    [[AlertManager sharedInstance] playTickingForDuration:duration];    
}

- (NSTimeInterval)scheduleTickingDurationForPomodoroAndBreakCount:(NSInteger)count basedOnPomodoroCount:(NSInteger)pomodoroCount
{
    NSTimeInterval duration = 0;
    for (int i = 0; i < count; i++) {
        duration += [SettingsManager sharedInstance].pomodoroDuration;
        pomodoroCount ++;
        duration += [[SettingsManager sharedInstance] plannedBreakDurationForCompletedPomodoroCount:pomodoroCount];
    }
    return duration;
}

- (void)stopTicking
{
    // check auto break and auto next pomodoro    
    if ([TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroEndStatus) {
        if (![SettingsManager sharedInstance].autoBreak) {
            [[AlertManager sharedInstance] stopTicking];
        }
        else {
            [[AlertManager sharedInstance] adjustTickingVolume:[NSNumber numberWithFloat:0]];
            [[AlertManager sharedInstance] adjustTickingVolume:[NSNumber numberWithFloat:1.0] afterDelay:END_ANIMATION_SECONDS];
        }
    }
    else if ([TomatoManager sharedInstance].tomatoStatus == TomatoBreakEndStatus) {
        if (![SettingsManager sharedInstance].autoNextPomodoro) {
           [[AlertManager sharedInstance] stopTicking];
        }
        else {
            [[AlertManager sharedInstance] adjustTickingVolume:[NSNumber numberWithFloat:0]];
            [[AlertManager sharedInstance] adjustTickingVolume:[NSNumber numberWithFloat:1.0] afterDelay:END_ANIMATION_SECONDS];
        }
    }
    else {
        [[AlertManager sharedInstance] stopTicking];
    }        
}

@end
