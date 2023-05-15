//
//  NSDate+Utils.h
//  Tomato
//
//  Created by Teng Lin on 13-2-3.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Utils)
- (void)reverse;
@end

@interface NSDate (Utils)

+ (NSMutableArray*)daysFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate reverse:(BOOL)reverse;
+ (NSMutableArray*)monthsFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate reverse:(BOOL)reverse;
+ (NSMutableArray*)allDaysInMonth:(NSDate*)anyDateInMonth;
+ (NSMutableArray*)daysInMonth:(NSDate*)anyDateInMonth limitFrom:(NSDate*)downLimitDate limitTo:(NSDate*)upLimitDate reverse:(BOOL)reverse;

+ (NSDate*)dateWithYear:(int)year month:(int)month day:(int)day hour:(int)hour minute:(int)minute second:(int)second;

// easy to test date in the future or others
+ (NSDate*)currentDateWrapper;

- (BOOL)isWeekend;
- (NSString*)weekDayName;

- (NSDate *)beginningOfDay;
- (NSDate *)beginningOfMonth;
- (NSDate *)beginningOfQuarter;
- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfYear;

- (NSDate *)endOfDay;
- (NSDate *)endOfMonth;
- (NSDate *)endOfQuarter;
- (NSDate *)endOfWeek;
- (NSDate *)endOfYear;

- (NSInteger)elapsedSecondsOfDay;
- (NSInteger)remainSecondsOfDay;

- (NSDate *)advance:(int)years months:(int)months weeks:(int)weeks days:(int)days
			  hours:(int)hours minutes:(int)minutes seconds:(int)seconds;

- (NSDate *)ago:(int)years months:(int)months weeks:(int)weeks days:(int)days
          hours:(int)hours minutes:(int)minutes seconds:(int)seconds;

- (NSDate *)change:(NSDictionary *)changes;

- (int)daysInMonth;

- (NSDate *)monthsSince:(int)months;
- (NSDate *)yearsSince:(int)years;

- (NSDate *)nextMonth;
- (NSDate *)nextWeek;
- (NSDate *)nextYear;

- (NSDate *)prevMonth;
- (NSDate *)prevYear;
- (NSDate *)yearsAgo:(int)years;
- (NSDate *)yesterday;

- (NSDate *)tomorrow;

- (BOOL)future;
- (BOOL)past;
- (BOOL)today;

- (BOOL)earlierThanDate:(NSDate*)date;
- (BOOL)laterThanDate:(NSDate*)date;

@end
