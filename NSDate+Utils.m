//
//  NSDate+Utils.m
//  Tomato
//
//  Created by Teng Lin on 13-2-3.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import "NSDate+Utils.h"


@implementation NSMutableArray (Reverse)

- (void)reverse {
    if ([self count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        
        i++;
        j--;
    }
}

@end

@implementation NSDate (Utils)

+ (NSMutableArray*)daysFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate reverse:(BOOL)reverse
{
    if ([fromDate laterDate:toDate] == fromDate) {
        return [NSMutableArray array];
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    /* if fromDate if beginning of Day, skip this
    NSDate *pFromDate;
    NSDate *pToDate;
     
    [cal rangeOfUnit:NSDayCalendarUnit startDate:&pFromDate
                 interval:NULL forDate:fromDate];
    [cal rangeOfUnit:NSDayCalendarUnit startDate:&pToDate
                 interval:NULL forDate:toDate];
    
    NSDateComponents *difference = [cal components:NSDayCalendarUnit
                                               fromDate:pFromDate toDate:pToDate options:0];
    */
    
    //NSInteger dayCount = [difference day] + 1;
    
    //other
    NSDateComponents *difference2 = [cal components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
    NSInteger dayCount = [difference2 day] + 1;
    
    NSMutableArray *daysArray = [NSMutableArray array];
       
    NSDateComponents *componentsOfFrom = [cal components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSEraCalendarUnit)  fromDate:fromDate];
    //NSDateComponents *componentsOfTo = [cal components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSEraCalendarUnit) fromDate:toDate];
    
   // NSInteger dayCount = [componentsOfTo day] - [componentsOfFrom day] + 1;
    NSInteger fromDayComponent = [componentsOfFrom day];
    for (NSInteger i = 0; i < dayCount; ++i) {
        [componentsOfFrom setDay:(fromDayComponent + i)];
#warning compare with [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:self options:0];
        NSDate *oneDay = [cal dateFromComponents:componentsOfFrom];
        [daysArray addObject:oneDay];
    }
    
    if (reverse) {
        [daysArray reverse];
    }    
    return daysArray;
       
}

+ (NSMutableArray*)monthsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate reverse:(BOOL)reverse
{
    if ([fromDate laterDate:toDate] == fromDate) {
        return [NSMutableArray array];
    }
    
    // first day represent the month
    NSMutableArray *firstDayOfMonths = [NSMutableArray array];
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsOfFrom = [cal components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSEraCalendarUnit) fromDate:fromDate];
    NSDateComponents *componentsOfTo = [cal components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSEraCalendarUnit) fromDate:toDate];
    
    NSInteger monthCount = [componentsOfTo month] - [componentsOfFrom month] + 1;
    
    //NSDateComponents *difference = [cal components:NSMonthCalendarUnit fromDate:fromDate toDate:toDate options:0];
    //NSInteger monthCount = [difference month] + 1;
    
    NSInteger fromMonthComponent = [componentsOfFrom month];
    for (NSInteger i = 0; i < monthCount; ++i) {
        [componentsOfFrom setMonth:(fromMonthComponent + i)];
        [componentsOfFrom setDay:1];
        NSDate *firstDayInMonth = [cal dateFromComponents:componentsOfFrom];
        [firstDayOfMonths addObject:firstDayInMonth];
    }
    
    if (reverse) {
        [firstDayOfMonths reverse];
    }
    
    return firstDayOfMonths;
}


+ (NSMutableArray*)allDaysInMonth:(NSDate*)anyDateInMonth
{
    return [self daysInMonth:anyDateInMonth limitFrom:nil limitTo:nil reverse:NO];
}

