//
//  TodayGraphViewController.m
//  Tomato
//
//  Created by Lin Teng on 2/1/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "HistoryGraphViewController.h"
#import "ChartView.h"
#import "DataManager.h"
#import "NSDate+Utils.h"
#import <QuartzCore/QuartzCore.h>

@interface HistoryGraphViewController () {
    CALayer *_leftAxisLayer;
    UIView *_leftAxisView;    
    CALayer *_gridContainerLayer;
    NSInteger _maxHoursInGraph;
}

@property (strong, nonatomic) ChartView *chartView;
@property (strong, nonatomic) NSMutableArray *historyMonthsArray;
@property (strong, nonatomic) NSMutableArray *historyDaysArray;
@property (strong, nonatomic) NSDate *currentDate;

@end

@implementation HistoryGraphViewController
@synthesize historyDaysArray = _historyDaysArray;
@synthesize historyMonthsArray = _historyMonthsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // self.view.frame is not right here
    // Do any additional setup after loading the view from its nib.
    
    // _gridContainerLayer contains background strips
    _gridContainerLayer = [CALayer layer];
    _gridContainerLayer.frame = CGRectZero;
    [self.view.layer addSublayer:_gridContainerLayer];
    
    self.chartView = [[ChartView alloc]initWithFrame:CGRectZero];
    self.chartView.backgroundColor = [UIColor clearColor];    
    [self.view addSubview:self.chartView];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    _gridContainerLayer.frame = self.view.bounds;    
    self.chartView.frame = self.view.bounds;
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {        
    [super viewDidUnload];
}

#pragma mark - getter

- (NSMutableArray*)historyMonthsArray
{
    if (_historyMonthsArray) {
        return  _historyMonthsArray;
    }
    
    [self refreshHistoryMonthsArray];
    return  _historyMonthsArray;
}

- (NSMutableArray*)historyDaysArray
{
    if (_historyDaysArray) {
        return _historyDaysArray;
    }
    
    [self refreshHistoryDaysArray];
    return _historyDaysArray;
}

#pragma mark - refreshData

- (void)refreshHistoryMonthsArray
{        
    if (!self.currentDate) {
        self.currentDate = [NSDate date];
    }
    
    _historyMonthsArray = [[DataManager sharedInstance] historyMonthsUntil:self.currentDate reverse:NO];
    return;
}

- (void)refreshHistoryDaysArray
{        
    if (!self.currentDate) {
        self.currentDate = [NSDate date];
    }
    
    _historyDaysArray = [[DataManager sharedInstance] historyDaysUntil:self.currentDate reverse:NO];
    
    if ([_historyDaysArray count] ==0) {
        [_historyDaysArray addObject:self.currentDate];
    }
    [_historyDaysArray addObject:[self.currentDate advance:0 months:0 weeks:0 days:1 hours:0 minutes:0 seconds:0]];
    [_historyDaysArray addObject:[self.currentDate advance:0 months:0 weeks:0 days:2 hours:0 minutes:0 seconds:0]];
    [_historyDaysArray addObject:[self.currentDate advance:0 months:0 weeks:0 days:3 hours:0 minutes:0 seconds:0]];
    [_historyDaysArray addObject:[self.currentDate advance:0 months:0 weeks:0 days:4 hours:0 minutes:0 seconds:0]];
    [_historyDaysArray addObject:[self.currentDate advance:0 months:0 weeks:0 days:5 hours:0 minutes:0 seconds:0]];
    [_historyDaysArray addObject:[self.currentDate advance:0 months:0 weeks:0 days:6 hours:0 minutes:0 seconds:0]];
    [_historyDaysArray addObject:[self.currentDate advance:0 months:0 weeks:0 days:7 hours:0 minutes:0 seconds:0]];
    return;
}

#pragma mark - reloadData and clear

- (void)reloadData
{
    _maxHoursInGraph = [[DataManager sharedInstance] redundantCeilingForBiggestPomodoroHoursOfAllDay];
    self.currentDate = [NSDate date];
    [self refreshHistoryMonthsArray];
    [self refreshHistoryDaysArray];
    self.chartView.historyMonthsArray = self.historyMonthsArray;
    self.chartView.historyDaysArray = self.historyDaysArray;    
    
    // update UI
    [self.chartView updateBars];
    [self updateBackgroundGrid];
    [self updateLeftAxis];
}

- (void)clearUiData
{
    [self.chartView clearUiData];
}

#pragma mark - scroll to today

- (void)scrollToToday
{    
    [self.chartView scrollToToday];
}

#pragma mark - update left Axis after the chartView updated.

#define L_AXIS_WIDTH 25

- (CGRect)leftAxisRect
{
    return CGRectMake(0, 0 , L_AXIS_WIDTH, self.view.bounds.size.height);
}

- (void)updateLeftAxis
{
    //Layer used as background
    if (_leftAxisLayer) {
        [_leftAxisLayer removeFromSuperlayer];
    }
    _leftAxisLayer = [CALayer layer];
    _leftAxisLayer.frame = [self leftAxisRect];
    _leftAxisLayer.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:0.5].CGColor;
    [self.view.layer addSublayer:_leftAxisLayer];    
    
    //View to add text   
    if (_leftAxisView) {
        [_leftAxisView removeFromSuperview];
    }
    _leftAxisView = [[UIView alloc] initWithFrame:[self leftAxisRect]];
    _leftAxisView.backgroundColor = [UIColor clearColor];
    
    // add text from 1,2,3, to biggest hour    
    for (int i = 1; i <= _maxHoursInGraph; i ++) {
        CGFloat yOfHour = [self.chartView barLayerHeight] - (CGFloat)(self.chartView.biggestBarHeight*i)/(CGFloat)_maxHoursInGraph;
        UIFont *labelfont = [UIFont systemFontOfSize:14];
        NSString *labelText = [NSString stringWithFormat:@"%dh", i];
        CGSize labelSize = [labelText sizeWithFont:labelfont];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, yOfHour-labelSize.height/2, L_AXIS_WIDTH, 20)];
        label.text = labelText;
        label.font = labelfont;
        label.textAlignment = NSTextAlignmentRight;
        label.backgroundColor = [UIColor clearColor];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.0, 1.0);
        [_leftAxisView addSubview:label];
    }    
    [self.view addSubview:_leftAxisView];     
}

- (void)updateBackgroundGrid
{
    // first remove all grid from _gridContainerLayer;
    //[_gridContainerLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];    
    /*
    for (CALayer *oldLayer in _gridContainerLayer.sublayers) {
        [oldLayer removeFromSuperlayer];
    }
     */
    
    // first remove all grid from _gridContainerLayer;
    _gridContainerLayer.sublayers = nil;    
    // draw grid, only draw white layer, self.view's backgroud is gray
    for (int i = 1; i <= _maxHoursInGraph + 1; i++ ) {
        CGFloat yOfHour = [self.chartView barLayerHeight] - (CGFloat)(self.chartView.biggestBarHeight*i)/(CGFloat)_maxHoursInGraph;
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, yOfHour, self.view.frame.size.width, (CGFloat)self.chartView.biggestBarHeight/(CGFloat)(2*_maxHoursInGraph));
        layer.backgroundColor = [UIColor whiteColor].CGColor;                              
        [_gridContainerLayer addSublayer:layer];
    }
}


@end
