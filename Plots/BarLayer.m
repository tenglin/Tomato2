//
//  BarStripLayer.m
//  Tomato
//
//  Created by Lin Teng on 3/1/13.
//  Copyright (c) 2013 Teng Lin. All rights reserved.
//

#import "BarLayer.h"
#import "UIColor+Utils.h"
#import "MyGlobal.h"

@implementation BarLayer
@dynamic dynamicBarHeight;

- (NSString*)description
{
    return [NSString stringWithFormat:@"dynamicBarHeight:%f",  self.dynamicBarHeight];
}

- (CABasicAnimation *)makeAnimationForKey:(NSString *)key {
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
	anim.fromValue = [[self presentationLayer] valueForKey:key];
    if (!anim.fromValue) {
        anim.fromValue = [NSNumber numberWithFloat:0];
    }
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	anim.duration = 1.0;
    
	return anim;
}

- (id)init {
    self = [super init];
    if (self) {		        
        [self setNeedsDisplay];
    }
    return self;
}

-(id<CAAction>)actionForKey:(NSString *)event {
	if ([event isEqualToString:@"dynamicBarHeight"] && kAnimationHistoryGraphBarLayer) {
		return [self makeAnimationForKey:event];
	}
    else {
        return nil;
    }	    
	//return [super actionForKey:event];
}

- (id)initWithLayer:(id)layer {
	if (self = [super initWithLayer:layer]) {
		if ([layer isKindOfClass:[BarLayer class]]) {
            //ClawInfo(@"initWithLayer layer: %@", layer);
			BarLayer *other = (BarLayer *)layer;
			self.dynamicBarHeight = other.dynamicBarHeight;
            self.topLabel = other.topLabel;
            self.values = other.values;
		}
	}	
	return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
	if ([key isEqualToString:@"dynamicBarHeight"]) {
		return YES;
	}	
	return [super needsDisplayForKey:key];
}

-(void)drawInContext:(CGContextRef)ctx {
	//ClawInfo(@"drawInContext self: %@", self);	            
    
    UIFont *topLabelFont = [UIFont systemFontOfSize:18];
    CGSize sizeOfText = [self.topLabel sizeWithFont:topLabelFont];
    
//    if (self.dynamicBarHeight > 0 && self.values && [self.values count] > 0) {
//        CGFloat offsetY = self.bounds.size.height;
//        for (int i = 0; i < [self.values count]; i++) {
//            NSNumber *value = [self.values objectAtIndex:i];
//            offsetY = offsetY - value.floatValue * self.dynamicBarHeight;
//            CGContextSetFillColorWithColor(ctx, [UIColor colorForGreenOfIndex:i fromSum:[self.values count]].CGColor);
//            CGContextFillRect(ctx, CGRectMake(0 , offsetY, self.bounds.size.width, self.dynamicBarHeight * value.floatValue +1));            
//        }
//    }
    
    CGContextSetFillColorWithColor(ctx, [UIColor colorForGreenOfIndex:0 fromSum:3].CGColor);
    CGContextFillRect(ctx, CGRectMake(0 , self.bounds.size.height - self.dynamicBarHeight, self.bounds.size.width, self.dynamicBarHeight));
    
    UIGraphicsPushContext(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);    
    [self.topLabel drawAtPoint:CGPointMake(self.bounds.size.width/2 - sizeOfText.width/2, self.bounds.size.height - self.dynamicBarHeight - sizeOfText.height)  withFont:topLabelFont];    
    UIGraphicsPopContext();
}

@end
