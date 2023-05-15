//
//  Vars.h
//  Tomato2
//
//  Created by Teng Lin on 13-11-12.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Vars : NSManagedObject

@property (nonatomic, retain) NSNumber * biggestPSecondsOfAllDay;
@property (nonatomic, retain) NSDate * firstSavedDayBegin;

@end
