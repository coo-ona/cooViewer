

#import <Cocoa/Cocoa.h>


@interface FullImageView : NSImageView {
	NSImage*image;
	NSPoint oldPoint;
	BOOL ignoreImageDpi;
}
- (void)setIgnoreImageDpi:(BOOL)ignoreDpi;
- (void)imageScroll:(NSPoint)point;
- (void)scrollToTop;
- (void)scrollToLast;
- (void)scrollDown;
- (void)scrollUp;

@end
