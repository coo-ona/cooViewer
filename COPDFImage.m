

#import "COPDFImage.h"


@implementation COPDFImage

-(id)initWithPDFRep:(COPDFImageRep*)rep page:(int)p
{
	self = [super init];
    if (self) {
		pdfRep = [rep retain];
		page = p;
		linkList = nil;
		
		image = [[NSImage alloc] initWithSize:[pdfRep size]];
		[image setDataRetained:YES];
		[image setScalesWhenResized:YES];
		[image addRepresentation:pdfRep];
		[self setLinkList:[rep linkListAtPage:p]];
	}
	return self;
}

- (void)dealloc
{
	if (linkList) {
		[linkList release];
	}
	[image release];
	[pdfRep release];
	[super dealloc];
}

- (NSArray *)representations
{
	[pdfRep setCurrentPage:page];
	return [NSArray arrayWithObject:pdfRep];
}

- (NSImageRep *)bestRepresentationForDevice:(NSDictionary *)deviceDescription
{
	[pdfRep setCurrentPage:page];
	return pdfRep;
}

- (void)setSize:(NSSize)aSize
{
	return;
}

- (NSSize)size
{
	[pdfRep setCurrentPage:page];
	return [pdfRep size];
}

- (void)drawInRect:(NSRect)dstRect fromRect:(NSRect)srcRect operation:(NSCompositingOperation)op fraction:(float)delta
{
	[pdfRep setCurrentPage:page];
	//[pdfRep drawInRect:dstRect];
	if (NSEqualSizes([pdfRep size],srcRect.size) || NSIsEmptyRect(srcRect)) {
		[pdfRep drawInRect:dstRect];
	} else {
		float rate = dstRect.size.width/srcRect.size.width;
		[image setSize:NSMakeSize((int)([pdfRep size].width*rate),(int)([pdfRep size].height*rate))];
		NSRect fromRect = NSMakeRect((int)(srcRect.origin.x*rate),(int)(srcRect.origin.y*rate),(int)srcRect.size.width*rate,(int)srcRect.size.height*rate);
		[image drawInRect:dstRect fromRect:fromRect operation:op fraction:delta];
	}
}
/*
- (void)drawAtPoint:(NSPoint)point fromRect:(NSRect)srcRect operation:(NSCompositingOperation)op fraction:(float)delta
{
	NSLog(@"kita2");
	[pdfRep setCurrentPage:page];
	[pdfRep drawAtPoint:point];
	//[image drawAtPoint:point fromRect:srcRect operation:op fraction:delta];
}*/
- (void)compositeToPoint:(NSPoint)aPoint operation:(NSCompositingOperation)op
{
	[pdfRep setCurrentPage:page];
	[image setSize:[pdfRep size]];
	[image compositeToPoint:aPoint operation:op];
	//[pdfRep drawAtPoint:NSMakePoint(0,0)];
	//[pdfRep drawInRect:NSMakeRect(aPoint.x,aPoint.y,[pdfRep size].width,[pdfRep size].height)];
}


-(void)setLinkList:(NSArray*)array
{
	linkList = [array retain];
}

-(NSArray*)linkList
{
	return linkList;
}


@end
