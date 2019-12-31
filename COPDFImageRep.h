

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>


@interface COPDFImageRep : NSPDFImageRep {
	NSArray *linkList;
}

-(void)setLinkList:(NSArray*)array;
-(NSArray*)linkListAtPage:(int)p;

@end
