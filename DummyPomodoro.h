//
//  DummyPomodoro.h
//  Tomato
//
//  Created by Teng Lin on 13-1-13.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DummyPomodoro : NSObject <NSCoding>

@property (strong, nonatomic) NSDate *pStartDate;
@property (nonatomic) NSInteger  pDuration;
@property (strong, nonatomic) NSDate *pEndDate;
@property (nonatomic) BOOL  pInterrupted;

@property (strong, nonatomic) NSDate *bStartDate;
@property (nonatomic) NSInteger bDuration;
@property (strong, nonatomic) NSDate *bEndDate;
@property (nonatomic) BOOL  bInterrupted;

+ (DummyPomodoro*)createInstanceAfterCountOfToday:(NSInteger)countOfToday;

@end
