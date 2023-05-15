//
//  HistoryTableViewController.m
//  Tomato
//
//  Created by Lin Teng on 2/1/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "Pomodoro.h"
#import "Day.h"
#import "NSDate+Utils.h"
#import "DataManager.h"
#import "MyUtils.h"

#define ROW_HEIGHT 52

@interface HistoryTableViewController ()

@property (strong, nonatomic) NSMutableArray *historyMonths;
@property (strong, nonatomic) NSMutableDictionary *historyDaysDict; // days array by monthIndex)

@property (strong, nonatomic) NSDate *currentDate;

@property (strong, nonatomic) IBOutlet HistoryTableCell *tableCell;

@end

@implementation HistoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.currentDate = [NSDate date];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // super will call methods about tableview... then below code
    // self.view.frame is right now!
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.   
    self.historyMonths = [[DataManager sharedInstance] historyMonthsUntil:self.currentDate reverse:YES];
    return [self.historyMonths count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray *historyDaysInMonth = [self historyDaysByMonthIndex:section];
    if (historyDaysInMonth) {
        return [historyDaysInMonth count];
    }
    else {
        return 0;
    }        
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];  
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];    
    
    return [dateFormatter stringFromDate:[self.historyMonths objectAtIndex:section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HistoryCell";
    HistoryTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];    
    
    if(!cell)
    {
        [[NSBundle mainBundle] loadNibNamed:@"HistoryTableCell" owner:self options:nil];        
        cell = self.tableCell;
        cell.countLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"history_cell_star.png"]];
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Core Data & configureCell

- (void)configureCell:(HistoryTableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *historyDaysInMonth = [self historyDaysByMonthIndex:indexPath.section];
    NSDate *date = [historyDaysInMonth objectAtIndex:indexPath.row];
        
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];      
    
    cell.dateLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
    //cell.timeLabel.text = [NSString stringWithFormat:@"pomodoro: %dmin", [[DataManager sharedInstance] pomodoroSecondsOfDate:date]/60];
    cell.timeLabel.text = [NSString stringWithFormat:@"pomodoro: %@", timeDecentDescription([[DataManager sharedInstance] pomodoroSecondsOfDate:date])];
    cell.countLabel.text =  [NSString stringWithFormat:@"%d", [[DataManager sharedInstance] pomodoroCountOfDate:date]];
    cell.weekLabel.text = [date weekDayName];    
    
    if ([date isWeekend]) {
        cell.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
    }
    else {
        cell.backgroundColor = [UIColor whiteColor];
    }     
}

#pragma mark - Core Data
#pragma mark - Fetched results controller

- (void)reloadData
{
    self.currentDate = [NSDate date];
    [self.historyMonths removeAllObjects];
    [self.historyDaysDict removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - utils
- (NSMutableArray*)historyDaysByMonthIndex:(NSInteger)monthIndex
{
    if (!self.historyDaysDict) {
        self.historyDaysDict = [NSMutableDictionary dictionary];
    }
    
    NSMutableArray *historyDaysInMonth = [self.historyDaysDict objectForKey:[NSNumber numberWithInteger:monthIndex]];
    if (historyDaysInMonth) {
        //ClawInfo(@"historyDaysInMonth cache used!");
        return historyDaysInMonth;
    }
    
    historyDaysInMonth = [NSDate daysInMonth:[self.historyMonths objectAtIndex:monthIndex] limitFrom:[[DataManager sharedInstance] beginningOfFirstHistoryDay] limitTo:self.currentDate reverse:YES];
    [self.historyDaysDict setObject:historyDaysInMonth forKey:[NSNumber numberWithInteger:monthIndex]];
    
    //ClawInfo(@"historyDaysInMonth new created!");
    return historyDaysInMonth;
}
/*
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Day" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
  
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(interrupted = %@) ", [NSNumber numberWithBool:NO]];
     
     [fetchRequest setPredicate:predicate];
     
    
    // Edit the sort key as appropriate.
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"beginOfDay" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    //NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"endDate" cacheName:@"Master"];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionMonth" cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    ClawInfo(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}
*/
/*
 
 - (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
 {
 [self.tableView beginUpdates];
 }
 
 - (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
 atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
 {
 switch(type) {
 case NSFetchedResultsChangeInsert:
 [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
 break;
 
 case NSFetchedResultsChangeDelete:
 [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
 break;
 }
 }
 
 - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
 atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
 newIndexPath:(NSIndexPath *)newIndexPath
 {
 UITableView *tableView = self.tableView;
 
 switch(type) {
 case NSFetchedResultsChangeInsert:
 [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
 break;
 
 case NSFetchedResultsChangeDelete:
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 break;
 
 case NSFetchedResultsChangeUpdate:
 [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
 break;
 
 case NSFetchedResultsChangeMove:
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
 break;
 }
 }
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 [self.tableView endUpdates];
 }
 */

// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

/*
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
*/

@end
