

#import <Cocoa/Cocoa.h>
#import <COPDFImageRep.h>


@interface COPDFImage : NSImage {
	COPDFImageRep *pdfRep;
	NSImage *image;
	int page;
	NSArray *linkList;
}

-(id)initWithPDFRep:(COPDFImageRep*)rep page:(int)p;
-(void)setLinkList:(NSArray*)array;
-(NSArray*)linkList;
@end
