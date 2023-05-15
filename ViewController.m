//
//  ViewController.m
//  Tomato2
//
//  Created by Teng Lin on 13-11-11.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "UIView+Genie.h"
#import "IASKSettingsReader.h"
#import "SettingsManager.h"
#import "AlertManager.h"
#import "TomatoManager.h"
#import "DataManager.h"
#import "SummaryViewController.h"
#import "TutorialViewController.h"

static NSString *const TOMATO_GREEN_IMG = @"pomodoro1.png";
//static NSString *const TOMATO_MATURE_IMG = @"pomodoro19.png";
static NSString *const BREAK_GREEN_IMG = @"break1.png";

static NSString *const TRASH_COVER_IMG = @"button_trash_cover.png";
static NSString *const TRASH_BODY_IMG = @"button_trash_body.png";

static NSString *const LEAVES1_IMAGE = @"background_leaves1.jpg";
static NSString *const LEAVES2_IMAGE = @"background_leaves2.jpg";

//static NSString *const STR_POMODORO_READY = @"Press to start pomodoro";
//static NSString *const STR_POMODORO_TIME = @"Pomodoro time";
//static NSString *const STR_POMODORO_END = @"Pomodoro ended";
//static NSString *const STR_POMODORO_WARNING = @"Pomodoro will end soon";
//static NSString *const STR_POMODORO_PAUSED = @"Pomodoro paused";
//static NSString *const STR_BREAK_READY = @"Press to start break";
//static NSString *const STR_BREAK_TIME = @"Break time";
//static NSString *const STR_BREAK_END = @"Break ended";
//static NSString *const STR_BREAK_WARNING = @"Break will end soon";
//static NSString *const STR_BREAK_PAUSED = @"Break paused";

static NSString *const STR_POMODORO_READY = @"TAP TO START POMODORO";
static NSString *const STR_POMODORO_TIME = @"POMODORO TIME";
static NSString *const STR_POMODORO_END = @"POMODORO ENDED";
static NSString *const STR_POMODORO_WARNING = @"POMODORO WILL END SOON";
static NSString *const STR_POMODORO_PAUSED = @"POMODORO PAUSED";

static NSString *const STR_BREAK_READY = @"TAP TO START BREAK";
static NSString *const STR_BREAK_TIME = @"BREAK TIME";
static NSString *const STR_BREAK_END = @"BREAK ENDED";
static NSString *const STR_BREAK_WARNING = @"BREAK WILL END SOON";
static NSString *const STR_BREAK_PAUSED = @"BREAK PAUSED";

static NSString *const STR_LONG_BREAK_READY = @"TAP TO START LONG BREAK";
static NSString *const STR_LONG_BREAK_TIME = @"LONG BREAK TIME";
static NSString *const STR_LONG_BREAK_END = @"LONG BREAK ENDED";
static NSString *const STR_LONG_BREAK_WARNING = @"LONG BREAK WILL END SOON";
static NSString *const STR_LONG_BREAK_PAUSED = @"LONG BREAK PAUSED";

static NSString *const STR_CANCEL = @"Cancel";
static NSString *const STR_PLUS_MINUTE = @"+1 Minute";
static NSString *const STR_MINUS_MINUTE = @"-1 Minute";
static NSString *const STR_TERMINATE_POMODORO = @"Terminate Pomodoro";
static NSString *const STR_TERMINATE_BREAK = @"Terminate Break";

static const CGFloat ICON_TRASH_WIDTH = 44.0;
static const CGFloat ICON_TRASH_HEIGHT = 44.0;
static const CGFloat ICON_TRASH_COVER_WIDTH = 44.0;
static const CGFloat ICON_TRASH_COVER_HEIGHT = 11.0;
static const CGFloat ICON_TRASH_BODY_WIDTH = 44.0;
static const CGFloat ICON_TRASH_BODY_HEIGHT = 33.0;

@interface ViewController (){
    NSInteger _dynamicPomodoroImageNumber;
    NSInteger _dynamicBreakImageNumber;
}

@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet UIImageView *pauseImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *invisibleButton;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (strong, nonatomic) UIView *extremeDarkMaskView;

@property (weak, nonatomic) IBOutlet UIButton *summaryButton;
@property (weak, nonatomic) IBOutlet UIButton *adjustTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *interruptionButton;

@property (strong, nonatomic) CALayer *tomatoImageLayer;
@property (strong, nonatomic) CALayer *trashParentLayer;
@property (strong, nonatomic) CALayer *trashCoverLayer;
@property (strong, nonatomic) CALayer *trashBodyLayer;

@property (strong, nonatomic) IASKAppSettingsViewController *appSettingsViewController;
@property (strong, nonatomic) SummaryViewController *summaryViewController;

- (IBAction)showSummary:(id)sender;
- (IBAction)popAdjustTimeMenu:(id)sender;
- (IBAction)popInterruptionMenu:(id)sender;
- (IBAction)showSettingView:(id)sender;
- (IBAction)tomatoTouchDown;
- (IBAction)tomatoTouchUp;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //mask view
    self.maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.maskView.userInteractionEnabled = NO;
    //[[[UIApplication sharedApplication] keyWindow] addSubview:overlayView];
    
    // tomato image
    self.tomatoImageLayer = [CALayer layer];
    
    [self showTomatoImageAccordingToImageName:TOMATO_GREEN_IMG];
	[self.imageView.layer addSublayer:self.tomatoImageLayer];
    [self.imageView bringSubviewToFront:self.timeLabel];
    self.imageView.backgroundColor = [UIColor clearColor];
    
    //    self.imageView.layer.shadowColor = [UIColor greenColor].CGColor;
    //    self.imageView.layer.shadowOffset = CGSizeZero;
    //    self.imageView.layer.shadowRadius = 5;
    //    self.imageView.layer.shadowOpacity = 1.0;
    
    // status label
    //self.statusLabel.font = [UIFont fontWithName:@"Chalkduster" size:24];
    //self.statusLabel.font = [UIFont fontWithName:@"Bebas" size:24];
    //self.statusLabel.font = [UIFont fontWithName:@"Komika Title" size:32];
    //self.statusLabel.font = [UIFont fontWithName:@"OSP-DIN" size:32];
    
    // time label, use FXLabel is performance sufferring!
    self.timeLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    self.timeLabel.shadowOffset = CGSizeMake(0.5f, 1.0f);
    //self.timeLabel.innerShadowColor = [UIColor blackColor];
    //self.timeLabel.innerShadowOffset = CGSizeMake(0.5f, 1.0f);
    //self.timeLabel.oversampling = 8;
    //self.timeLabel.alpha = 0.7;
    
    // play and pause
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
    
    // summaryButton
    self.summaryButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.summaryButton setShowsTouchWhenHighlighted:YES];
    
    // clockButton
    [self.adjustTimeButton setShowsTouchWhenHighlighted:YES];
    
    // trash for termination
    [self.interruptionButton setShowsTouchWhenHighlighted:YES];
    
    self.trashParentLayer = [CALayer layer];
    [self.interruptionButton.layer addSublayer:self.trashParentLayer];
    
    self.trashCoverLayer = [CALayer layer];
    self.trashCoverLayer.contents = (__bridge id)([UIImage imageNamed:TRASH_COVER_IMG].CGImage);
    [self.trashParentLayer addSublayer:self.trashCoverLayer];
    
    self.trashBodyLayer = [CALayer layer];
    self.trashBodyLayer.contents = (__bridge id)([UIImage imageNamed:TRASH_BODY_IMG].CGImage);
    [self.trashParentLayer addSublayer:self.trashBodyLayer];
    
    // for extreme dark theme
    self.extremeDarkMaskView = [[UIView alloc] initWithFrame:CGRectZero];
    self.extremeDarkMaskView.userInteractionEnabled = NO;
    self.extremeDarkMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.view addSubview:self.extremeDarkMaskView];
    
    // Settings Observer
#warning remove observer in viewDidUnload, to make sure only register once, or use other method?
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
    
    //Pomodoro Ready? or Restore tomato status from disk
    //[[TomatoManager sharedInstance] readyOrRestoreFromDisk];
    ClawInfo(@"viewDidLoad enddddddddddd");
}

