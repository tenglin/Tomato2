//
//  MyGlobal.m
//  Tomato
//
//  Created by Teng Lin on 13-1-9.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import "MyGlobal.h"

ClawLogLevel kClawDebugLogLevel = ClawLogLevelNothing;
//ClawLogLevel kClawDebugLogLevel = ClawLogLevelError;
//ClawLogLevel kClawDebugLogLevel = ClawLogLevelInfo;
//ClawLogLevel kClawDebugLogLevel = ClawLogLevelVerbose;

BOOL kAnimationHistoryGraphBarLayer = YES;

//NSString *const MyFirstConstant = @"abc";
//NSString *const MySecondConstant = @"xyz";

NSString *const TOMATO_NOTIFICATION_KEY = @"claw_notification_name";
NSString *const TOMATO_NOTIFICATION_OBJECT = @"com.coolclaw.tomato_notif";

@implementation MyGlobal

+ (void)showClawErrorAlert:(NSInteger)reason
{
    NSString *message = nil;    
    if (reason == kClawErrorCoreData) {
        message = @"CoreData error, please try to delete the app then reinstall the app and restart it.";
    } else if (reason == kClawErrorOther) {
        message = @"We are sorry, but something is wrong!";
    } else {
        message = @"undefined error!";
    }
    
    UIAlertView *errorInfoAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorInfoAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];   
}

@end
