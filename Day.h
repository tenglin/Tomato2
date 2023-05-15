//
//  Day.h
//  Tomato2
//
//  Created by Teng Lin on 13-11-12.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Day : NSManagedObject

@property (nonatomic, retain) NSDate * beginOfDay;
@property (nonatomic, retain) NSNumber * pomodoroCount;
@property (nonatomic, retain) NSNumber * pomodoroSeconds;
@property (nonatomic, retain) NSSet *pomodoro;

@property (nonatomic, retain) NSString *sectionMonth;
@end

@interface Day (CoreDataGeneratedAccessors)

- (void)addPomodoroObject:(NSManagedObject *)value;
- (void)removePomodoroObject:(NSManagedObject *)value;
- (void)addPomodoro:(NSSet *)values;
- (void)removePomodoro:(NSSet *)values;

@end
