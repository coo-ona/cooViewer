//
//  COCALayer.m
//  cooViewer
//
//  Created by coo on 2020/01/11.
//


#import "COCALayer.h"


@implementation COCALayer
-(void)setInterpolation:(int)index
{
    interpolation = index;
}
- (void)drawInContext:(CGContextRef)ctx
{
    CGContextRef context = ctx;
    CGContextRetain(context);
    CGContextSaveGState(context);
    switch (interpolation) {
        case 1:
            CGContextSetInterpolationQuality(context,kCGInterpolationNone);
            break;
        case 2:
            CGContextSetInterpolationQuality(context,kCGInterpolationLow);
            break;
        case 3:
            CGContextSetInterpolationQuality(context,kCGInterpolationHigh);
            break;
        default:
            CGContextSetInterpolationQuality(context,kCGInterpolationDefault);
            break;
    }
    CGImageRef imageRef = [[self contents] CGImageForProposedRect:nil context:nil hints:nil];
    CGRect rect = [self bounds];
    CGContextDrawImage(context, rect, imageRef);
    CGContextRestoreGState(context);
    CGContextRelease(context);
}

- (void)display {
    [super display];
    [self removeAllAnimations];
}

@end
