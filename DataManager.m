//
//  DataManager.m
//  Tomato
//
//  Created by Lin Teng on 3/7/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "DataManager.h"
#import "TomatoManager.h"
#import "NSDate+Utils.h"
#import "MyGlobal.h"
#import "Day.h"
#import "Vars.h"

@interface DataManager ()

@end

@implementation DataManager

+ (DataManager*)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static DataManager* _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (BOOL)saveCoreDataContext
{
    NSError *error;
    if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
        // Handle the error.        
        ClawError(@"saveCoreDataContext error %@, %@", error, [error userInfo]);
        //abort();
        return NO;
    }
    return YES;
}

#pragma mark - Days related methods

- (Day*)getDayObjectOfDate:(NSDate*)date
{
    Day *dayObject = [self fetchDayObjectOfDate:date];
    if (dayObject == nil) {
        dayObject = [self createDayObjectOfDate:date];
    }
    return dayObject;
}

- (Day*)createDayObjectOfDate:(NSDate*)date{
    
    Day *dayObject = [NSEntityDescription insertNewObjectForEntityForName:@"Day" inManagedObjectContext:self.managedObjectContext];
    dayObject.pomodoroSeconds = [NSNumber numberWithInt:0];
    dayObject.pomodoroCount = [NSNumber numberWithInt:0];
    dayObject.beginOfDay = [date beginningOfDay];
        
    if (![self saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
        return nil;
    }    
#warning check ARC,  anything about previous autorelease here?
    return dayObject;
}

- (Day*)fetchDayObjectOfDate:(NSDate*)date
{
    return [self fetchDayObjectOfDayBeginning:[date beginningOfDay]];
}

// return nil if find nothing
- (Day*)fetchDayObjectOfDayBeginning:(NSDate*)beginningOfDay
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Day" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"beginOfDay = %@", beginningOfDay];    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {        
        // Handle the error.
        return nil;       
    }
    
    if ([fetchedObjects count] <= 0) {
        return nil;
    }
    
    return [fetchedObjects objectAtIndex:0];          
}

#warning write testing for it date = 2014-02-01 ... etc
// completed pomodoros of Day
- (NSArray*)pomodorosOfDate:(NSDate*)date ascending:(BOOL)ascending
{
    Day *dayObj = [self fetchDayObjectOfDate:date];
    if (!dayObj) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Set entity name.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pomodoro" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    /********************
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(interrupted = %@) ", [NSNumber numberWithBool:NO]];
     [fetchRequest setPredicate:predicate];
     *********************/
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(day = %@) ", dayObj];
    [fetchRequest setPredicate:predicate];
    
    // Set the sort key.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pEndDate" ascending:ascending];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error.
        return nil;
    }
    else {
        return fetchedObjects;
    }
    
/*
    Day * dayMObject = [self fetchDayObjectOfDate:date];
    NSSet *pomodoroSet = [dayMObject pomodoro];
    if (pomodoroSet.count <= 0) {
        return nil;
    }
    //else    
    // Order the Pomodoro by end date, most recent first.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pEndDate" ascending:ascending];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    return [pomodoroSet sortedArrayUsingDescriptors:sortDescriptors];
*/
    
}

// for restore from disk purpose
- (Pomodoro*)fetchPomodoroByPStartDate:(NSDate*)pStartDate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pomodoro" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pStartDate = %@", pStartDate];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error.
        return nil;
    }
    
    if ([fetchedObjects count] <= 0) {
        return nil;
    }
    return [fetchedObjects objectAtIndex:0];
}

- (NSInteger)todayPomodoroCount
{
    return [self pomodoroCountOfDate:[NSDate currentDateWrapper]];
}

// return how many seconds
- (NSInteger)todayPomodoroSeconds
{
    return [self pomodoroSecondsOfDate:[NSDate currentDateWrapper]];
}

- (NSInteger)pomodoroCountOfDate:(NSDate*)date
{
    Day *object = [self fetchDayObjectOfDate:date];
    if (object) {
        return object.pomodoroCount.intValue;
    }
    return 0;
}

