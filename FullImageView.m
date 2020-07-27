//
//  FullImageView.m
//  cooViewer
//

#import "FullImageView.h"
#import "NSImage_Adding.h"


@implementation FullImageView

- (BOOL)isFlipped { return YES; } 


- (void)setImage:(NSImage *)im
{
	NSSize imageSize = ignoreImageDpi ? [im pixelsSize] : [im size];
	[self setFrameSize:imageSize];
	//[self setFrame:NSMakeRect(0,0,imageSize.width,imageSize.height)];
	[super setImage:im];
	/*
	[image autorelease];
	 image = [im retain];
	 [[image bestRepresentationForDevice:nil] drawInRect:[self bounds]];*/
	 /*
	[image drawInRect:[self bounds]
			  fromRect:NSMakeRect(0,0,imageSize.width,imageSize.height)
			 operation:NSCompositeSourceOver fraction:1.0];*/
}

- (void)drawRect:(NSRect)dirtyRect {
	//[super drawRect:dirtyRect];
	NSImage *image = [self image];
	[image drawInRect:[self bounds]
			 fromRect:NSMakeRect(0,0,[image size].width,[image size].height)
			operation:NSCompositingOperationSourceOver
			 fraction:1.0
	   respectFlipped:self.isFlipped
				hints:nil];
}

-(void)mouseDown:(NSEvent *)event
{
	//[[self superview] setDocumentCursor:[NSCursor openHandCursor]];
	oldPoint=[event locationInWindow];
	//    [self addCursorRect:[self bounds] cursor:[NSCursor closedHandCursor]];
	//	[[self superview] scrollToPoint:[event locationInWindow]];
	//	[[NSCursor closedHandCursor] set];
}
/*
-(void)mouseUp:(NSEvent *)event
{
	[[self superview] setDocumentCursor: nil];
}
*/
- (void)mouseDragged:(NSEvent *)event
{
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return;
	}
	
	NSPoint visiblePoint = [clipView documentVisibleRect].origin;
	
	float newY = visiblePoint.y + [event locationInWindow].y - oldPoint.y;
	float newX = visiblePoint.x + oldPoint.x - [event locationInWindow].x;
	if (newY < 0) {
		newY = 0;
	}
	if (newX < 0) {
		newX = 0;
	}
	if (newX > [self bounds].size.width - [clipView documentVisibleRect].size.width){
		newX = [self bounds].size.width - [clipView documentVisibleRect].size.width;
	}
	if (newY > [self bounds].size.height - [clipView documentVisibleRect].size.height) {
		newY = [self bounds].size.height - [clipView documentVisibleRect].size.height;
	}
	
	NSSize imageSize = ignoreImageDpi ? [[self image] pixelsSize] : [[self image] size];
	if (imageSize.width < [clipView documentVisibleRect].size.width) {
		newX = 0;
	}
	/*
	if (imageSize.height == [self bounds].size.height) {
		newY = 0;
	}
	*/
	
	NSPoint newPoint = NSMakePoint(newX,newY);
	
	[clipView scrollToPoint:newPoint];
	[scrollView reflectScrolledClipView:clipView];
	oldPoint=[event locationInWindow];
	
	
	
//	[[self superview] autoscroll:event];
//	NSLog(@"Current mouse point:%@", NSStringFromPoint([event locationInWindow]));
//	[self setNeedsDisplay:YES];
}

- (void)setIgnoreImageDpi:(BOOL)ignoreDpi
{
	ignoreImageDpi = ignoreDpi;
}

- (void)imageScroll:(NSPoint)point
{
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	NSPoint visiblePoint = [clipView documentVisibleRect].origin;
	
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return;
	}
	
	float newY = visiblePoint.y + point.y;
	float newX = visiblePoint.x + point.x;
	if (newY < 0) {
		newY = 0;
	}
	if (newX < 0) {
		newX = 0;
	}
	if (newX > [self bounds].size.width - [clipView documentVisibleRect].size.width){
		newX = [self bounds].size.width - [clipView documentVisibleRect].size.width;
	}
	if (newY > [self bounds].size.height - [clipView documentVisibleRect].size.height) {
		newY = [self bounds].size.height - [clipView documentVisibleRect].size.height;
	}
	NSSize imageSize = ignoreImageDpi ? [[self image] pixelsSize] : [[self image] size];
	if (imageSize.width < [clipView documentVisibleRect].size.width) {
		newX = 0;
	}
	NSPoint newPoint = NSMakePoint(newX,newY);
	
	[clipView scrollToPoint:newPoint];
	[scrollView reflectScrolledClipView:clipView];
}

- (void)scrollToTop
{
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return;
	}
	[clipView scrollToPoint:NSMakePoint(0,0)];
	[scrollView reflectScrolledClipView:clipView];
}

- (void)scrollToLast
{
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return;
	}
	float x = [clipView documentRect].size.width - [clipView documentVisibleRect].size.width;
	float y = [clipView documentRect].size.height - [clipView documentVisibleRect].size.height;
	
	[clipView scrollToPoint:NSMakePoint(x,y)];
	[scrollView reflectScrolledClipView:clipView];
}

- (void)spaceBarAction
{
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return;
	}
	float x = [clipView documentRect].size.width - [clipView documentVisibleRect].size.width;
	float y = [clipView documentRect].size.height - [clipView documentVisibleRect].size.height;
	
	[clipView scrollToPoint:NSMakePoint(x,y)];
	[scrollView reflectScrolledClipView:clipView];
}

- (void)scrollUp
{
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return;
	}
	float x = [clipView documentVisibleRect].origin.x;
	float y = [clipView documentVisibleRect].origin.y - [clipView documentVisibleRect].size.height;
	if (y < 0) {
		y = 0;
	}
	[clipView scrollToPoint:NSMakePoint(x,y)];
	[scrollView reflectScrolledClipView:clipView];
}

- (void)scrollDown
{
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return;
	}
	float x = [clipView documentVisibleRect].origin.x;
	float y = [clipView documentVisibleRect].origin.y + [clipView documentVisibleRect].size.height;
	float max = [clipView documentRect].size.height - [clipView documentVisibleRect].size.height;
	if (y > max) {
		y = max;
	}
	[clipView scrollToPoint:NSMakePoint(x,y)];
	[scrollView reflectScrolledClipView:clipView];
}


@end
