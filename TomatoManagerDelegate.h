//
//  TomatoManagerDelegate.h
//  Tomato
//
//  Created by Lin Teng on 1/17/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TomatoManagerDelegate <NSObject>

- (void)showPomodoroReadyScreenWithAnimation:(BOOL)animation;
- (void)showPomodoroScreen;
- (void)showPomodoroWarningScreen:(NSNumber*)playSound;
- (void)showPomodoroEndScreen;
- (void)showPomodoroPauseScreen;
- (void)showPomodoroResumeScreen;

- (void)showBreakReadyScreenWithAnimation:(BOOL)animation;
- (void)showBreakScreen;
- (void)showBreakWarningScreen:(NSNumber*)playSound;
- (void)showBreakEndScreen;
- (void)showBreakPauseScreen;
- (void)showBreakResumeScreen;

- (void)showCommonPauseScreen;

- (void)remainingTimeDidChange:(NSNumber*)remainingSeconds;

// move to here as delegate api to support: yesterday app in ViewController, completed count > 0, then enter background
// then, today user open the app(in fact is enterForeground), the completed count still > 0, which should be 0 now
// use this update the completed count when app enterforegournd.
- (void)updateTodayCompletedCountWithAnimation:(BOOL)animation;

@end
