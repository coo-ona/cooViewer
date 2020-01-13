

#import "COPDFImageRep.h"


@implementation COPDFImageRep

-(id)init
{
	self = [super init];
    if (self) {
		linkList = nil;
	}
	return self;
}

- (void)dealloc
{
	if (linkList) {
		[linkList release];
	}
	[super dealloc];
}

- (BOOL)drawInRect:(NSRect)rect
{
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	return [super drawInRect:rect];
}
- (BOOL)drawInRect:(NSRect)dstSpacePortionRect fromRect:(NSRect)srcSpacePortionRect operation:(NSCompositingOperation)op fraction:(CGFloat)requestedAlpha respectFlipped:(BOOL)respectContextIsFlipped hints:(nullable NSDictionary *)hints
{
    [[NSColor whiteColor] set];
    NSRectFill(dstSpacePortionRect);
    return [super drawInRect:dstSpacePortionRect fromRect:srcSpacePortionRect operation:NSCompositeSourceOver fraction:requestedAlpha respectFlipped:respectContextIsFlipped hints:hints];
    
}

-(NSInteger)pixelsWide {return [self size].width;}
-(NSInteger)pixelsHigh{return [self size].height;}

+ (id)imageRepWithContentsOfFile:(NSString *)filename
{
	id rep = [super imageRepWithContentsOfFile:filename];
	
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1040
	if([NSObject respondsToSelector:@selector(finalize)]){
		NSData *data = [NSData dataWithContentsOfFile:filename];
		
		PDFPage		*page;
		NSArray		*annotations;
		PDFDocument *pdf = [[[PDFDocument alloc] initWithData:data] autorelease];
		
		NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
		int pageIndex;
		for (pageIndex = 0; pageIndex < [pdf pageCount]; pageIndex++) {
			NSMutableArray *tmpTmpArray = [[NSMutableArray alloc] init];
			page = [pdf pageAtIndex: pageIndex];
			
			// Get page annotations (if any).
			annotations = [page annotations];
			if ((annotations != NULL) && ([annotations count] > 0)) {
				unsigned int	count;
				unsigned int	i;
				
				// Walk annotations looking for links.
				count = (int)[annotations count];
				for (i = 0; i < count; i++)
				{
					PDFAnnotation	*oneAnnotation;
					
					// Link must have a URL associated with it.
					oneAnnotation = [annotations objectAtIndex: i];
					if (([[oneAnnotation type] isEqualToString: @"Link"]) && 
						([(PDFAnnotationLink *)oneAnnotation URL] != NULL))
					{
						[tmpTmpArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
												[NSValue valueWithRect:[oneAnnotation bounds]],@"rect",
												[(PDFAnnotationLink *)oneAnnotation URL],@"url",
												nil]];
					}
				}
			}
			[tmpArray addObject:tmpTmpArray];
			[tmpTmpArray release];
		}
		[rep setLinkList:tmpArray];
		[tmpArray release];
	}
#endif
	
	return rep;
}

-(void)setLinkList:(NSArray*)array;
{
	linkList = [array retain];
}

-(NSArray*)linkListAtPage:(int) p
{
    if (p<0) {
        p = 0;
    } else if (p>=[linkList count]) {
        p = (int)[linkList count]-1;
    }
	return [linkList objectAtIndex:p];
}
@end
