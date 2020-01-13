/* ThumbnailPanel */

#import <Cocoa/Cocoa.h>

@interface ThumbnailPanel : NSPanel
{
    IBOutlet id matrix;
	id target;
	SEL selector;
	float setting;
}
@end
