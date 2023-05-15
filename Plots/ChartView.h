//
//  BarView.h
//  Tomato
//
//  Created by Lin Teng on 3/1/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BarLayer;
@class ChartView;

@protocol ChartViewDelegate

- (NSInteger)numberOfBarsForChartView:(ChartView*)chartView;
- (BarLayer*)chartView:(ChartView*)chartView layerForBarAtIndex:(NSInteger)index;
- (CGFloat)barWidthForChartView:(ChartView *)chartView;

@end

@interface ChartView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *barValues;

@property (strong, nonatomic) NSMutableArray *historyMonthsArray;
@property (strong, nonatomic) NSMutableArray *historyDaysArray;

- (NSInteger)biggestBarHeight;
- (NSInteger)barLayerHeight;

//- (NSInteger)barWidth;
//- (NSInteger)firstBarOffsetX;

- (void)updateBars;
- (void)clearUiData;
- (void)scrollToToday;

@end
