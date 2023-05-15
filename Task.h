//
//  Task.h
//  Tomato2
//
//  Created by Teng Lin on 13-11-12.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSString * taskName;
@property (nonatomic, retain) NSNumber * taskPriority;
@property (nonatomic, retain) NSSet *pomodoro;
@end

@interface Task (CoreDataGeneratedAccessors)

- (void)addPomodoroObject:(NSManagedObject *)value;
- (void)removePomodoroObject:(NSManagedObject *)value;
- (void)addPomodoro:(NSSet *)values;
- (void)removePomodoro:(NSSet *)values;

@end
