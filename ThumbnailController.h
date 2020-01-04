/* ThumbnailController */

#import <Cocoa/Cocoa.h>
#import "COImageLoader.h"


@interface ThumbnailController : NSObject
{
	BOOL bookmarkMode;
	int nowBookmarkPage;
		
	COImageLoader *imageLoader;
	
	
	int doCount;
	
	int cellCount;
	BOOL stop;
	BOOL mangaMode;
	
    IBOutlet id controller;
    IBOutlet id matrix;
    IBOutlet id panel;
	
	NSMutableArray *pathArray;
	NSMutableDictionary *pathDic;
	int now;
	int sortMode;
    IBOutlet id sortPopUpButton;
    IBOutlet id stateTextField;
    IBOutlet id nameTextField;
    IBOutlet id onlyBookmarkButton;
    IBOutlet id comicModeButton;
    IBOutlet id contextMenu;
	
	NSArray *keyArray;
	
	NSMutableArray *thumImageArray;
	int maxCacheCount;
	
	float wheelSensitivity;
	NSTimer *wheelUpTimer,*wheelDownTimer;	
}
-(void)setmaxCacheCount:(int)size;
-(void)setImageLoader:(COImageLoader*)loader;

-(id)loadImage:(int)index;



-(void)showBookmarkThumbnail;
-(void)setBookmarkImageCells:(BOOL)back;
-(void)setBookmarkImageCellsMethod:(NSNumber*)backValue;
-(void)setBookmarkImageCellWithInfo:(id)infoDic;



-(BOOL)isVisible;

-(void)setCellRow:(int)rowI column:(int)columnI;

-(void)showThumbnail:(int)nowPage;
-(void)setImageCells:(BOOL)back;
-(void)setImageCellsMethod:(NSNumber*)backValue;
-(void)setImageCellWithInfo:(id)info;

-(void)setImageToCellAtRow:(int)row column:(int)col back:(BOOL)back;

-(void)clearCell;
-(void)clearAll;
- (void)imageSelected:(id)sender;
-(void)appleRemoteAction:(NSString*)characters;
-(void)action:(NSEvent*)event;
-(void)wheelAction:(NSEvent*)event;
-(void)wheelSetting:(float)set;
-(void)wheelUp;
-(void)wheelDown;
-(void)setPageKey:(NSArray*)array;
-(IBAction)sort:(id)sender;
-(IBAction)next:(id)sender;
-(IBAction)prev:(id)sender;
-(void)mangaModePrev;


-(IBAction)onlyBookmark:(id)sender;
-(IBAction)comicMode:(id)sender;

-(IBAction)contextAction:(id)sender;
@end
