#import <Cocoa/Cocoa.h>


@interface COColorPopUpButton : NSPopUpButton {
	NSColor *currentColor;
}

- (void)setCurrentColor:(NSColor*)aColor;
- (NSColor*)currentColor;
@end
