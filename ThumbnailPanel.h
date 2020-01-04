/* ThumbnailPanel */

#import <Cocoa/Cocoa.h>
#import "ThumbnailController.h"

@interface ThumbnailPanel : NSPanel
{
    IBOutlet id matrix;
	ThumbnailController *target;
	SEL selector;
	float setting;
}
@end
