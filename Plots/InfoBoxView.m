//
//  InfoBoxView.m
//  Tomato
//
//  Created by Lin Teng on 2/26/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "InfoBoxView.h"
#import <QuartzCore/QuartzCore.h>

@implementation InfoBoxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        self.font=[UIFont fontWithName:@"Helvetica" size:16];
        self.fontColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)initWithTitle:(NSString *)title withBoxColor:(UIColor *)boxColor
{    
    
    CALayer *boxLayer = [CALayer layer];
    boxLayer.frame = CGRectMake(0, 0, 20, 20);
    boxLayer.backgroundColor = boxColor.CGColor;
    
    //Its not working right for some reason.
    if(self.boxShadow) {
        /*
        [boxLabel.layer setShadowRadius:5.0];
        [boxLabel.layer setShadowColor:[UIColor redColor].CGColor];
        [boxLabel.layer setShadowOffset:CGSizeMake(3, 0)];
        [boxLabel.layer setShadowOpacity:0.5];
        */        
        boxLayer.shadowRadius = 5;
        boxLayer.shadowColor = [UIColor blackColor].CGColor;
        boxLayer.shadowOpacity = 0.6;
        boxLayer.shadowOffset = CGSizeMake(0.0, 2.5);
    }
    
    if(self.boxCorner) {
        boxLayer.cornerRadius=3.0;
    }            
    
   [self.layer addSublayer:boxLayer];    
    
    self.titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(25, 0, CGRectGetWidth(self.frame)-25, 20)];
    
    
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:self.font];
    [self.titleLabel setTextColor:self.fontColor];
    [self.titleLabel setText:title];    
    
    [self addSubview:self.titleLabel];
}

- (void)setInfoTitle:(NSString*)title
{
    [self.titleLabel setText:title];  
}


@end
