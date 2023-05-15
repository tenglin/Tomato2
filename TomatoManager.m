//
//  TomatoManager.m
//  Tomato
//
//  Created by Teng Lin on 13-1-11.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//
#import "TomatoManager.h"
#import "SettingsManager.h"
#import "DummyPomodoro.h"
#import "NSDate+Utils.h"
#import "MyGlobal.h"
#import "DataManager.h"

static NSString *const NOTIF_POMODORO_WARNING = @"Warning: Pomodoro will end soon!";
static NSString *const NOTIF_POMODORO_END = @"Pomodoro ended.";
static NSString *const NOTIF_POMODORO_END_AUTO_BREAK = @"Pomodoro ended. Break started automatically.";
static NSString *const NOTIF_POMODORO_END_AUTO_LONG_BREAK = @"Pomodoro ended. Long break started automatically.";

static NSString *const NOTIF_BREAK_WARNING = @"Warning: Break will end soon!";
static NSString *const NOTIF_BREAK_END = @"Break ended.";
static NSString *const NOTIF_BREAK_END_AUTO_POMODORO = @"Break ended. Pomodoro started automatically.";

static NSString *const NOTIF_LONG_BREAK_WARNING = @"Warning: Long break will end soon!";
static NSString *const NOTIF_LONG_BREAK_END = @"Long break ended.";
static NSString *const NOTIF_LONG_BREAK_END_AUTO_POMODORO = @"Long break ended. Pomodoro started automatically.";

static NSString *const NOTIF_ALERT_ACTION = @"Show";

@interface TomatoManager ()

@property (strong, nonatomic) NSMutableArray *dummyPomodoroArray;
@property (nonatomic) NSInteger newDummyPomodoroCount;

@end

@implementation TomatoManager

+ (TomatoManager*)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static TomatoManager* _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

#pragma mark - tomato status wrapper

