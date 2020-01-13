//
//  COTextView.m
//  cooViewer
//
//  Created by coo on 08/02/17.
//  Copyright 2008 coo. All rights reserved.
//

#import "COTextView.h"


@implementation COTextView
- (void)setTarget:(id)tar
{
	target = tar;
	[self setSelectedTextAttributes:[NSDictionary dictionary]];
}

- (void)setAction:(SEL)sel
{
	selector = sel;
}

- (void)keyDown:(NSEvent *)theEvent
{
	[target performSelector:selector withObject:theEvent];	
}
- (BOOL)shouldDrawInsertionPoint
{
	return NO;
}
- (BOOL)becomeFirstResponder
{
	[self setBackgroundColor:[NSColor lightGrayColor]];
	return YES;
}
- (BOOL)resignFirstResponder
{
	[self setBackgroundColor:[NSColor whiteColor]];
	return YES;
}
- (void)mouseMoved:(NSEvent *)theEvent
{
	[[NSCursor arrowCursor] set];
}
/*
- (void)resetCursorRects
{
	[self discardCursorRects];
}
*/
@end
