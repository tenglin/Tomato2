//
//  TodayTimeViewController.m
//  Tomato
//
//  Created by Lin Teng on 1/6/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "TodayTimeViewController.h"
#import "InfoBoxView.h"
#import "DataManager.h"
#import "NSDate+Utils.h"
#import "UIColor+Utils.h"
#import "PieView.h"
#import "MyUtils.h"

@interface TodayTimeViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet PieView *timeChart;
@property (weak, nonatomic) IBOutlet UIImageView *clockImageView;

@property (nonatomic, strong) InfoBoxView *infoBox1;
@property (nonatomic, strong) InfoBoxView *infoBox2;
@property (nonatomic, strong) InfoBoxView *infoBox3;

@property (nonatomic) NSInteger remainSeconds;
@property (nonatomic) NSInteger pomodoroSeconds;
@property (nonatomic) NSInteger otherSeconds;

@end

@implementation TodayTimeViewController

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
    // Do any additional setup after loading the view from its nib.
    
    /*
    [self reloadChartSourceData];
       
    [self.timeChart setDataSource:self];
    
    [self.timeChart setAnimationSpeed:1.0];
    [self.timeChart setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:24]];
    [self.timeChart setLabelRadius:100];
    [self.timeChart setShowPercentage:YES];
    //[self.timeChart setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];
    [self.timeChart setPieCenter:CGPointMake(150, 150)];
    //[self.timeChart setUserInteractionEnabled:NO];
    [self.timeChart setLabelShadowColor:[UIColor blackColor]];
    
    [self.timeChart setDelegate:self];
    [self.timeChart setDataSource:self];
    [self.timeChart setPieCenter:CGPointMake(150, 150)];
    [self.timeChart setShowPercentage:NO];
    [self.timeChart setLabelColor:[UIColor blackColor]];
    
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:1],
                       [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:1],
                       [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:1],
                       [UIColor colorWithRed:229/255.0 green:66/255.0 blue:115/255.0 alpha:1],
                       [UIColor colorWithRed:148/255.0 green:141/255.0 blue:139/255.0 alpha:1],nil];
    
#warning background frame is not right?
    self.timeChart.backgroundColor = [UIColor clearColor];
    //self.view.backgroundColor = [UIColor clearColor];
     */
    
    self.timeChart.backgroundColor = [UIColor clearColor];    
    self.timeChart.showStroke = NO;
    self.timeChart.showLabel = NO;
    self.timeChart.showPercentage = NO;
    self.timeChart.showShadow = NO;
    self.timeChart.startPieAngle = -M_PI_2;    
    
    self.infoBox1=[[InfoBoxView alloc]initWithFrame:CGRectZero];
    self.infoBox1.boxShadow = YES;
    self.infoBox1.boxCorner = YES;    
    [self.scrollView addSubview:self.infoBox1];
    
    self.infoBox2=[[InfoBoxView alloc]initWithFrame:CGRectZero];
    self.infoBox2.boxShadow = YES;
    self.infoBox2.boxCorner = YES;    
    [self.scrollView addSubview:self.infoBox2];
    
    self.infoBox3=[[InfoBoxView alloc]initWithFrame:CGRectZero];
    self.infoBox3.boxShadow = YES;
    self.infoBox3.boxCorner = YES;    
    [self.scrollView addSubview:self.infoBox3];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [self customSubViewsLayout];
    [self reloadData];        
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];     
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTimeChart:nil];
    [self setScrollView:nil];
    [self setClockImageView:nil];
    [super viewDidUnload];
}

#pragma mark - layout

