#import "COPopUpTextField.h"

@implementation COPopUpTextField
- (void)setMaxSize:(NSSize)size
{
	if (size.width > maxSize.width || size.height > maxSize.height) {
		maxSize = size;
	}
	
}

- (void)awakeFromNib
{
	pb = [[NSPopUpButton alloc] init];
	//maxSize = NSZeroSize;
}

- (void)setMenu:(NSMenu *)aMenu
{
	[pb setMenu:aMenu];
}

- (void)drawRect:(NSRect)aRect
{
	[super drawRect:aRect];
	
	NSImage *image = [NSImage imageNamed:@"updown"];
	NSImageRep *rep = [[image representations] objectAtIndex:0];
	NSRect tempRect = NSMakeRect(aRect.size.width-25,-6,25,25);
	tempRect = NSMakeRect(aRect.size.width-25,-6,25,25);
	
	
	[image drawInRect:tempRect
			 fromRect:NSMakeRect(0,0,[rep pixelsWide],[rep pixelsHigh])
			operation:NSCompositeSourceOver fraction:1.0];
}

- (void)sizeToFit
{
	[self setHidden:YES];
	[super sizeToFit];
	NSRect tempRect = [self frame];
	NSSize tempSize = tempRect.size;
	/*
	if (tempSize.height>maxSize.height) {
		tempRect = NSMakeRect(tempRect.origin.x,tempRect.origin.y,maxSize.width,19)
	}*/
	if (tempSize.width > maxSize.width) {
		tempRect = NSMakeRect(tempRect.origin.x,tempRect.origin.y,maxSize.width-25,19);
	}
	[self setFrame:NSMakeRect(tempRect.origin.x,tempRect.origin.y,tempRect.size.width+25,19)];
	[self setFrame:NSMakeRect(tempRect.origin.x,tempRect.origin.y,tempRect.size.width+25,19)];
	[self setHidden:NO];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	/*
	NSEvent *aMenuEvent;
	NSPoint aMenuLoc;
	aMenuLoc = [self frame].origin;
	aMenuEvent = [ NSEvent mouseEventWithType:[ theEvent type ] 
									 location: aMenuLoc
								modifierFlags:[ theEvent modifierFlags ] 
									timestamp:[ theEvent timestamp ] 
								 windowNumber:[ theEvent windowNumber ]
									  context:[ theEvent context ] 
								  eventNumber:[ theEvent eventNumber ] 
								   clickCount:[ theEvent clickCount ] 
									 pressure:[ theEvent pressure ]];
	
	[ NSMenu popUpContextMenu:[ self menu ] withEvent:aMenuEvent forView:self ];
	 */
	NSRect temp;
	temp = NSMakeRect([self visibleRect].origin.x+8,
					  [self visibleRect].origin.y+20,
					  [self visibleRect].size.width,
					  [self visibleRect].size.height);
	[[pb cell] performClickWithFrame:temp inView:self];
	//[self display];
	//[[pb cell] attachPopUpWithFrame:[self visibleRect]  inView:self];
}
/*
- (void)mouseUp:(NSEvent *)theEvent
{
	[[pb cell] dismissPopUp];
}
*/
@end
