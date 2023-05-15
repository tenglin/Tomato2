//
//  Timer.h
//  Tomato
//
//  Created by Lin Teng on 1/5/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimerDelegate.h"

@interface Timer : NSObject
{
   
}

+(id)startWithDuration:(NSTimeInterval)duration andCallWhenEnded:(SEL)selector on:(NSObject<TimerDelegate>*)delegate;
+(id)startWithDuration:(NSTimeInterval)duration andCallWhenEnded:(SEL)selector on:(NSObject<TimerDelegate>*)delegate afterDelay:(NSTimeInterval)delay;
+(id)startWithDuration:(NSTimeInterval)duration andCallWhenWarning:(SEL)warningSelector andCallWhenEnded:(SEL)endSelector on:(NSObject<TimerDelegate>*)delegate afterDelay:(NSTimeInterval)delay;

@property (nonatomic) NSTimeInterval remainDuration;

@property (nonatomic) SEL warningSelector;
@property (nonatomic) SEL endSelector;

@property (nonatomic, strong) NSNumber *playWarningSound;

@property (nonatomic) BOOL isPaused;
@property (nonatomic) BOOL isRunning;

-(void)pause;
-(void)resume;
-(void)stop;

-(void)pauseWithoutStopTicking;

-(void)scheduleTicking;


@end