- (void)customSubViewsLayout
{    
    if (IS_WIDESCREEN) {
        // code for 4-inch screen
        self.clockImageView.frame = CGRectMake(25, 30, 270, 270);
        self.timeChart.frame = CGRectMake(50, 72, 220, 220);
        self.infoBox1.frame = CGRectMake(60, 340, 300, 20);
        self.infoBox2.frame = CGRectMake(60, 373, 300, 20);
        self.infoBox3.frame = CGRectMake(60, 406, 300, 20);
        
        self.infoBox1.font = [UIFont fontWithName:@"Helvetica" size:18];
        self.infoBox2.font = [UIFont fontWithName:@"Helvetica" size:18];
        self.infoBox3.font = [UIFont fontWithName:@"Helvetica" size:18];
        
    } else {
        // code for 3.5-inch screen
        self.clockImageView.frame = CGRectMake(35, 10, 250, 250);
        self.timeChart.frame = CGRectMake(60, 50, 200, 200);
        self.infoBox1.frame = CGRectMake(70, 277, 300, 20);
        self.infoBox2.frame = CGRectMake(70, 307, 300, 20);
        self.infoBox3.frame = CGRectMake(70, 337, 300, 20);
    }
    
    self.scrollView.contentSize = self.timeChart.frame.size;
    [self.infoBox1 initWithTitle:[NSString stringWithFormat:@"pomodoro: "] withBoxColor:[UIColor colorWithHue:1.0/3.0 saturation:0.6 brightness:1.0  alpha:1]];
    [self.infoBox2 initWithTitle:[NSString stringWithFormat:@"coming time: "] withBoxColor:[UIColor colorForLightBlue]];
    [self.infoBox3 initWithTitle:[NSString stringWithFormat:@"other time: "] withBoxColor:[UIColor lightGrayColor]];
}


#pragma mark - PieView

#pragma mark - reloadData and clear

- (void)reloadData
{
    NSDate *now = [NSDate date];
    self.remainSeconds = [now remainSecondsOfDay];
    NSInteger elapsedSeconds =[now elapsedSecondsOfDay];
    self.pomodoroSeconds = [[DataManager sharedInstance] todayPomodoroSeconds];
    self.otherSeconds = elapsedSeconds - self.pomodoroSeconds;// - self.breakSeconds;
    
    [self.infoBox1 setInfoTitle:[NSString stringWithFormat:@"pomodoro: %@", timeDecentDescription(self.pomodoroSeconds)]];
    [self.infoBox2 setInfoTitle:[NSString stringWithFormat:@"coming time: %@", timeDecentDescription(self.remainSeconds)]];
    [self.infoBox3 setInfoTitle:[NSString stringWithFormat:@"other time: %@", timeDecentDescription(self.otherSeconds)]];
    
    // for slices values
    NSMutableArray *valueArray = [NSMutableArray array];
    NSMutableArray *colorArray = [NSMutableArray array];
    
    // fetch values from core data   
    
    NSArray *fetchedObjects = [[DataManager sharedInstance] pomodorosOfDate:now ascending:YES];
    if (fetchedObjects == nil || fetchedObjects.count == 0) {
        [valueArray addObject:[NSNumber numberWithInt:elapsedSeconds]];
        [colorArray addObject:[UIColor lightGrayColor]];
    }
    else {
        NSDate *startOfOtherTime = [now beginningOfDay];
        for (Pomodoro *onePomodoro in fetchedObjects) {
            NSInteger pomodoroSeconds = [[onePomodoro pDuration] intValue];
            NSTimeInterval averageTimeIntervalSinceOtherTime = [onePomodoro.pEndDate timeIntervalSinceDate:startOfOtherTime] - pomodoroSeconds;
            if ( averageTimeIntervalSinceOtherTime > 0) {
                [valueArray addObject:[NSNumber numberWithFloat:averageTimeIntervalSinceOtherTime]];
                [colorArray addObject:[UIColor lightGrayColor]];
            }
            [valueArray addObject:[NSNumber numberWithFloat:pomodoroSeconds]];
            [colorArray addObject:[UIColor colorWithHue:1.0/3.0 saturation:0.6 brightness:1.0  alpha:1]];
            startOfOtherTime = onePomodoro.pEndDate;
        }
        // time after last pomodoro
        NSTimeInterval timeIntervalSinceLastPomodoro = [now timeIntervalSinceDate:startOfOtherTime];
        if (timeIntervalSinceLastPomodoro > 0) {
            [valueArray addObject:[NSNumber numberWithInt:timeIntervalSinceLastPomodoro]];
            [colorArray addObject:[UIColor lightGrayColor]];
        }
    }
    // upcoming time
    [valueArray addObject:[NSNumber numberWithInt:self.remainSeconds]];
    [colorArray addObject:[UIColor colorForLightBlue]];
    
	[self.timeChart loadWithSliceValues:valueArray withSliceColor:colorArray];
}

- (void)clearUiData
{
    //self.timeChart.sliceValues = nil;
    [self.timeChart clearUiData];
}

@end
