//
//  TutorialViewController.m
//  Tomato2
//
//  Created by Teng Lin on 13-11-12.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//


#import "TutorialViewController.h"
#import "TutorialPageViewController.h"
#import <QuartzCore/QuartzCore.h>

static NSUInteger kNumberOfPages = 8;

@interface TutorialViewController () {
    BOOL _pageControlUsed;
    CGPoint _getStartedPosition;
}

@property (nonatomic, weak) IBOutlet UIImageView *backImageView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, weak) IBOutlet UIButton *getStartedButton;

- (IBAction)changePage:(id)sender;
- (IBAction)getStarted:(id)sender;

@end

@implementation TutorialViewController

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
    if (IS_WIDESCREEN) {
        self.backImageView.image = [UIImage imageNamed:@"tutorial_background_568.png"];
    }
    else {
        self.backImageView.image = [UIImage imageNamed:@"tutorial_background.png"];
    }
    
    // Do any additional setup after loading the view from its nib.
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    self.pageControl.numberOfPages = kNumberOfPages;
    self.pageControl.currentPage = 0;
    
    self.getStartedButton.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    //[self.getStartedButton setBackgroundImage:[UIImage imageNamed:@"get_started_button.png"] forState:UIControlStateNormal];
    //[self.getStartedButton setBackgroundImage:[UIImage imageNamed:@"get_started_button_highlight.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [self.getStartedButton  setTitle:@"Done" forState:UIControlStateNormal];
        [self.getStartedButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    }
    
#if DEBUG_MAKE_DEFAULT_PNG
    self.pageControl.hidden = YES;
    self.getStartedButton.hidden = YES;
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self customSubViewsLayout];
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    [self loadScrollViewWithPage:2];
    [self loadScrollViewWithPage:3];
    [self loadScrollViewWithPage:4];
    [self loadScrollViewWithPage:5];
    [self loadScrollViewWithPage:6];
    [self loadScrollViewWithPage:7];
    
    _getStartedPosition  = self.getStartedButton.layer.position;
    self.getStartedButton.layer.position = CGPointMake(_getStartedPosition.x, _getStartedPosition.y + 60);
    
    self.pageControl.alpha = 0.0;
    [UIView animateWithDuration:0.7
                     animations:^{
                         self.pageControl.alpha = 1.0;
                     }
                     completion:^(BOOL  completed){
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - layout

- (void)showGetStartedButton
{
    if (self.getStartedButton.layer.position.y == _getStartedPosition.y) {
        return;
    }
    if ([self.getStartedButton.layer animationForKey:@"GetStartedAnimationKey"]) {
        ClawInfo(@"NOT start get started animation!!!-----!!!!!_###########");
        return;
    }
    
    CGMutablePathRef jumpPath = CGPathCreateMutable();
    CGPathMoveToPoint(jumpPath, NULL, _getStartedPosition.x, _getStartedPosition.y + 60);
    CGPathAddLineToPoint(jumpPath, NULL, _getStartedPosition.x, _getStartedPosition.y - 6);
    CGPathAddLineToPoint(jumpPath, NULL, _getStartedPosition.x, _getStartedPosition.y + 3);
    CGPathAddLineToPoint(jumpPath, NULL, _getStartedPosition.x, _getStartedPosition.y);
    
    CAKeyframeAnimation *jumpAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    jumpAnimation.path = jumpPath;
#warning jumpAnimation.path is not retain, why below release is OK?
    CGPathRelease(jumpPath);
    jumpAnimation.duration = 1.;
    jumpAnimation.fillMode = kCAFillModeForwards;
    jumpAnimation.removedOnCompletion = NO;
    jumpAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.getStartedButton.layer.position = _getStartedPosition;
    }];
    [self.getStartedButton.layer addAnimation:jumpAnimation forKey:@"GetStartedAnimationKey"];
    [CATransaction commit];
}

- (void)customSubViewsLayout
{
    if (IS_WIDESCREEN) {
        // code for 4-inch screen
        self.scrollView.frame = CGRectMake(0, 0, 320, 450);
#if DEBUG_MAKE_DEFAULT_PNG
        self.scrollView.frame = CGRectMake(0, 0, 320, 490);
#endif
    } else {
        // code for 3.5-inch screen
        self.scrollView.frame = CGRectMake(0, 0, 320, 400);
#if DEBUG_MAKE_DEFAULT_PNG
        self.scrollView.frame = CGRectMake(0, 0, 320, 420);
#endif
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * kNumberOfPages, self.scrollView.frame.size.height);
}

#pragma mark - private methods

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    TutorialPageViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[TutorialPageViewController alloc] initWithPageNumber:page];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (_pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    if (page == 7) {
        [self showGetStartedButton];
    }
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender
{
    int page = self.pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    _pageControlUsed = YES;
    
    if (page == 7) {
        [self showGetStartedButton];
    }
}

- (IBAction)getStarted:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    [self setGetStartedButton:nil];
    [self setBackImageView:nil];
    [super viewDidUnload];
}
@end

