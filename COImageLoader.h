#import <Cocoa/Cocoa.h>
#import "COPDFImage.h"
#import "COPDFImageRep.h"

@class HetimaUnZipContainer;

@interface COImageLoader : NSObject {
	BOOL inTempDir;
	BOOL rightPassward;
	
	NSMutableArray *thumbnailArray;
	
	id controller;
	
	NSString *tempDir;
	NSMutableArray *inArchiveArray;
	
	NSString *filePath;
	NSString *displayPath;
	NSMutableArray *contentPathArray;
	NSMutableArray *rawContentPathArray;
	NSMutableDictionary *contentPathDic;
	
	//NSStringEncoding	nameEncoding;
	NSString *password;
	id archiveContainer;
	id subArchiveContainer;
	NSArray *filterArray;
	
	BOOL readSubFolder;
	int mode;
	
	
	COPDFImageRep	*pdfRep;
}
+(NSArray *)fileTypes;
+(NSArray *)archiveTypes;

- (id)initWithPath:(NSString *)path readSubFolder:(BOOL)boo controller:(id)ctr;
- (id)initWithPath:(NSString *)path displayPath:(NSString *)dispPath readSubFolder:(BOOL)boo controller:(id)ctr;
//- (id)initWithPath:(NSString *)path readSubFolder:(BOOL)boo;
//- (id)initWithPath:(NSString *)path displayPath:(NSString *)dispPath readSubFolder:(BOOL)boo;

- (NSString*)filePath;
- (NSString*)displayPath;
- (NSString*)itemPathAtIndex:(int)index;
- (NSString*)itemNameAtIndex:(int)index;
- (BOOL)canSortByDate;

- (int)itemCount;

//NSImageを返す
- (id)itemAtIndex:(int)index;

//file名のsort済みarray
- (NSMutableArray*)pathArray;

//pass付きか否か
- (BOOL)crypted;
- (NSString *)password;
- (void)setPassword:(NSString *)inStr;

//間違ってたらNO
- (BOOL)checkPassword;
- (BOOL)checkAndSetPassword:(NSString *)newPassword;

//(-1=err),0=dir,1=zip,2=rar,3=savedSearch,4=pdf
- (int)mode;

- (int)nextFolder:(int)now;
- (int)prevFolder:(int)now;

- (BOOL)isInTempDir;
- (void)setInTempDir:(BOOL)b;
/*
- (NSStringEncoding)nameEncoding;
- (void)setNameEncoding:(NSStringEncoding)enc;
*/
@end
