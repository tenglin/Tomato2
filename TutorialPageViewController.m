//
//  TutorialPageViewController.m
//  Tomato2
//
//  Created by Teng Lin on 13-11-12.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import "TutorialPageViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TutorialPageViewController () {
    BOOL _swipeToLearnAnimated;
}
@end

@implementation TutorialPageViewController

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
    self.view.backgroundColor = [UIColor clearColor];
    self.ImageBackView.backgroundColor = [UIColor whiteColor];
    self.textView.backgroundColor = [UIColor clearColor];
#warning perform loadContentForPageNumber:pageNumber in viewWillAppear will cause a very weird error, seems scrollview will auto scroll!! so we should do it here.
    [self loadContentForPageNumber:pageNumber];
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setTextView:nil];
    [self setImageBackView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self customSubViewsLayout];
#warning loadContentForPageNumber:pageNumber here will cause a very weird error, seems scrollview will auto scroll!!
    //[self loadContentForPageNumber:pageNumber];
    
    if (pageNumber != 0) {
        return;
    }
    
#if DEBUG_MAKE_DEFAULT_PNG
    self.textView.text = @"\n\nVersion 1.1";
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.frame = CGRectOffset(self.textView.frame, 0, 50);
#endif
    
    
    // if (pageNumber == 0)
    CGPoint swipeToLearnPosition = self.textView.layer.position;
    self.textView.layer.position = CGPointMake(swipeToLearnPosition.x + 300, swipeToLearnPosition.y);
    
    if (_swipeToLearnAnimated) {
        return;
    }
    
    CGMutablePathRef swipePath = CGPathCreateMutable();
    CGPathMoveToPoint(swipePath, NULL, swipeToLearnPosition.x + 300, swipeToLearnPosition.y);
    CGPathAddLineToPoint(swipePath, NULL, swipeToLearnPosition.x - 20, swipeToLearnPosition.y);
    CGPathAddLineToPoint(swipePath, NULL, swipeToLearnPosition.x + 10 , swipeToLearnPosition.y);
    CGPathAddLineToPoint(swipePath, NULL, swipeToLearnPosition.x, swipeToLearnPosition.y);
    CAKeyframeAnimation *swipeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    swipeAnimation.path = swipePath;
    CGPathRelease(swipePath);
    swipeAnimation.duration = 1.;
    swipeAnimation.fillMode = kCAFillModeForwards;
    swipeAnimation.removedOnCompletion = NO;
    swipeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.textView.layer.position = swipeToLearnPosition;
    }];
    [self.textView.layer addAnimation:swipeAnimation forKey:@"GetStartedAnimationKey"];
    [CATransaction commit];
    _swipeToLearnAnimated = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithPageNumber:(int)page
{
    if (self = [super initWithNibName:@"TutorialPageViewController" bundle:nil])
    {
        pageNumber = page;
        // loading image here do not works, since view not loaded! so should do it later
        // [self loadContentForPageNumber:page];
    }
    return self;
}

#pragma mark - layout

- (void)customSubViewsLayout
{
    if (IS_WIDESCREEN) {
        // code for 4-inch screen
        self.ImageBackView.frame = CGRectMake(22, 40, 280, 280);
        self.imageView.frame = CGRectMake(25, 45, 270, 270);
        self.textView.frame = CGRectMake(20, 365, 280, 130);
        if (pageNumber == 0) {
            self.imageView.frame = CGRectMake(0, 0, 320, 548);
        }
    } else {
        // code for 3.5-inch screen
        self.ImageBackView.frame = CGRectMake(30, 20, 260, 260);
        self.imageView.frame = CGRectMake(35, 25, 250, 250);
        //self.ImageBackView.frame = CGRectMake(25, 0, 270, 270);
        //self.imageView.frame = CGRectMake(30, 5, 260, 260);
        self.textView.frame = CGRectMake(20, 295, 280, 135);
        if (pageNumber == 0) {
            self.imageView.frame = CGRectMake(0, 0, 320, 548);
        }
    }
}

- (void)loadContentForPageNumber:(NSInteger)page
{
    if (page ==0 && IS_WIDESCREEN) {
        self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"tutorial%d_568.png", page]];
    }
    else {
        self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"tutorial%d.png", page]];
    }
    
    switch (page) {
        case 0:
            self.textView.text = @"\n\nSwipe to see the guide ->";
            break;
        case 1:
            self.textView.text = @"Step1: Choose a task to be done, write it on your paper.";
            break;
        case 2:
            self.textView.text = @"Step2: Set the pomodoro timer to 25 minutes, and start to work.";
            break;
        case 3:
            self.textView.text = @"Step3: Work on the task until the pomodoro timer ends and rings.";
            break;
        case 4:
            self.textView.text = @"Step4: Take a short break, 3-5 minutes is OK.";
            break;
        case 5:
            self.textView.text = @"Step5: Every 4 pomodoros take a longer break, 15-30 minutes is OK.";
            break;
        case 6:
            self.textView.text = @"Step6: Put check on your paper when the task is accomplished.";
            break;
        case 7:
            self.textView.text = @"That's it! You will have good performance and good health!";
            break;
        default:
            break;
    }
}

@end
