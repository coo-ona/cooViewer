
#import <Cocoa/Cocoa.h>


@interface FullImagePanel : NSPanel {
	id keyArray;
	id target;
	BOOL fitMode;
}
- (void)setFitMode:(BOOL)yes;
-(void)setSelfMaxSize;
@end
