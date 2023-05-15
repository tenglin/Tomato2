//
//  HistoryTableCell.h
//  Tomato
//
//  Created by Lin Teng on 2/4/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *weekLabel;
@property (nonatomic, retain) IBOutlet UILabel *countLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@end
