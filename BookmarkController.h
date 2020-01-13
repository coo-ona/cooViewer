/* BookmarkController */

#import <Cocoa/Cocoa.h>
#import <Controller.h>

@interface BookmarkController : NSObject
{
	IBOutlet id controller;
	
	IBOutlet id window;
    IBOutlet id bookmarkPanel;
    IBOutlet id bookmarkTableView;
	
    IBOutlet id allBookmarkPanel;
    IBOutlet id allBookmarkTableView;
    IBOutlet id allBookNameTableView;
    IBOutlet id allNewBookmarkTextField;
	IBOutlet id allBookmarkSplitView;
	
    IBOutlet id contextMenuItem;
	
    IBOutlet id newBookmarkTextField;

	NSUserDefaults *defaults;
	NSMutableArray *bookmarkArray;
	
	NSMutableDictionary *allBookmark;
	NSMutableArray *bookNameArray;
	
//	NSArray *names;
//	NSArray *pages;
//	NSArray *paths;
	NSString *directoryPath;
	NSString *bookName;
	
	id selectedView;
	NSMutableDictionary *completeAll;
}

- (void)setSplitViewPosition:(NSSplitView *)splitView position:(NSString *)position;

-(void)setPathDic:(NSDictionary*)dic;
-(void)editBookmark:(NSArray*)array;
-(void)editAllBookmark:(NSArray*)array;
- (BOOL)validateMenuItem:(NSMenuItem *)anItem;

- (IBAction)deleteRow:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)addNewBookmark:(id)sender;
- (IBAction)openInFinder:(id)sender;
- (IBAction)openInSelf:(id)sender;
@end
