//
//  BarView.m
//  Tomato
//
//  Created by Lin Teng on 3/1/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "ChartView.h"
#import "BarLayer.h"
#import "DataManager.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+Utils.h"
#import "MyGlobal.h"

#define BAR_OFFSET_X 47
#define BAR_WIDTH 44

#define BAR_LABEL_OFFSET 27
#define B_AXIS_HEIGHT 40
#define TOP_LABEL_SPACE 20

#define kBarPoolSize 20

@interface ChartView() {	
	CALayer *_barsContainerLayer;
    CALayer *_bottomAxisLayer;
    UIView *_bottomAxisView;
    
    NSUInteger _currentBarIndex;
    NSInteger _visibleBarsCount;
    
    NSInteger _maxHoursInGraph;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *scrollContainerView;

@property (strong, nonatomic) NSMutableArray *bars;
@property (strong, nonatomic) NSMutableArray *barLayerPool;

@end

@implementation ChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self doInitialSetup];        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        self.scrollView.delegate = self;
        self.scrollView.autoresizesSubviews = YES;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = YES;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.alwaysBounceVertical = NO;
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollView];
        
        self.scrollContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.scrollContainerView.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:self.scrollContainerView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGRect)scrollContainerViewRect
{
    CGFloat width = [self.historyDaysArray count] * self.barWidth + self.firstBarOffsetX;
    return CGRectMake(0, 0, width, self.bounds.size.height);
}

- (CGRect)bottomAxisRect
{
    CGFloat width = [self.historyDaysArray count] * self.barWidth + self.firstBarOffsetX;
    return CGRectMake(0, self.bounds.size.height - B_AXIS_HEIGHT, width, B_AXIS_HEIGHT);
}

- (NSInteger)barLayerHeight
{
    return self.bounds.size.height - B_AXIS_HEIGHT;
}

- (NSInteger)biggestBarHeight
{
    return [self barLayerHeight] - TOP_LABEL_SPACE;
}

- (NSInteger)barWidth
{
    return BAR_WIDTH;
}

- (NSInteger)firstBarOffsetX
{
    return BAR_OFFSET_X;
}

