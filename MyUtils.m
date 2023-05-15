//
//  MyUtils.m
//  Tomato
//
//  Created by Teng Lin on 13-6-24.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import "MyUtils.h"


NSString* timeDecentDescription(NSInteger seconds)
{
    NSInteger hour = (seconds/60)/60;
    NSInteger minutes = (seconds/60)%60;
    
    if (hour==0) {
        return [NSString stringWithFormat:@"%d min", minutes];
    }
    else if (hour>0) {
        return [NSString stringWithFormat:@"%d hr %d min", hour,minutes];
    }
    else {
        return @"unknown";
    }
}

NSString* timeDecentDescriptionComplex(NSInteger seconds)
{
    NSInteger hour = (seconds/60)/60;
    NSInteger minutes = (seconds/60)%60;
    
    if (hour==0 && minutes > 1) {
        return [NSString stringWithFormat:@"%d minutes", minutes];
    }
    else if (hour==0 && minutes <= 1) {
        return [NSString stringWithFormat:@"%d minute", minutes];
    }
    else if (hour>0 &&minutes <= 1) {
        return [NSString stringWithFormat:@"%dh %dminute", hour,minutes];
    }
    else if (hour>0 &&minutes > 1) {
        return [NSString stringWithFormat:@"%dh %dminutes", hour,minutes];
    }
    else {
        return @"unknown";
    }
}