- (void)viewDidUnload
{
    // remove observer
    // what's the others should do here
    [self setPlayImageView:nil];
    [self setSummaryButton:nil];
    [self setAdjustTimeButton:nil];
    [self setInterruptionButton:nil];
    [self setStatusLabel:nil];
    [self setMaskView:nil];
    [self setImageView:nil];
    [self setSettingButton:nil];
    [self setPauseImageView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self customSubViewsLayout];
    [self customViewElementsTheme];
    self.maskView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tomatoImageLayer.anchorPoint = CGPointMake(0.5, 1);
	self.tomatoImageLayer.bounds = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
	self.tomatoImageLayer.position = CGPointMake(self.imageView.frame.size.width/2, self.imageView.frame.size.height);
    
    self.trashParentLayer.anchorPoint = CGPointMake(0.5, 1);
    self.trashParentLayer.bounds = CGRectMake(0, 0, ICON_TRASH_WIDTH, ICON_TRASH_HEIGHT);
    self.trashParentLayer.position = CGPointMake(ICON_TRASH_WIDTH/2, ICON_TRASH_HEIGHT);
    self.trashCoverLayer.anchorPoint = CGPointMake(1, 1);
    self.trashCoverLayer.bounds = CGRectMake(0, 0, ICON_TRASH_COVER_WIDTH, ICON_TRASH_COVER_HEIGHT);
	self.trashCoverLayer.position = CGPointMake(ICON_TRASH_COVER_WIDTH, ICON_TRASH_COVER_HEIGHT);
    self.trashBodyLayer.anchorPoint = CGPointMake(0.5, 1);
    self.trashBodyLayer.bounds = CGRectMake(0, 0, ICON_TRASH_BODY_WIDTH, ICON_TRASH_BODY_HEIGHT);
	self.trashBodyLayer.position = CGPointMake(ICON_TRASH_BODY_WIDTH/2, ICON_TRASH_HEIGHT);
    
    [self updateTodayCompletedCountWithAnimation:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - other methods

#define POMODORO_IMAGES_COUNT 19
#define BREAK_IMAGES_COUNT 10

- (void)showTomatoImageAccordingToImageName:(NSString*)imageName
{
    if ([imageName isEqualToString:TOMATO_GREEN_IMG]) {
        self.tomatoImageLayer.contents = (__bridge id)([UIImage imageNamed:TOMATO_GREEN_IMG].CGImage);
        _dynamicPomodoroImageNumber = 1;
        _dynamicBreakImageNumber = -1;
    }
    else if ([imageName isEqualToString:BREAK_GREEN_IMG]) {
        self.tomatoImageLayer.contents = (__bridge id)([UIImage imageNamed:BREAK_GREEN_IMG].CGImage);
        _dynamicPomodoroImageNumber = -1;
        _dynamicBreakImageNumber = 1;
    }
}

- (void)showDynamicImageAccordingToRemainingSeconds:(CGFloat)remainingSeconds
{
    CGFloat percentage;
    NSInteger imageNumber;
    if ([[TomatoManager sharedInstance] isPomodoroRunningStatus]) {
        if ([TomatoManager sharedInstance].currentPomodoro.pDuration.floatValue > 0) {
            percentage = ([TomatoManager sharedInstance].currentPomodoro.pDuration.floatValue-remainingSeconds)/[TomatoManager sharedInstance].currentPomodoro.pDuration.floatValue;
        }
        else {
            percentage = 1;
        }
        
        if (percentage < 0) {
            percentage = 0;
        }
        if (percentage > 1) {
            percentage = 1;
        }
        imageNumber = (percentage*((POMODORO_IMAGES_COUNT -1)*15 + 1) +1)/15 + 1;
        if (imageNumber > POMODORO_IMAGES_COUNT) {
            imageNumber = POMODORO_IMAGES_COUNT;
        }
        if (imageNumber < 1) {
            imageNumber = POMODORO_IMAGES_COUNT;
        }
        if (_dynamicPomodoroImageNumber != imageNumber) {
            ClawInfo(@"View imageNumber: %d", imageNumber);
            self.tomatoImageLayer.contents = (__bridge id)([UIImage imageNamed:[NSString stringWithFormat:@"pomodoro%d.png", imageNumber]].CGImage);
            _dynamicPomodoroImageNumber = imageNumber;
            _dynamicBreakImageNumber = -1;
        }
    }
    else if ([[TomatoManager sharedInstance] isBreakRunningStatus]) {
        if ([TomatoManager sharedInstance].currentPomodoro.bDuration.floatValue > 0) {
            percentage = ([TomatoManager sharedInstance].currentPomodoro.bDuration.floatValue-remainingSeconds)/[TomatoManager sharedInstance].currentPomodoro.bDuration.floatValue;
        }
        else {
            percentage = 1;
        }
        if (percentage < 0) {
            percentage = 0;
        }
        if (percentage > 1) {
            percentage = 1;
        }
        imageNumber = (percentage*((BREAK_IMAGES_COUNT -1)*3 + 1) +1)/3 + 1;
        if (imageNumber > BREAK_IMAGES_COUNT) {
            imageNumber = BREAK_IMAGES_COUNT;
        }
        if (imageNumber < 1) {
            imageNumber = BREAK_IMAGES_COUNT;
        }
        if (_dynamicBreakImageNumber != imageNumber) {
            ClawInfo(@"View imageNumber: %d", imageNumber);
            self.tomatoImageLayer.contents = (__bridge id)([UIImage imageNamed:[NSString stringWithFormat:@"break%d.png", imageNumber]].CGImage);
            _dynamicBreakImageNumber = imageNumber;
            _dynamicPomodoroImageNumber = -1;
        }
    }
}

- (void)updateScreenAutolockPolicy
{
    if (![SettingsManager sharedInstance].disableAutolock) {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        return;
    }
    if ([TomatoManager sharedInstance].timer.isPaused) {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        return;
    }
    switch ([TomatoManager sharedInstance].tomatoStatus) {
        case TomatoPomodoroStatus:
        case TomatoPomodoroWarningStatus:
        case TomatoPomodoroEndStatus:
        case TomatoBreakStatus:
        case TomatoBreakWarningStatus:
        case TomatoBreakEndStatus:
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            return;
            break;
        case TomatoPomodoroReadyStatus:
        case TomatoBreakReadyStatus:
        default:
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            break;
    }
}

- (NSString*)shortOrLongBreakString:(NSString*)shortBreakString
{
    if ([[DataManager sharedInstance] todayPomodoroCount]%[SettingsManager sharedInstance].longBreakEveryPomodoro != 0) {
        return shortBreakString;
    }
    
    // else, should be long break
    if ([shortBreakString isEqualToString:STR_BREAK_READY]) {
        return STR_LONG_BREAK_READY;
    }
    else if ([shortBreakString isEqualToString:STR_BREAK_TIME]) {
        return STR_LONG_BREAK_TIME;
    }
    else if ([shortBreakString isEqualToString:STR_BREAK_END]) {
        return STR_LONG_BREAK_END;
    }
    else if ([shortBreakString isEqualToString:STR_BREAK_WARNING]) {
        return STR_LONG_BREAK_WARNING;
    }
    else if ([shortBreakString isEqualToString:STR_BREAK_PAUSED]) {
        return STR_LONG_BREAK_PAUSED;
    }
    else {
        // only for wrong case, shoud not go here
        return shortBreakString;
    }
}

- (void)updateStatusLabelWithText:(NSString*)text animated:(BOOL)animation
{
    [self.statusLabel.layer removeAllAnimations];
    if (!animation) {
        self.statusLabel.text = text;
        return;
    }
    // else, animation
    CATransition *transitionAnimation = [CATransition animation];
    transitionAnimation.duration = 0.5;
    transitionAnimation.type = kCATransitionFade;
    transitionAnimation.startProgress = 0;
    transitionAnimation.endProgress = 1.0;
    transitionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.statusLabel.layer addAnimation:transitionAnimation forKey:@"changeTextTransition"];
    // Change the text
    self.statusLabel.text = text;
}

- (void)updateTimeLabelForDuration:(NSInteger)duration {
    if (duration <=60) {
        //self.timeLabel.textColor = [UIColor yellowColor];
        //self.timeLabel.font = [UIFont boldSystemFontOfSize:64];
        self.timeLabel.font = [UIFont fontWithName:@"OSP-DIN" size:64];
        NSString *string = [NSString stringWithFormat:@" %d\"", duration];
        self.timeLabel.text = string;
    }
    else{
        //self.timeLabel.textColor = [UIColor blackColor];
        //self.timeLabel.font = [UIFont boldSystemFontOfSize:50];
        self.timeLabel.font = [UIFont fontWithName:@"OSP-DIN" size:50];
        NSString *string = [NSString stringWithFormat: @"%d:%02d", duration / 60, duration % 60];
        self.timeLabel.text = string;
    }
}

- (void)updateTodayCompletedCountWithAnimation:(BOOL)animation
{
    [self.summaryButton setTitle:[NSString stringWithFormat:@"%d", [[DataManager sharedInstance] todayPomodoroCount]] forState:UIControlStateNormal];
    if (!animation) {
        return;
    }
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = 0.5;
    pulseAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.2];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    [self.summaryButton.layer addAnimation:pulseAnimation forKey:nil];
}

