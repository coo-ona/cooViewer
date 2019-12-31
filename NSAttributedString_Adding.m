//
//  NSAttributedString_Adding.m
//  cooViewer
//
//  Created by coo on 08/02/11.
//  Copyright 2008 coo. All rights reserved.
//

#import "NSAttributedString_Adding.h"
#import "NSBezierPath_Adding.h"


@implementation NSAttributedString (Adding)

-(void)drawInRect:(NSRect)rect bg:(NSColor*)bg border:(NSColor*)border
{
	if (bg || border) {
		NSPoint temp = rect.origin;
		temp.x+=1;
		temp.y+=1;
		int rad = [self size].height/2;
		NSRect tempRect = NSMakeRect(temp.x,temp.y,rad+[self size].width+rad,[self size].height+1);
		
		NSBezierPath *bezier = [NSBezierPath bezierPathWithRectWithDoubleArc:tempRect];
		[bezier closePath];
		if (bg) {
			[bg set];
			[bezier fill];
		}
		if (border) {
			[border set];
			[bezier stroke];
		}
		NSPoint tempPt = NSMakePoint(temp.x+rad,temp.y+1);
		[self drawInRect:NSMakeRect(tempPt.x,tempPt.y,[self size].width,[self size].height)];
	} else {
		[self drawInRect:rect];
	}
}

-(void)drawInRect:(NSRect)rect bg:(NSColor*)bg
{
	[self drawInRect:rect bg:bg border:nil];
}

-(void)drawAtPoint:(NSPoint)pt bg:(NSColor*)bg border:(NSColor*)border
{
	if (bg || border) {
		NSPoint temp = pt;
		temp.x+=1;
		temp.y+=1;
		int rad = [self size].height/2;
		NSRect tempRect = NSMakeRect(temp.x,temp.y,rad+[self size].width+rad,[self size].height+1);
		
		NSBezierPath *bezier = [NSBezierPath bezierPathWithRectWithDoubleArc:tempRect];
		[bezier closePath];
		if (bg) {
			[bg set];
			[bezier fill];
		}
		if (border) {
			[border set];
			[bezier stroke];
		}
		NSPoint tempPt = NSMakePoint(temp.x+rad,temp.y+1);
		[self drawAtPoint:tempPt];
	} else {
		[self drawAtPoint:pt];
	}
}

-(void)drawAtPoint:(NSPoint)pt bg:(NSColor*)bg
{
	[self drawAtPoint:pt bg:bg border:nil];
}

-(NSSize)sizeWithBG
{
	int rad = [self size].height/2;
	return NSMakeSize(rad+[self size].width+rad+2,[self size].height+4);
}
@end
