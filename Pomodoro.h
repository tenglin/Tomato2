//
//  Pomodoro.h
//  Tomato2
//
//  Created by Teng Lin on 13-11-12.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Day, Task;

@interface Pomodoro : NSManagedObject

@property (nonatomic, retain) NSNumber * bDuration;
@property (nonatomic, retain) NSDate * bEndDate;
@property (nonatomic, retain) NSNumber * bInterrupted;
@property (nonatomic, retain) NSDate * bStartDate;
@property (nonatomic, retain) NSNumber * pDuration;
@property (nonatomic, retain) NSDate * pEndDate;
@property (nonatomic, retain) NSNumber * pInterrupted;
@property (nonatomic, retain) NSDate * pStartDate;
@property (nonatomic, retain) Day *day;
@property (nonatomic, retain) Task *task;

// xxx
@property (nonatomic, retain) NSString *sectionDay;
@property (nonatomic, retain) NSString *pDurationString;
@property (nonatomic, retain) NSString *bDurationString;

@end
