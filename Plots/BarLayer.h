//
//  BarStripLayer.h
//  Tomato
//
//  Created by Lin Teng on 3/1/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface BarLayer : CALayer

@property (nonatomic) CGFloat dynamicBarHeight;
@property (nonatomic, strong) NSArray *values;

@property (nonatomic, strong) NSString *topLabel;
//@property (nonatomic, strong) UIFont *topLabelFont;

//@property (nonatomic, strong) UIColor *fillColor;
//@property (nonatomic) BOOL showStroke;
//@property (nonatomic) CGFloat strokeWidth;
//@property (nonatomic, strong) UIColor *strokeColor;

//@property (nonatomic, strong) NSString *popLabel;
//@property (nonatomic, strong) UIFont *popLabelFont;



@end
