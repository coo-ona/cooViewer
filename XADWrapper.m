//
//  XADWrapper.m
//  cooViewer
//
//  Created by coo on 08/01/20.
//  Copyright 2008 coo. All rights reserved.
//

#import "XADWrapper.h"
#import "XADItem.h"


@implementation XADWrapper

-(id)initWithPath:(NSString*)path nameEncoding:(NSStringEncoding)enc{
    self = [super init];
    if (self) {
		archive = [[XADArchive alloc] initWithFile:path];
		contentArray = [[NSMutableArray array] retain];
		contentIndexArray = [[NSMutableArray array] retain];
		filePath=[path retain];
		
		if (enc) [archive setNameEncoding:enc];
		password=nil;
		nameEncoding=enc;
		
		if ([archive nameOfEntry:0] == nil) {
			[archive setNameEncoding:nil];
		}
		int i;
		for (i=0; i<[archive numberOfEntries]; i++) {
			[contentIndexArray addObject:[archive nameOfEntry:i]];
			if (![archive entryIsDirectory:i] && [archive sizeOfEntry:i] != 0) {
				[contentArray addObject:[[XADItem alloc] initWithPath:[archive nameOfEntry:i] andWrapper:self]];
			} else {
				//NSLog(@"isdir %@",[archive nameOfEntry:i]);
			}
		}
	}
    return self;
}

- (void)dealloc
{
	[archive init];
	if(archive)[archive release];
	if(filePath)[filePath release];
	if(contentArray)[contentArray release];
	if(contentIndexArray)[contentIndexArray release];
	
	[super dealloc];
}



	//access
-(int)itemCount
{
	return [archive numberOfEntries];
}

-(int)xadIndexOfName:(NSString *)name
{
	return [contentIndexArray indexOfObject:name];
}


-(id)itemForPath:(NSString *)path
{
	//NSLog(@"%@ %i",path,[archive _entryIndexOfName:path]);
	return [archive contentsOfEntry:[self xadIndexOfName:path]];
}

-(id)itemAtIndex:(int)index
{
	//使ってない
	//return [archive contentsOfEntry:index];
	return [self itemForPath:[[contentArray objectAtIndex:index] path]];
}

-(id)itemArray
{
	return contentArray;
}
-(id)contents
{
	return contentArray;
}

	//ファイルパス
-(NSString *)filePath
{
	return filePath;
}

-(BOOL)crypted
{
	if ([archive isEncrypted]) {
		return YES;
	}
	return NO;
}

-(NSString *)password
{
	return password;
}

-(void)setPassword:(NSString *)inStr
{
	if(password)[password release];
	password=nil;
	if(inStr){
		password=[inStr retain];
		[archive setPassword:password];
	}
}

	//パスワードを設定してあっていればYES,間違ってればNOを返す
-(BOOL)checkAndSetPassword:(NSString *)newPassword
{
	if ([self itemCount]==0) return NO;
	
	[self setPassword:newPassword];
	NSData *temp = [self itemAtIndex:0];
	//NSLog(@"%@",[archive describeLastError]);
	if (temp) {
		return YES;
	} 
	return NO;
}
-(XADArchive*)archive
{
	return archive;
}

-(NSStringEncoding)encoding
{
	return [archive nameEncoding];
}

-(BOOL)uncompress:(int)index toTempDir:(NSString*)dir
{
	return [archive extractEntry:[self xadIndexOfName:[[contentArray objectAtIndex:index] path]] to:dir];
}

-(BOOL)uncompress:(int)index as:(NSString*)fileName
{
	return [archive _extractEntry:[self xadIndexOfName:[[contentArray objectAtIndex:index] path]] as:fileName];
}
@end