- (void)customSubViewsLayout
{
    if (IS_WIDESCREEN) {
        // code for 4-inch screen
        self.settingButton.frame = CGRectMake(282, 20, 18, 19);
        self.statusLabel.frame = CGRectMake(0, 50, 320, 44);
        self.statusLabel.font = [UIFont fontWithName:@"OSP-DIN" size:32];
        
        self.imageView.frame = CGRectMake(45, 141, 230, 230);
        self.invisibleButton.frame = CGRectMake(45, 141, 230, 230);
        
        self.playImageView.frame = CGRectMake(121, 228, 90, 90);
        self.pauseImageView.frame = CGRectMake(115, 233, 90, 90);
        
        self.summaryButton.frame = CGRectMake(45, 460, 44, 44);
        self.adjustTimeButton.frame = CGRectMake(138, 460, 44, 44);
        self.interruptionButton.frame = CGRectMake(233, 460, 44, 44);
        
    } else {
        // code for 3.5-inch screen
        self.settingButton.frame = CGRectMake(282, 15, 18, 19);
        self.statusLabel.frame = CGRectMake(0, 35, 320, 44);
        self.statusLabel.font = [UIFont fontWithName:@"OSP-DIN" size:30];
        
        self.imageView.frame = CGRectMake(50, 105, 220, 220); //CGRectMake(45, 110, 230, 240);
        self.invisibleButton.frame = CGRectMake(50, 105, 220, 220);
        
        self.playImageView.frame = CGRectMake(125, 188, 85, 85);
        self.pauseImageView.frame = CGRectMake(118, 193, 85, 85);
        
        self.summaryButton.frame = CGRectMake(45, 385, 44, 44);
        self.adjustTimeButton.frame = CGRectMake(138, 385, 44, 44);
        self.interruptionButton.frame = CGRectMake(233, 385, 44, 44);
    }
}

- (void)customViewElementsTheme
{
    self.extremeDarkMaskView.hidden = YES;
    switch ([SettingsManager sharedInstance].theme) {
            /*
             case TomatoThemeLeaves2:
             ///self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:LEAVES2_IMAGE]];
             self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_gray3.png"]];
             break;
             case TomatoThemeLeaves1:
             ///self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:LEAVES1_IMAGE]];
             self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_gray1.png"]];
             break;
             case TomatoThemeExtremeDark:
             //self.view.backgroundColor = [UIColor colorWithRed:139.0/255 green:169.0/255 blue:135.0/255 alpha:1.0];
             self.view.backgroundColor = [UIColor blackColor];
             self.extremeDarkMaskView.frame = self.view.bounds;
             self.extremeDarkMaskView.hidden = NO;
             break;
             */
        case TomatoThemeBlack:
            self.view.backgroundColor = [UIColor blackColor];
            break;
        case TomatoThemeMoss:
            self.view.backgroundColor = [UIColor colorWithRed:43.0/255 green:62.0/255 blue:56.0/255 alpha:1.0];
            break;
        case TomatoThemeIron:
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_iron.png"]];
            break;
        case TomatoThemeGray:
        default:
            self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
            break;
            break;
    }
}

- (void)playTomatoImageWarningAnimation
{
    if ([self.tomatoImageLayer animationForKey:@"WarningAnimationKey"]) {
        //ClawInfo(@"NOT start new animation!!!-----!!!!!_###########");
        return;
    }
    
    //ClawInfo(@"Start new animation!!!-----!!!!!_____!!NEWWWWWWWWWWWWWWW");
    
    [self.tomatoImageLayer removeAllAnimations];
    self.tomatoImageLayer.anchorPoint = CGPointMake(0.5, 0.5);
    self.tomatoImageLayer.position = CGPointMake(self.imageView.frame.size.width/2, self.imageView.frame.size.height/2);
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = .3;
    pulseAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    pulseAnimation.toValue = [NSNumber numberWithFloat:1.06];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = FLT_MAX;
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void){
        self.tomatoImageLayer.anchorPoint = CGPointMake(0.5, 1.0);
        self.tomatoImageLayer.position = CGPointMake(self.imageView.frame.size.width/2, self.imageView.frame.size.height);
    }];
    
    [self.tomatoImageLayer addAnimation:pulseAnimation forKey:@"WarningAnimationKey"];
    [CATransaction commit];
}

