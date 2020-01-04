//
//  XADWrapper.h
//  cooViewer
//
//  Created by coo on 08/01/20.
//  Copyright 2008 coo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XADMaster/XADArchive.h>


@interface XADWrapper : NSObject {
	XADArchive *archive;
	NSString*	filePath;
	NSMutableArray*	contentArray;
	NSMutableArray*	contentIndexArray;
	
	NSString *password;
}

-(id)initWithPath:(NSString*)path;
-(id)initWithPath:(NSString*)path nameEncoding:(NSStringEncoding)enc;

	
	//access
-(int)itemCount;
-(id)itemForPath:(NSString *)path;
-(id)itemAtIndex:(int)index;

-(id)itemArray;
-(id)contents;

	//ファイルパス
-(NSString *)filePath;
-(BOOL)crypted;

-(NSString *)password;
-(void)setPassword:(NSString *)inStr;

	//パスワードを設定してあっていればYES,間違ってればNOを返す
-(BOOL)checkAndSetPassword:(NSString *)newPassword;

-(NSStringEncoding)encoding;

-(BOOL)uncompress:(int)index toTempDir:(NSString*)dir;
-(BOOL)uncompress:(int)index as:(NSString*)fileName;
-(XADArchive*)archive;
@end