+ (NSMutableArray*)daysInMonth:(NSDate*)anyDateInMonth limitFrom:(NSDate*)downLimitDate limitTo:(NSDate*)upLimitDate reverse:(BOOL)reverse
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSMutableArray *daysInThisMonth = [NSMutableArray array];
    NSRange rangeOfDaysThisMonth = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:anyDateInMonth];
    
    NSDateComponents *components = [cal components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSEraCalendarUnit) fromDate:anyDateInMonth];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    for (NSInteger i = rangeOfDaysThisMonth.location; i < NSMaxRange(rangeOfDaysThisMonth); ++i) {
        [components setDay:i];
        NSDate *dayInMonth = [cal dateFromComponents:components];
        /*
         if (downLimitDate && [downLimitDate compare:dayInMonth] == NSOrderedDescending) {
         continue;
         }
         if (upLimitDate && [upLimitDate compare:dayInMonth] == NSOrderedAscending) {
         continue;
         }
         */
        if ([dayInMonth timeIntervalSinceDate:downLimitDate] < -1) {
            //ClawInfo(@"time inteval %f", [dayInMonth timeIntervalSinceDate:downLimitDate]);
            continue;
        }
        if ([dayInMonth timeIntervalSinceDate:upLimitDate] > 1) {
            continue;
        }
        [daysInThisMonth addObject:dayInMonth];
    }
    
    if (reverse) {
        [daysInThisMonth reverse];
    }
    
    return daysInThisMonth;
}

+ (NSDate *)dateWithYear:(int)year month:(int)month day:(int)day hour:(int)hour minute:(int)minute second:(int)second
{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:year];
	[comps setMonth:month];
	[comps setDay:day];
	[comps setHour:hour];
	[comps setMinute:minute];
	[comps setSecond:second];
	
	return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

+ (NSDate*)currentDateWrapper
{
    return [NSDate date];
}
- (BOOL)isWeekend
{    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange weekdayRange = [calendar maximumRangeOfUnit:NSWeekdayCalendarUnit];
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    NSUInteger weekdayOfDate = [components weekday];
    
    if (weekdayOfDate == weekdayRange.location || weekdayOfDate == weekdayRange.length) {
        //the date falls somewhere on the first or last days of the week
        //ClawInfo(@"weekend! weekdayOfDate %d of %@", weekdayOfDate , self);
        return YES;
    }
    else {
        return NO;
    }
}

- (NSString*)weekDayName
{
    /*
    NSCalendar *calendar = [NSCalendar currentCalendar];   
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    NSUInteger weekdayOfDate = [components weekday];
    return [NSString stringWithFormat:@"%d", weekdayOfDate];
    */
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *formattedDateString = [dateFormatter stringFromDate:self];
    return formattedDateString;
}

#pragma mark -
#pragma mark Beginning of

- (NSDate *)beginningOfDay
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSEraCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	
	return [currentCalendar dateFromComponents:comps];
}

- (NSDate *)beginningOfMonth
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setDay:1];
	[comps setHour:0];
	[comps setMinute:00];
	[comps setSecond:00];
	
	return [currentCalendar dateFromComponents:comps];
}

// 1st of january, april, july, october
- (NSDate *)beginningOfQuarter
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	int month = [comps month];
	
	if (month < 4)
		[comps setMonth:1];
	else if (month < 7)
		[comps setMonth:4];
	else if (month < 10)
		[comps setMonth:7];
	else
		[comps setMonth:10];
    
	[comps setDay:1];
	[comps setHour:0];
	[comps setMinute:00];
	[comps setSecond:00];
	
	return [currentCalendar dateFromComponents:comps];
}

// Week starts on sunday for the gregorian calendar
- (NSDate *)beginningOfWeek
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setWeekday:1];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	
	return [currentCalendar dateFromComponents:comps];
}

- (NSDate *)beginningOfYear
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setMonth:1];
	[comps setDay:1];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	
	return [currentCalendar dateFromComponents:comps];
}

#pragma mark -
#pragma mark End of

- (NSDate *)endOfDay
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	
	return [currentCalendar dateFromComponents:comps];
}

- (NSDate *)endOfMonth
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setDay:[self daysInMonth]];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	
	return [currentCalendar dateFromComponents:comps];
}

// 1st of january, april, july, october
- (NSDate *)endOfQuarter
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	int month = [comps month];
	
	if (month < 4)
	{
		[comps setMonth:3];
		[comps setDay:31];
	}
	else if (month < 7)
	{
		[comps setMonth:6];
		[comps setDay:30];
	}
	else if (month < 10)
	{
		[comps setMonth:9];
		[comps setDay:30];
	}
	else
	{
		[comps setMonth:12];
		[comps setDay:31];
	}
	
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	
	return [currentCalendar dateFromComponents:comps];
}

- (NSDate *)endOfWeek
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setWeekday:7];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	
	return [currentCalendar dateFromComponents:comps];
}

- (NSDate *)endOfYear
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	int calendarComponents = (NSYearCalendarUnit);
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	[comps setMonth:12];
	[comps setDay:31];
	[comps setHour:23];
	[comps setMinute:59];
	[comps setSecond:59];
	
	return [currentCalendar dateFromComponents:comps];
}