- (void)playAnimationThenStartingForTomatoStatus:(TomatoStatus)tomatoStatus
{
    if (!self.tomatoImageLayer) {
        return;
    }
    
    self.tomatoImageLayer.anchorPoint = CGPointMake(0.5, 1.0);
    self.tomatoImageLayer.position = CGPointMake(self.imageView.frame.size.width/2, self.imageView.frame.size.height);
    
    // animations for tomatoImageLayer
    CABasicAnimation *animationBoundsBigFat = [CABasicAnimation animationWithKeyPath:@"bounds"];
	animationBoundsBigFat.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.imageView.frame.size.width+30, self.imageView.frame.size.height-50)];
	animationBoundsBigFat.duration = 0.25;
    //animationBigFat.beginTime = 0;
    animationBoundsBigFat.fillMode = kCAFillModeForwards;
	animationBoundsBigFat.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationBoundsBigThin = [CABasicAnimation animationWithKeyPath:@"bounds"];
	animationBoundsBigThin.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.imageView.frame.size.width-10, self.imageView.frame.size.height+10)];
	animationBoundsBigThin.duration = 0.25;
    animationBoundsBigThin.beginTime = 0.25;
    animationBoundsBigThin.fillMode = kCAFillModeForwards;
	animationBoundsBigThin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationBoundsSmallFat = [CABasicAnimation animationWithKeyPath:@"bounds"];
	animationBoundsSmallFat.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.imageView.frame.size.width+7, self.imageView.frame.size.height-7)];
	animationBoundsSmallFat.duration = 0.25;
    animationBoundsSmallFat.beginTime = 0.5;
    animationBoundsSmallFat.fillMode = kCAFillModeForwards;
	animationBoundsSmallFat.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationBoundsOrigin = [CABasicAnimation animationWithKeyPath:@"bounds"];
	animationBoundsOrigin.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height)];
	animationBoundsOrigin.duration = 0.25;
    animationBoundsOrigin.beginTime = 0.75;
    animationBoundsOrigin.fillMode = kCAFillModeForwards;
	animationBoundsOrigin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationPositionDown = [CABasicAnimation animationWithKeyPath:@"position"];
	animationPositionDown.toValue = [NSValue valueWithCGPoint:CGPointMake(self.imageView.frame.size.width/2, self.imageView.frame.size.height-10)];
	animationPositionDown.duration = 0.25;
    animationPositionDown.beginTime = 0.25;
    animationPositionDown.fillMode = kCAFillModeForwards;
	animationPositionDown.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationPositionOrigin = [CABasicAnimation animationWithKeyPath:@"position"];
	animationPositionOrigin.toValue = [NSValue valueWithCGPoint:CGPointMake(self.imageView.frame.size.width/2, self.imageView.frame.size.height)];
	animationPositionOrigin.duration = 0.25;
    animationPositionOrigin.beginTime = 0.5;
    animationPositionOrigin.fillMode = kCAFillModeForwards;
	animationPositionOrigin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *groupForTomatoImage = [CAAnimationGroup animation];
    groupForTomatoImage.animations = [NSArray arrayWithObjects:animationBoundsBigFat, animationBoundsBigThin, animationBoundsSmallFat, animationBoundsOrigin, animationPositionDown, animationPositionOrigin, nil];
    groupForTomatoImage.duration = 1.0;
    //group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // animations for timeLabel.layer
    CABasicAnimation *animationDown = [CABasicAnimation animationWithKeyPath:@"position"];
	animationDown.toValue = [NSValue valueWithCGPoint:CGPointMake(self.timeLabel.frame.origin.x + self.timeLabel.frame.size.width/2.0, self.timeLabel.frame.origin.y + self.timeLabel.frame.size.height/2.0 + 2.0 )];
	animationDown.duration = 0.25;
    animationDown.beginTime = 0.0;
    animationDown.fillMode = kCAFillModeForwards;
	animationDown.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationUp = [CABasicAnimation animationWithKeyPath:@"position"];
	animationUp.toValue = [NSValue valueWithCGPoint:CGPointMake(self.timeLabel.frame.origin.x + self.timeLabel.frame.size.width/2.0, self.timeLabel.frame.origin.y + self.timeLabel.frame.size.height/2.0 - 8)];
	animationUp.duration = 0.25;
    animationUp.beginTime = 0.25;
    animationUp.fillMode = kCAFillModeForwards;
	animationUp.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationOrigin = [CABasicAnimation animationWithKeyPath:@"position"];
	animationOrigin.toValue = [NSValue valueWithCGPoint:CGPointMake(self.timeLabel.frame.origin.x + self.timeLabel.frame.size.width/2.0, self.timeLabel.frame.origin.y + self.timeLabel.frame.size.height/2.0)];
	animationOrigin.duration = 0.25;
    animationOrigin.beginTime = 0.5;
    animationOrigin.fillMode = kCAFillModeForwards;
	animationOrigin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *groupForTimeLabel = [CAAnimationGroup animation];
    groupForTimeLabel.animations = [NSArray arrayWithObjects: animationDown, animationUp, animationOrigin, nil];
    groupForTimeLabel.duration = 1.0;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
#warning endIgnoring at beginning or other enter point to ensure endIgnoring
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if (tomatoStatus == TomatoPomodoroReadyStatus) {
            [[TomatoManager sharedInstance] startPomodoroNow];
        }
        else if (tomatoStatus == TomatoBreakReadyStatus) {
            [[TomatoManager sharedInstance] startBreakNow];
        }
    }];
    [self.tomatoImageLayer addAnimation:groupForTomatoImage forKey:nil];
    [self.timeLabel.layer addAnimation:groupForTimeLabel forKey:nil];
    [CATransaction commit];
    
    if (tomatoStatus == TomatoPomodoroReadyStatus) {
        [[AlertManager sharedInstance] playPomodoroStart];
    }
    return;
}

- (IBAction)tomatoTouchDown
{
    switch ([TomatoManager sharedInstance].tomatoStatus) {
        case TomatoPomodoroReadyStatus:
            [self playAnimationThenStartingForTomatoStatus:TomatoPomodoroReadyStatus];
            self.maskView.hidden = YES;
            self.playImageView.hidden = YES;
            self.pauseImageView.hidden = YES;
            break;
        case TomatoPomodoroStatus:
        case TomatoPomodoroWarningStatus:
        case TomatoBreakStatus:
        case TomatoBreakWarningStatus:
            if ([TomatoManager sharedInstance].timer.isPaused) {
                [[TomatoManager sharedInstance] resumeTimer];
            }
            else if ((NSInteger)[TomatoManager sharedInstance].timer.remainDuration > 0){
                [[TomatoManager sharedInstance] pauseTimer];
                [self showCommonPauseScreen];
            }
            break;
        case TomatoPomodoroEndStatus:
            // pause animation?
            break;
        case TomatoBreakReadyStatus:
            [self playAnimationThenStartingForTomatoStatus:TomatoBreakReadyStatus];
            self.maskView.hidden = YES;
            self.playImageView.hidden = YES;
            self.pauseImageView.hidden = YES;
            break;
        case TomatoBreakEndStatus:
            // pause animation?
            break;
        default:
            break;
    }
}

- (IBAction)tomatoTouchUp
{
    return;
    //    switch ([TomatoManager sharedInstance].tomatoStatus) {
    //        case TomatoPomodoroReadyStatus:
    //            // do nothing, since when the touch down animaton complete, will start the Pomodoro and play sound
    //            break;
    //        case TomatoPomodoroStatus:
    //            break;
    //        case TomatoPomodoroEndStatus:
    //            // pause animation?
    //            break;
    //        case TomatoBreakReadyStatus:
    //            break;
    //        case TomatoBreakStatus:
    //            break;
    //        case TomatoBreakEndStatus:
    //            // pause ?
    //            break;
    //        default:
    //            break;
    //    }
}

// just to eliminate  screen flash, so set it same as ready screen
- (void)showWelcomeScreen
{
    [self showPomodoroReadyScreenWithAnimation:YES];
}

- (void)showPomodoroReadyScreenWithAnimation:(BOOL)animation
{
    [self updateScreenAutolockPolicy];
    [self updateStatusLabelWithText:STR_POMODORO_READY animated:animation];
    [self updateTimeLabelForDuration:[TomatoManager sharedInstance].currentPomodoro.pDuration.intValue];
    [self updateTodayCompletedCountWithAnimation:NO];
    [self.tomatoImageLayer removeAllAnimations];
    [self showTomatoImageAccordingToImageName:TOMATO_GREEN_IMG];
    
    self.maskView.hidden = NO;
    
    // animation elements
    self.imageView.hidden = NO;
    self.imageView.alpha = 0.0;
    
    self.timeLabel.hidden = NO;
    self.timeLabel.alpha = 0.0;
    
    self.pauseImageView.hidden = YES;
    self.playImageView.hidden = NO;
    self.playImageView.alpha = 0.0;
    
    // others setup before animation
    self.adjustTimeButton.enabled = NO;
    self.interruptionButton.enabled = NO;
    
    if (!animation) {
        self.imageView.alpha = 1.0;
        self.timeLabel.alpha = 1.0;
        self.playImageView.alpha = 1.0;
        self.adjustTimeButton.enabled = YES;
        self.interruptionButton.enabled = YES;
        return;
    }
    // else, animation
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.7
                     animations:^{
                         self.imageView.alpha = 1.0;
                         self.timeLabel.alpha = 1.0;
                     }
     
                     completion:^(BOOL  completed){
                         self.adjustTimeButton.enabled = YES;
                         self.interruptionButton.enabled = YES;
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              self.playImageView.alpha = 1.0;
                                          }
                                          completion:^(BOOL  completed){
                                              [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                          }];
                     }];
}

- (void)showPomodoroScreen {
    [self updateScreenAutolockPolicy];
    [self updateStatusLabelWithText:STR_POMODORO_TIME animated:YES];
    [self updateTimeLabelForDuration:[TomatoManager sharedInstance].timer.remainDuration];
    [self updateTodayCompletedCountWithAnimation:NO];
    [self.tomatoImageLayer removeAllAnimations];
    [self showDynamicImageAccordingToRemainingSeconds:[TomatoManager sharedInstance].timer.remainDuration];
    self.maskView.hidden = YES;
    self.imageView.hidden = NO;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
    self.adjustTimeButton.enabled = YES;
    self.interruptionButton.enabled = YES;
}

