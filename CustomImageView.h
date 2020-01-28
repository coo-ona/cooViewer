#import <Cocoa/Cocoa.h>
#import "Controller.h"
#import "LoupeView.h"

@interface CustomImageView : NSImageView
{
	IBOutlet id accessoryWindow;
	IBOutlet id accessoryView;
	
	BOOL needFirstScroll;
	    
    CALayer *fLayer;
    CALayer *sLayer;
	
	BOOL didFirst;
	NSWindow *lensWindow;
	int maxEnlargement;
	//rotate
	/*0=normal 1=left90 2=left180 3=left270(right90)*/
	int rotateMode;
	
	//lens
	int lensSize;
	float lensRate;
	NSPoint lensOldPoint;
	NSRect fRect;
	NSRect sRect;
	NSCursor *crossCursor;
	NSRect lensRect;
	
	/*#import <QuartzCore/QuartzCore.h>*/
	/*OTHER_LDFLAGS -weak_framework QuartzCore*/
	NSImage *_image;
	NSPoint oldPoint;
	NSPoint cursorMoved;
	BOOL rightPage;
	
	//id target; 
	Controller *target;
	SEL selector;
	double time;
	NSTimer *timer;
	float setting;
	

	
	int interpolation;
	int fitScreenMode;
	BOOL images;
	
	int tempPageNum;
	
	
	
	NSMutableDictionary *dragScrollDic;
	
	BOOL inDragScroll;
	BOOL didDragScroll;
	
	BOOL startFromEnd;
	
	@private
	NSMutableArray *urlRectArray;
	float mt_rotation;
	float mt_deltaZ;
	BOOL mt_didAction;
}

-(void)setScreenFitMode:(int)mode;

-(void)setInterpolation:(int)index;
-(void)setImages:(NSImage *)image;

-(BOOL)pageMover;
-(int)tempPageNum;
-(void)drawPageMover:(int)page;

-(void)drawImages:(NSImage*)image1 and:(NSImage*)image2;
-(void)drawImage:(NSImage*)image;

-(BOOL)scrollTo:(NSPoint)point;
-(void)scrollToPoint:(NSPoint)newOrigin;
-(void)_scrollToPoint:(NSPoint)point;
-(void)scrollUp;
-(void)scrollDown;
-(void)scrollToTop;
-(void)scrollToLast;
-(BOOL)firstScroll;

-(BOOL)next;
-(BOOL)prev;


-(void)setDragScroll:(NSArray*)array mode:(int)mode;
//-(void)setAccessory:(id)ac;
-(void)setStartFromEnd:(BOOL)boo;

-(void)setLoupe;
-(void)setLoupeRate;
-(void)drawLoupe;
-(BOOL)loupeIsVisible;

-(void)rotateRight;
-(void)rotateLeft;

-(void)setPageString:(NSString*)string;
-(NSString*)pageString;

-(void)drawPageBar;
-(void)setSlideshow:(BOOL)b;
-(void)setInfoString:(NSString*)string;

-(id)accessoryView;
-(void)setAccessoryWindowFrame;
@end
