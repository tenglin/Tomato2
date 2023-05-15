//
//  HistoryTableViewController.h
//  Tomato
//
//  Created by Lin Teng on 2/1/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HistoryTableCell.h"

@interface HistoryTableViewController : UITableViewController <UITableViewDelegate>

- (void)reloadData;

@end