- (void)updateBars
{
    //ui setup
    self.scrollView.frame = self.bounds;
    self.scrollContainerView.frame = [self scrollContainerViewRect];
    self.scrollView.contentSize = self.scrollContainerView.frame.size;       
    
    if (_barsContainerLayer) {
        [_barsContainerLayer removeFromSuperlayer];
    }
    _barsContainerLayer = [CALayer layer];
	[self.scrollContainerView.layer addSublayer:_barsContainerLayer];
 	_barsContainerLayer.frame = self.scrollContainerView.bounds;
    
    // data
    _maxHoursInGraph = [[DataManager sharedInstance] redundantCeilingForBiggestPomodoroHoursOfAllDay];
    self.barLayerPool = [[NSMutableArray alloc] initWithCapacity:kBarPoolSize];
    self.bars = [NSMutableArray array];
    // to save time and memory, we won't load the layers immediately
    for (NSUInteger i = 0; i < [self.historyDaysArray count]; ++i) {
        [self.bars addObject:[NSNull null]];
    }
    
    // bottom asix
    [self updateBottomAxis];
   
    //  add text "pomodoro time" beside of first bar
    CATextLayer *pomodoroTextLayer = [CATextLayer layer];
    NSString *pomodoroString = @"pomodoro time";
    UIFont *font = [UIFont systemFontOfSize:16];
    CGSize size = [pomodoroString sizeWithFont:font];
    
    pomodoroTextLayer.contentsScale = [[UIScreen mainScreen] scale];
    CGFontRef fontRef = CGFontCreateWithFontName((__bridge CFStringRef)[font fontName]);
    [pomodoroTextLayer setFont:fontRef];
    CFRelease(fontRef);
    [pomodoroTextLayer setFontSize:font.pointSize];
    
    [pomodoroTextLayer setString:pomodoroString];
    [pomodoroTextLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [pomodoroTextLayer setPosition:CGPointMake(BAR_LABEL_OFFSET,_barsContainerLayer.frame.size.height - B_AXIS_HEIGHT - 2)];
    
    [pomodoroTextLayer setAnchorPoint:CGPointMake(0, 0)];
    [pomodoroTextLayer setAlignmentMode:kCAAlignmentCenter];
    [pomodoroTextLayer setForegroundColor:[UIColor blackColor].CGColor];
    [pomodoroTextLayer setBackgroundColor:[UIColor yellowColor].CGColor];
    pomodoroTextLayer.transform = CATransform3DMakeRotation(-M_PI/2, 0, 0, 1);
    [_barsContainerLayer addSublayer:pomodoroTextLayer];
    
    // new solution
    kAnimationHistoryGraphBarLayer = YES;
    // set scrollView content offset, to make sure currentDate sit in right place
    CGFloat offsetX = self.scrollContainerView.frame.size.width - (self.barWidth * 7) - self.bounds.size.width + self.barWidth;
    if ( offsetX < 0) {
        offsetX = 0;
    }        
    self.scrollView.contentOffset = CGPointMake(offsetX, 0);
    
    _currentBarIndex = (self.scrollView.contentOffset.x - BAR_OFFSET_X)/[self barWidth];
    
    [self currentBarIndexDidChange];
    
    return;
    
    /*
    NSInteger hours = [[DataManager sharedInstance] redundantCeilingForBiggestPomodoroHoursOfAllDay];
        
    NSInteger index = 0;
    for (NSDate *day in self.historyDaysArray ) {
        if (index >= ([self.historyDaysArray count] - 7)) {
            // the last seven days is coming day, so skip
            break;
        } 
        BarLayer *bar = [BarLayer layer];
        NSInteger pomodoroSecondsOfDay = [[DataManager sharedInstance] pomodoroSecondsOfDate:day];
        NSMutableArray *values = [NSMutableArray array];
        //strip.strokeColor = [UIColor colorWithWhite:0.25 alpha:1.0];
        //strip.strokeWidth = 0.5;
        bar.frame = CGRectMake(BAR_OFFSET_X+BAR_WIDTH * index + 1, 0, BAR_WIDTH - 2 , [self barLayerHeight]);
        bar.dynamicBarHeight =  (CGFloat)(pomodoroSecondsOfDay * [self biggestBarHeight])/(CGFloat)(hours * 3600) ;
        
        NSArray *fetchedObjects = [[DataManager sharedInstance] pomodorosOfDate:day ascending:YES];
        if (fetchedObjects == nil) {
            // Handle the error.
            bar.values = nil;
        }
        else {            
            for (Pomodoro *onePomodoro in fetchedObjects) {
                NSInteger pomodoroSeconds = [[onePomodoro pDuration] intValue];
                if (pomodoroSecondsOfDay > 0) {
                    [values addObject:[NSNumber numberWithFloat:((CGFloat)pomodoroSeconds)/((CGFloat)pomodoroSecondsOfDay)]];
                }
            }
            bar.values = values;
        }   
        
        bar.topLabel = [NSString stringWithFormat:@"%d", [[DataManager sharedInstance] pomodoroCountOfDate:day]];
        [_barsContainerLayer addSublayer:bar];
        
        // add text "pomodoro time" beside of first strip
        if (index == 0) {
            CATextLayer *pomodoroTextLayer = [CATextLayer layer];
            NSString *pomodoroString = @"pomodoro time";
            UIFont *font = [UIFont systemFontOfSize:16];
            CGSize size = [pomodoroString sizeWithFont:font];
            
            pomodoroTextLayer.contentsScale = [[UIScreen mainScreen] scale];
            CGFontRef fontRef = CGFontCreateWithFontName((__bridge CFStringRef)[font fontName]);
            [pomodoroTextLayer setFont:fontRef];
            CFRelease(fontRef);
            [pomodoroTextLayer setFontSize:font.pointSize];
            
            [pomodoroTextLayer setString:pomodoroString];
            [pomodoroTextLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
            [pomodoroTextLayer setPosition:CGPointMake(BAR_LABEL_OFFSET,_barsContainerLayer.frame.size.height - B_AXIS_HEIGHT - 2)];
            
            [pomodoroTextLayer setAnchorPoint:CGPointMake(0, 0)];
            [pomodoroTextLayer setAlignmentMode:kCAAlignmentCenter];
            [pomodoroTextLayer setForegroundColor:[UIColor blackColor].CGColor];
            [pomodoroTextLayer setBackgroundColor:[UIColor yellowColor].CGColor];
            pomodoroTextLayer.transform = CATransform3DMakeRotation(-M_PI/2, 0, 0, 1);
            [_barsContainerLayer addSublayer:pomodoroTextLayer];
        }
        index ++;        
    }    
     */
}

- (void)updateBottomAxis
{
    // Layer as background
    if (_bottomAxisLayer) {
        [_bottomAxisLayer removeFromSuperlayer];
    }    
    _bottomAxisLayer = [CALayer layer];
    _bottomAxisLayer.frame = [self bottomAxisRect];
    _bottomAxisLayer.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0].CGColor;
    _bottomAxisLayer.shadowRadius = 1;
    _bottomAxisLayer.shadowColor = [UIColor blackColor].CGColor;
    _bottomAxisLayer.shadowOpacity = 0.4;
    _bottomAxisLayer.shadowOffset = CGSizeMake(0, -1);    
    [self.scrollContainerView.layer addSublayer:_bottomAxisLayer];
    
    // View to add text
    if (_bottomAxisView) {
        [_bottomAxisView removeFromSuperview];
    }
    _bottomAxisView = [[UIView alloc] initWithFrame:[self bottomAxisRect]];    
    _bottomAxisView.backgroundColor = [UIColor clearColor];
       
    NSDateFormatter *dateFormatterDay = [[NSDateFormatter alloc] init];
    [dateFormatterDay setDateFormat:@"dd"];
    [dateFormatterDay setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSDateFormatter *dateFormatterMonth = [[NSDateFormatter alloc] init];
    [dateFormatterMonth setDateFormat:@"yyyy-MM"];
    [dateFormatterMonth setTimeZone:[NSTimeZone systemTimeZone]];
        
    // for weekend checking
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange weekdayRange = [calendar maximumRangeOfUnit:NSWeekdayCalendarUnit];      
    
    NSInteger index = 0;
    for (NSDate *day in self.historyDaysArray) {        
        // add day label
        NSString *dayText = [dateFormatterDay stringFromDate:day];
        UIFont *font = [UIFont systemFontOfSize:16];
        CGSize dayTextSize = [dayText sizeWithFont:font];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(BAR_OFFSET_X + BAR_WIDTH * index + BAR_WIDTH/2 - dayTextSize.width/2, 0, dayTextSize.width, 15)];
        label.text = dayText;
        label.font = font;
        label.textAlignment = NSTextAlignmentCenter;
        
        if (index == [self.historyDaysArray count] - 8) {
            // today
            label.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:204.0/255 alpha:1.0];
        }
        
#warning we don't use [NSDate isWeekend] here to avoid to invoke [NSCalendar currentCalendar] many times
        // weekend or not?
        NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:day];
        NSUInteger weekdayOfDate = [components weekday];
        if (weekdayOfDate == weekdayRange.location || weekdayOfDate == weekdayRange.length) {
            // weekend
            label.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
        }
        else {
            label.backgroundColor = [UIColor clearColor];
            //label.shadowColor = [UIColor whiteColor];
            //label.shadowOffset = CGSizeMake(0.0, 1.0);
        }
        
        [_bottomAxisView addSubview:label];
        
        // add year and month label
        // only one month, so display month name below the first historyDay(index ==0)
        if ([self.historyMonthsArray count] <=1 && index == 0) {
            UILabel * monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(BAR_OFFSET_X + BAR_WIDTH * index + BAR_WIDTH/2 - dayTextSize.width/2, 15, BAR_WIDTH*3, 15)];
            monthLabel.text = [dateFormatterMonth stringFromDate:day];
            monthLabel.backgroundColor = [UIColor clearColor];
            monthLabel.shadowColor = [UIColor whiteColor];
            monthLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [_bottomAxisView addSubview:monthLabel];            
        }
        else if ([self.historyMonthsArray count] >1 ) {
            //NSCalendar *currentCalendar = [NSCalendar currentCalendar];
            int calendarComponents = (NSDayCalendarUnit | NSMonthCalendarUnit);
            NSDateComponents *comps = [calendar components:calendarComponents fromDate:day];            
            //int monthNumber = [comps month];
            int dayNumber = [comps day];
            // more than one month,
            // 1, display the month name below the historyDay if it's the first day of month
            // 2, or, display month name below the first historyDay(index ==0) if it's not close to the end of the month
            //    (make sure has space to show month name without conflicting with the name of next month)
            //    for example, if first month has 30 days, and the first historyDay is ... 25, 26, 27, 28 , show month name
            //    if is 29, don't show, since count (30) !> 29 +1
            if (dayNumber == 1 || (index == 0 && [[NSDate allDaysInMonth:day] count] > dayNumber + 1)) {
                UILabel * monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(BAR_OFFSET_X + BAR_WIDTH * index + BAR_WIDTH/2 - dayTextSize.width/2, 15, BAR_WIDTH*3, 15)];
                monthLabel.text = [dateFormatterMonth stringFromDate:day];
                monthLabel.backgroundColor = [UIColor clearColor];
                monthLabel.shadowColor = [UIColor whiteColor];
                monthLabel.shadowOffset = CGSizeMake(0.0, 1.0);
                [_bottomAxisView addSubview:monthLabel];
            }            
        }
        index ++;               
    }    
    [self.scrollContainerView addSubview:_bottomAxisView];
}

