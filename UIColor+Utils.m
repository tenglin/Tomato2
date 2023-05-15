//
//  UIColor+Utils.m
//  Tomato
//
//  Created by Lin Teng on 3/6/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "UIColor+Utils.h"

static NSInteger greenRandomNumber = 0;

@implementation UIColor (Utils)


+ (UIColor *)colorForGreen0 { return [UIColor colorWithRed:41/255.0 green:138/255.0 blue:8/255.0 alpha:1.0]; }
+ (UIColor *)colorForGreen1 { return [UIColor colorWithRed:4/255.0 green:180/255.0 blue:4/255.0 alpha:1.0]; }
+ (UIColor *)colorForGreen2 { return [UIColor colorWithRed:1/255.0 green:223/255.0 blue:58/255.0 alpha:1.0]; }
+ (UIColor *)colorForGreen3 { return [UIColor colorWithRed:0/255.0 green:255/255.0 blue:0/255.0 alpha:1.0]; }
+ (UIColor *)colorForGreen4 { return [UIColor colorWithRed:0/255.0 green:255/255.0 blue:128/255.0 alpha:1.0]; }

+ (UIColor *)colorForRandomGreen
{
    greenRandomNumber = greenRandomNumber%5;
    switch (greenRandomNumber) {
        case 0:
            greenRandomNumber ++;            
            return [UIColor colorForGreen0];
            break;
        case 1:
            greenRandomNumber ++;
            return [UIColor colorForGreen1];
            break;
        case 2:
            greenRandomNumber ++;            
            return [UIColor colorForGreen2];
            break;
        case 3:
            greenRandomNumber ++;            
            return [UIColor colorForGreen3];
            break;
        case 4:
            greenRandomNumber ++;            
            return [UIColor colorForGreen4];
            break;
        default:
            greenRandomNumber ++;            
            return [UIColor colorForGreen1];
            break;
    }    
}

+ (UIColor *)colorForGreenOfIndex:(NSInteger)index fromSum:(CGFloat)total;
{
    
    return [UIColor colorWithHue:0.33 saturation:0.8 brightness:(0.4 + (0.6*index)/total) alpha:1];
    
    switch (index%5) {
        case 0:            
            return [UIColor colorForGreen0];
            break;
        case 1:           
            return [UIColor colorForGreen1];
            break;
        case 2:            
            return [UIColor colorForGreen2];
            break;
        case 3:           
            return [UIColor colorForGreen3];
            break;
        case 4:           
            return [UIColor colorForGreen4];
            break;
        default:           
            return [UIColor colorForGreen1];         
    }

}

+ (UIColor *)colorForLightBlue
{
    return [UIColor colorWithRed:153.0/255.0 green:204.0/255.0 blue:1.0 alpha:1.0];
}

@end