- (NSInteger)elapsedSecondsOfDay
{
    NSTimeInterval secondsBetween = [self timeIntervalSinceDate:[self beginningOfDay]];
    return secondsBetween;
}

- (NSInteger)remainSecondsOfDay
{
    NSTimeInterval secondsBetween = [[self endOfDay] timeIntervalSinceDate:self];
    return secondsBetween;
}
#pragma mark -
#pragma mark Other Calculations

- (NSDate *)advance:(int)years months:(int)months weeks:(int)weeks days:(int)days
			  hours:(int)hours minutes:(int)minutes seconds:(int)seconds
{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:years];
	[comps setMonth:months];
	[comps setWeek:weeks];
	[comps setDay:days];
	[comps setHour:hours];
	[comps setMinute:minutes];
	[comps setSecond:seconds];
	
	return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:self options:0];
}

- (NSDate *)ago:(int)years months:(int)months weeks:(int)weeks days:(int)days
		  hours:(int)hours minutes:(int)minutes seconds:(int)seconds
{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setYear:-years];
	[comps setMonth:-months];
	[comps setWeek:-weeks];
	[comps setDay:-days];
	[comps setHour:-hours];
	[comps setMinute:-minutes];
	[comps setSecond:-seconds];
	
	return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:self options:0];
}

- (NSDate *)change:(NSDictionary *)changes
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	
	int calendarComponents = (NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
							  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |
							  NSWeekCalendarUnit | NSWeekdayCalendarUnit |  NSWeekdayOrdinalCalendarUnit |
							  NSQuarterCalendarUnit);
	
	NSDateComponents *comps = [currentCalendar components:calendarComponents fromDate:self];
	
	for (id key in changes) {
		SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@:", [key capitalizedString]]);
		int value = [[changes valueForKey:key] intValue];
		
		NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[comps methodSignatureForSelector:selector]];
		[inv setSelector:selector];
		[inv setTarget:comps];
		[inv setArgument:&value atIndex:2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
		[inv invoke];
	}
    
	return [currentCalendar dateFromComponents:comps];
}

- (int)daysInMonth
{
	NSCalendar *currentCalendar = [NSCalendar currentCalendar];
	NSRange days = [currentCalendar rangeOfUnit:NSDayCalendarUnit
										 inUnit:NSMonthCalendarUnit
										forDate:self];
	return days.length;
}

- (NSDate *)monthsSince:(int)months
{
	return [self advance:0 months:months weeks:0 days:0 hours:0 minutes:0 seconds:0];
}

- (NSDate *)yearsSince:(int)years
{
	return [self advance:years months:0 weeks:0 days:0 hours:0 minutes:0 seconds:0];
}

- (NSDate *)nextMonth
{
	return [self monthsSince:1];
}

- (NSDate *)nextWeek
{
	return [self advance:0 months:0 weeks:1 days:0 hours:0 minutes:0 seconds:0];
}

- (NSDate *)nextYear
{
	return [self advance:1 months:0 weeks:0 days:0 hours:0 minutes:0 seconds:0];
}

- (NSDate *)prevMonth
{
	return [self monthsSince:-1];
}

- (NSDate *)prevYear
{
	return [self yearsAgo:1];
}

- (NSDate *)yearsAgo:(int)years
{
	return [self advance:-years months:0 weeks:0 days:0 hours:0 minutes:0 seconds:0];
}

- (NSDate *)yesterday
{
	return [self advance:0 months:0 weeks:0 days:-1 hours:0 minutes:0 seconds:0];
}

- (NSDate *)tomorrow
{
	return [self advance:0 months:0 weeks:0 days:1 hours:0 minutes:0 seconds:0];
}

- (BOOL)future
{
	return self == [self laterDate:[NSDate date]];
}

- (BOOL)past
{
	return self == [self earlierDate:[NSDate date]];
}

- (BOOL)today
{
	return self == [self laterDate:[[NSDate date] beginningOfDay]] &&
    self == [self earlierDate:[[NSDate date] endOfDay]];
}

- (BOOL)earlierThanDate:(NSDate*)date
{
    return self == [self earlierDate:date];
}

- (BOOL)laterThanDate:(NSDate*)date
{
    return self == [self laterDate:date];
}

@end
