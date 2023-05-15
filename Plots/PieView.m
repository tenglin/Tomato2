//
//  PieView.m
//  PieChart
//
//  Created by Pavan Podila on 2/21/12.
//  Copyright (c) 2012 Pixel-in-Gene. All rights reserved.
//

#import "PieView.h"
#import "PieSliceLayer.h"
#import <QuartzCore/QuartzCore.h>

#define DEG2RAD(angle) angle*M_PI/180.0
static const CGFloat PercentageCircleRadius = 80.0;

@interface PieView() {
    
}

@property (nonatomic, strong) CALayer *containerLayer;
@property (nonatomic, strong) PieSliceLayer *shadowLayer;

@property (nonatomic, strong) NSArray *sliceColors;
@property (nonatomic, strong) NSArray *sliceValues;

@property (nonatomic, strong) NSMutableArray *normalizedValues;

@end

@implementation PieView
@synthesize sliceValues = _sliceValues;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self doInitialSetup];
    }	
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		[self doInitialSetup];
	}	
	return self;
}

- (void)loadWithSliceValues:(NSArray*)sliceValues withSliceColor:(NSArray*)sliceColors
{
	if (self) {
        self.sliceColors = sliceColors;
		self.sliceValues = sliceValues;
    }	
}

- (void)reloadData
{
    self.containerLayer.frame = self.bounds;
    //[self.containerLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    self.containerLayer.sublayers = nil;
	
	// Adjust number of slices
	if (self.normalizedValues.count > self.containerLayer.sublayers.count) {
		int count = self.normalizedValues.count - self.containerLayer.sublayers.count;
		for (int i = 0; i < count; i++) {
			PieSliceLayer *slice = [PieSliceLayer layer];
			slice.strokeColor = [UIColor colorWithWhite:0.25 alpha:1.0];
			slice.strokeWidth = 0.5;
			slice.frame = self.bounds;
			[self.containerLayer addSublayer:slice];
		}
	}
	else if (self.normalizedValues.count < self.containerLayer.sublayers.count) {
		int count = self.containerLayer.sublayers.count - self.normalizedValues.count;
		for (int i = 0; i < count; i++) {
			[[self.containerLayer.sublayers objectAtIndex:0] removeFromSuperlayer];
		}
	}
	
	// Set the angles on the slices
	CGFloat startAngle = self.startPieAngle;
	int index = 0;
	CGFloat count = self.normalizedValues.count;
	for (NSNumber *num in self.normalizedValues) {
		CGFloat angle = num.floatValue * 2 * M_PI;
		
		ClawInfo(@"Angle = %f", angle);
		
		PieSliceLayer *slice = [self.containerLayer.sublayers objectAtIndex:index];
        if (self.sliceColors) {
            slice.fillColor = [self.sliceColors objectAtIndex:index];
        }
        else {
            slice.fillColor = [UIColor colorWithHue:index/count saturation:0.5 brightness:0.75 alpha:1.0];
        }
		//
        //
        if (index == count-1) {
            // the last slice
            slice.startAngleFrom = self.startPieAngle;
            slice.endAngleFrom = self.startPieAngle + 2*M_PI;
            slice.startAngle = startAngle;
            slice.endAngle = startAngle + angle;            
        }
        else {
            slice.startAngleFrom = self.startPieAngle;
            slice.endAngleFrom = self.startPieAngle;
            slice.startAngle = startAngle;
            slice.endAngle = startAngle + angle;
        }        
        if (self.showLabel) {
            if (self.showPercentage) {
                slice.labelText = [NSString stringWithFormat:@"%d", (int)(num.floatValue*100)];
            }
            else {
                slice.labelText = [NSString stringWithFormat:@"%d", ((NSNumber*)[self.sliceValues objectAtIndex:index]).intValue];
            }
        }
		slice.showLabel = self.showLabel;
        slice.showStroke = self.showStroke;
        
		startAngle += angle;
		index++;
        
       
	}
    
    // hide the percentage center label
    if (!self.showPercentage || !self.showLabel) {
        for (CALayer *layer in self.layer.sublayers) {
            if ([layer isKindOfClass:[CAShapeLayer class]]) {
                layer.hidden = YES;
                break;
            }
        }
    }
    
    if (self.showShadow) {
        [self addShadowLayer];
    }    
}

- (void)clearUiData
{
    if (_shadowLayer) {
        [_shadowLayer removeFromSuperlayer];
        _shadowLayer = nil;
    }
    
    //[_containerLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    _containerLayer.sublayers = nil;
}

#pragma mark - private methods

-(void)doInitialSetup {
	self.containerLayer = [CALayer layer];
	[self.layer addSublayer:self.containerLayer];
    [self addPercentageCircleLayer];
}

- (void)addPercentageCircleLayer
{
	CAShapeLayer *circleLayer = [CAShapeLayer layer];
	
	CGPoint offset = CGPointMake((self.bounds.size.width-PercentageCircleRadius)/2, (self.bounds.size.height-PercentageCircleRadius)/2);
	circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(offset.x, offset.y, PercentageCircleRadius, PercentageCircleRadius)].CGPath;
	circleLayer.fillColor = [UIColor colorWithWhite:0.75 alpha:1.0].CGColor;
	circleLayer.frame = self.bounds;
    [self.layer addSublayer:circleLayer];
    
    // add the % symbol
    CATextLayer *textLayer = [CATextLayer layer];
    UIFont *font = [UIFont systemFontOfSize:36];
    CGSize size = [@"%" sizeWithFont:font];
    [textLayer setFontSize:36];
    //[textLayer setFont:(__bridge CFTypeRef)(font)];
	
    [textLayer setString:@"%"];
    [textLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
    [textLayer setPosition:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [circleLayer addSublayer:textLayer];
}

-(void)setSliceValues:(NSArray *)sliceValues {
	_sliceValues = sliceValues;
	
	self.normalizedValues = [NSMutableArray array];
	if (sliceValues) {
		// total
		CGFloat total = 0.0;
		for (NSNumber *num in sliceValues) {
			total += num.floatValue;
		}		
		// normalize
		for (NSNumber *num in sliceValues) {
			[self.normalizedValues addObject:[NSNumber numberWithFloat:num.floatValue/total]];
		}
	}
	
	[self reloadData];
}

- (void)addShadowLayer
{
    // remove old shadow layer       
    if (_shadowLayer) {
        [_shadowLayer removeFromSuperlayer];
    }       
    // add new shadow layer
    _shadowLayer = [PieSliceLayer layer];    
    _shadowLayer.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    _shadowLayer.fillColor = [UIColor colorWithHue:0.0 saturation:0.5 brightness:0.75 alpha:1.0];
    _shadowLayer.startAngleFrom = self.startPieAngle;
    _shadowLayer.endAngleFrom = self.startPieAngle;
    _shadowLayer.startAngle = self.startPieAngle;
    _shadowLayer.endAngle = self.startPieAngle + 2*M_PI;
    _shadowLayer.zPosition = -1;
    
    _shadowLayer.shadowRadius = 10;
    _shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    _shadowLayer.shadowOpacity = 0.6;
    _shadowLayer.shadowOffset = CGSizeMake(0.0, 5.0);
    
    [self.layer addSublayer:_shadowLayer];
}

@end
