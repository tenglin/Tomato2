//
//  PieSliceLayer.m
//  PieChart
//
//  Created by Pavan Podila on 2/20/12.
//  Copyright (c) 2012 Pixel-in-Gene. All rights reserved.
//

#import "PieSliceLayer.h"

@implementation PieSliceLayer
@dynamic startAngle, endAngle;

- (NSString*)description
{
    return [NSString stringWithFormat:@"startAngle:%f, endAngle:%f", self.startAngle/M_PI*180,  self.endAngle/M_PI*180];
}

-(CABasicAnimation *)makeAnimationForKey:(NSString *)key {
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
	anim.fromValue = [[self presentationLayer] valueForKey:key];
    if (!anim.fromValue) {
        if ([key isEqualToString:@"startAngle"]) {
            anim.fromValue = [NSNumber numberWithFloat:self.startAngleFrom];
        }
        else if ([key isEqualToString:@"endAngle"]) {
            anim.fromValue = [NSNumber numberWithFloat:self.endAngleFrom];
        }        
    }
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	anim.duration = 1.0;

	return anim;
}

- (id)init {
    self = [super init];
    if (self) {                
		self.fillColor = [UIColor grayColor];
        
        //self.showStroke = YES;
        self.strokeColor = [UIColor blackColor];
		self.strokeWidth = 1.0;        
        
        //self.showLabel = YES;
        self.labelFont = [UIFont boldSystemFontOfSize:18];
        self.labelColor = [UIColor whiteColor];
        self.labelShadowColor = [UIColor blackColor];

        [self setNeedsDisplay];        
    }	
    return self;
}

-(id<CAAction>)actionForKey:(NSString *)event {
	if ([event isEqualToString:@"startAngle"] ||
		[event isEqualToString:@"endAngle"]) {
		return [self makeAnimationForKey:event];
	}
	
	return [super actionForKey:event];
}

- (id)initWithLayer:(id)layer {
	if (self = [super initWithLayer:layer]) {
		if ([layer isKindOfClass:[PieSliceLayer class]]) {
            //ClawInfo(@"initWithLayer layer: %@", layer);                 
			PieSliceLayer *other = (PieSliceLayer *)layer;
			self.startAngle = other.startAngle;
			self.endAngle = other.endAngle;
			self.fillColor = other.fillColor;

            self.showStroke = other.showStroke;
			self.strokeColor = other.strokeColor;
			self.strokeWidth = other.strokeWidth;
            
            //
            self.showLabel = other.showLabel;
            self.labelText = other.labelText;
            self.labelFont = other.labelFont;
            self.labelColor = other.labelColor;
            self.labelShadowColor = other.labelShadowColor;            
		}
	}
	
	return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
	if ([key isEqualToString:@"startAngle"] || [key isEqualToString:@"endAngle"]) {        
		return YES;
	}
	
	return [super needsDisplayForKey:key];
}

-(void)drawInContext:(CGContextRef)ctx {
	//ClawInfo(@"drawInContext self: %@", self);
	// Create the path
	CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	CGFloat radius = MIN(center.x, center.y)-5;
    
    self.pieCenter = center;
    self.pieRadius = radius;       

	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, center.x, center.y);
	
	CGPoint p1 = CGPointMake(center.x + radius * cosf(self.startAngle), center.y + radius * sinf(self.startAngle));
	CGContextAddLineToPoint(ctx, p1.x, p1.y);

	int clockwise = self.startAngle > self.endAngle;
	CGContextAddArc(ctx, center.x, center.y, radius, self.startAngle, self.endAngle, clockwise);

//	CGContextAddLineToPoint(ctx, center.x, center.y);

	CGContextClosePath(ctx);
	
	// Color it
	CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    if (self.showStroke) {
        CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
        CGContextSetLineWidth(ctx, self.strokeWidth);
        CGContextDrawPath(ctx, kCGPathFillStroke);
    }
	else {
        CGContextDrawPath(ctx, kCGPathFill);
    }		
        
    // Label    
    if (!self.showLabel || !self.labelText) {
        return;
    }
    self.labelRadius = self.pieRadius * 0.7;
    CGFloat interpolatedMidAngle = (self.startAngle + self.endAngle) / 2;
    
    CGSize size = [self.labelText sizeWithFont:self.labelFont];
    
    if((self.endAngle - self.startAngle)*self.labelRadius < MAX(size.width,size.height))
    {
        ClawInfo(@"arc %f is small than max of width %f and height %f ", (self.endAngle - self.startAngle)*self.labelRadius, size.width, size.height );
        return;
    }
    else
    {
        /*
        //how to make CGContextShowTextAtPoint work
        CGContextSetFillColorWithColor(ctx, self.labelColor.CGColor);
        CGContextSelectFont(ctx, [self.labelFont.fontName UTF8String], self.labelFont.pointSize, kCGEncodingMacRoman);
        
       // CGContextSelectFont(ctx, "Arial", 24, kCGEncodingMacRoman);
        
        CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1.0, -1.0));
        CGContextShowTextAtPoint(ctx, center.x + (self.labelRadius * cos(interpolatedMidAngle)) - size.width/2, center.y + (self.labelRadius * sin(interpolatedMidAngle)) + 8, [self.labelText UTF8String], strlen([self.labelText UTF8String]));
        
        //CGContextShowTextAtPoint(ctx, center.x + (self.labelRadius * cos(interpolatedMidAngle)) - size.width/2, center.y + (self.labelRadius * sin(interpolatedMidAngle)) + size.height/2, [self.labelText UTF8String], strlen([self.labelText UTF8String]));
        */
        //how to make drawAtPoint work
        CGContextSetFillColorWithColor(ctx, self.labelColor.CGColor);        
        UIGraphicsPushContext(ctx);
        //[text drawAtPoint:CGPointMake(center.x + (self.labelRadius * cos(interpolatedMidAngle)), center.y + (self.labelRadius * sin(interpolatedMidAngle))) withFont:[UIFont fontWithName:@"Helvetica" size:36.0]];
        [self.labelText drawAtPoint:CGPointMake(center.x + (self.labelRadius * cos(interpolatedMidAngle)) - size.width/2, center.y + (self.labelRadius * sin(interpolatedMidAngle)) -size.height/2)  withFont:self.labelFont];
        UIGraphicsPopContext();

    }
}
@end