#pragma mark - clearUiData;

- (void)clearUiData
{
    if (_bottomAxisLayer) {
        [_bottomAxisLayer removeFromSuperlayer];
        _bottomAxisLayer = nil;
    }
    
    if (_bottomAxisView) {
        [_bottomAxisView removeFromSuperview];
        _bottomAxisLayer = nil;
    }
    
    if (_barsContainerLayer) {
        [_barsContainerLayer removeFromSuperlayer];
        _barsContainerLayer = nil;
    }    
}
#pragma mark - others

- (void)scrollToToday
{
    CGFloat offsetX = self.scrollContainerView.frame.size.width - (self.barWidth * 7) - self.bounds.size.width + self.barWidth;
    if ( offsetX < 0) {
        offsetX = 0;
    }
    CGRect frame = CGRectMake(offsetX, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

#define KEPT_INVISIBLE_COUNT 2 // for one side, total should be KEPT_INVISIBLE_COUNT*2
- (void)currentBarIndexDidChange
{
    CGFloat screenWidth = self.bounds.size.width;
    CGFloat barWidth = [self barWidth];
    _visibleBarsCount = screenWidth / barWidth + 2;
    
    NSInteger leftMostBarIndex = 0;
    NSInteger rightMostBarIndex = 0;
    NSInteger index = 0;
    for (NSInteger i = -KEPT_INVISIBLE_COUNT; i < _visibleBarsCount + KEPT_INVISIBLE_COUNT; i++) {
        index = _currentBarIndex + i;
        if (index < [self.bars count] -7 && (index >= 0)) {
            [self layoutBar:index];
        }
    }
    rightMostBarIndex = index;
    leftMostBarIndex = _currentBarIndex - KEPT_INVISIBLE_COUNT;
    if (leftMostBarIndex < 0) {
        leftMostBarIndex = 0;
    }
    
    // clear out Bars to the left
    for (NSInteger i = 0; i < leftMostBarIndex; i++) {
        if (i<[self.bars count] -37) {
            [self removeBar:i];
        }        
    }
    // clear out Bars to the right
    for (NSInteger i = rightMostBarIndex + 1; i < [self.bars count]; i++) {
        if (i<[self.bars count] -37) {
            [self removeBar:i];
        }
    }
    
    kAnimationHistoryGraphBarLayer = NO;
}

- (void)layoutBar:(NSUInteger)index
{
	BarLayer *barLayer = [self layerForBarAtIndex:index];
    if (!barLayer) {
        // do nothing
        return;
    }
	barLayer.frame = CGRectMake(BAR_OFFSET_X+BAR_WIDTH * index + 1, 0, BAR_WIDTH - 2 , [self barLayerHeight]);
    
    //NSMutableArray *values = [NSMutableArray array];
    NSDate *day = [self.historyDaysArray objectAtIndex:index];
    
    NSInteger pomodoroSecondsOfDay = [[DataManager sharedInstance] pomodoroSecondsOfDate:day];    
    
    barLayer.dynamicBarHeight =  (CGFloat)(pomodoroSecondsOfDay * [self biggestBarHeight])/(CGFloat)(_maxHoursInGraph * 3600) ;
    
//    NSArray *fetchedObjects = [[DataManager sharedInstance] pomodorosOfDate:day ascending:YES];
//    if (fetchedObjects == nil) {
//        // Handle the error.
//        barLayer.values = nil;
//    }
//    else {
//        for (Pomodoro *onePomodoro in fetchedObjects) {
//            NSInteger pomodoroSeconds = [[onePomodoro pDuration] intValue];
//            if (pomodoroSecondsOfDay > 0) {
//                [values addObject:[NSNumber numberWithFloat:((CGFloat)pomodoroSeconds)/((CGFloat)pomodoroSecondsOfDay)]];
//            }
//        }
//        barLayer.values = values;
//    }
    
    barLayer.topLabel = [NSString stringWithFormat:@"%d", [[DataManager sharedInstance] pomodoroCountOfDate:day]];
    
    if (!barLayer.superlayer) {
        [_barsContainerLayer addSublayer:barLayer];
    }    
}

- (BarLayer*)layerForBarAtIndex:(NSUInteger)index
{
	if (index >= [self.bars count]) {
        return nil;
    }
	
	BarLayer *barLayer;
	if ([self.bars objectAtIndex:index] == [NSNull null]) {
        barLayer = [self dequeueBarLayer];
        if (!barLayer) {
            barLayer = [BarLayer layer];
            ClawInfo(@"Create NEW Layer@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        }
        [self.bars replaceObjectAtIndex:index withObject:barLayer];        
        ClawInfo(@"BarLayer loaded for index %d", index);
        
	} else {
		barLayer = [self.bars objectAtIndex:index];
	}
    
	return barLayer;
}

- (void)queueBarLayer:(BarLayer*)layer
{
    if ([self.barLayerPool count] >= kBarPoolSize) {
        return;
    }
    layer.dynamicBarHeight = 0;
    [self.barLayerPool addObject:layer];
}

- (BarLayer*)dequeueBarLayer
{
    BarLayer *layer = [self.barLayerPool lastObject];
    if (layer) {
        [self.barLayerPool removeLastObject];
        ClawInfo(@"Supply from reuse pool##################################################");
    }
    return layer;
}

- (void)removeBar:(NSInteger)index
{
    if ([self.bars objectAtIndex:index] != [NSNull null]) {
        ClawInfo(@"Removing barLayer at index %d", index);
        BarLayer *layer = [self.bars objectAtIndex:index];
        [self queueBarLayer:layer];
        [layer removeFromSuperlayer];
        [self.bars replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //DLog(@"Did Scroll");
	//ClawInfo(@"self.scrollView.contentOffset.x = %f",self.scrollView.contentOffset.x);
	NSUInteger newCurrentBarIndex = (self.scrollView.contentOffset.x - BAR_OFFSET_X)/[self barWidth];
	if (newCurrentBarIndex == _currentBarIndex) return;
	_currentBarIndex = newCurrentBarIndex;
	//_currentPageIndex = newPageIndex;
	
    ClawInfo(@"_currentPhysicalPageIndex =============================== %d", _currentBarIndex);
    
	[self currentBarIndexDidChange];
        
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    ClawInfo(@"scrollViewDidEndDragging");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	//DLog(@"scrollViewDidEndDecelerating");
}

@end