- (NSInteger)pomodoroSecondsOfDate:(NSDate*)date
{
    Day *object = [self fetchDayObjectOfDate:date];
    if (object) {
        return object.pomodoroSeconds.intValue;
    }
    return 0;    
}

// if added before, will skip
- (void)updateDayObjectInMem:(Day*)dayObject addNewPomodoroObject:(Pomodoro*)pomodoroObject
{
    if (!dayObject || !pomodoroObject) {
        return;
    }
    
    if ([pomodoroObject.pInterrupted boolValue]) {
        // interrupted, so skip;
        return;
    }
    
    // get all pomodoro of the dayObject
    NSSet *pomodoroSet = [dayObject pomodoro];
    
    // not find any pomodoro, so add, and update count and seconds
    if (pomodoroSet.count <= 0) {
        [dayObject addPomodoroObject:pomodoroObject];
        dayObject.pomodoroCount = [NSNumber numberWithInt:1];
        dayObject.pomodoroSeconds = pomodoroObject.pDuration;        
        return;
    }
    
    // else, go through all pomodoro, if not find , then add, and update count and seconds
    for (Pomodoro *onePomodoro in pomodoroSet) {
        if ([[onePomodoro objectID] isEqual:[pomodoroObject objectID] ]) {
            ClawInfo(@"Match Pomodoro ID!");
            return;
        }
//        if ([[[onePomodoro objectID] URIRepresentation] isEqual:[[pomodoroObject objectID] URIRepresentation]]) {
//            ClawInfo(@"Match Pomodoro ID URIRepresentation !");
//            return;
//        }
    }
    
    // not find then add, and update count and seconds
    [dayObject addPomodoroObject:pomodoroObject];
    [self updateDayObjectValuesInMem:dayObject];
}

- (void)updateDayObjectInMem:(Day*)dayObject removePomodoroObject:(Pomodoro*)pomodoroObject
{
    if (!dayObject || !pomodoroObject) {
        return;
    }
    
    Pomodoro *currentPomodoroObj = [TomatoManager sharedInstance].currentPomodoro;
    
    if (![pomodoroObject.objectID isEqual:currentPomodoroObj.objectID]) {
        [dayObject removePomodoroObject:pomodoroObject];
        [self.managedObjectContext deleteObject:pomodoroObject];
    }
    else {
        [dayObject removePomodoroObject:pomodoroObject];
    }
    
    //dayObject and pomodoroObject.day is same?
    //re-calc count and seconds  of dayObject
    [self updateDayObjectValuesInMem:dayObject];    
}

// only update the object in memory, does not save it here
- (void)updateDayObjectValuesInMem:(Day*)dayObject
{
    if (!dayObject) {
        return;
    }
    
    NSInteger count = 0;
    NSInteger seconds = 0;
    
    NSSet *pomodoroSet = [dayObject pomodoro];
    for (Pomodoro *onePomodoro in pomodoroSet) {
        count ++;
        seconds += onePomodoro.pDuration.intValue;
    }    
    dayObject.pomodoroCount = [NSNumber numberWithInt:count];
    dayObject.pomodoroSeconds = [NSNumber numberWithInt:seconds];
}

