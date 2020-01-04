//
//  LoupeView.h
//  cooViewer
//
//  Created by coo on 2020/01/02.
//

#import "Controller.h"
#import <Cocoa/Cocoa.h>

@interface LoupeView : NSView
{
    NSPoint mPoint;
    NSRect fRect;
    NSRect sRect;
    float lensRate;
    int rotateMode;
    
    Controller *targetController;
    
    NSAffineTransform *transform;
    int lensSize;
    int interpolation;
    
    NSRect parentFrame;
    
}

-(void)setTargetController:(Controller *)c;
-(void)setMPoint:(NSPoint)p;
-(void)setFRect:(NSRect)fr;
-(void)setSRect:(NSRect)sr;
-(void)setLensRate:(float)lr;
-(void)setLensSize:(int)ls;
-(void)setRotateMode:(int)rm;
-(void)setInterpolation:(int)index;
-(void)setParentFrame:(NSRect)pf;

@end
