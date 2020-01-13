

#import <Cocoa/Cocoa.h>


@interface FullImageView : NSImageView {
	NSImage*image;
	NSPoint oldPoint;
}
- (void)imageScroll:(NSPoint)point;
- (void)scrollToTop;
- (void)scrollToLast;
- (void)scrollDown;
- (void)scrollUp;

@end