- (BOOL)isPomodoroRunningStatus
{
    if (self.tomatoStatus == TomatoPomodoroStatus || self.tomatoStatus == TomatoPomodoroWarningStatus ) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isBreakRunningStatus
{
    if (self.tomatoStatus == TomatoBreakStatus || self.tomatoStatus == TomatoBreakWarningStatus) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - timer related methods

- (void)pauseTimerWithoutStopTicking
{
    [self.timer pauseWithoutStopTicking];
    if ([self isPomodoroRunningStatus]) {
        [self.uiDelegate showPomodoroPauseScreen];
    }
    else if ([self isBreakRunningStatus]) {
        [self.uiDelegate showBreakPauseScreen];
    }
}

- (void)pauseTimer
{
    [self.timer pause];
    if ([self isPomodoroRunningStatus]) {
        [self.uiDelegate showPomodoroPauseScreen];
    }
    else if ([self isBreakRunningStatus]) {
        [self.uiDelegate showBreakPauseScreen];
    }
}

- (void)resumeTimer
{
    [self.timer resume];
    if ([self isPomodoroRunningStatus]) {
        [self.uiDelegate showPomodoroResumeScreen];
    }
    else if ([self isBreakRunningStatus]) {
        [self.uiDelegate showBreakResumeScreen];
    }
}

- (void)startTimerWithDuration:(NSInteger)duration andCallWhenWarning:(SEL)warningSelector andCallWhenEnded:(SEL)endSelector
{
    [self.timer stop];    
    self.timer = [Timer startWithDuration:duration andCallWhenWarning:warningSelector andCallWhenEnded:endSelector on:self afterDelay:1];
}

- (void)startTimerWithDuration:(NSInteger)duration andCallWhenEnded:(SEL)endSelector
{
    [self.timer stop];
    self.timer = [Timer startWithDuration:duration andCallWhenEnded:endSelector on:self afterDelay:1];
}

#pragma mark - switch pomodoro's pomodoro among status

- (void)readyToPomodoroWithUiAnimation:(BOOL)animation
{
    self.tomatoStatus = TomatoPomodoroReadyStatus;
    [self createNewPomodoroObject];
    [self.uiDelegate showPomodoroReadyScreenWithAnimation:animation];
}

// can be called without readyToPomodoro be called before
- (void)startPomodoroNow
{    
    // data
    [self initPomodoroObjectWithStartTime:[NSDate date]];
    // logic
    [self startPomodoroWithRemainTime:self.currentPomodoro.pDuration.intValue];
}

- (void)startPomodoroWithRemainTime:(NSInteger)timerDuration
{        
    self.tomatoStatus = TomatoPomodoroStatus;
    [self updateRunningPomodoroObject];
    [self startTimerWithDuration:timerDuration andCallWhenWarning:@selector(pomodoroWarning:) andCallWhenEnded:@selector(pomodoroEnded)];
    [self.uiDelegate showPomodoroScreen];
}

- (void)pomodoroWarning:(NSNumber*)playSound
{
    self.tomatoStatus = TomatoPomodoroWarningStatus;
    [self.uiDelegate showPomodoroWarningScreen:playSound];
}

- (void)pomodoroEnded {
    self.tomatoStatus = TomatoPomodoroEndStatus;    
    [self saveCompletedPomodoro];    
    [self.uiDelegate showPomodoroEndScreen];
    // play animation when end, so move the following logic to viewController
    // viewController should check autobreak, then call startBreak or  readyToBreak after the animation.    
}

- (void)changePomodoroDurationSetting:(NSInteger)duration
{
    if ([self isPomodoroRunningStatus]) {
        [self changePomodoroDuration:duration];
    }
    else if (self.tomatoStatus == TomatoPomodoroReadyStatus) {
        [self readyToPomodoroWithUiAnimation:YES];
    }
}

// change the pDuration of the currentPomodoro during TomatoPomodoroStatus or TomatoPomodoroWarningStatus
- (void)changePomodoroDuration:(NSInteger)duration
{
    if (![self isPomodoroRunningStatus]) {
        return;
    }
    if (duration < 0) {
        duration = 0;
    }    
    
    NSInteger originDuration = self.currentPomodoro.pDuration.intValue;
    NSInteger originRemainDuration = self.timer.remainDuration;
    NSInteger newDuration;
    NSInteger newRemainDuration;
    
    if (duration == originDuration) {
        // do nothing and return;
        return;
    }
    else if (duration > originDuration) {        
        newDuration = duration;
        newRemainDuration = originRemainDuration + (duration - originDuration);
    }
    else {
        // duration < originDuration        
        NSInteger diff = originDuration - duration;
        newRemainDuration = originRemainDuration - diff;
        if (newRemainDuration > 0) {
            newDuration = duration;
            // newRemainDuration = newRemainDuration;
        }
        else {
            newRemainDuration = 0;
            newDuration = originDuration - originRemainDuration;
        }
    }
    
    self.currentPomodoro.pDuration = [NSNumber numberWithInt:newDuration];    
    // Commit the change.
    if (![[DataManager sharedInstance] saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }
    [self startPomodoroWithRemainTime:newRemainDuration];
}

// increase the pDuration of the currentPomodoro during TomatoPomodoroStatus, or TomatoPomodoroWarningStatus
- (void)plusPomodoroDuration:(NSInteger)duration
{
    if (![self isPomodoroRunningStatus]) {
        return;
    }
    [self changePomodoroDuration:duration + self.currentPomodoro.pDuration.intValue];
}

// decrease the pDuration of the currentPomodoro during TomatoPomodoroStatus, or TomatoPomodoroWarningStatus
- (void)minusPomodoroDuration:(NSInteger)duration
{
    if (![self isPomodoroRunningStatus]) {
        return;
    }
    
    NSInteger newDuration = self.currentPomodoro.pDuration.intValue - duration;
    [self changePomodoroDuration:newDuration < 0 ? 0 : newDuration];
}

#pragma mark - switch pomodoro's break among status

- (void)readyToBreakWithUiAnimation:(BOOL)animation {
    self.tomatoStatus = TomatoBreakReadyStatus;    
    [self updateReadyBreakObject];
    [self.uiDelegate showBreakReadyScreenWithAnimation:animation];
}

// can be called without readyToBreak be called before
- (void)startBreakNow {
    
    [self updateStartingBreakObject];
    [self startBreakWithRemainTime:self.currentPomodoro.bDuration.intValue];
}

#warning think about the delay in the [Timer startWithDuration ...
- (void)startBreakWithRemainTime:(NSInteger)timerDuration
{
    self.tomatoStatus = TomatoBreakStatus;
    [self updateRunningBreakObject];    
    [self startTimerWithDuration:timerDuration andCallWhenWarning:@selector(breakWarning:) andCallWhenEnded:@selector(breakEnded)];
    [self.uiDelegate showBreakScreen];
}

- (void)breakWarning:(NSNumber*)playSound
{
    self.tomatoStatus = TomatoBreakWarningStatus;
    [self.uiDelegate showBreakWarningScreen:playSound];
}

- (void)breakEnded
{   
    self.tomatoStatus = TomatoBreakEndStatus;
    [self saveCompletedBreak];
    [self.uiDelegate showBreakEndScreen];    
    // play animation when end, so move the following logic to viewController
    // viewController should check autoNextPomodoro, then call startPomodoro or  readyToPomodoro after the animation.
 }

- (void)changeBreakDurationSetting:(NSInteger)duration
{
    if ([self isBreakRunningStatus]) {
        [self changeBreakDuration:duration];
    }
    else if (self.tomatoStatus == TomatoBreakReadyStatus) {
        [self readyToBreakWithUiAnimation:YES];
    }
}

- (void)changeShortBreakDurationSetting:(NSInteger)duration
{
    if ([self isBreakRunningStatus]) {
        [self changeShortBreakDuration:duration];
    }
    else if (self.tomatoStatus == TomatoBreakReadyStatus) {
        [self readyToBreakWithUiAnimation:YES];
    }
}

- (void)changeLongBreakDurationSetting:(NSInteger)duration
{
    if ([self isBreakRunningStatus]) {
        [self changeLongBreakDuration:duration];
    }
    else if (self.tomatoStatus == TomatoBreakReadyStatus) {
        [self readyToBreakWithUiAnimation:YES];
    }
}

- (void)changeBreakDuration:(NSInteger)duration
{
    if (![self isBreakRunningStatus]) {
        return;
    }    
    if (duration < 0) {
        duration = 0;
    }    
    NSInteger newDuration;
    NSInteger newRemainDuration;
    NSInteger originDuration = self.currentPomodoro.bDuration.intValue;
    NSInteger originRemainDuration = self.timer.remainDuration;
    
    if (duration == originDuration) {
        return;
    }
    else if (duration > originDuration) {
        newDuration = duration;
        newRemainDuration = originRemainDuration + (duration - originDuration);
    }
    else {
        // duration < originDuration
        NSInteger diff = originDuration - duration;
        newRemainDuration = originRemainDuration - diff;
        if (newRemainDuration > 0) {
            newDuration = duration;
            // newRemainDuration = newRemainDuration;
        }
        else {
            newRemainDuration = 0;
            newDuration = originDuration - originRemainDuration;
        }
    }
    
    self.currentPomodoro.bDuration = [NSNumber numberWithInt:newDuration];
    // Commit the change.
    if (![[DataManager sharedInstance] saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }
    [self startBreakWithRemainTime:newRemainDuration];
}

- (void)changeShortBreakDuration:(NSInteger)duration
{
    if (![self isBreakRunningStatus]) {
        return;
    }
    
    if ([[DataManager sharedInstance] todayPomodoroCount]%[SettingsManager sharedInstance].longBreakEveryPomodoro != 0) {
        [self changeBreakDuration:duration];
    }
    else {
        return;
    }    
}

- (void)changeLongBreakDuration:(NSInteger)duration
{
    if (![self isBreakRunningStatus]) {
        return;
    }
    
    if ([[DataManager sharedInstance] todayPomodoroCount]%[SettingsManager sharedInstance].longBreakEveryPomodoro != 0) {
        return;
    }
    else {
        [self changeBreakDuration:duration];
    }
}

- (void)plusBreakDuration:(NSInteger)duration
{
    if (![self isBreakRunningStatus]) {
        return;
    }
    [self changeBreakDuration:duration + self.currentPomodoro.bDuration.intValue];
}

- (void)minusBreakDuration:(NSInteger)duration
{
    if (![self isBreakRunningStatus]) {
        return;
    }    
    NSInteger newDuration = self.currentPomodoro.bDuration.intValue - duration;
    [self changeBreakDuration:newDuration < 0 ? 0 : newDuration];
}

#pragma mark - interruption related

- (void)userInterrupt
{
    if (self.tomatoStatus == TomatoPomodoroReadyStatus) {
        [self readyToPomodoroWithUiAnimation:YES];
    }
    else if ([self isPomodoroRunningStatus]) {
        [self interruptPomodoro];
    }
    else if ([self isBreakRunningStatus]) {
        [self interruptBreak];
    }
    else if (self.tomatoStatus == TomatoBreakReadyStatus) {
        [self readyToPomodoroWithUiAnimation:YES];
    }
}

- (void)interruptPomodoro
{
    [self.timer stop];
    [self saveInterruptedPomodoro];
    [self readyToPomodoroWithUiAnimation:YES];
}

- (void)interruptBreak
{
    [self.timer stop];
    [self saveInterruptedBreak];
    [self readyToPomodoroWithUiAnimation:YES];
}

#pragma mark - core data

static const NSInteger INITIAL_BREAK_DURATION = -1;
// create new PomodoroObject
- (void)createNewPomodoroObject
{
    self.currentPomodoro = [NSEntityDescription insertNewObjectForEntityForName:@"Pomodoro" inManagedObjectContext:self.managedObjectContext];
	self.currentPomodoro.pStartDate = nil;
    self.currentPomodoro.pDuration = [NSNumber numberWithInt:[SettingsManager sharedInstance].pomodoroDuration];
    self.currentPomodoro.pEndDate = nil;
    self.currentPomodoro.pInterrupted = [NSNumber numberWithBool:YES];
    
    self.currentPomodoro.bStartDate = nil;
    self.currentPomodoro.bDuration = [NSNumber numberWithInt:INITIAL_BREAK_DURATION];
    self.currentPomodoro.bEndDate = nil;
    self.currentPomodoro.bInterrupted = [NSNumber numberWithBool:YES];   
    
    // Commit the change.
//    if (![[DataManager sharedInstance] saveCoreDataContext]) {
//        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
//    }
}

// self.currentPomodoro is new a created Object,
// that means, self.currentPomodoro only exsit for TomatoPomodoroReadyStatus since created
// otherwise the pStartDate is not nil
- (BOOL)currentPomodoroObjectIsNew
{
    if (!self.currentPomodoro) {
        return NO;
    }
    if (self.currentPomodoro.pStartDate == nil &&
        self.currentPomodoro.pEndDate == nil &&
        self.currentPomodoro.bStartDate == nil &&
        self.currentPomodoro.bEndDate == nil) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)initPomodoroObjectWithStartTime:(NSDate*)nowDate
{
    if (![self currentPomodoroObjectIsNew]) {
        [self createNewPomodoroObject];
    }        
	self.currentPomodoro.pStartDate = nowDate;           
    self.currentPomodoro.pEndDate = nil;
    self.currentPomodoro.pInterrupted = [NSNumber numberWithBool:YES];
    
    self.currentPomodoro.bDuration = [NSNumber numberWithInt:INITIAL_BREAK_DURATION];
    self.currentPomodoro.bStartDate = nil;
    self.currentPomodoro.bEndDate = nil;
    self.currentPomodoro.bInterrupted = [NSNumber numberWithBool:YES];
    
    // Commit the change.
//    if (![[DataManager sharedInstance] saveCoreDataContext]) {
//        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
//    }
}


- (void)updateRunningPomodoroObject
{
    self.currentPomodoro.pEndDate = nil;
    self.currentPomodoro.pInterrupted = [NSNumber numberWithBool:YES];
    
    self.currentPomodoro.bDuration = [NSNumber numberWithInt:INITIAL_BREAK_DURATION];
    self.currentPomodoro.bStartDate = nil;
    self.currentPomodoro.bEndDate = nil;
    self.currentPomodoro.bInterrupted = [NSNumber numberWithBool:YES];
    
    // Commit the change.
//    if (![[DataManager sharedInstance] saveCoreDataContext]) {
//        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
//    }
}

- (void)saveCompletedPomodoro
{
    self.currentPomodoro.pEndDate = [NSDate date];
    self.currentPomodoro.pInterrupted = [NSNumber numberWithBool:NO];
    // Commit the change.    
    [self checkCurrentPomodoroAndUpdateDayThenUpdateVarsAndSaveContext];
}

- (void)saveInterruptedPomodoro
{    
    self.currentPomodoro.pEndDate = [NSDate date];
    self.currentPomodoro.pInterrupted = [NSNumber numberWithBool:YES];
    // Commit the change.
    if (![[DataManager sharedInstance] saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }    
}

// break related methods

- (void)updateReadyBreakObject
{
    self.currentPomodoro.bDuration = [NSNumber numberWithInteger:[[SettingsManager sharedInstance] plannedBreakDurationForCompletedPomodoroCount:[[DataManager sharedInstance] todayPomodoroCount]]];
    self.currentPomodoro.bStartDate = nil;
    self.currentPomodoro.bEndDate = nil;
    self.currentPomodoro.bInterrupted = [NSNumber numberWithBool:YES];
    // Commit the change.
//    if (![[DataManager sharedInstance] saveCoreDataContext]) {
//        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
//    }
}

- (void)updateStartingBreakObject
{
    if (self.currentPomodoro.bDuration.intValue == INITIAL_BREAK_DURATION) {
        self.currentPomodoro.bDuration = [NSNumber numberWithInteger:[[SettingsManager sharedInstance] plannedBreakDurationForCompletedPomodoroCount:[[DataManager sharedInstance] todayPomodoroCount]]];
    }
    NSDate *nowDate = [NSDate date];
    self.currentPomodoro.bStartDate = nowDate;
    self.currentPomodoro.bEndDate = nil;
    self.currentPomodoro.bInterrupted = [NSNumber numberWithBool:YES];
    // Commit the change.
//    if (![[DataManager sharedInstance] saveCoreDataContext]) {
//        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
//    }
}

- (void)updateRunningBreakObject
{
    self.currentPomodoro.bEndDate = nil;
    self.currentPomodoro.bInterrupted = [NSNumber numberWithBool:YES];
    // Commit the change.
//    if (![[DataManager sharedInstance] saveCoreDataContext]) {
//        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
//    }
}

- (void)saveCompletedBreak
{
    self.currentPomodoro.bEndDate = [NSDate date];
    self.currentPomodoro.bInterrupted = [NSNumber numberWithBool:NO];
    // Commit the change.
    if (![[DataManager sharedInstance] saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }
}

- (void)saveInterruptedBreak
{
    self.currentPomodoro.bEndDate = [NSDate date];
    self.currentPomodoro.bInterrupted = [NSNumber numberWithBool:YES];   
    // Commit the change.
    if (![[DataManager sharedInstance] saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }
}

// update them only when pomodoro completed without interruption
- (void)checkCurrentPomodoroAndUpdateDayThenUpdateVarsAndSaveContext
{    
    [[DataManager sharedInstance] updateVarsBiggestPomodoroSecondsByCheckingNewDayObject:[self updateDayAfterCheckingCurrentPomodoroInMem]];
    // Commit the change.
    if (![[DataManager sharedInstance] saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }
}

- (Day*)updateDayAfterCheckingCurrentPomodoroInMem
{
    Day *dayObject = [[DataManager sharedInstance] getDayObjectOfDate:self.currentPomodoro.pEndDate];
    if ([self.currentPomodoro.pInterrupted boolValue]) {
        // interrupted, so skip;
        return dayObject;
    }
    [[DataManager sharedInstance] updateDayObjectInMem:dayObject addNewPomodoroObject:self.currentPomodoro];
    return dayObject;
}

#pragma mark - Lcoal Notification, replay dummys

// self.currentPomodoro's pStartDate, pEndDate, bStartDate, bEndDate sometime is nil, depending on the status
// Dummy's pStartDate, pEndDate, bStartDate, bEndDate is always not nil, this is different from self.currentPomodoro

// Dummy:
// pStartDate < pEndDate = bStartDate < bEndDate  , means has break
// pStartDate < pEndDate = bStartDate = bEndDate  , means no break

// no blank time interval between two dummy!
// Dummy1.bEndDate = Dummy2.pStartDate

typedef enum
{
    DummyType_Not_Come,  // s < pStartDate && a < pStartDate        Not come in yet, so don't need replay
    DummyType_New,       // s < pStartDate && pStartDate <= a       New pomodoro in background,  need replay    
    DummyType_Current,   // pStartDate <= s && s < bEndDate         relay currentPomodoro, suspend on this pomodoro
    DummyType_Old_Ready, // bEndDate <= s                           Don't relay, but set to PomodoroReady or BreakReady
    DummyType_Unknown,   // impossible
} DummyType;    

- (DummyType)dummyTypeOfDummy:(DummyPomodoro*)dummy
{
    if ([self.awake_time compare:dummy.pStartDate] == NSOrderedAscending) {
        return DummyType_Not_Come;
    }
    else if ([self.suspend_time compare:dummy.pStartDate] == NSOrderedAscending &&
             [self.awake_time compare:dummy.pStartDate] != NSOrderedAscending) {
        return DummyType_New;
    }
    else if ([self.suspend_time compare:dummy.pStartDate] != NSOrderedAscending &&
             [self.suspend_time compare:dummy.bEndDate] == NSOrderedAscending) {
        return DummyType_Current;
    }
    else if ([self.suspend_time compare:dummy.bEndDate] != NSOrderedAscending) {
        return DummyType_Old_Ready;
    }
        
    return DummyType_Unknown;
}

- (void)replayDummyPomodoroArray
{
    if ([self.dummyPomodoroArray count] ==0) {
        return;
    }
    
    // below code is for user set up the date&time back many day ago, nothing will be replay, so show pause
    if ([self.suspend_time compare:[NSDate date]] != NSOrderedAscending) {
        [self.uiDelegate showCommonPauseScreen];
    }
    
    for (DummyPomodoro * dummy in self.dummyPomodoroArray) {
        if ([self dummyTypeOfDummy:dummy] == DummyType_Not_Come) {
            break;
        }
        switch ([self dummyTypeOfDummy:dummy]) {
            case DummyType_Old_Ready:
                [self replayDummyType_Old_Ready:dummy];
                break;
            case DummyType_Current:
                [self replayDummyType_Current:dummy];
                break;
            case DummyType_New:
                [self replayDummyType_New:dummy];
                break;
            default:
                ClawError(@"DummyType is out of range!");
                break;
        }
    }    
    
    if (self.tomatoStatus == TomatoPomodoroReadyStatus) {
        if (![[DataManager sharedInstance] saveCoreDataContext]) {
            ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
        }
#warning if there are many days and pomodoro, think about below code
        [[DataManager sharedInstance] updateVarsBiggestPomodoroSecondsByRecalc];
        [self readyToPomodoroWithUiAnimation:NO];
    }
}

- (void)currentPomodoroSetToDummy:(DummyPomodoro*)dummy
{
    self.currentPomodoro.pDuration = [NSNumber numberWithInt:dummy.pDuration];
    self.currentPomodoro.pStartDate = dummy.pStartDate;    
    self.currentPomodoro.pEndDate = dummy.pEndDate;
    self.currentPomodoro.pInterrupted = [NSNumber numberWithBool:dummy.pInterrupted];
    
    self.currentPomodoro.bDuration = [NSNumber numberWithInt:dummy.bDuration];
    self.currentPomodoro.bStartDate = dummy.bStartDate;    
    self.currentPomodoro.bEndDate = dummy.bEndDate;
    self.currentPomodoro.bInterrupted = [NSNumber numberWithBool:dummy.bInterrupted];
}

- (void)replayDummyType_Old_Ready:(DummyPomodoro*)dummy
{     
    if ([dummy.bStartDate compare:dummy.bEndDate] == NSOrderedSame) {
        [self readyToBreakWithUiAnimation:NO];
    }
    else if ([dummy.bStartDate compare:dummy.bEndDate] == NSOrderedAscending) {
        [self readyToPomodoroWithUiAnimation:NO];
    }      
}

- (void)replayDummyType_New:(DummyPomodoro*)dummy
{
    if (![self currentPomodoroObjectIsNew]) {
        self.currentPomodoro = [NSEntityDescription insertNewObjectForEntityForName:@"Pomodoro" inManagedObjectContext:self.managedObjectContext];
    }
    [self replayDummyType_Current:dummy];    
}

- (void)replayDummyType_Current:(DummyPomodoro*)dummy
{
    [self currentPomodoroSetToDummy:dummy];
        
    // pStartDate <= a < pEndDate           restore to  pomodoroStatus
    if ([self.awake_time compare:dummy.pStartDate] != NSOrderedAscending &&
        [self.awake_time compare:dummy.pEndDate] == NSOrderedAscending) {
        self.currentPomodoro.pInterrupted = [NSNumber numberWithBool:YES];
        [self checkCurrentPomodoroAndUpdateDayThenUpdateVarsAndSaveContext];
        NSInteger remainTime = [dummy.pEndDate timeIntervalSinceDate:self.awake_time];
        [self startPomodoroWithRemainTime:remainTime];
    }
    // pEndDate <= a && a <= bStartDate     restore to BreakReady, check if need to auto break?
    else if ([self.awake_time compare:dummy.pEndDate] != NSOrderedAscending &&
             [self.awake_time compare:dummy.bStartDate] != NSOrderedDescending) {
        // if added before, will skip adding
        [self checkCurrentPomodoroAndUpdateDayThenUpdateVarsAndSaveContext];        
        if ([SettingsManager sharedInstance].autoBreak) {
            [self startBreakNow];
        }
        else {
            [self readyToBreakWithUiAnimation:NO];
        }        
    }
    // bStartDate < a < bEndDate            restore to breakingStatus
    else if ([self.awake_time compare:dummy.bStartDate] == NSOrderedDescending &&
             [self.awake_time compare:dummy.bEndDate] == NSOrderedAscending) {
         // if added before, will skip adding
        [self checkCurrentPomodoroAndUpdateDayThenUpdateVarsAndSaveContext];
        NSInteger remainTime = [dummy.bEndDate timeIntervalSinceDate:self.awake_time];
        [self startBreakWithRemainTime:remainTime];
    }
    // bEndDate <= a                        restore to PomodoroReadyStatus
    else if ([self.awake_time compare:dummy.bEndDate] != NSOrderedAscending) {        
        if ([dummy.bStartDate compare:dummy.bEndDate] == NSOrderedSame) {
            //means did not break
            [self checkCurrentPomodoroAndUpdateDayThenUpdateVarsAndSaveContext];  
            [self readyToBreakWithUiAnimation:NO];
        }
        else {
            // dummy.bStartDate < dummy.bEndDate ==>  means did break
            [self updateDayAfterCheckingCurrentPomodoroInMem];
             self.tomatoStatus = TomatoPomodoroReadyStatus;
            [self createNewPomodoroObject];
        }
    }
}

#pragma mark - Lcoal Notification, schedule notification

- (NSString*)shortOrLongNotification:(NSString*)shortNotification withPomodoroCount:(NSInteger)pomodoroCount
{
    if (pomodoroCount%[SettingsManager sharedInstance].longBreakEveryPomodoro != 0) {
        return shortNotification;
    }
    
    // else, should be related with long break
    if ([shortNotification isEqualToString:NOTIF_BREAK_WARNING]) {
        return NOTIF_LONG_BREAK_WARNING;
    }
    else if ([shortNotification isEqualToString:NOTIF_BREAK_END]) {
        return NOTIF_LONG_BREAK_END;
    }
    else if ([shortNotification isEqualToString:NOTIF_BREAK_END_AUTO_POMODORO]) {
        return NOTIF_LONG_BREAK_END_AUTO_POMODORO;
    }
    else if ([shortNotification isEqualToString:NOTIF_POMODORO_END_AUTO_BREAK]) {
        return NOTIF_POMODORO_END_AUTO_LONG_BREAK;
    }
    else {
        // only other pomodoro end, warning notification shoud not go here
        return shortNotification;
    }
}


- (void)scheduleBatchAutoNotificationForCount:(NSInteger)count fromDate:(NSDate*)baseDate basedOnTodayPomodoroCount:(NSInteger)todayPomodoroCount;
{
    BOOL pomodoroWarningBeforeEnd = [SettingsManager sharedInstance].pomodoroWarningBeforeEnd;
    BOOL breakWarningBeforeEnd = [SettingsManager sharedInstance].breakWarningBeforeEnd;
    
    for (int i = 0; i < count; i++) {
        DummyPomodoro * dummy = [DummyPomodoro createInstanceAfterCountOfToday:(todayPomodoroCount + self.newDummyPomodoroCount)];
        [self.dummyPomodoroArray addObject:dummy];
        self.newDummyPomodoroCount ++; // new dummy
        
        // schedule notification for pomodoro
        dummy.pStartDate = baseDate;
        dummy.pEndDate = [NSDate dateWithTimeInterval:dummy.pDuration sinceDate:dummy.pStartDate];
        [self scheduleNotificationForTomatoStatus:TomatoPomodoroEndStatus  forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy.pEndDate withText:NOTIF_POMODORO_END_AUTO_BREAK withWarning:pomodoroWarningBeforeEnd];
        
        // schedule notification for break
        dummy.bStartDate = dummy.pEndDate;
        dummy.bEndDate = [NSDate dateWithTimeInterval:dummy.bDuration sinceDate:dummy.bStartDate];
        if (i == count -1) {
            // the last one break;
            [self scheduleNotificationForTomatoStatus:TomatoBreakEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy.bEndDate withText:NOTIF_BREAK_END withWarning:breakWarningBeforeEnd];
        }
        else {            
            [self scheduleNotificationForTomatoStatus:TomatoBreakEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy.bEndDate withText:NOTIF_BREAK_END_AUTO_POMODORO withWarning:breakWarningBeforeEnd];
        }
#warning set baseDate in method is ok? 
        baseDate = dummy.bEndDate;
    }
}

- (void)scheduleBackgroundNotification
{
    BOOL pomodoroWarningBeforeEnd = [SettingsManager sharedInstance].pomodoroWarningBeforeEnd;
    BOOL breakWarningBeforeEnd = [SettingsManager sharedInstance].breakWarningBeforeEnd;
    
    _dummyPomodoroArray = [[NSMutableArray alloc] init];
    NSInteger todayPomodoroCount = [[DataManager sharedInstance] todayPomodoroCount];
    self.newDummyPomodoroCount = 0;
    if ([self isPomodoroRunningStatus]) {
        // currentPomodoro's pInterrupted=YES, not counted in todayPomodoroCount
        DummyPomodoro * dummy1 = [DummyPomodoro createInstanceAfterCountOfToday:todayPomodoroCount];  
        [self.dummyPomodoroArray addObject:dummy1];
        self.newDummyPomodoroCount ++;
        dummy1.pStartDate = self.currentPomodoro.pStartDate;
        dummy1.pDuration = self.currentPomodoro.pDuration.intValue; // user might +5min before here!, so don't use the value in settings
        dummy1.pEndDate = [NSDate dateWithTimeInterval:self.timer.remainDuration sinceDate:[NSDate date]];
        if (self.timer.remainDuration > WARNING_BEFORE_END_SECONDS && pomodoroWarningBeforeEnd) {            
            [self scheduleNotificationForTomatoStatus:TomatoPomodoroEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy1.pEndDate withWarning:YES];
        }
        else {
            [self scheduleNotificationForTomatoStatus:TomatoPomodoroEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy1.pEndDate withWarning:NO];
        }        
        
        //set the bStartDate same as bEndDate, means: No Break
        dummy1.bStartDate = dummy1.pEndDate;
        dummy1.bEndDate = dummy1.bStartDate;                
        // check auto break then
        if ([SettingsManager sharedInstance].autoBreak) {                        
            dummy1.bEndDate = [NSDate dateWithTimeInterval:dummy1.bDuration sinceDate:dummy1.bStartDate];            
            [self scheduleNotificationForTomatoStatus:TomatoBreakEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy1.bEndDate withWarning:breakWarningBeforeEnd];
            if ([SettingsManager sharedInstance].autoNextPomodoro) {
                // batch notification
                [self scheduleBatchAutoNotificationForCount:(MAX_LOC_NOTIFICATION + 1) fromDate:dummy1.bEndDate basedOnTodayPomodoroCount:todayPomodoroCount];
            }
        }
    }
    else if (self.tomatoStatus == TomatoPomodoroEndStatus) {
        // suppose the currentPomodoro is saved as pInterrupted=NO, and counted in todayPomodoroCount,
        DummyPomodoro * dummy1PE = [DummyPomodoro createInstanceAfterCountOfToday:todayPomodoroCount-1];
        // p_p_s ...
        [self.dummyPomodoroArray addObject:dummy1PE]; // not new dummy, so don't need self.newDummyPomodoroCount ++;
        dummy1PE.pStartDate = self.currentPomodoro.pStartDate;
        dummy1PE.pDuration = self.currentPomodoro.pDuration.intValue; // user might +5min before here!, so don't use the value in settings
        dummy1PE.pEndDate = self.currentPomodoro.pEndDate;
        //[self scheduleNotification:@"Pomodoro is completed!" after:1];
        
        //set the bStartDate same as bEndDate, means: No Break
        dummy1PE.bStartDate = [NSDate date];
        dummy1PE.bEndDate = dummy1PE.bStartDate;                
        // check auto break then
        if ([SettingsManager sharedInstance].autoBreak) {            
            dummy1PE.bEndDate = [NSDate dateWithTimeInterval:dummy1PE.bDuration sinceDate:dummy1PE.bStartDate];
            [self scheduleNotificationForTomatoStatus:TomatoBreakEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy1PE.bEndDate withWarning:breakWarningBeforeEnd];
            if ([SettingsManager sharedInstance].autoNextPomodoro) {
                // batch notification
                [self scheduleBatchAutoNotificationForCount:(MAX_LOC_NOTIFICATION + 1) fromDate:dummy1PE.bEndDate basedOnTodayPomodoroCount:todayPomodoroCount];
            }
        }
    }
    else if ([self isBreakRunningStatus]) {
        // currentPomodoro should be completed pomodoro, now is in breaking, dummy0 is for this, mainly for recording break
        // so, dummy0 should not be counted as new one, but for currentPomodoro;
        // condition: suppose the currentPomodoro is saved, and is count in todayPomodoroCount,
        DummyPomodoro * dummy0 = [DummyPomodoro createInstanceAfterCountOfToday:todayPomodoroCount-1];      
        [self.dummyPomodoroArray addObject:dummy0];  // not new dummy
        dummy0.pStartDate = self.currentPomodoro.pStartDate;
        dummy0.pDuration = [self.currentPomodoro.pDuration intValue];
        dummy0.pEndDate = self.currentPomodoro.pEndDate; 
        
        dummy0.bStartDate = self.currentPomodoro.bStartDate;
        dummy0.bEndDate = [NSDate dateWithTimeInterval:self.timer.remainDuration sinceDate:[NSDate date]];
        if (self.timer.remainDuration > WARNING_BEFORE_END_SECONDS && breakWarningBeforeEnd) {
            [self scheduleNotificationForTomatoStatus:TomatoBreakEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy0.bEndDate withWarning:YES];
        }
        else {
            [self scheduleNotificationForTomatoStatus:TomatoBreakEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy0.bEndDate withWarning:NO];
            
        }        
        
        if ([SettingsManager sharedInstance].autoNextPomodoro) {
            DummyPomodoro * dummy01 = [DummyPomodoro createInstanceAfterCountOfToday:todayPomodoroCount];            
            [self.dummyPomodoroArray addObject:dummy01];
            self.newDummyPomodoroCount ++; // new dummy
            dummy01.pStartDate = dummy0.bEndDate;
            dummy01.pEndDate = [NSDate dateWithTimeInterval:dummy01.pDuration sinceDate:dummy01.pStartDate];
            [self scheduleNotificationForTomatoStatus:TomatoPomodoroEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy01.pEndDate withWarning:pomodoroWarningBeforeEnd];
            
            //set the bStartDate same as bEndDate, means: No Break
            dummy01.bStartDate = dummy01.pEndDate;
            dummy01.bEndDate = dummy01.bStartDate;           
            // check auto break then
            if ([SettingsManager sharedInstance].autoBreak) {               
                dummy01.bEndDate = [NSDate dateWithTimeInterval:dummy01.bDuration sinceDate:dummy01.bStartDate];
                [self scheduleNotificationForTomatoStatus:TomatoBreakEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy01.bEndDate withWarning:breakWarningBeforeEnd];
                // batch notification
                [self scheduleBatchAutoNotificationForCount:MAX_LOC_NOTIFICATION fromDate:dummy01.bEndDate basedOnTodayPomodoroCount:todayPomodoroCount];                
            }                      
        }
    }
    else if (self.tomatoStatus == TomatoBreakEndStatus) {
        // currentPomodoro should complete pomodoro, now is in breakend
        DummyPomodoro * dummy0 = [DummyPomodoro createInstanceAfterCountOfToday:todayPomodoroCount-1];
        [self.dummyPomodoroArray addObject:dummy0];
        dummy0.pStartDate = self.currentPomodoro.pStartDate;
        dummy0.pDuration = [self.currentPomodoro.pDuration intValue];
        dummy0.pEndDate = self.currentPomodoro.pEndDate;
        
        dummy0.bStartDate = self.currentPomodoro.bStartDate;
        dummy0.bEndDate = self.currentPomodoro.bEndDate;  
                
        if ([SettingsManager sharedInstance].autoNextPomodoro) {
            DummyPomodoro * dummy01 = [DummyPomodoro createInstanceAfterCountOfToday:todayPomodoroCount];    
            [self.dummyPomodoroArray addObject:dummy01];
            self.newDummyPomodoroCount ++; // new dummy
            dummy01.pStartDate = [NSDate date];
            dummy01.pEndDate = [NSDate dateWithTimeInterval:dummy01.pDuration sinceDate:dummy01.pStartDate];
            [self scheduleNotificationForTomatoStatus:TomatoPomodoroEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy01.pEndDate withWarning:pomodoroWarningBeforeEnd];
            
            //set the bStartDate same as bEndDate, means: No Break
            dummy01.bStartDate = dummy01.pEndDate;
            dummy01.bEndDate = dummy01.bStartDate;                                
            // check auto break then
            if ([SettingsManager sharedInstance].autoBreak) {                
                dummy01.bEndDate = [NSDate dateWithTimeInterval:dummy01.bDuration sinceDate:dummy01.bStartDate];
                [self scheduleNotificationForTomatoStatus:TomatoBreakEndStatus forPomodoroCount:(todayPomodoroCount + self.newDummyPomodoroCount) atDate:dummy01.bEndDate withWarning:breakWarningBeforeEnd];
                // batch notification
                [self scheduleBatchAutoNotificationForCount:MAX_LOC_NOTIFICATION fromDate:dummy01.bEndDate basedOnTodayPomodoroCount:todayPomodoroCount];
            }
        }
    }
} 

- (void)clearAllNotification
{
#warning big issue about clear notification
    // clear all notification by this SESSION of the app ?
    // how about app shedule local notifications, then force quit the app, then restart this app, can
    // previous notification be cancel?
    // if not, think about how many notification should we shedule? obvously, not 31!!!, too much for this case!
       
    ClawInfo(@"scheduledLocalNotifications 1 has %d", [[[UIApplication sharedApplication] scheduledLocalNotifications] count]);    
	[[UIApplication sharedApplication] cancelAllLocalNotifications];    
    ClawInfo(@"scheduledLocalNotifications 2 has %d", [[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
#warning really need below code?
    for (UILocalNotification *localNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([[localNotification.userInfo valueForKey:TOMATO_NOTIFICATION_KEY] isEqualToString:TOMATO_NOTIFICATION_OBJECT]) {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification] ; // delete the notification from the system
        }
    }    
    ClawInfo(@"scheduledLocalNotifications 3 has %d", [[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
}

//- (void)scheduleNotification:(NSString*)text after:(NSInteger)timeInterval
//{
//    NSDate *fireDate = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:[NSDate date]];
//    [self scheduleNotification:text atDate:fireDate];
//}

- (void)scheduleNotificationForTomatoStatus:(TomatoStatus)tomatoStatus  forPomodoroCount:(NSInteger)pomodoroCount
                                     atDate:(NSDate*)date  withWarning:(BOOL)warningBeforeEnd
{
    if (tomatoStatus == TomatoPomodoroEndStatus) {
        if ([SettingsManager sharedInstance].autoBreak) {
            [self scheduleNotificationForTomatoStatus:tomatoStatus forPomodoroCount:pomodoroCount
                                               atDate:date withText:NOTIF_POMODORO_END_AUTO_BREAK withWarning:warningBeforeEnd];
        }
        else {
            [self scheduleNotificationForTomatoStatus:tomatoStatus forPomodoroCount:pomodoroCount
                                               atDate:date withText:NOTIF_POMODORO_END withWarning:warningBeforeEnd];
        }
    }
    else if (tomatoStatus == TomatoBreakEndStatus) {
        if ([SettingsManager sharedInstance].autoNextPomodoro) {
            [self scheduleNotificationForTomatoStatus:tomatoStatus forPomodoroCount:pomodoroCount
                                               atDate:date withText:NOTIF_BREAK_END_AUTO_POMODORO withWarning:warningBeforeEnd];
        }
        else {
            [self scheduleNotificationForTomatoStatus:tomatoStatus forPomodoroCount:pomodoroCount
                                               atDate:date withText:NOTIF_BREAK_END withWarning:warningBeforeEnd];
        }
    }
}

- (void)scheduleNotificationForTomatoStatus:(TomatoStatus)tomatoStatus forPomodoroCount:(NSInteger)pomodoroCount
                                     atDate:(NSDate*)date withText:(NSString*)text withWarning:(BOOL)warningBeforeEnd
{
    NSString *soundFile;
    NSString *warningText;
    if (tomatoStatus == TomatoPomodoroEndStatus) {
        soundFile = [SettingsManager sharedInstance].pomodoroEndSoundFile;
        if ([soundFile isEqualToString:@"empty_sound"] || soundFile.length == 0) {
            soundFile = nil;            
        }
        else {
            soundFile = [NSString stringWithFormat:@"%@.caf",soundFile];
        }
        warningText = NOTIF_POMODORO_WARNING;
        text = [self shortOrLongNotification:text withPomodoroCount:pomodoroCount];
        
        if (warningBeforeEnd) {
            NSString *pomodoroWarningSoundFile = [NSString stringWithFormat:@"%@.caf", [SettingsManager sharedInstance].pomodoroWarningSoundFile];
            [self scheduleNotification:warningText atDate:[date ago:0 months:0 weeks:0 days:0 hours:0 minutes:0 seconds:WARNING_BEFORE_END_SECONDS] withSoundName:pomodoroWarningSoundFile];
        }
    }
    else if (tomatoStatus == TomatoBreakEndStatus) {
        soundFile = [SettingsManager sharedInstance].breakEndSoundFile;
        if ([soundFile isEqualToString:@"empty_sound"] || soundFile.length == 0) {
            soundFile = nil;
        }
        else {
            soundFile = [NSString stringWithFormat:@"%@.caf",soundFile];
        }
        warningText = [self shortOrLongNotification:NOTIF_BREAK_WARNING withPomodoroCount:pomodoroCount];
        text = [self shortOrLongNotification:text withPomodoroCount:pomodoroCount];
        
        if (warningBeforeEnd) {
            NSString *breakWarningSoundFile = [NSString stringWithFormat:@"%@.caf", [SettingsManager sharedInstance].breakWarningSoundFile];
            [self scheduleNotification:warningText atDate:[date ago:0 months:0 weeks:0 days:0 hours:0 minutes:0 seconds:WARNING_BEFORE_END_SECONDS] withSoundName:breakWarningSoundFile];
        }
    }
    else {
        soundFile = UILocalNotificationDefaultSoundName;
    }    
    
    [self scheduleNotification:text atDate:date withSoundName:soundFile];
}

- (void)scheduleNotification:(NSString*)text atDate:(NSDate*)date withSoundName:(NSString*)soundFile
{    
    UILocalNotification *notif = [[UILocalNotification alloc] init];    
#warning systemTimeZone vs localTimeZone
    notif.timeZone = [NSTimeZone systemTimeZone];
    //notif.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];    
    notif.fireDate = date;    
    notif.alertBody = text;
    notif.alertAction = NOTIF_ALERT_ACTION;
    if (!soundFile) {
        notif.soundName = nil;
        // or: // notif.soundName = ;
    }
    else {
        //notif.soundName = @"alert_blip.caf";
        notif.soundName = soundFile;
    }    
    //notif.applicationIconBadgeNumber = 0;
    //notif.applicationIconBadgeNumber = -1;
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    notif.repeatInterval = 0;    
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:TOMATO_NOTIFICATION_OBJECT forKey:TOMATO_NOTIFICATION_KEY];
    notif.userInfo = userDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

- (void)stopTasksAfterEnterBackground {
#warning cancel animation
    // cancel animation if any
    [self pauseTimerWithoutStopTicking];    
    
    // update: 2013-09-07, we do not call below code here since this will make screen show pause icon in any situation, when enter forground later.
    //[self.uiDelegate showCommonPauseScreen];
}

#pragma mark - muti-thread, notification, save & restore
- (void)didEnterBackground;
{
    ClawInfo(@"didEnterBackgrounddddddddddd  1");
    self.suspend_time = [NSDate date];
    self.runningInBackground = YES;
    if ((self.tomatoStatus == TomatoPomodoroStatus
         || self.tomatoStatus == TomatoPomodoroWarningStatus
         || self.tomatoStatus == TomatoPomodoroEndStatus
         || self.tomatoStatus == TomatoBreakStatus
         || self.tomatoStatus == TomatoBreakWarningStatus
         || self.tomatoStatus == TomatoBreakEndStatus) && !self.timer.isPaused) {
         ClawInfo(@"didEnterBackgrounddddddddddd  A");
        [self stopTasksAfterEnterBackground];
        [self scheduleBackgroundNotification];
        [self saveDummysToDisk];
        [self enableRestoreDummyFromDisk];
    }
    else if ((self.tomatoStatus == TomatoPomodoroStatus
         || self.tomatoStatus == TomatoPomodoroWarningStatus
         || self.tomatoStatus == TomatoBreakStatus
         || self.tomatoStatus == TomatoBreakWarningStatus) && self.timer.isPaused) {
         ClawInfo(@"didEnterBackgrounddddddddddd  B");
        [self savePauseToDisk];
        [self enableRestorePauseFromDisk];
    }
    
    ClawInfo(@"didEnterBackgrounddddddddddd  2");
}

- (void)willEnterForeground
{
    [self disableRestoreAllFromDisk];
    self.awake_time = [NSDate date];
    self.runningInBackground = NO;
    [self clearAllNotification];
    if ([self.dummyPomodoroArray count] > 0) {
        [self replayDummyPomodoroArray];
    }    
    [self. dummyPomodoroArray removeAllObjects];
    [self.uiDelegate updateTodayCompletedCountWithAnimation:NO];
}

#warning need to handle Active, inActive?
- (void)willResignActive
{
    // pause, or do nothing ?

}

- (void)didBecomeActive
{
    // resume or do nothing?
}

#pragma mark - restore tomato status from disk, save tomato status to disk

#define kDummyArray @"DummyArray"
#define kSuspendTime @"SuspendTime"

#define kCurrentPomodoroPStartDate @"CurrentPomodoroPStartDate"

#define kTomatoStatus @"TomatoStatus"
#define kRemainDuration @"RemainDuration"

//Pomodoro Ready? or Restore tomato status from disk 
- (void)readyOrRestoreFromDisk
{
    if ([self needRestorePauseFromDisk]) {
        [self restorePauseFromDisk];
    }
    else if ([self needRestoreDummyFromDisk]) {
        [self restoreDummysFromDisk];
    }
    else {
        [self readyToPomodoroWithUiAnimation:YES];
    }
    [self disableRestoreAllFromDisk];
}

- (void)restorePauseFromDisk
{
    NSString *path = [self pathForDataFile];
    //path = [path stringByExpandingTildeInPath];
    NSMutableDictionary *rootObject;
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    // restore tomato status
    NSNumber *tomatoStatusNumber = [rootObject valueForKey:kTomatoStatus];
    
    // restore remain duration
    NSNumber *remainDurationNumber = [rootObject valueForKey:kRemainDuration];
    
    // resotre currentPomodoro
    NSDate *oldCurrentPomodoroPStartDate = [rootObject valueForKey:kCurrentPomodoroPStartDate];
    
    if (!oldCurrentPomodoroPStartDate) {
        //pStartDate is nil, so don't need to restore
        return;
    }    
    self.currentPomodoro = [[DataManager sharedInstance] fetchPomodoroByPStartDate:oldCurrentPomodoroPStartDate];
    
    if (tomatoStatusNumber && remainDurationNumber && self.currentPomodoro) {
        self.tomatoStatus = [tomatoStatusNumber intValue];
        if ([self isPomodoroRunningStatus]) {
            [self startPomodoroWithRemainTime:[remainDurationNumber doubleValue]];
            [self pauseTimer];
            [self.uiDelegate showCommonPauseScreen];
        }
        else if ([self isBreakRunningStatus]) {
            [self startBreakWithRemainTime:[remainDurationNumber doubleValue]];
            [self pauseTimer];
            [self.uiDelegate showCommonPauseScreen];
        }
    }
    //
}

- (void)restoreDummysFromDisk
{
    NSString *path = [self pathForDataFile];
    //path = [path stringByExpandingTildeInPath];    
    NSMutableDictionary *rootObject;
    rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    // restore dummyArray
    self.dummyPomodoroArray = [rootObject valueForKey:kDummyArray];
    
    // restore suspend_time
    self.suspend_time = [rootObject valueForKey:kSuspendTime];
    
    // resotre currentPomodoro
    NSDate *oldCurrentPomodoroPStartDate = [rootObject valueForKey:kCurrentPomodoroPStartDate];
    
    if (!oldCurrentPomodoroPStartDate) {
        //pStartDate is nil, so don't need to restore
        return;
    }
    
    self.currentPomodoro = [[DataManager sharedInstance] fetchPomodoroByPStartDate:oldCurrentPomodoroPStartDate];
    
    self.awake_time = [NSDate date];
    
    if (self.dummyPomodoroArray && self.suspend_time && self.currentPomodoro) {
        [self replayDummyPomodoroArray];
    }
}

- (void)savePauseToDisk
{
    // Commit the change of core data first
    if (![[DataManager sharedInstance] saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }
    
    //Archive other things : self.dummyPomodoroArray, self.suspend_time, self.currentPomodoro.pStartDate
    NSString * path = [self pathForDataFile];
    NSMutableDictionary *rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    NSNumber *tomatoStatusNumber = [NSNumber numberWithInt:self.tomatoStatus];
    NSNumber *remainDurationNumber = [NSNumber numberWithDouble:self.timer.remainDuration];
    
    [rootObject setValue:tomatoStatusNumber forKey:kTomatoStatus];
    [rootObject setValue:remainDurationNumber forKey:kRemainDuration];
    [rootObject setValue:self.currentPomodoro.pStartDate forKey:kCurrentPomodoroPStartDate];
    
    // clear dummy in datafile
    [rootObject setValue:nil forKey:kDummyArray];
    [NSKeyedArchiver archiveRootObject:rootObject toFile: path];
}

- (void)saveDummysToDisk
{
    // Commit the change of core data first
    if (![[DataManager sharedInstance] saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }
    
    //Archive other things : self.dummyPomodoroArray, self.suspend_time, self.currentPomodoro.pStartDate
    NSString * path = [self pathForDataFile];
    NSMutableDictionary *rootObject;
    rootObject = [NSMutableDictionary dictionary];
    
    [rootObject setValue:self.dummyPomodoroArray forKey:kDummyArray];
    [rootObject setValue:self.suspend_time forKey:kSuspendTime];
    [rootObject setValue:self.currentPomodoro.pStartDate forKey:kCurrentPomodoroPStartDate];
    
    // clear kRemainDuration in datafile
    [rootObject setValue:nil forKey:kRemainDuration];
    [NSKeyedArchiver archiveRootObject:rootObject toFile: path];    
}


- (BOOL)needRestorePauseFromDisk
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"NeedRestorePause"];
}

- (BOOL)needRestoreDummyFromDisk
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"NeedRestoreDummy"];
}

- (void)enableRestorePauseFromDisk
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NeedRestorePause"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NeedRestoreDummy"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)enableRestoreDummyFromDisk
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NeedRestorePause"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NeedRestoreDummy"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)disableRestoreAllFromDisk
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NeedRestorePause"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NeedRestoreDummy"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)pathForDataFile
{
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    //return basePath;
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"tomato.data"];        
    return dataPath;
}

#pragma mark - TimerDelegate

- (void)remainingTimeDidChange:(NSNumber*)remainingSeconds
{
    [self.uiDelegate remainingTimeDidChange:remainingSeconds];
}

#pragma mark - utility methods

// when create the new dummy pomodoro,we need figure out break is short break or long break; the total count can be calc by this function.
//- (NSInteger)newDummyCountPlusTodayPomodoroCount
//{    
//    return self.newDummyPomodoroCount + [[DataManager sharedInstance] todayPomodoroCount];
//}

/*
- (NSArray*)pomodorosOfDay:(NSDate*)date completed:(PomodoroStatus)status;
{
    //////
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pomodoro"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"interrupted = %@", [NSNumber numberWithBool:NO]];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(interrupted = %@) AND (endDate > %@)", [NSNumber numberWithBool:NO], [NSDate dateWithTimeIntervalSinceNow: -(60.0f*30.0f)]];
    
    NSPredicate *predicate;
    switch (status) {
        case PomodoroCompleted:
            predicate = [NSPredicate predicateWithFormat:@"(pInterrupted = %@) AND (pEndDate > %@) AND (pEndDate < %@)", [NSNumber numberWithBool:NO], [date beginningOfDay], [[date tomorrow ]beginningOfDay]];
            break;
        case PomodoroInterrupted:
            predicate = [NSPredicate predicateWithFormat:@"(pInterrupted = %@) AND (pEndDate > %@) AND (pEndDate < %@)", [NSNumber numberWithBool:YES], [date beginningOfDay], [[date tomorrow ]beginningOfDay]];
            break;
        case PomodoroAll:
            predicate = [NSPredicate predicateWithFormat:@"(pEndDate > %@) AND (pEndDate < %@)", [NSNumber numberWithBool:NO], [date beginningOfDay], [[date tomorrow ]beginningOfDay]];
            break;
        default:
            predicate = [NSPredicate predicateWithFormat:@"(pInterrupted = %@) AND (pEndDate > %@) AND (pEndDate < %@)", [NSNumber numberWithBool:NO], [date beginningOfDay], [[date tomorrow ]beginningOfDay]];
            break;
    }    
    
    [fetchRequest setPredicate:predicate];
    
    // Order the events by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pEndDate" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
        // Handle the error.
        return nil;
        //return [NSArray array];
    }
    else{
        return fetchedObjects;
    }
    
   
}

    

- (NSInteger)todayCompletedCount
{
    return [self completedCountOfDay:[NSDate date]];
}

- (NSInteger)completedCountOfDay:(NSDate*)date
{    
    NSArray *fetchedObjects = [self pomodorosOfDay:date completed:PomodoroCompleted];
    if (fetchedObjects == nil) {                
        return 0;
    }
    else{
        return [fetchedObjects count];
    }
}

// return how many seconds 
- (NSInteger)todayPomodoroSeconds
{
    return [self pomodoroSecondsOfDay:[NSDate date]];
}

- (NSInteger)pomodoroSecondsOfDay:(NSDate*)date
{    
    NSArray *fetchedObjects = [self pomodorosOfDay:date completed:PomodoroCompleted];
    if (fetchedObjects == nil) {
        // Handle the error.
        return 0;
    }
   
    NSInteger pomodoroSeconds = 0;    
    for (Pomodoro *onePomodoro in fetchedObjects) {
        pomodoroSeconds += [[onePomodoro pDuration] intValue];        
    }
    
#if DEBUG_TOMATO
    return pomodoroSeconds*60*5; // *60 only for test;
#else
    return pomodoroSeconds;
#endif
         
}

#warning this value should be save in core data to improve performance
- (NSInteger)biggestPomodoroSecondsOfAllDay
{
    return 1*60*60;
}

- (Pomodoro*)firstCompletedPomodoro
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pomodoro"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
#warning is it ok for performance? is there other methods?
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pInterrupted = %@", [NSNumber numberWithBool:NO]];
    [fetchRequest setPredicate:predicate];
    
    // Order the events by creation date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pEndDate" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || fetchedObjects.count ==0) {
        
        // Handle the error.
        return nil;
    }
    else{
        return [fetchedObjects objectAtIndex:0];
    }
}

- (NSDate*)firstPomodoroEndDate {
    Pomodoro *firstPomodoro = [self firstCompletedPomodoro];
    if (firstPomodoro) {
        return firstPomodoro.pEndDate;
    }
    else {
        return nil;
    }
}

- (NSMutableArray*)historyMonthArrayUntil:(NSDate*)toDate reverse:(BOOL)reverse
{
    if (![self firstPomodoroEndDate]) {
        return [NSMutableArray array];
    }
    
    return [NSDate monthsFromDate:[self firstPomodoroEndDate] toDate:toDate reverse:reverse];
}
*/


/*
#warning  check timeZone below
- (NSDate*)beginningOfDate:(NSDate*)date
{
    NSDate* sourceDate = date;
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:sourceDate];
    
    
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *destinationTodayBeginning = [cal dateByAddingComponents:components toDate:destinationDate options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
    
    NSDate *sourceTodayBeginning = [[NSDate alloc] initWithTimeInterval:-interval sinceDate:destinationTodayBeginning];
    NSDate * a = [cal dateByAddingComponents:components toDate:sourceDate options:0];
    
    return sourceTodayBeginning;
    //
}
    */
    /*
     [components setHour:-24];
     [components setMinute:0];
     [components setSecond:0];
     NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
     
     components = [cal components:NSWeekdayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[[NSDate alloc] init]];
     
     [components setDay:([components day] - ([components weekday] - 1))];
     NSDate *thisWeek  = [cal dateFromComponents:components];
     
     [components setDay:([components day] - 7)];
     NSDate *lastWeek  = [cal dateFromComponents:components];
     
     [components setDay:([components day] - ([components day] -1))];
     NSDate *thisMonth = [cal dateFromComponents:components];
     
     [components setMonth:([components month] - 1)];
     NSDate *lastMonth = [cal dateFromComponents:components];
     
     ClawInfo(@"today=%@",today);
     ClawInfo(@"yesterday=%@",yesterday);
     ClawInfo(@"thisWeek=%@",thisWeek);
     ClawInfo(@"lastWeek=%@",lastWeek);
     ClawInfo(@"thisMonth=%@",thisMonth);
     ClawInfo(@"lastMonth=%@",lastMonth);
     */

@end
