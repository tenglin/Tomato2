//
//  SettingsManager.h
//  Tomato
//
//  Created by Lin Teng on 1/9/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef enum {
//    SimpleTheme = 0, // cartoon
//    BusinessTheme = 1,
//    ArtTheme = 2,
//    SilentTheme, //humble
//    AnimationTheme // aspiring
//} PomodoroUITheme;

typedef enum
{              
    TomatoThemeGray,    
    TomatoThemeIron,
    TomatoThemeMoss,
    TomatoThemeBlack,
} TomatoTheme;

@interface SettingsManager : NSObject

@property (nonatomic) NSInteger pomodoroDuration;
@property (nonatomic) NSInteger breakDuration;
@property (nonatomic) NSInteger longBreakEveryPomodoro;
@property (nonatomic) NSInteger longBreakDuration;

// auto
@property (nonatomic) BOOL autoBreak;
@property (nonatomic) BOOL autoNextPomodoro;

@property (strong, nonatomic) NSString *sampleSoundFile;
@property (strong, nonatomic) NSString *pomodoroStartSoundFile;
@property (strong, nonatomic) NSString *pomodoroEndSoundFile;
@property (strong, nonatomic) NSString *breakEndSoundFile;
@property (strong, nonatomic) NSString *tickingSoundFile;
@property (nonatomic) BOOL ticking;

@property (strong, nonatomic) NSString *pomodoroWarningSoundFile;
@property (nonatomic) BOOL pomodoroWarningBeforeEnd;
@property (strong, nonatomic) NSString *breakWarningSoundFile;
@property (nonatomic) BOOL breakWarningBeforeEnd;

@property (nonatomic) BOOL alarmVibration;

@property (nonatomic) BOOL screenDimming;
@property (nonatomic) BOOL disableAutolock;

// advance
//@property (nonatomic) BOOL enableTasks;
//@property (nonatomic) NSInteger extraTime;
//@property (nonatomic) NSInteger beginningTime;

@property (nonatomic) TomatoTheme theme;

+ (SettingsManager*)sharedInstance;

- (NSInteger)plannedBreakDurationForCompletedPomodoroCount:(NSInteger)pomodoroCount;

@end
