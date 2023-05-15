//
//  ViewController.h
//  Tomato2
//
//  Created by Teng Lin on 13-11-11.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IASKAppSettingsViewController.h"
#import "TomatoManagerDelegate.h"

@interface ViewController : UIViewController <UIActionSheetDelegate, IASKSettingsDelegate, TomatoManagerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
