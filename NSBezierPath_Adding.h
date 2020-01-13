//
//  NSBezierPath_Adding.h
//  cooViewer
//
//  Created by coo on 08/02/11.
//  Copyright 2008 coo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (Adding)
+ (NSBezierPath*)bezierPathWithRectWithDoubleArc:(NSRect)rect;
+ (NSBezierPath*)bezierPathWithRectWithArc:(NSRect)rect rad:(int)rad open:(int)open;
@end