- (void)createVarsAndDayObjectNowIfNeccessary
{
    Day *currentDayObj = [self getDayObjectOfDate:[NSDate currentDateWrapper]];
    
    // update Vars
    Vars *someVars = [[DataManager sharedInstance] getVarsObject];    
    if (someVars == nil) {
        ClawError(@"createVarsObject error");
        return;
    }
    
    if (!someVars.firstSavedDayBegin) {
        someVars.firstSavedDayBegin = currentDayObj.beginOfDay;
    }
    
    if (![self saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }
}

#pragma mark - Vars related methods

- (Vars*)getVarsObject
{
    Vars *someVars = [self fetchVarsObject];
    if (someVars == nil) {        
        someVars = [self createVarsObject];
    }    
    return someVars;
}

- (Vars*)createVarsObject
{
    Vars *someVars = [NSEntityDescription insertNewObjectForEntityForName:@"Vars" inManagedObjectContext:self.managedObjectContext];
    someVars.biggestPSecondsOfAllDay = [NSNumber numberWithInt:0];    
    someVars.firstSavedDayBegin = nil;
    
    if (![self saveCoreDataContext]) {
        // Handle the error.
        ClawError(@"createVarsObject error");
        return nil;
    }
    
#warning check ARC,  anything about previous autorelease here?
    return someVars;
}

- (Vars*)fetchVarsObject
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vars"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
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

- (void)updateVarsBiggestPomodoroSecondsByCheckingNewDayObject:(Day*)dayObject 
{
    // update Vars
    Vars *someVars = [[DataManager sharedInstance] getVarsObject];
    
    if (someVars == nil) {
        ClawError(@"createVarsObject error");
        return;
    }    
   
    if (someVars.biggestPSecondsOfAllDay.intValue < dayObject.pomodoroSeconds.intValue) {
        someVars.biggestPSecondsOfAllDay = [NSNumber numberWithInt:dayObject.pomodoroSeconds.intValue];
    }
    if (![self saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }
}

- (void)updateVarsBiggestPomodoroSecondsByRecalc
{
    // get all Days
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Day" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!fetchedObjects) {
        return;
    }
    NSInteger biggestSeconds = 0;
    for (Day *dayObject in fetchedObjects) {
        if (dayObject.pomodoroSeconds.intValue > biggestSeconds) {
            biggestSeconds = dayObject.pomodoroSeconds.intValue;
        }
    }
    if (biggestSeconds <= 0) {
        return;
    }    
    // biggest of all days is the need one, then update someVars
    Vars *someVars = [self getVarsObject];    
    someVars.biggestPSecondsOfAllDay = [NSNumber numberWithInt:biggestSeconds];    
   
    if (![self saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }
}

- (NSInteger)biggestPomodoroSecondsOfAllDay
{
    Vars *someVars = [self fetchVarsObject];    
    if (someVars == nil) {        
        return 0;
    }
    return someVars.biggestPSecondsOfAllDay.intValue;
}

- (NSDate*)beginningOfFirstSavedDay
{
    Vars *someVars = [self fetchVarsObject];    
    if (someVars == nil) {        
        return nil;
    }
    return someVars.firstSavedDayBegin;
}

// later date of (beginningOfFirstSavedDay, firstdayBegin of 2 years ago)
// update: 2013-09-06, if user set the date&time to the date before [firstSavedDayBegin laterDate:dayBegin2YeasAgo];
// then that means, the [NSDate date] will be before [firstSavedDayBegin laterDate:dayBegin2YeasAgo];
// so, we need set the return value of this method to [NSDate date] ago:0 months:0 weeks:0 days:0 hours:1 minutes:0 seconds:0] beginningOfDay];

- (NSDate*)beginningOfFirstHistoryDay
{
    NSDate *firstSavedDayBegin = [self beginningOfFirstSavedDay];
    if (!firstSavedDayBegin) {
        return nil;
    }
    
    //day begin of two years ago
#if DEBUG_TOMATO
    NSDate *dayBegin2YeasAgo = [[[NSDate date] beginningOfDay] ago:0 months:0 weeks:0 days:2 hours:0 minutes:0 seconds:0];
#else
    NSDate *dayBegin2YeasAgo = [[[NSDate date] beginningOfDay] ago:2 months:0 weeks:0 days:0 hours:0 minutes:0 seconds:0];
#endif
    
    NSDate *laterOneOfFirstSavedDayAndDay2YeasAgo = [firstSavedDayBegin laterDate:dayBegin2YeasAgo];
    
    // if one hour ago is yesterday, then beginningOfToayOrYesterday is begin Of Yesterday
    NSDate *beginningOfToayOrYesterday = [[[NSDate date] ago:0 months:0 weeks:0 days:0 hours:1 minutes:0 seconds:0] beginningOfDay];
    if ([laterOneOfFirstSavedDayAndDay2YeasAgo compare:beginningOfToayOrYesterday] != NSOrderedDescending) {
        return laterOneOfFirstSavedDayAndDay2YeasAgo;
    }
    else {
        //save
        // update Vars
        Vars *someVars = [[DataManager sharedInstance] getVarsObject];
        if (someVars == nil) {
            ClawError(@"createVarsObject error");
            return nil;
        }             
        someVars.firstSavedDayBegin = beginningOfToayOrYesterday;            
        if (![self saveCoreDataContext]) {
            ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
        }
        
        //then return
        return beginningOfToayOrYesterday;
    }
}

- (NSInteger)redundantCeilingForBiggestPomodoroHoursOfAllDay
{
    NSInteger hours = [self biggestPomodoroSecondsOfAllDay]/3600 + 2;
    NSInteger defaultMinHours;
    if (IS_WIDESCREEN) {
        defaultMinHours = 7;
    }
    else {
        defaultMinHours = 6;
    }
    
    if (hours < defaultMinHours) {
        hours = defaultMinHours;
    }
    if (hours > 24) {
        hours = 24;
    }
    return hours;
}

#pragma mark - utils
- (NSMutableArray*)historyDaysUntil:(NSDate*)toDate reverse:(BOOL)reverse
{
    if (![self beginningOfFirstHistoryDay]) {
        return [NSMutableArray array];
    }    
    return [NSDate daysFromDate:[self beginningOfFirstHistoryDay] toDate:toDate reverse:reverse];
}

- (NSMutableArray*)historyMonthsUntil:(NSDate*)toDate reverse:(BOOL)reverse
{
    if (![self beginningOfFirstHistoryDay]) {
        return [NSMutableArray array];
    }    
    return [NSDate monthsFromDate:[self beginningOfFirstHistoryDay] toDate:toDate reverse:reverse];
}

- (void)deleteAllObjectsInDB
{
    Pomodoro *currentPomodoroObj = [TomatoManager sharedInstance].currentPomodoro;
    Day *currentDayObj = [self getDayObjectOfDate:[NSDate currentDateWrapper]];
    
    NSFetchRequest * allDays = [[NSFetchRequest alloc] init];
    [allDays setEntity:[NSEntityDescription entityForName:@"Day" inManagedObjectContext:self.managedObjectContext]];
    [allDays setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * days = [self.managedObjectContext executeFetchRequest:allDays error:&error];
    
    //error handling goes here
    for (NSManagedObject * day in days) {
        if (![day.objectID isEqual:currentDayObj.objectID]) {
            [self.managedObjectContext deleteObject:day];
        }        
    }
    if (![self saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }
    
    NSFetchRequest * allPomodoro = [[NSFetchRequest alloc] init];
    [allPomodoro setEntity:[NSEntityDescription entityForName:@"Pomodoro" inManagedObjectContext:self.managedObjectContext]];
    [allPomodoro setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    //NSError * error = nil;
    NSArray * pomodoros = [self.managedObjectContext executeFetchRequest:allPomodoro error:&error];
    
    //error handling goes here
    for (NSManagedObject * pomodoro in pomodoros) {
        if (![pomodoro.objectID isEqual:currentPomodoroObj.objectID]) {
            [self.managedObjectContext deleteObject:pomodoro];
        }
        else {
            [currentPomodoroObj.day removePomodoroObject:currentPomodoroObj];
        }
    }
    if (![self saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }

    // update Day
    [self updateDayObjectValuesInMem:currentDayObj];
    // update Vars
    Vars *someVars = [[DataManager sharedInstance] getVarsObject];
    
    if (someVars == nil) {
        ClawError(@"createVarsObject error");
        return;
    }    
    
    someVars.firstSavedDayBegin = currentDayObj.beginOfDay;    
    someVars.biggestPSecondsOfAllDay = [NSNumber numberWithInt:currentDayObj.pomodoroSeconds.intValue];
    
    if (![self saveCoreDataContext]) {
        ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
    }    
}

@end
