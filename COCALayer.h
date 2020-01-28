//
//  COCALayer.h
//  cooViewer
//
//  Created by coo on 2020/01/11.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface COCALayer : CALayer
{
    int interpolation;
    id tmpContents;
}
-(void)setInterpolation:(int)index;

@end
