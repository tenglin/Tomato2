//
//  TodayViewController.m
//  Tomato
//
//  Created by Lin Teng on 1/5/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "SummaryViewController.h"
#import "TodayTableViewController.h"
#import "TodayTimeViewController.h"
#import "HistoryTableViewController.h"
#import "HistoryGraphViewController.h"
#import "DataManager.h"

@interface SummaryViewController ()

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *myNavigationItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *myNavigationBar;

@property (strong, nonatomic) TodayTableViewController *todayTableViewController;
@property (strong, nonatomic) TodayTimeViewController *todayTimeViewController;
@property (strong, nonatomic) HistoryTableViewController *historyTableViewController;
@property (strong, nonatomic) HistoryGraphViewController *historyGraphViewController;

- (IBAction)backButtonTouched:(id)sender;

@end

@implementation SummaryViewController

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
    // self.view.frame is not right here.
    
    self.todayTableViewController = [[TodayTableViewController alloc] initWithNibName:@"TodayTableViewController" bundle:nil];    
    self.todayTimeViewController = [[TodayTimeViewController alloc] initWithNibName:@"TodayTimeViewController" bundle:nil];    
    self.historyTableViewController = [[HistoryTableViewController alloc] initWithNibName:@"HistoryTableViewController" bundle:nil];    
    self.historyGraphViewController = [[HistoryGraphViewController alloc] initWithNibName:@"HistoryGraphViewController" bundle:nil];

    self.todayTableViewController.managedObjectContext = self.managedObjectContext;       
   
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 60, 60)];
    [btn setImage:[UIImage imageNamed:@"nav_back_btn.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc] initWithCustomView:btn];
    self.myNavigationItem.leftBarButtonItem=leftButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // self.view.frame is right now!
    [self todayTableButtonTouched:nil];
}

/*
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.myNavigationBar.hidden = NO;
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - other methods
- (IBAction)backButtonTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGRect)contentViewsFrame
{
    CGRect frame = CGRectMake(0, self.myNavigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height -  self.myNavigationBar.frame.size.height - self.toolBar.frame.size.height);
    return frame;
}

- (IBAction)todayTableButtonTouched:(id)sender
{
    if ([self.view.subviews indexOfObject:self.todayTableViewController.view]==NSNotFound) {        
        self.todayTableViewController.view.frame = [self contentViewsFrame];
        [self.view addSubview:self.todayTableViewController.view];
    }
    else {
        [self.view bringSubviewToFront:self.todayTableViewController.view];
    }    
    [self.view bringSubviewToFront:self.toolBar];
    [self.view bringSubviewToFront:self.myNavigationBar];
    
    self.myNavigationItem.title = @"Today Pomodoro";    
    self.myNavigationItem.rightBarButtonItem = self.todayTableViewController.editButtonItem;
    
    // clear the possible old View UI elements
    [self.historyGraphViewController clearUiData];
    [self.todayTimeViewController clearUiData];
}

- (IBAction)todayTimeButtonTouched:(id)sender
{
    if ([self.view.subviews indexOfObject:self.todayTimeViewController.view]==NSNotFound) {        
        self.todayTimeViewController.view.frame = [self contentViewsFrame];
        [self.view addSubview:self.todayTimeViewController.view];
    }
    else {
        [self.todayTimeViewController reloadData];
        [self.view bringSubviewToFront:self.todayTimeViewController.view];
    }    
    [self.view bringSubviewToFront:self.toolBar];
    [self.view bringSubviewToFront:self.myNavigationBar];
    
    self.myNavigationItem.title = @"Today Time";
    self.myNavigationItem.rightBarButtonItem = nil;
    
    // clear the possible old View UI elements
    [self.historyGraphViewController clearUiData];
}
- (IBAction)historyTableButtonTouched:(id)sender
{
    if ([self.view.subviews indexOfObject:self.historyTableViewController.view]==NSNotFound) {        
        self.historyTableViewController.view.frame = [self contentViewsFrame];
        [self.view addSubview:self.historyTableViewController.view];
    }
    else {
        [self.historyTableViewController reloadData];
        [self.view bringSubviewToFront:self.historyTableViewController.view];
    }    
    [self.view bringSubviewToFront:self.toolBar];
    [self.view bringSubviewToFront:self.myNavigationBar];
    
    self.myNavigationItem.title = @"History";
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Clear History" style:UIBarButtonItemStyleBordered target:self action:@selector(clearAllHistory)];
    //button.tintColor = [UIColor blackColor];
    self.myNavigationItem.rightBarButtonItem = button;
    
    // clear the possible old View UI elements
    [self.historyGraphViewController clearUiData];
    [self.todayTimeViewController clearUiData];
}

- (IBAction)historyGraphButtonTouched:(id)sender
{
    if ([self.view.subviews indexOfObject:self.historyGraphViewController.view]==NSNotFound) {
        self.historyGraphViewController.view.frame = [self contentViewsFrame];
        [self.view addSubview:self.historyGraphViewController.view];
    }
    else {
        [self.historyGraphViewController reloadData];
        [self.view bringSubviewToFront:self.historyGraphViewController.view];
    }    
    [self.view bringSubviewToFront:self.toolBar];
    [self.view bringSubviewToFront:self.myNavigationBar];
    
    self.myNavigationItem.title = @"History Graph";
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self.historyGraphViewController action:@selector(scrollToToday)];
    self.myNavigationItem.rightBarButtonItem = button;
    
    // clear the possible old View UI elements
    [self.todayTimeViewController clearUiData];
}

- (void)viewDidUnload {    
    [self setToolBar:nil];
    [super viewDidUnload];
}

#pragma mark - utility

- (void)clearAllHistory
{
    ClawInfo(@"clearAllHistory");
    UIActionSheet *styleAlert = [[UIActionSheet alloc] initWithTitle:@""
                                                            delegate:self
                                                   cancelButtonTitle:@"Cacel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Clear All History",
                                 nil,
                                 nil];
	
	// use the same style as the nav bar
	styleAlert.actionSheetStyle = UIActionSheetStyleDefault;
	styleAlert.tag = 1;
    styleAlert.destructiveButtonIndex = 0;
	[styleAlert showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ClawInfo(@"view tag is %d", modalView.tag);
    if (modalView.tag == 1) {
        // clear All History Menu
        switch (buttonIndex)
        {
            case 0:
            {
                ClawInfo(@"actionSheet: Clear All History %d", buttonIndex);
                [[DataManager sharedInstance] deleteAllObjectsInDB];
                [self.historyTableViewController reloadData];
                break;
            }
            case 1:
            {
                ClawInfo(@"actionSheet: cancel %d", buttonIndex);
                //cancel, so do nothing               
                break;
            }
        }        
    }
}

@end
