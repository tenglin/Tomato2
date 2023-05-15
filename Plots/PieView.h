//
//  PieView.h
//  PieChart
//
//  Created by Pavan Podila on 2/21/12.
//  Copyright (c) 2012 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PieView : UIView

@property (nonatomic) BOOL showStroke;
@property (nonatomic) BOOL showLabel;
@property (nonatomic) BOOL showPercentage;
@property (nonatomic) BOOL showShadow;
@property(nonatomic, assign) CGFloat startPieAngle;

//values should be float
- (void)loadWithSliceValues:(NSArray*)sliceValues withSliceColor:(NSArray*)sliceColors;

- (void)reloadData;
- (void)clearUiData;

@end
