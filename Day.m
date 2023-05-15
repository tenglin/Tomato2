//
//  Day.m
//  Tomato2
//
//  Created by Teng Lin on 13-11-12.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import "Day.h"
#import "Pomodoro.h"


@implementation Day

@dynamic beginOfDay;
@dynamic pomodoroCount;
@dynamic pomodoroSeconds;
@dynamic pomodoro;

@synthesize sectionMonth;

- (NSString *)sectionMonth
{
    //[self willAccessValueForKey:@"sectionDay"];
    //NSString *temp = sectionDay;
    //[self didAccessValueForKey:@"sectionDay"];
    NSString *temp = nil;
    
    if(!temp)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd EEEE"]; // format your section titles however you want
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        temp = [dateFormatter stringFromDate:self.beginOfDay];
        sectionMonth = temp;
    }
    
    return temp;
}

@end
