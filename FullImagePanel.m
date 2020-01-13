

#import "FullImagePanel.h"
#import "FullImageView.h"

@implementation FullImagePanel
-(void)awakeFromNib
{
	keyArray = nil;
}
-(void)setTarget:(id)tar
{
	target = tar;
}

-(void)resignKeyWindow
{
	[self performClose:self];
	[super resignKeyWindow];
}


-(void)becomeKeyWindow
{
	[super becomeKeyWindow];
	
	if ([[[NSApp windowsMenu] itemWithTitle:NSLocalizedString(@"Fullscreen", @"")] state] == NSOnState){
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DontHideMenuBar"] == NO) [NSMenu setMenuBarVisible:NO];
	}
	 
}


- (void)keyDown:(NSEvent *)event
{
	id view = [[[[self contentView] subviews] objectAtIndex:0] documentView];
	NSString *characters = [event charactersIgnoringModifiers];
    unichar character = [characters characterAtIndex: 0];
	unsigned short  key=[event keyCode];
	if (key ==  0x7e){
		//up
		[view imageScroll:NSMakePoint(0,-20)];
	} else if (key ==  0x7c){
		//right
		[view imageScroll:NSMakePoint(20,0)];
	} else if (key ==  0x7d){
		//down
		[view imageScroll:NSMakePoint(0,20)];
	} else 	if (key ==  0x7b){
		//left
		[view imageScroll:NSMakePoint(-20,0)];
	} else if (key == 0x73) {
		// home
		//[view imageScroll:NSMakePoint(0,30000)];
		[view scrollToTop];
		//[view imageScroll:[[[[self contentView] subviews] objectAtIndex:0] pageScroll]];
	} else if (key == 0x77) {
		// end
		//[view imageScroll:NSMakePoint(0,-30000)];
		[view scrollToLast];
	} else if (key == 0x79) {
		// pgdn
		//[view imageScroll:NSMakePoint(0,30000)];
		[view scrollDown];
		//[view imageScroll:[[[[self contentView] subviews] objectAtIndex:0] pageScroll]];
	} else if (key == 0x74) {
		// pgup
		//[view imageScroll:NSMakePoint(0,-30000)];
		[view scrollUp];
	} else if (character == 0x20) {
		// space
		//[view spaceBarAction];
		
		BOOL shiftTemp = ([event modifierFlags] & NSShiftKeyMask) ? YES : NO;
		
		//NSScrollView *scrollView = [[[self contentView] subviews] objectAtIndex:0];
		NSScrollView *scrollView = [view enclosingScrollView];
		NSClipView *clipView = [scrollView contentView];
		
		if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
			if (!shiftTemp) {
				//[target nextOriginal];
				[target performSelector:@selector(nextOriginal) withObject:nil];
				[view scrollToTop];
				[self setSelfMaxSize];
			} else {
				//[target prevOriginal];
				[target performSelector:@selector(prevOriginal) withObject:nil];
				[view scrollToTop];
				[self setSelfMaxSize];
			}
		} else if ([clipView documentVisibleRect].origin.y == [clipView documentRect].size.height-[clipView frame].size.height && !shiftTemp) {
			//[target nextOriginal];
			[target performSelector:@selector(nextOriginal) withObject:nil];
			[view scrollToTop];
			[self setSelfMaxSize];
		} else if ([clipView documentVisibleRect].origin.y == 0 && shiftTemp) {
			//[target prevOriginal];
			[target performSelector:@selector(prevOriginal) withObject:nil];
			[view scrollToTop];
			[self setSelfMaxSize];
		} else {
			if (shiftTemp) {
				[view scrollUp];
			} else {
				[view scrollDown];
			}
		}
		
	} else {
		NSEnumerator *enu = [keyArray objectEnumerator];
		id dic;
		
		unsigned int cMod = 0;
		BOOL shift = ([event modifierFlags] & NSShiftKeyMask) ? YES : NO;
		BOOL option = ([event modifierFlags] & NSAlternateKeyMask) ? YES : NO;
		BOOL control = ([event modifierFlags] & NSControlKeyMask) ? YES : NO;
		
		if (shift) cMod += 1;
		if (option) cMod += 2;
		if (control) cMod += 4;
		
		while (dic = [enu nextObject]) {
			if (character == [[dic objectForKey:@"key"] characterAtIndex:0] && cMod == [[dic objectForKey:@"modifier"] intValue]){
				int action = [[dic objectForKey:@"action"] intValue];
				switch (action) {
					case 0:
						//[target nextOriginal];
						[target performSelector:@selector(nextOriginal) withObject:nil];
						[view scrollToTop];
						[self setSelfMaxSize];
						break;
					case 1:
						//[target prevOriginal];
						[target performSelector:@selector(prevOriginal) withObject:nil];
						[view scrollToTop];
						[self setSelfMaxSize];
						break;
					default:
						break;
				}
				return;
			}
		}
		[super keyDown:event];
	}
}

-(void)setSelfMaxSize
{
	NSRect fullscreenRect = [[NSScreen mainScreen] frame];
	id view = [[[[self contentView] subviews] objectAtIndex:0] documentView];
	
	NSScrollView *scrollView = [view enclosingScrollView];
	NSSize theScrollViewSize = [NSScrollView
				  frameSizeForContentSize:[view frame].size
					hasHorizontalScroller:[scrollView hasHorizontalScroller]
					  hasVerticalScroller:[scrollView hasVerticalScroller]
							   borderType:[scrollView borderType]
		];
	NSRect theScrollViewRect;
	theScrollViewRect.origin = NSZeroPoint;
	theScrollViewRect.size = theScrollViewSize;
	NSRect theWindowMaxRect = [ NSWindow
				 frameRectForContentRect:theScrollViewRect
							   styleMask:[self styleMask]
		];
	if (theWindowMaxRect.size.width > fullscreenRect.size.width) {
		theWindowMaxRect.size.width = fullscreenRect.size.width;
	}
	if (theWindowMaxRect.size.height > fullscreenRect.size.height) {
		theWindowMaxRect.size.height = fullscreenRect.size.height;
	}
	[self setMaxSize:theWindowMaxRect.size];
	if (fitMode) {
		[self setContentSize:theScrollViewSize];
		if ([self frame].size.width + [self frame].origin.x > NSWidth(fullscreenRect)) {
			float x = NSWidth(fullscreenRect) - [self frame].size.width;
			float y = [self frame].origin.y;
			if (x<0) x=0;
			[self setFrameOrigin:NSMakePoint(x,y)];
		}
	}
}

-(void)setPageKey:(NSArray*)array
{
	[keyArray autorelease];
	keyArray = [array retain];
}

- (BOOL)windowShouldClose:(id)sender
{
	[[[[[self contentView] subviews] objectAtIndex:0] documentView] setImage:nil];
	return YES;
}

- (void)setFitMode:(BOOL)yes
{
	fitMode = yes;
}
/*
- (void)setLevel:(int)level
{
	//[super setLevel:NSNormalWindowLevel];
	
	if ([[[NSApp windowsMenu] itemWithTitle:NSLocalizedString(@"Fullscreen", @"")] state] == NSOffState){
		[super setLevel:NSNormalWindowLevel];
	} else {
		if (level == NSPopUpMenuWindowLevel) {
			[super setLevel:NSPopUpMenuWindowLevel];
			//[super setLevel:NSScreenSaverWindowLevel];
		} else {
			[super setLevel:level];
		}
	}
	
}
*/
/*
- (void)zoom:(id)sender
{
	[self setMaxSize:[[NSScreen mainScreen] frame]];
}
*/
@end