- (void)showPomodoroWarningScreen:(NSNumber*)playSound;
{
    [self updateStatusLabelWithText:STR_POMODORO_WARNING animated:NO];
    if (playSound.boolValue) {
        [[AlertManager sharedInstance] playPomodoroWarning];
    }
    [self playTomatoImageWarningAnimation];
}

- (void)showPomodoroEndScreen {
    ClawInfo(@"animateWithDuration completionnnnnnnnnnnn1");
    [self updateStatusLabelWithText:STR_POMODORO_END animated:YES];
    [self.tomatoImageLayer removeAllAnimations];
    [[AlertManager sharedInstance] playPomodoroEnd];
    [self updateTodayCompletedCountWithAnimation:YES];
    
    self.maskView.hidden = YES;
    self.imageView.hidden = NO;
    self.timeLabel.hidden = NO;
    self.imageView.alpha = 1.0;
    self.timeLabel.alpha = 1.0;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
    self.adjustTimeButton.enabled = NO;
    self.interruptionButton.enabled = NO;
    ClawInfo(@"animateWithDuration completionnnnnnnnnnnn2");
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:END_ANIMATION_SECONDS
                     animations:^{
                         ClawInfo(@"animateWithDuration completionnnnnnnnnnnn3");
                         self.imageView.alpha = 0.0;
                         self.timeLabel.alpha = 0.0;
                     }
                     completion:^(BOOL  completed){
                         ClawInfo(@"animateWithDuration completionnnnnnnnnnnn4");
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         self.imageView.alpha = 1.0;
                         self.timeLabel.alpha = 1.0;
                         [self showTomatoImageAccordingToImageName:BREAK_GREEN_IMG];
                         if ([TomatoManager sharedInstance].runningInBackground) {
                             // come back from background, so replay, and discard below code.
                             return;
                         }
                         if ([SettingsManager sharedInstance].autoBreak) {
                             [[TomatoManager sharedInstance] startBreakNow];
                         }
                         else {
                             [[TomatoManager sharedInstance] readyToBreakWithUiAnimation:YES];
                         }
                     }];
}

- (void)showPomodoroPauseScreen
{
    [self updateScreenAutolockPolicy];
    [self updateStatusLabelWithText:STR_POMODORO_PAUSED animated:YES];
    [self.tomatoImageLayer removeAllAnimations];
}

- (void)showPomodoroResumeScreen
{
    [self updateScreenAutolockPolicy];
    if ([TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroStatus) {
        [self updateStatusLabelWithText:STR_POMODORO_TIME animated:YES];
    }
    else if ([TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroWarningStatus) {
        [self updateStatusLabelWithText:STR_POMODORO_WARNING animated:NO];
        [self playTomatoImageWarningAnimation];
    }
    self.maskView.hidden = YES;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
}

- (void)showBreakReadyScreenWithAnimation:(BOOL)animation;
{
    [self updateScreenAutolockPolicy];
    [self updateStatusLabelWithText:[self shortOrLongBreakString:STR_BREAK_READY] animated:animation];
    [self updateTimeLabelForDuration:[TomatoManager sharedInstance].currentPomodoro.bDuration.intValue];
    [self updateTodayCompletedCountWithAnimation:NO];
    [self.tomatoImageLayer removeAllAnimations];
    [self showTomatoImageAccordingToImageName:BREAK_GREEN_IMG];
    self.maskView.hidden = NO;
    
    // animation elements
    self.imageView.hidden = NO;
    self.imageView.alpha = 0.0;
    
    self.timeLabel.hidden = NO;
    self.timeLabel.alpha = 0.0;
    
    self.pauseImageView.hidden = YES;
    self.playImageView.hidden = NO;
    self.playImageView.alpha = 0.0;
    
    // others setup before animation
    self.adjustTimeButton.enabled = NO;
    self.interruptionButton.enabled = NO;
    
    if (!animation) {
        self.imageView.alpha = 1.0;
        self.timeLabel.alpha = 1.0;
        self.adjustTimeButton.enabled = YES;
        self.interruptionButton.enabled = YES;
        self.playImageView.alpha = 1.0;
        return;
    }
    //else animation
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.7
                     animations:^{
                         self.imageView.alpha = 1.0;
                         self.timeLabel.alpha = 1.0;
                     }
     
                     completion:^(BOOL  completed){
                         self.adjustTimeButton.enabled = YES;
                         self.interruptionButton.enabled = YES;
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              self.playImageView.alpha = 1.0;
                                          }
                                          completion:^(BOOL  completed){
                                              [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                          }];
                     }];
}

- (void)showBreakScreen {
    [self updateScreenAutolockPolicy];
    [self updateStatusLabelWithText:[self shortOrLongBreakString:STR_BREAK_TIME] animated:YES];
    [self updateTimeLabelForDuration:[TomatoManager sharedInstance].timer.remainDuration];
    [self updateTodayCompletedCountWithAnimation:NO];
    [self.tomatoImageLayer removeAllAnimations];
    [self showDynamicImageAccordingToRemainingSeconds:[TomatoManager sharedInstance].timer.remainDuration];
    self.maskView.hidden = YES;
    self.imageView.hidden = NO;
    self.timeLabel.hidden = NO;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
    self.adjustTimeButton.enabled = YES;
    self.interruptionButton.enabled = YES;
}

- (void)showBreakWarningScreen:(NSNumber*)playSound;
{
    [self updateStatusLabelWithText:[self shortOrLongBreakString:STR_BREAK_WARNING] animated:NO];
    if (playSound.boolValue) {
        [[AlertManager sharedInstance] playBreakWarning];
    }
    [self playTomatoImageWarningAnimation];
}

- (void)showBreakEndScreen
{
    [self updateStatusLabelWithText:[self shortOrLongBreakString:STR_BREAK_END] animated:YES];
    [self.tomatoImageLayer removeAllAnimations];
    [[AlertManager sharedInstance] playBreakEnd];
    [self updateTodayCompletedCountWithAnimation:NO];
    
    self.maskView.hidden = YES;
    self.imageView.hidden = NO;
    self.timeLabel.hidden = NO;
    self.imageView.alpha = 1.0;
    self.timeLabel.alpha = 1.0;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
    self.adjustTimeButton.enabled = NO;
    self.interruptionButton.enabled = NO;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:END_ANIMATION_SECONDS
                     animations:^{
                         self.imageView.alpha = 0.0;
                         self.timeLabel.alpha = 0.0;
                     }
                     completion:^(BOOL  completed){
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         self.imageView.alpha = 1.0;
                         self.timeLabel.alpha = 1.0;
                         [self showTomatoImageAccordingToImageName:TOMATO_GREEN_IMG];
                         if ([TomatoManager sharedInstance].runningInBackground) {
                             // come back from background, so replay, and discard below code.
                             return;
                         }
                         if ([SettingsManager sharedInstance].autoNextPomodoro) {
                             [[AlertManager sharedInstance] playPomodoroStart];
                             [[TomatoManager sharedInstance] startPomodoroNow];
                         }
                         else {
                             [[TomatoManager sharedInstance] readyToPomodoroWithUiAnimation:YES];
                         }
                     }];
}

- (void)showBreakPauseScreen
{
    [self updateScreenAutolockPolicy];
    [self updateStatusLabelWithText:[self shortOrLongBreakString:STR_BREAK_PAUSED] animated:YES];
    [self.tomatoImageLayer removeAllAnimations];
}

- (void)showBreakResumeScreen
{
    [self updateScreenAutolockPolicy];
    if ([TomatoManager sharedInstance].tomatoStatus == TomatoBreakStatus) {
        [self updateStatusLabelWithText:[self shortOrLongBreakString:STR_BREAK_TIME] animated:YES];
    }
    else if ([TomatoManager sharedInstance].tomatoStatus == TomatoBreakWarningStatus) {
        [self updateStatusLabelWithText:[self shortOrLongBreakString:STR_BREAK_WARNING] animated:NO];
        [self playTomatoImageWarningAnimation];
    }
    self.maskView.hidden = YES;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = YES;
}

