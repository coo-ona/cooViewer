
#import <Cocoa/Cocoa.h>
#import "Controller.h"


@interface FullImagePanel : NSPanel {
	id keyArray;
	Controller *target;
	BOOL fitMode;
}
- (void)setFitMode:(BOOL)yes;
-(void)setSelfMaxSize;
@end
