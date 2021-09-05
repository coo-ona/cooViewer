#import "ThumbnailMatrix.h"
#import "NSBezierPath_Adding.h"
#import "NSAttributedString_Adding.h"

@implementation ThumbnailMatrix

- (void)awakeFromNib
{
	lastPoint =  NSZeroPoint;
	mouseDownPoint =  NSZeroPoint;
	lastRect =  NSZeroRect;
	bmarray = [[NSMutableArray alloc] init];
	attrString = nil;
}

- (void)setBookmarkIconAtRow:(int)row column:(int)column left:(BOOL)b
{
	[bmarray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromRect([self cellFrameAtRow:row column:column]),@"frame",
		[NSNumber numberWithInt:row],@"row",
		[NSNumber numberWithInt:column],@"column",
		[NSNumber numberWithBool:b],@"left",
		nil]];
}
- (void)removeBookmarkIconAtRow:(int)row column:(int)column
{
	id object;
	int index;
	for (index = 0; index<[bmarray count]; index++) {
		object = [bmarray objectAtIndex:index];
		if ([[object objectForKey:@"row"] intValue] == row && [[object objectForKey:@"column"] intValue] == column) {
			[bmarray removeObject:object];
		}
	}
}

- (void)resetBookMarkIcon
{
	[bmarray removeAllObjects];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	id object;
	int index;
	for (index=0; index<[bmarray count]; index++) {
		object = [bmarray objectAtIndex:index];
		if (NSEqualRects(NSRectFromString([object objectForKey:@"frame"]),rect)) {
			int row = [[object objectForKey:@"row"] intValue];
			int col = [[object objectForKey:@"column"] intValue];
			id cell = [self cellAtRow:row column:col];
			NSRect imageRect = [cell imageRectForBounds:[self cellFrameAtRow:row column:col]];
			if ([[object objectForKey:@"left"] boolValue]) {
				imageRect.origin.x += 4;
			} else {
				imageRect.origin.x += imageRect.size.width;
				imageRect.origin.x -= 24+4;
			}
			imageRect.origin.y += 4;
			imageRect.size.width = 24;
			imageRect.size.height = 24;
			
			NSBezierPath *bezier = [NSBezierPath bezierPathWithRectWithArc:imageRect rad:7.0 open:0];
			[bezier closePath];
			[[[NSColor blackColor] colorWithAlphaComponent:0.8] set];
			[bezier fill];
			
			NSImage *image = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bookmark_a" ofType:@"tiff"]] autorelease];
			
			imageRect.origin.y+=1;
			[image drawInRect:imageRect
					 fromRect:NSMakeRect(0,0,[image size].width,[image size].height)
					operation:NSCompositeSourceOver
					 fraction:1.0
               respectFlipped:YES
                        hints:nil];
		}
	}
	
	id lastCell;
	NSInteger row,col;
	if (!NSEqualPoints(lastPoint,NSZeroPoint)&&[self getRow:&row column:&col forPoint:lastPoint]) {
		lastCell = [self cellAtRow:row column:col];
		if ([[lastCell alternateTitle] isEqualToString:@""]) return;
		if (!attrString) return;
		
		NSRect cellRect = [self convertRect:[self cellFrameAtRow:row column:col] fromView:self];
		float x = (cellRect.size.width-[attrString sizeWithBG].width)/2+cellRect.origin.x;
		float y = (cellRect.size.height-[attrString sizeWithBG].height)/2+cellRect.origin.y;
		x = (int)x;
		y = (int)y;
		[attrString drawInRect:NSMakeRect(x,y,0,0) bg:[[NSColor darkGrayColor] colorWithAlphaComponent:0.8]];
		lastRect = NSMakeRect(x,y,[attrString sizeWithBG].width,[attrString sizeWithBG].height);
		
		[attrString release];
		attrString = nil;
	}
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	if (!NSPointInRect([theEvent locationInWindow],[self visibleRect])) {
		lastPoint = NSZeroPoint;
		if (!NSEqualRects(lastRect,NSZeroRect)) [self displayRect:lastRect];
		lastRect = NSZeroRect;
		return;
	}
	id lastCell;
	NSInteger row,col;
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if ([self getRow:&row column:&col forPoint:point]) {
		lastCell = [self cellAtRow:row column:col];
		NSRect imageRect =[lastCell imageRectForBounds:[self cellFrameAtRow:row column:col]];
		if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil],imageRect)){
			NSInteger rowS,colS;
			if ([self getRow:&rowS column:&colS forPoint:lastPoint] && rowS==row && colS==col) {
				if (NSPointInRect(lastPoint,imageRect)) {
					lastPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
					return;
				}
			}
			lastPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
			[self setNeedsDisplayInRect:lastRect];
			
			
			NSMutableParagraphStyle* style = [[[NSMutableParagraphStyle alloc] init] autorelease];
			[style setAlignment:NSCenterTextAlignment];
			[style setLineBreakMode:NSLineBreakByTruncatingHead];
			
			NSMutableDictionary* attr = [NSMutableDictionary dictionary];
			[attr setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
			[attr setObject:[NSFont userFontOfSize:15] forKey:NSFontAttributeName];
			[attr setObject:style forKey:NSParagraphStyleAttributeName];
			
			if ([lastCell representedObject]) {
				attrString = [[NSAttributedString alloc] initWithString:[lastCell representedObject] attributes:attr];
			} else {
				attrString = [[NSAttributedString alloc] initWithString:[[lastCell alternateTitle] lastPathComponent] attributes:attr];
			}
			NSRect cellRect = [self convertRect:[self cellFrameAtRow:row column:col] fromView:self];
			float x = (cellRect.size.width-[attrString sizeWithBG].width)/2+cellRect.origin.x;
			float y = (cellRect.size.height-[attrString sizeWithBG].height)/2+cellRect.origin.y;
			x = (int)x;
			y = (int)y;
			
			[self displayRect:NSMakeRect(x,y,[attrString sizeWithBG].width,[attrString sizeWithBG].height)];
		} else {
			lastPoint = NSZeroPoint;
			if (!NSEqualRects(lastRect,NSZeroRect)) [self displayRect:lastRect];
			lastRect = NSZeroRect;
		}
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	id lastCell;
	NSInteger row,col;
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	mouseDownPoint = point;
	if ([self getRow:&row column:&col forPoint:point]) {
		lastCell = [self cellAtRow:row column:col];
		NSRect imageRect =[lastCell imageRectForBounds:[self cellFrameAtRow:row column:col]];
		if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil],imageRect)){
			[super mouseDown:theEvent];
		}
	}
}

- (NSMenu *)menu
{
	id lastCell;
	NSInteger row,col;
	NSEvent *theEvent = [NSApp currentEvent];
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if ([self getRow:&row column:&col forPoint:point]) {
		lastCell = [self cellAtRow:row column:col];
		
		id menu = [super menu];
		id menuItem = [menu itemWithTitle:NSLocalizedString(@"Remove Bookmark",@"")];
		if (menuItem) {
			[menuItem setTitle:NSLocalizedString(@"Add Bookmark",@"")];
		} else {
			menuItem = [menu itemWithTitle:NSLocalizedString(@"Add Bookmark",@"")];
		}
		id object;
		int index;
		for (index=0; index<[bmarray count]; index++) {
			object = [bmarray objectAtIndex:index];
			if (NSEqualRects(NSRectFromString([object objectForKey:@"frame"]),[self cellFrameAtRow:row column:col])) {
				[menuItem setTitle:NSLocalizedString(@"Remove Bookmark",@"")];
				break;
			}
		}
		
		NSRect imageRect =[lastCell imageRectForBounds:[self cellFrameAtRow:row column:col]];
		if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil],imageRect)){
			return menu;	
		}	
	}
	return nil;
}

@end