- (void)showCommonPauseScreen
{
    self.maskView.hidden = NO;
    self.playImageView.hidden = YES;
    self.pauseImageView.hidden = NO;
}

- (void)remainingTimeDidChange:(NSNumber*)remainingSeconds
{
    [self updateTimeLabelForDuration:remainingSeconds.intValue];
    [self showDynamicImageAccordingToRemainingSeconds:remainingSeconds.floatValue];
}

#pragma mark - PopMenu Delegate

- (void)plusTimerDuration:(NSInteger)seconds
{
    if ([TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroReadyStatus) {
        [TomatoManager sharedInstance].currentPomodoro.pDuration = [NSNumber numberWithInt:([TomatoManager sharedInstance].currentPomodoro.pDuration.intValue + seconds)];
        [self updateTimeLabelForDuration:[TomatoManager sharedInstance].currentPomodoro.pDuration.intValue];
    }
    else if ([TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroStatus
             || [TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroWarningStatus) {
        [[TomatoManager sharedInstance] plusPomodoroDuration:seconds];
    }
    else if ([TomatoManager sharedInstance].tomatoStatus == TomatoBreakReadyStatus) {
        [TomatoManager sharedInstance].currentPomodoro.bDuration = [NSNumber numberWithInt:([TomatoManager sharedInstance].currentPomodoro.bDuration.intValue + seconds)];
        [self updateTimeLabelForDuration:[TomatoManager sharedInstance].currentPomodoro.bDuration.intValue];
    }
    else if ([TomatoManager sharedInstance].tomatoStatus == TomatoBreakStatus
             || [TomatoManager sharedInstance].tomatoStatus == TomatoBreakWarningStatus) {
        [[TomatoManager sharedInstance] plusBreakDuration:seconds];
    }
}

- (void)minusTimerDuration:(NSInteger)seconds
{
    if ([TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroReadyStatus) {
        NSInteger newDuration = [TomatoManager sharedInstance].currentPomodoro.pDuration.intValue - seconds;
        if (newDuration < 0 ) {
            newDuration = 0;
        }
        [TomatoManager sharedInstance].currentPomodoro.pDuration = [NSNumber numberWithInt:newDuration];
        [self updateTimeLabelForDuration:[TomatoManager sharedInstance].currentPomodoro.pDuration.intValue];
    }
    else if ([TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroStatus
             || [TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroWarningStatus) {
        [[TomatoManager sharedInstance] minusPomodoroDuration:seconds];
    }
    else if ([TomatoManager sharedInstance].tomatoStatus == TomatoBreakReadyStatus) {
        NSInteger newDuration = [TomatoManager sharedInstance].currentPomodoro.bDuration.intValue - seconds;
        if (newDuration < 0 ) {
            newDuration = 0;
        }
        [TomatoManager sharedInstance].currentPomodoro.bDuration = [NSNumber numberWithInt:newDuration];
        [self updateTimeLabelForDuration:[TomatoManager sharedInstance].currentPomodoro.bDuration.intValue];
    }
    else if ([TomatoManager sharedInstance].tomatoStatus == TomatoBreakStatus
             || [TomatoManager sharedInstance].tomatoStatus == TomatoBreakWarningStatus) {
        [[TomatoManager sharedInstance] minusBreakDuration:seconds];
    }
}

- (void)terminateAfterGenieToRect:(CGRect)rect edge:(BCRectEdge)edge
{
    // animations for Cover, Open
    CABasicAnimation *animationOpenCoverRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animationOpenCoverRotation.toValue = [NSNumber numberWithFloat:2.8];
	animationOpenCoverRotation.duration = 0.35;
    animationOpenCoverRotation.fillMode = kCAFillModeForwards;
    animationOpenCoverRotation.removedOnCompletion = NO;
	animationOpenCoverRotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationOpenCoverPosition = [CABasicAnimation animationWithKeyPath:@"position"];
	animationOpenCoverPosition.toValue = [NSValue valueWithCGPoint:CGPointMake(ICON_TRASH_COVER_WIDTH-12, ICON_TRASH_COVER_HEIGHT-6)];
	animationOpenCoverPosition.duration = 0.35;
    animationOpenCoverPosition.fillMode = kCAFillModeForwards;
    animationOpenCoverPosition.removedOnCompletion = NO;
	animationOpenCoverPosition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // animations for Body, Open
    CABasicAnimation *animationOpenBodyRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animationOpenBodyRotation.toValue = [NSNumber numberWithFloat:-0.1];
	animationOpenBodyRotation.duration = 0.35;
    animationOpenBodyRotation.fillMode = kCAFillModeForwards;
    animationOpenBodyRotation.removedOnCompletion = NO;
	animationOpenBodyRotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationOpenBodyPosition = [CABasicAnimation animationWithKeyPath:@"position"];
	animationOpenBodyPosition.toValue = [NSValue valueWithCGPoint:CGPointMake(ICON_TRASH_WIDTH/2, ICON_TRASH_HEIGHT-6)];
	animationOpenBodyPosition.duration = 0.35;
    animationOpenBodyPosition.fillMode = kCAFillModeForwards;
    animationOpenBodyPosition.removedOnCompletion = NO;
	animationOpenBodyPosition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // animations for Cover, Close
    CABasicAnimation *animationCloseCoverRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animationCloseCoverRotation.toValue = [NSNumber numberWithFloat:0.0];
	animationCloseCoverRotation.duration = 0.1;
    animationCloseCoverRotation.fillMode = kCAFillModeForwards;
    animationCloseCoverRotation.removedOnCompletion = NO;
	animationCloseCoverRotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationCloseCoverPosition = [CABasicAnimation animationWithKeyPath:@"position"];
	animationCloseCoverPosition.toValue = [NSValue valueWithCGPoint:CGPointMake(ICON_TRASH_COVER_WIDTH, ICON_TRASH_COVER_HEIGHT)];
	animationCloseCoverPosition.duration = 0.1;
    animationCloseCoverPosition.fillMode = kCAFillModeForwards;
    animationCloseCoverPosition.removedOnCompletion = NO;
	animationCloseCoverPosition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // animations for Body, Close
    CABasicAnimation *animationCloseBodyRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animationCloseBodyRotation.toValue = [NSNumber numberWithFloat:0.0];
	animationCloseBodyRotation.duration = 0.1;
    animationCloseBodyRotation.fillMode = kCAFillModeForwards;
    animationCloseBodyRotation.removedOnCompletion = NO;
	animationCloseBodyRotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationCloseBodyPosition = [CABasicAnimation animationWithKeyPath:@"position"];
	animationCloseBodyPosition.toValue = [NSValue valueWithCGPoint:CGPointMake(ICON_TRASH_WIDTH/2, ICON_TRASH_HEIGHT)];
	animationCloseBodyPosition.duration = 0.1;
    animationCloseBodyPosition.fillMode = kCAFillModeForwards;
    animationCloseBodyPosition.removedOnCompletion = NO;
	animationCloseBodyPosition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // animation for Shake
    CABasicAnimation *animationShakeRotation1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animationShakeRotation1.toValue = [NSNumber numberWithFloat:0.1];
	animationShakeRotation1.duration = 0.1;
    animationShakeRotation1.beginTime = 0.1;
    animationShakeRotation1.fillMode = kCAFillModeForwards;
    animationShakeRotation1.removedOnCompletion = NO;
	animationShakeRotation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationShakeRotation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animationShakeRotation2.toValue = [NSNumber numberWithFloat:-0.08];
	animationShakeRotation2.duration = 0.1;
    animationShakeRotation2.beginTime = 0.2;
    animationShakeRotation2.fillMode = kCAFillModeForwards;
    animationShakeRotation2.removedOnCompletion = NO;
	animationShakeRotation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationShakeRotation3 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animationShakeRotation3.toValue = [NSNumber numberWithFloat:0.05];
	animationShakeRotation3.duration = 0.1;
    animationShakeRotation3.beginTime = 0.3;
    animationShakeRotation3.fillMode = kCAFillModeForwards;
    animationShakeRotation3.removedOnCompletion = NO;
	animationShakeRotation3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *animationShakeRotation4 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animationShakeRotation4.toValue = [NSNumber numberWithFloat:0.0];
	animationShakeRotation4.duration = 0.1;
    animationShakeRotation4.beginTime = 0.4;
    animationShakeRotation4.fillMode = kCAFillModeForwards;
    animationShakeRotation4.removedOnCompletion = NO;
	animationShakeRotation4.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    //
    CAAnimationGroup *groupForShake = [CAAnimationGroup animation];
    groupForShake.animations = [NSArray arrayWithObjects:animationShakeRotation1, animationShakeRotation2, animationShakeRotation3, animationShakeRotation4, nil];
    groupForShake.duration = 0.5;
    groupForShake.fillMode = kCAFillModeForwards;
    groupForShake.removedOnCompletion = NO;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        //[self.trashCoverLayer setValue:[NSNumber numberWithFloat:1.5] forKeyPath:@"transform.rotation.z"];
        //self.trashCoverLayer.position = CGPointMake(ICON_TRASH_COVER_WIDTH+10, ICON_TRASH_COVER_HEIGHT-10);
        //[self.trashBodyLayer setValue:[NSNumber numberWithFloat:-0.5] forKeyPath:@"transform.rotation.z"];
        NSTimeInterval duration = 0.7;
        CGRect endRect = CGRectInset(rect, 10.0, 10.0);
        endRect = CGRectOffset(endRect, -3, 0);
        [self.imageView genieInTransitionWithDuration:duration destinationRect:endRect destinationEdge:edge completion:
         ^{
             [CATransaction begin];
             [self.trashCoverLayer addAnimation:animationCloseCoverRotation forKey:nil];
             [self.trashCoverLayer addAnimation:animationCloseCoverPosition forKey:nil];
             [self.trashBodyLayer addAnimation:animationCloseBodyRotation forKey:nil];
             [self.trashBodyLayer addAnimation:animationCloseBodyPosition forKey:nil];
             [self.trashParentLayer addAnimation:groupForShake forKey:nil];
             [CATransaction setCompletionBlock:^{
                 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                 self.imageView.hidden = YES;
                 self.timeLabel.hidden = YES;
                 [self.imageView genieRestoreViewOrigin];
                 [[TomatoManager sharedInstance] userInterrupt];
             }];
             [CATransaction commit];
         }];
    }];
    [self.trashCoverLayer addAnimation:animationOpenCoverRotation forKey:nil];
    [self.trashCoverLayer addAnimation:animationOpenCoverPosition forKey:nil];
    [self.trashBodyLayer addAnimation:animationOpenBodyRotation forKey:nil];
    [self.trashBodyLayer addAnimation:animationOpenBodyPosition forKey:nil];
    [CATransaction commit];
}

- (void)animationTomatoVerticallyWithDuration:(NSTimeInterval)duration withOffset:(CGFloat)offset
{
    CGRect tomatoFrame = self.imageView.frame;
    tomatoFrame = CGRectOffset(tomatoFrame, 0, offset);
    
    CGRect playFrame = self.playImageView.frame;
    playFrame = CGRectOffset(playFrame, 0, offset);
    
    CGRect pauseFrame = self.pauseImageView.frame;
    pauseFrame = CGRectOffset(pauseFrame, 0, offset);
    
    CGRect statusLabelFrame = self.statusLabel.frame;
    statusLabelFrame = CGRectOffset(statusLabelFrame, 0, offset*0.6);
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.imageView setFrame:tomatoFrame];
                         [self.playImageView setFrame:playFrame];
                         [self.pauseImageView setFrame:pauseFrame];
                         [self.statusLabel setFrame:statusLabelFrame];
                     }
                     completion:^(BOOL  completed){
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}

typedef enum
{
    TagAdjustTimePausedBefore,
    TagAdjustTimeNotPausedBefore,
    TagTerminationPausedBefore,
    TagTerminationNotPausedBefore,
} PopMenuTag;

static const NSInteger TOMATO_UP_DOWN_OFFSET = 60;

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ClawInfo(@"view tag is %d", modalView.tag);
    if (modalView.tag == TagAdjustTimePausedBefore) {
        // Adjust Time Menu, timer paused BEFORE
        switch (buttonIndex)
        {
            case 0:
            {
                // +1 min
                ClawInfo(@"actionSheet: +1min %d", buttonIndex);
                [self plusTimerDuration:60];
                [[TomatoManager sharedInstance] pauseTimer];
                [self showCommonPauseScreen];
                break;
            }
            case 1:
            {
                ClawInfo(@"actionSheet: -1min %d", buttonIndex);
                // -1 min
                [self minusTimerDuration:60];
                [[TomatoManager sharedInstance] pauseTimer];
                [self showCommonPauseScreen];
                break;
            }
            case 2:
            {
                ClawInfo(@"actionSheet: cacel %d", buttonIndex);
                //cancel, so do nothing
                break;
            }
        }
        if (!IS_WIDESCREEN) {
            [self animationTomatoVerticallyWithDuration:0.3 withOffset:TOMATO_UP_DOWN_OFFSET];
        }
    }
    else if (modalView.tag == TagAdjustTimeNotPausedBefore) {
        // Adjust Time Menu, timer NOT paused BEFORE
        switch (buttonIndex)
        {
            case 0:
            {
                // +1 min
                ClawInfo(@"actionSheet: +1min %d", buttonIndex);
                [self plusTimerDuration:60];
                break;
            }
            case 1:
            {
                ClawInfo(@"actionSheet: -1min %d", buttonIndex);
                // -1 min
                [self minusTimerDuration:60];
                break;
            }
            case 2:
            {
                ClawInfo(@"actionSheet: cacel %d", buttonIndex);
                if ([TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroStatus
                    || [TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroWarningStatus
                    || [TomatoManager sharedInstance].tomatoStatus == TomatoBreakStatus
                    || [TomatoManager sharedInstance].tomatoStatus == TomatoBreakWarningStatus) {
                    [[TomatoManager sharedInstance] resumeTimer];
                }
                break;
            }
        }
        if (!IS_WIDESCREEN) {
            [self animationTomatoVerticallyWithDuration:0.3 withOffset:TOMATO_UP_DOWN_OFFSET];
        }
    }
    else if (modalView.tag == TagTerminationPausedBefore) {
        // Termination Menu, timer paused BEFORE
        switch (buttonIndex)
        {
            case 0:
            {
                ClawInfo(@"actionSheet: termination %d", buttonIndex);
                self.maskView.hidden = YES;
                self.playImageView.hidden = YES;
                self.pauseImageView.hidden = YES;
                [self terminateAfterGenieToRect:[self.interruptionButton frame] edge:BCRectEdgeTop];
                break;
            }
            case 1:
            {
                ClawInfo(@"actionSheet: cancel %d", buttonIndex);
                break;
            }
        }
    }
    else if (modalView.tag == TagTerminationNotPausedBefore) {
        // Termination Menu, timer NOT paused BEFORE
        switch (buttonIndex)
        {
            case 0:
            {
                ClawInfo(@"actionSheet: termination %d", buttonIndex);
                self.maskView.hidden = YES;
                self.playImageView.hidden = YES;
                self.pauseImageView.hidden = YES;
                [self terminateAfterGenieToRect:[self.interruptionButton frame] edge:BCRectEdgeTop];
                break;
            }
            case 1:
            {
                ClawInfo(@"actionSheet: cancel %d", buttonIndex);
                if ([TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroStatus
                    || [TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroWarningStatus
                    || [TomatoManager sharedInstance].tomatoStatus == TomatoBreakStatus
                    || [TomatoManager sharedInstance].tomatoStatus == TomatoBreakWarningStatus) {
                    [[TomatoManager sharedInstance] resumeTimer];
                }
                break;
            }
        }
    }
}

#pragma mark - IBOutlet

- (IBAction)showSummary:(id)sender
{
    self.summaryViewController = [[SummaryViewController alloc]  initWithNibName:@"SummaryViewController" bundle:nil];
    self.summaryViewController.managedObjectContext = self.managedObjectContext;
    self.summaryViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:self.summaryViewController animated:YES completion:nil];
}

- (IBAction)popAdjustTimeMenu:(id)sender
{
    if ([TomatoManager sharedInstance].tomatoStatus!=TomatoPomodoroReadyStatus
        &&[TomatoManager sharedInstance].tomatoStatus!=TomatoPomodoroStatus
        &&[TomatoManager sharedInstance].tomatoStatus!=TomatoPomodoroWarningStatus
        &&[TomatoManager sharedInstance].tomatoStatus!=TomatoBreakReadyStatus
        &&[TomatoManager sharedInstance].tomatoStatus!=TomatoBreakStatus
        &&[TomatoManager sharedInstance].tomatoStatus!=TomatoBreakWarningStatus) {
        return;
    }
    NSInteger menuTag;
    if ([TomatoManager sharedInstance].timer.isPaused) {
        menuTag = TagAdjustTimePausedBefore;
    }
    else {
        menuTag = TagAdjustTimeNotPausedBefore;
        [[TomatoManager sharedInstance] pauseTimer];
    }
    
    if (!IS_WIDESCREEN) {
        [self animationTomatoVerticallyWithDuration:0.3 withOffset:-TOMATO_UP_DOWN_OFFSET];
    }
    UIActionSheet *styleAlert = [[UIActionSheet alloc] initWithTitle:@""
                                                            delegate:self
                                                   cancelButtonTitle:STR_CANCEL
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:STR_PLUS_MINUTE,
                                 STR_MINUS_MINUTE,
                                 nil,
                                 nil];
    
    // use the same style as the nav bar
    styleAlert.actionSheetStyle = UIActionSheetStyleDefault;
    //styleAlert.title = @"stop Pomodoro?";
    styleAlert.tag = menuTag;
    //styleAlert.destructiveButtonIndex = 0;
    [styleAlert showInView:self.view];
}

- (IBAction)popInterruptionMenu:(id)sender
{
    NSString *ternimationTitle;
    if ([TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroStatus
        || [TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroWarningStatus
        || [TomatoManager sharedInstance].tomatoStatus == TomatoPomodoroReadyStatus) {
        ternimationTitle = STR_TERMINATE_POMODORO;
    }
    else if ([TomatoManager sharedInstance].tomatoStatus == TomatoBreakStatus
             || [TomatoManager sharedInstance].tomatoStatus == TomatoBreakWarningStatus
             || [TomatoManager sharedInstance].tomatoStatus == TomatoBreakReadyStatus){
        ternimationTitle = STR_TERMINATE_BREAK;
    }
    else {
        return;
    }
    
    NSInteger menuTag;
    if ([TomatoManager sharedInstance].timer.isPaused) {
        menuTag = TagTerminationPausedBefore;
    }
    else {
        menuTag = TagTerminationNotPausedBefore;
        [[TomatoManager sharedInstance] pauseTimer];
    }
    
    UIActionSheet *styleAlert = [[UIActionSheet alloc] initWithTitle:@""
                                                            delegate:self
                                                   cancelButtonTitle:STR_CANCEL
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:ternimationTitle,
                                 nil,
                                 nil];
	
	// use the same style as the nav bar
	styleAlert.actionSheetStyle = UIActionSheetStyleDefault;
    //styleAlert.title = @"";
	styleAlert.tag = menuTag;
    styleAlert.destructiveButtonIndex = 0;
	[styleAlert showInView:self.view];
}

#pragma mark - settings

- (void)showTutorialScreen
{
    // show tutorial screen
    TutorialViewController *modalViewController = [[TutorialViewController alloc] initWithNibName:@"TutorialViewController" bundle:nil];
    modalViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.appSettingsViewController presentViewController:modalViewController animated:YES completion:nil];
}

- (IBAction)showSettingView:(id)sender
{
    if (!_appSettingsViewController) {
		_appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
		_appSettingsViewController.delegate = self;
	}
    
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    //[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
    self.appSettingsViewController.showDoneButton = YES;
    //aNavController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //aNavController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:aNavController animated:YES completion:nil];
}

#pragma mark - IASKAppSettingsViewControllerDelegate protocol

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
	// your code here to reconfigure the app for changed settings
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:@"ReplayUserGuide"]) {
		[self showTutorialScreen];
	}
}

#pragma mark - kIASKAppSettingChanged notification

- (void)settingDidChange:(NSNotification*)notification {
	if ([notification.object isEqual:@"pomodoro_duration_pref"]) {
        NSNumber * duration = [notification.userInfo objectForKey:@"pomodoro_duration_pref"];
        [[TomatoManager sharedInstance] changePomodoroDurationSetting:duration.intValue];
        [[TomatoManager sharedInstance].timer scheduleTicking];
    }
    else if ([notification.object isEqual:@"break_duration_pref"]) {
        NSNumber * duration = [notification.userInfo objectForKey:@"break_duration_pref"];
        [[TomatoManager sharedInstance] changeShortBreakDurationSetting:duration.intValue];
        [[TomatoManager sharedInstance].timer scheduleTicking];
    }
    else if ([notification.object isEqual:@"long_break_duration_pref"]) {
        NSNumber * duration = [notification.userInfo objectForKey:@"long_break_duration_pref"];
        [[TomatoManager sharedInstance] changeLongBreakDurationSetting:duration.intValue];
        [[TomatoManager sharedInstance].timer scheduleTicking];
    }
    else if ([notification.object isEqual:@"long_break_every_pref"]) {
        [[TomatoManager sharedInstance].timer scheduleTicking];
    }
    else if ([notification.object isEqual:@"auto_break_pref"]) {
        [[TomatoManager sharedInstance].timer scheduleTicking];
    }
    else if ([notification.object isEqual:@"auto_next_pref"]) {
        [[TomatoManager sharedInstance].timer scheduleTicking];
    }
    else if ([notification.object isEqual:@"pomodoro_start_pref"]) {
        NSString * fileName = [notification.userInfo objectForKey:@"pomodoro_start_pref"];
        [[AlertManager sharedInstance] playSoundFile:fileName];
    }
    else if ([notification.object isEqual:@"pomodoro_end_pref"]) {
        NSString * fileName = [notification.userInfo objectForKey:@"pomodoro_end_pref"];
        [[AlertManager sharedInstance] playSoundFile:fileName];
    }
    else if ([notification.object isEqual:@"break_end_pref"]) {
        NSString * fileName = [notification.userInfo objectForKey:@"break_end_pref"];
        [[AlertManager sharedInstance] playSoundFile:fileName];
    }
    else if ([notification.object isEqual:@"ticking_pref"]) {
        if ([[TomatoManager sharedInstance].timer isRunning]) {
            [[TomatoManager sharedInstance].timer scheduleTicking];
        }
        else {
            NSString * fileName = [notification.userInfo objectForKey:@"ticking_pref"];
            [[AlertManager sharedInstance] playSoundFile:fileName];
        }
    }
    else if ([notification.object isEqual:@"pomodoro_warning_sound_pref"]) {
        NSString * fileName = [notification.userInfo objectForKey:@"pomodoro_warning_sound_pref"];
        [[AlertManager sharedInstance] playSoundFile:fileName];
    }
    else if ([notification.object isEqual:@"break_warning_sound_pref"]) {
        NSString * fileName = [notification.userInfo objectForKey:@"break_warning_sound_pref"];
        [[AlertManager sharedInstance] playSoundFile:fileName];
    }
    else if ([notification.object isEqual:@"vibrate_pref"]) {
        [[AlertManager sharedInstance] triggerVibration];
    }
    else if ([notification.object isEqual:@"disable_autolock_pref"]) {
        [self updateScreenAutolockPolicy];
    }
    //    else if ([notification.object isEqual:@"sound_volume_pref"]) {
    //        [[AlertManager sharedInstance] playSampleSound];
    //        if ([[TomatoManager sharedInstance].timer isRunning]) {
    //            [[TomatoManager sharedInstance].timer playTicking];
    //        }
    //    }
    
}

@end
