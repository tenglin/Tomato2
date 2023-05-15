//
//  TodayTableViewController.m
//  Tomato
//
//  Created by Lin Teng on 1/6/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "TodayTableViewController.h"
#import "DataManager.h"
#import "Pomodoro.h"

#define ROW_HEIGHT 52

@interface TodayTableViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSDate *currentDate;
@property (nonatomic, strong) UILabel *emptyPomodoroLabel;

@end

@implementation TodayTableViewController

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
    // self.view.frame is not right here

    self.currentDate = [NSDate date];
    [self addNonePomodoroSubViews];
    [self showNonePomodoroSubViews:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // self.view.frame is right now!
    [self customSubViewsLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNonePomodoroSubViews
{
    self.emptyPomodoroLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.emptyPomodoroLabel.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.emptyPomodoroLabel.backgroundColor = [UIColor clearColor];
    self.emptyPomodoroLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    self.emptyPomodoroLabel.shadowOffset = CGSizeMake(0.5f, 1.0f);    
    [self.view addSubview:self.emptyPomodoroLabel];
}

- (void)showNonePomodoroSubViews:(BOOL)visibility;
{
    if (visibility) {
        self.emptyPomodoroLabel.hidden = NO;
    }
    else {
        self.emptyPomodoroLabel.hidden = YES;
    }
}

- (void)customSubViewsLayout
{
    UIFont *font = [UIFont systemFontOfSize:18];
    NSString *infoString = @"No Pomodoro of Today";
    CGSize size = [infoString sizeWithFont:font];
    CGFloat xOffset = (self.view.bounds.size.width - size.width)/2;
    self.emptyPomodoroLabel.font = font;
    self.emptyPomodoroLabel.text = infoString;
    if (IS_WIDESCREEN) {
        // code for 4-inch screen
        // set frame, font, text of emptyPomodoroLabel        
        self.emptyPomodoroLabel.frame = CGRectMake(xOffset, 20, size.width, 30);
    } else {
        // code for 3.5-inch screen
        // set frame, font, text of emptyPomodoroLabel       
        self.emptyPomodoroLabel.frame = CGRectMake(xOffset, 20, size.width, 30);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionsCount = [[self.fetchedResultsController sections] count];
    if (sectionsCount == 0) {
        [self showNonePomodoroSubViews:YES];
    }
    else {
        [self showNonePomodoroSubViews:NO];
    }
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger rowsCount = [sectionInfo numberOfObjects];
    return rowsCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TodayCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }    
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        Pomodoro *pomodoro = [self.fetchedResultsController objectAtIndexPath:indexPath];
        //[context deleteObject:pomodoro];
        if (!pomodoro.pInterrupted.boolValue) {
            [[DataManager sharedInstance] updateDayObjectInMem:[[DataManager sharedInstance] getDayObjectOfDate:pomodoro.pEndDate] removePomodoroObject:pomodoro];
            [[DataManager sharedInstance] updateVarsBiggestPomodoroSecondsByRecalc];
        }
              
        if (![[DataManager sharedInstance] saveCoreDataContext]) {
            ClawError(@"%s saveCoreDataContext error", __PRETTY_FUNCTION__);
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

#pragma mark - Core Data
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    Day *currentDayObj = [[DataManager sharedInstance] getDayObjectOfDate:self.currentDate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Set entity name.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pomodoro" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    /********************
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(interrupted = %@) ", [NSNumber numberWithBool:NO]];    
    [fetchRequest setPredicate:predicate];
    *********************/    
    
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(day = %@) ", currentDayObj];     
     [fetchRequest setPredicate:predicate]; 
    
    // Set the sort key.        
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pEndDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    //NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"endDate" cacheName:@"Master"];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"sectionDay" cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    ClawInfo(@"Unresolved error %@, %@", error, [error userInfo]);
	    //abort();
	}    
    return _fetchedResultsController;
}

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

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Pomodoro *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *startTime = [dateFormatter stringFromDate:object.pStartDate];
    NSString *endTime = [dateFormatter stringFromDate:object.pEndDate];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"pomodoro: %@", [object pDurationString]];
        
    if ([object.pInterrupted boolValue]) {
        cell.backgroundColor = [UIColor brownColor];
    }
    else {
        cell.backgroundColor = [UIColor whiteColor];
    }
}



@end
