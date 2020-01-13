/* COPopUpTextField */

#import <Cocoa/Cocoa.h>

@interface COPopUpTextField : NSTextField
{
	NSPopUpButton *pb;
	NSSize maxSize;
}
- (void)setMaxSize:(NSSize)size;

@end
