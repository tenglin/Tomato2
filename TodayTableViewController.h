//
//  TodayTableViewController.h
//  Tomato
//
//  Created by Lin Teng on 1/6/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
