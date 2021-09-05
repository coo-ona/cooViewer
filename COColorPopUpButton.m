#import "COColorPopUpButton.h"


@implementation COColorPopUpButton
- (void)windowDidResignKey:(NSNotification *)aNotification
{
	[[aNotification object] orderOut:self];
	[self changeColor:[aNotification object]];
}

- (void)setCurrentColor:(NSColor*)aColor
{
	[currentColor autorelease];
	currentColor = [aColor retain];
	
	NSArray *itemArray = [self itemArray];
	int i;
	for (i=0;i<[itemArray count];i++) {
		NSMenuItem *item = [self itemAtIndex:i];
		if ([aColor isEqualTo:[item representedObject]]) {
			[self selectItemAtIndex:i];
			item = (NSMenuItem*)[self lastItem];
			[item setImage:nil];
			return;
		}
	}
	
	NSMenuItem *item = [self lastItem];
	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(12,12)];
	[image lockFocus];
	[[NSColor grayColor] set];
	NSFrameRect(NSMakeRect(0,0,12,12));
	[currentColor set];
	NSRectFill(NSMakeRect(1,1,10,10));
	[image unlockFocus];
	[item setImage:image];
	[image release];
	[self selectItemAtIndex:[self numberOfItems]-1];
}

- (NSColor*)currentColor
{
	return currentColor;
}
- (void)changeColor:(id)sender
{
	[currentColor autorelease];
	currentColor = [[sender color] retain];
	
	NSMenuItem *item = [self lastItem];
	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(12,12)];
	[image lockFocus];
	[[NSColor grayColor] set];
	NSFrameRect(NSMakeRect(0,0,12,12));
	[currentColor set];
	NSRectFill(NSMakeRect(1,1,10,10));
	[image unlockFocus];
	[item setImage:image];
	[image release];
	[self selectItemAtIndex:[self numberOfItems]-1];
	
	[[self target] performSelector:[self action] withObject:self];
}

- (void)selectItem:(id)sender
{
	if (sender == [self lastItem]) {
		NSColorPanel *panel = [NSColorPanel sharedColorPanel];
		[panel setColor:currentColor];
		[panel setLevel:NSMainMenuWindowLevel];
		[panel setContinuous:NO];
		[panel setDelegate:(id)self];
		[panel makeKeyAndOrderFront:self];
	} else {
		[self setCurrentColor:[sender representedObject]];
		[[self target] performSelector:[self action] withObject:self];
	}
}

-(void)awakeFromNib
{
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
	
	NSImage *image;
	NSMenuItem *item;
	NSColor *frameColor = [NSColor grayColor];
	NSColor *fillColor;
	
	[self removeAllItems];
	[self addItemWithTitle:@"White"];
	[self addItemWithTitle:@"LightGray"];
	[self addItemWithTitle:@"Gray"];
	[self addItemWithTitle:@"DarkGray"];
	[self addItemWithTitle:@"Black"];
	[self addItemWithTitle:@"Blue"];
	[self addItemWithTitle:@"Cyan"];
	[self addItemWithTitle:@"Green"];
	[self addItemWithTitle:@"Magenta"];
	[self addItemWithTitle:@"Orange"];
	[self addItemWithTitle:@"Purple"];
	[self addItemWithTitle:@"Red"];
	[self addItemWithTitle:@"Yellow"];
	[self addItemWithTitle:@"Clear"];
	[self addItemWithTitle:@"Other..."];
	
	NSArray *itemArray = [self itemArray];
	int i;
	for (i=0;i<[itemArray count];i++) {
		item = (NSMenuItem*)[self itemAtIndex:i];
		NSString *title = [item title];
		
		if ([title isEqualToString:@"Other..."]) {
			[item setAction:@selector(selectItem:)];
			[item setTarget:self];
			return;
		} else if ([title isEqualToString:@"White"]) {
			fillColor = [NSColor whiteColor];
		} else if ([title isEqualToString:@"LightGray"]) {
			fillColor = [NSColor lightGrayColor];
		} else if ([title isEqualToString:@"Gray"]) {
			fillColor = [NSColor grayColor];
		} else if ([title isEqualToString:@"DarkGray"]) {
			fillColor = [NSColor darkGrayColor];
		} else if ([title isEqualToString:@"Black"]) {
			fillColor = [NSColor blackColor];
		} else if ([title isEqualToString:@"Blue"]) {
			fillColor = [NSColor blueColor];
		} else if ([title isEqualToString:@"Brown"]) {
			fillColor = [NSColor brownColor];
		} else if ([title isEqualToString:@"Cyan"]) {
			fillColor = [NSColor cyanColor];
		} else if ([title isEqualToString:@"Green"]) {
			fillColor = [NSColor greenColor];
		} else if ([title isEqualToString:@"Magenta"]) {
			fillColor = [NSColor magentaColor];
		} else if ([title isEqualToString:@"Orange"]) {
			fillColor = [NSColor orangeColor];
		} else if ([title isEqualToString:@"Purple"]) {
			fillColor = [NSColor purpleColor];
		} else if ([title isEqualToString:@"Red"]) {
			fillColor = [NSColor redColor];
		} else if ([title isEqualToString:@"Yellow"]) {
			fillColor = [NSColor yellowColor];
		} 
		if ([title isEqualToString:@"Clear"]) {
			fillColor = [NSColor clearColor];
			NSBezierPath *path = [[NSBezierPath alloc] init];
			[path moveToPoint:NSMakePoint(0,0)];
			[path lineToPoint:NSMakePoint(12,12)];
			[path moveToPoint:NSMakePoint(12,0)];
			[path lineToPoint:NSMakePoint(0,12)];
			image = [[NSImage alloc] initWithSize:NSMakeSize(12,12)];
			[image lockFocus];
			[frameColor set];
			NSFrameRect(NSMakeRect(0,0,12,12));
			[path stroke];
			[image unlockFocus];
			[item setImage:image];
			[item setAction:@selector(selectItem:)];
			[item setTarget:self];
			[item setRepresentedObject:fillColor];
			[image release];
			[path release];
		} else {
			image = [[NSImage alloc] initWithSize:NSMakeSize(12,12)];
			[image lockFocus];
			[frameColor set];
			NSFrameRect(NSMakeRect(0,0,12,12));
			[fillColor set];
			NSRectFill(NSMakeRect(1,1,10,10));
			[image unlockFocus];
			[item setImage:image];
			[item setAction:@selector(selectItem:)];
			[item setTarget:self];
			[item setRepresentedObject:fillColor];
			[image release];
		}
	}
}

@end
