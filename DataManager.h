//
//  DataManager.h
//  Tomato
//
//  Created by Lin Teng on 3/7/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyGlobal.h"
#import "Pomodoro.h"
#import "Vars.h"
#import "Day.h"

@interface DataManager : NSObject

+ (DataManager*)sharedInstance;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//save context
- (BOOL)saveCoreDataContext;

//Date and Pomodoro
//only care about completed pomodoro, pInterrupted = NO
- (NSInteger)todayPomodoroCount;
- (NSInteger)pomodoroCountOfDate:(NSDate*)date;
- (NSInteger)todayPomodoroSeconds;
- (NSInteger)pomodoroSecondsOfDate:(NSDate*)date;
- (NSArray*)pomodorosOfDate:(NSDate*)date ascending:(BOOL)ascending;

- (Pomodoro*)fetchPomodoroByPStartDate:(NSDate*)pStartDate;

//Days
//"get" means: fetch or create, anyway, get it!
- (Day*)getDayObjectOfDate:(NSDate*)date;
- (void)updateDayObjectInMem:(Day*)dayObject addNewPomodoroObject:(Pomodoro*)pomodoroObject;
- (void)updateDayObjectInMem:(Day*)dayObject removePomodoroObject:(Pomodoro*)pomodoroObject;

- (void)createVarsAndDayObjectNowIfNeccessary;
- (void)updateVarsBiggestPomodoroSecondsByRecalc;
- (void)updateVarsBiggestPomodoroSecondsByCheckingNewDayObject:(Day*)dayObject;

//Vars
//get 
- (Vars*)getVarsObject;
//member var
- (NSInteger)biggestPomodoroSecondsOfAllDay;
- (NSDate*)beginningOfFirstSavedDay;
- (NSDate*)beginningOfFirstHistoryDay; // later date of (beginningOfFirstSavedDay, firstdayBegin of 2 years ago)
//other
- (NSInteger)redundantCeilingForBiggestPomodoroHoursOfAllDay;

//Utils
- (NSMutableArray*)historyDaysUntil:(NSDate*)toDate reverse:(BOOL)reverse;
- (NSMutableArray*)historyMonthsUntil:(NSDate*)toDate reverse:(BOOL)reverse;

- (void)deleteAllObjectsInDB;

@end
