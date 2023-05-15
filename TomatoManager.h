//
//  TomatoManager.h
//  Tomato
//
//  Created by Teng Lin on 13-1-11.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimerDelegate.h"
#import "Timer.h"
#import "Pomodoro.h"
#import "TomatoManagerDelegate.h"
#import "MyGlobal.h"

typedef enum
{
    // Pomodoro
    TomatoPomodoroReadyStatus,
    TomatoPomodoroStatus,
    TomatoPomodoroWarningStatus,
    TomatoPomodoroEndStatus, // end, show end animation or something else
    // Break
    TomatoBreakReadyStatus,
    TomatoBreakStatus,
    TomatoBreakWarningStatus,
    TomatoBreakEndStatus, // end, show end animation or something else
    // unknown
    TomatoUnknownStatus,
} TomatoStatus;


@interface TomatoManager : NSObject <TimerDelegate>
{
    
}

+ (TomatoManager*)sharedInstance;

@property (weak, nonatomic) id<TomatoManagerDelegate> uiDelegate;    
@property (nonatomic) TomatoStatus tomatoStatus;

@property (strong, nonatomic) Timer* timer;
- (void)pauseTimer;
- (void)resumeTimer;

- (BOOL)isPomodoroRunningStatus;
- (BOOL)isBreakRunningStatus;

- (void)readyToPomodoroWithUiAnimation:(BOOL)animation;
- (void)startPomodoroNow;
- (void)pomodoroEnded;
- (void)changePomodoroDurationSetting:(NSInteger)duration;
- (void)changePomodoroDuration:(NSInteger)duration;
- (void)plusPomodoroDuration:(NSInteger)duration;
- (void)minusPomodoroDuration:(NSInteger)duration;

- (void)readyToBreakWithUiAnimation:(BOOL)animation;
- (void)startBreakNow;
- (void)breakEnded;
- (void)changeBreakDurationSetting:(NSInteger)duration;
- (void)changeShortBreakDurationSetting:(NSInteger)duration;
- (void)changeLongBreakDurationSetting:(NSInteger)duration;
- (void)changeBreakDuration:(NSInteger)duration;
- (void)changeShortBreakDuration:(NSInteger)duration;
- (void)changeLongBreakDuration:(NSInteger)duration;
- (void)plusBreakDuration:(NSInteger)duration;
- (void)minusBreakDuration:(NSInteger)duration;

//- (void)startWarning;

- (void)userInterrupt;
- (void)interruptPomodoro;
- (void)interruptBreak;

// muti-thread, notification, save & restore
- (void)didEnterBackground;
- (void)willEnterForeground;
- (void)willResignActive;
- (void)didBecomeActive;
- (void)clearAllNotification;

// restore tomato status from disk, save tomato status to disk
- (void)readyOrRestoreFromDisk;
- (void)disableRestoreAllFromDisk;

@property (strong, nonatomic) NSDate *suspend_time;
@property (strong, nonatomic) NSDate *awake_time;
@property (atomic) BOOL runningInBackground;

#pragma mark - Core Data
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Pomodoro *currentPomodoro;

#pragma mark - TimerDelegate
- (void)remainingTimeDidChange:(NSNumber*)remainingSeconds;
@end
