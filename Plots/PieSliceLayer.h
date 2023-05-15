//
//  PieSliceLayer.h
//  PieChart
//
//  Created by Pavan Podila on 2/20/12.
//  Copyright (c) 2012 Pixel-in-Gene. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface PieSliceLayer : CALayer

@property(nonatomic, assign) CGPoint pieCenter;
@property(nonatomic, assign) CGFloat pieRadius;

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;

@property (nonatomic) CGFloat startAngleFrom;
@property (nonatomic) CGFloat endAngleFrom;

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic, strong) UIColor *strokeColor;

@property (nonatomic, strong) NSString *labelText;
@property (nonatomic, strong) UIFont  *labelFont;
@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, strong) UIColor *labelShadowColor;
@property (nonatomic, assign) CGFloat labelRadius;

@property (nonatomic) BOOL showStroke;
@property (nonatomic) BOOL showLabel;

@end
