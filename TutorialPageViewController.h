//
//  TutorialPageViewController.h
//  Tomato2
//
//  Created by Teng Lin on 13-11-12.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialPageViewController : UIViewController
{
    int pageNumber;
}

@property (weak, nonatomic) IBOutlet UIView *ImageBackView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (id)initWithPageNumber:(int)page;



@end

