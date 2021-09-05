#import "ThumbnailPanel.h"

@implementation ThumbnailPanel
//-(BOOL)canBecomeKeyWindow{return YES;}
-(void)awakeFromNib
{
	[self setAcceptsMouseMovedEvents:YES];
	[self makeFirstResponder:matrix];
}

- (void)setTarget:(ThumbnailController *)tar
{
	target = tar;
}

- (void)setAction:(SEL)sel
{
	selector = sel;
}
/*
- (void)mouseMoved:(NSEvent *)theEvent
{
	[super mouseMoved:theEvent];
	NSLog(@"kita0");
}
*/
-(void)becomeKeyWindow
{
	[super becomeKeyWindow];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DontHideMenuBar"] == NO) [NSMenu setMenuBarVisible:NO];
}

-(void)resignKeyWindow
{
	//[self performClose:self];
	[super resignKeyWindow];
}


-(NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)aScreen
{
	if ([NSMenu menuBarVisible]) {
		NSRect result = [[NSScreen mainScreen] frame];
		result.size.height -= 6;
		return result;
	}
	//NSRect result = [[NSScreen mainScreen] frame];
	NSRect result=[super constrainFrameRect:[[NSScreen mainScreen] frame] toScreen:aScreen];
	result.size.height+= 16;
	return result;
}



- (void)performClose:(id)sender
{
	[super performClose:sender];
	[target performSelector:@selector(clearCell)];
}

- (void)sendEvent:(NSEvent *)theEvent
{
	if ([theEvent type] == NSKeyDown) {
		[target performSelector:@selector(action:) withObject:theEvent];
	} else {
		[super sendEvent:theEvent];
	}
}
/*
- (void)keyDown:(NSEvent *)theEvent
{
	NSLog(@"kita");
	[target performSelector:@selector(action:) withObject:theEvent];
}*/



- (void)scrollWheel:(NSEvent *)theEvent
{
	if (setting == 0) {
		return;
	}
	[target performSelector:@selector(wheelAction:) withObject:theEvent];
}

-(void)wheelSetting:(float)set
{
	setting = set;
}

@end
