#import "CustomWindow.h"
#import "Controller.h"

@implementation CustomWindow

-(void)awakeFromNib
{
	id defaults = [NSUserDefaults standardUserDefaults];
	
	[self setLevel:NSNormalWindowLevel];
	[self setAcceptsMouseMovedEvents:YES];
	fullscreen = [defaults boolForKey:@"Fullscreen"];
	if ([defaults boolForKey:@"DontHideMenuBar"]) {
		hideMenuBar = NO;
	} else {
		hideMenuBar = YES;
	}
	if (![defaults objectForKey:@"NSWindow Frame NormalWindow"]) {
		[self saveFrameUsingName:@"NormalWindow"];
	}
	resizable = YES;
	[self setFullScreen:fullscreen];
	if (!fullscreen) [[[[[NSApp mainMenu] itemWithTitle:NSLocalizedString(@"Window", @"")] submenu] itemWithTitle:NSLocalizedString(@"Fullscreen", @"")] setState:NSOffState];
	[self setShowsResizeIndicator:NO];
}
- (void)setFrame:(NSRect)windowFrame display:(BOOL)displayViews
{
	if (!resizable) {
		return;
	} else {
		[super setFrame:windowFrame display:displayViews];
        [view setAccessoryWindowFrame];
	}	
}
- (void)setFullScreen:(BOOL)b
{	
	fullscreen = b;
	if (!fullscreen) {
		resizable = YES;
		[NSMenu setMenuBarVisible:YES];
		[self setFrameUsingName:@"NormalWindow"];
		[self setHidesOnDeactivate:NO];
	} else {
		[self setFrame:NSMakeRect(0,0,100,100) display:YES];
		[self setHidesOnDeactivate:YES];
		[self setHideMenuBar:hideMenuBar];
		resizable = NO;
	}
}
- (BOOL)isFullScreen
{
	return fullscreen;
}

-(NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)aScreen
{
	if (fullscreen) {
		NSRect result = [[NSScreen mainScreen] frame];
		if (hideMenuBar == YES) result.size.height+= 22;
		return result;
	} else {
		NSRect result = [super constrainFrameRect:frameRect toScreen:aScreen];
		
		NSRect screen = [[NSScreen mainScreen] frame];
		if (result.size.height>screen.size.height || result.size.width>screen.size.width) {
			result = NSMakeRect(0,0,screen.size.height/4,screen.size.width/4);
		}
		return result;
	}
}
- (void)setHideMenuBar:(BOOL)b
{
	hideMenuBar = b;
	if (fullscreen) {
		resizable = YES;
		if (!hideMenuBar) {
			[NSMenu setMenuBarVisible:YES];
			NSRect result = [[NSScreen mainScreen] frame];
			[self setFrame:result display:YES];
		} else {
			if ([self isKeyWindow]) [NSMenu setMenuBarVisible:NO];
			NSRect result = [[NSScreen mainScreen] frame];
			result.size.height += 22;
			[self setFrame:result display:YES];
		}
		resizable = NO;
		[self updateTrackingRect];
	}
}



- (void)setTarget:(id)tar
{
	target = tar;
}

- (void)setAction:(SEL)sel
{
	selector = sel;
}

- (void)keyDown:(NSEvent *)theEvent
{
	if (fullscreen) [NSCursor setHiddenUntilMouseMoves:YES];
	[controller keyAction:theEvent];
}

- (void)performClose:(id)sender
{
	[NSMenu setMenuBarVisible:YES];
	[super performClose:sender];
	[self display];
}

- (BOOL)performKeyEquivalent:(NSEvent *)anEvent
{	
	if (fullscreen) {
		unsigned int cMod = 0;
		BOOL option = ([anEvent modifierFlags] & NSAlternateKeyMask) ? YES : NO;
		BOOL control = ([anEvent modifierFlags] & NSControlKeyMask) ? YES : NO;
		BOOL command = ([anEvent modifierFlags] & NSCommandKeyMask) ? YES : NO;
		
		if (option) cMod += 1;
		if (control) cMod += 2;
		if (command) cMod += 4;
		
		if (cMod == 4 && [[anEvent charactersIgnoringModifiers] isEqualToString:@"m"] && ![NSMenu menuBarVisible]) {
			[NSMenu setMenuBarVisible:YES];
			[NSTimer scheduledTimerWithTimeInterval:0.0
											 target:self
										   selector:@selector(performMiniaturize:)
										   userInfo:NULL
											repeats:NO];
			return YES;
		}
	}
	return [super performKeyEquivalent:anEvent];
}

- (void)performMiniaturize:(id)sender
{
	[NSMenu setMenuBarVisible:YES];
	[super performMiniaturize:sender];	
}

- (void)deminiaturize:(id)sender
{
	[NSMenu setMenuBarVisible:YES];
	[super deminiaturize:sender];
	[NSMenu setMenuBarVisible:YES];
}

- (void)makeKeyAndOrderFront:(id)sender
{
	if (fullscreen) {
		if (![NSMenu menuBarVisible]) {
			[self makeKeyWindow];
		} else {
			[self orderFront:self];
			[self makeKeyWindow];
			if (hideMenuBar) [NSMenu setMenuBarVisible:NO];
		}
		if (hideMenuBar == NO) [NSMenu setMenuBarVisible:YES];
	} else {
		[super makeKeyAndOrderFront:sender];
	}
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	if (fullscreen && [self isKeyWindow]) {
		if (hideMenuBar) [NSMenu setMenuBarVisible:NO];
	}
}


- (void)mouseExited:(NSEvent *)theEvent
{
	if (fullscreen && [self isKeyWindow]) {
		//[NSMenu setMenuBarVisible:YES];
		NSRect fullscreenRect = [[NSScreen mainScreen] frame];
		NSRect newRect = NSOffsetRect(fullscreenRect, 0, -10);
		if (NSPointInRect([theEvent locationInWindow],newRect)) {
			if (hideMenuBar) [NSMenu setMenuBarVisible:NO];
		} else {
			[NSMenu setMenuBarVisible:YES];
		}
	}
}

-(void)updateTrackingRect
{
	if (!fullscreen) return;
	NSRect fullscreenRect = [[NSScreen mainScreen] frame];
	NSRect newRect = NSOffsetRect(fullscreenRect, 0, -10);
	[[self contentView] addTrackingRect:newRect owner:self userData:NULL assumeInside:YES];
}


- (void)cursorHide
{
	if (fullscreen && [self isKeyWindow]) {
		[NSCursor setHiddenUntilMouseMoves:YES];
		cursorTimer = nil;
	}
}


- (void)mouseMoved:(NSEvent *)theEvent
{
	if (fullscreen && !cursorTimer) {
		cursorTimer = [NSTimer scheduledTimerWithTimeInterval:3
													   target:self
													 selector:@selector(cursorHide)
													 userInfo:NULL
													  repeats:NO];
	}
	[view mouseMoved:theEvent];
}

-(void)becomeKeyWindow
{
	[super becomeKeyWindow];
	if (fullscreen && hideMenuBar) {
		[NSMenu setMenuBarVisible:NO];
	} else {
		[NSMenu setMenuBarVisible:YES];
	}
}




@end
