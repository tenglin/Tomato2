//
//  InfoBoxView.h
//  Tomato
//
//  Created by Lin Teng on 2/26/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoBoxView : UIView

@property (nonatomic,retain)UIFont *font;
@property (nonatomic,retain)UIColor *fontColor;
@property (nonatomic,assign)BOOL boxShadow;
@property (nonatomic,assign)BOOL boxCorner;

@property (nonatomic,retain)UILabel *titleLabel;

- (void)initWithTitle:(NSString *)title withBoxColor:(UIColor *)boxColor;
- (void)setInfoTitle:(NSString*)title;


//- (void)initInfoBoxWithTitles:(NSArray *)titles withSquareColor:(NSArray *)sqColor;

@end
