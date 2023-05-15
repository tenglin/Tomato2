//
//  UIColor+Utils.h
//  Tomato
//
//  Created by Lin Teng on 3/6/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utils)
+ (UIColor *)colorForGreen1;
+ (UIColor *)colorForGreen2;
+ (UIColor *)colorForGreen3;
+ (UIColor *)colorForGreen4;

+ (UIColor *)colorForRandomGreen;
+ (UIColor *)colorForGreenOfIndex:(NSInteger)index fromSum:(CGFloat)total;

+ (UIColor *)colorForLightBlue;

@end
