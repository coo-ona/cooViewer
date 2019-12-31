#import <HetimaUnZip/HetimaUnZip.h>
#import "XADWrapper.h"
#import "XADItem.h"
#import "Controller.h"
#import "COImageLoader.h"

@interface COImageLoader(private)
-(void)content;
-(BOOL)checkArchiveContainer:(int)index;
-(void)uncompressToTempDir:(NSString*)file;
//-(BOOL)uncompressAllFileToTempDir;
@end

@implementation COImageLoader
+(NSArray *)fileTypes
{
	return [NSArray arrayWithObjects:@"zip",@"cbz",@"rar",@"cbr",@"lzh",@"lha",@"7z",@"sit",@"pdf",@"cvbdl",nil];
}
+(NSArray *)archiveTypes
{
	return [NSArray arrayWithObjects:@"zip",@"cbz",@"rar",@"cbr",@"lzh",@"lha",@"7z",@"sit",nil];
}

- (NSString*)displayPath
{
	return displayPath;
}

- (id)initWithPath:(NSString *)path displayPath:(NSString *)dispPath readSubFolder:(BOOL)boo controller:(id)ctr;
//- (id)initWithPath:(NSString *)path displayPath:(NSString *)dispPath readSubFolder:(BOOL)boo;
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
	
	self = [super init];
    if (self) {
		rightPassward = NO;
		controller = ctr;
		tempDir = nil;
		inArchiveArray = [[NSMutableArray alloc] init];
		//inArchiveNameDic = [[NSMutableDictionary alloc] init];
		
		//nameEncoding=NSShiftJISStringEncoding;
		NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[COImageLoader fileTypes]];
		[tempArray addObjectsFromArray:[NSImage imageFileTypes]];
		
		filterArray = [[NSArray arrayWithArray:tempArray] retain];
		readSubFolder=boo;
		mode=-1;
		password=nil;
		filePath=[path retain];
		displayPath = [dispPath retain];
		archiveContainer = nil;
		contentPathArray = [[NSMutableArray alloc] init];
		contentPathDic = [[NSMutableDictionary alloc] init];
		rawContentPathArray = [[NSMutableArray alloc] init];
		pdfRep = nil;
		
		[self content];
	}
    return self;	
}

- (id)initWithPath:(NSString *)path readSubFolder:(BOOL)boo controller:(id)ctr;
//- (id)initWithPath:(NSString *)path readSubFolder:(BOOL)boo;
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
	
	self = [super init];
    if (self) {
		rightPassward = NO;
		controller = ctr;
		tempDir = nil;
		inArchiveArray = [[NSMutableArray alloc] init];
		//inArchiveNameDic = [[NSMutableDictionary alloc] init];
		
		//nameEncoding=NSShiftJISStringEncoding;
		NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[COImageLoader fileTypes]];
		[tempArray addObjectsFromArray:[NSImage imageFileTypes]];
		
		filterArray = [[NSArray arrayWithArray:tempArray] retain];
		readSubFolder=boo;
		mode=-1;
		password=nil;
		filePath=[path retain];
		displayPath = [path retain];
		archiveContainer = nil;
		contentPathArray = [[NSMutableArray alloc] init];
		contentPathDic = [[NSMutableDictionary alloc] init];
		rawContentPathArray = [[NSMutableArray alloc] init];
		pdfRep = nil;
		
		[self content];
	}
    return self;	
}

- (void)dealloc
{
	if(tempDir) {
		[[NSFileManager defaultManager] removeFileAtPath:tempDir handler:nil];
		[tempDir release];
	}
	
	if(rawContentPathArray)[rawContentPathArray release];
	if(inArchiveArray)[inArchiveArray release];
	if(filePath)[filePath release];
	if(displayPath)[displayPath release];
	if(password)[password release];
	if(archiveContainer)[archiveContainer release];
	if(contentPathArray)[contentPathArray release];
	if(contentPathDic)[contentPathDic release];
	if(filterArray)[filterArray release];
	if(pdfRep)[pdfRep release];
	//if(mode==4)CGPDFDocumentRelease(pdfDocument);
	
	[super dealloc];
}

#pragma mark -
- (NSString *)filePath
{
	return filePath;
}

- (int)itemCount
{
	if(contentPathArray)	return [contentPathArray count];
	return 0;
}
- (int)mode
{
	return mode;
}

- (NSString*)itemPathAtIndex:(int)index
{
	if ([inArchiveArray count] > 0) {
		NSString *fileName = [contentPathArray objectAtIndex:index];
		int i;
		for (i=0; i<[inArchiveArray count]; i++) {
			COImageLoader *inLoader = [inArchiveArray objectAtIndex:i];
			if ([[inLoader pathArray] indexOfObject:fileName] != NSNotFound) {
				return [inLoader filePath];
			}
		}
	}
	if (mode==0 || mode==3) {
		return [contentPathArray objectAtIndex:index];
	} else {
		return filePath;
	}
}

- (NSString*)itemNameAtIndex:(int)index
{
	return [contentPathArray objectAtIndex:index];
}

- (BOOL)canSortByDate
{
	if ([inArchiveArray count]>0) {
		return NO;
	}
	if (mode==0 || mode==3) {
		return YES;
	}
	return NO;
}

- (NSString *)password
{
	return password;
}
- (NSMutableArray*)pathArray
{
	return contentPathArray;
}
#pragma mark -

- (id)itemAtIndex:(int)index
{
	if ([inArchiveArray count] > 0) {
		NSString *fileName = [contentPathArray objectAtIndex:index];
		int i;
		for (i=0; i<[inArchiveArray count]; i++) {
			COImageLoader *inLoader = [inArchiveArray objectAtIndex:i];
			if ([[inLoader pathArray] indexOfObject:fileName] != NSNotFound) {
				return [inLoader itemAtIndex:[[inLoader pathArray] indexOfObject:fileName]];
			}
		}
	}
	if (mode==4) {
		return [[[COPDFImage alloc] initWithPDFRep:pdfRep page:index] autorelease];
	} else if(mode==1|mode==2) {		
		NSString *rawName = [contentPathDic objectForKey:[contentPathArray objectAtIndex:index]];
		NSArray*    items=[archiveContainer contents];
		
		NSData* data;
		if ([rawContentPathArray indexOfObject:rawName] != NSNotFound) {
			data =[[items objectAtIndex:[rawContentPathArray indexOfObject:rawName]] data];
		} else {
			return [[[NSImage allocWithZone:NULL] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broken" ofType:@"png"]] autorelease];
		}
		
		if(data && [data length]>0){
			NSImage*	image = [[[NSImage allocWithZone:NULL] initWithData:data] autorelease];
			if (![image bestRepresentationForDevice:nil]) {
				return [[[NSImage allocWithZone:NULL] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broken" ofType:@"png"]] autorelease];
			}
			if(image && [image isValid]){
				return image;
			}
		} else {
			if (![self checkArchiveContainer:index]) {
			}
			items=[archiveContainer contents];
			rawName = [contentPathDic objectForKey:[contentPathArray objectAtIndex:index]];
			if ([rawContentPathArray indexOfObject:rawName] != NSNotFound) {
				data =[[items objectAtIndex:[rawContentPathArray indexOfObject:rawName]] data];
			} else {
				return [[[NSImage allocWithZone:NULL] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broken" ofType:@"png"]] autorelease];
			}
			if(data && [data length]>0){
				NSImage *image = [[[NSImage allocWithZone:NULL] initWithData:data] autorelease];
				if (![image bestRepresentationForDevice:nil]) {
					return [[[NSImage allocWithZone:NULL] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broken" ofType:@"png"]] autorelease];
				}
				if(image && [image isValid]){
					return image;
				}
			}
		}
	} else {
		NSImage *image;
		image = [[[NSImage allocWithZone:NULL] initWithContentsOfFile:[contentPathArray objectAtIndex:index]] autorelease];
		
		//NSImage *image = [[[NSImage allocWithZone:NULL] initWithContentsOfFile:[contentPathArray objectAtIndex:index]] autorelease];
		if (![image bestRepresentationForDevice:nil]) {
			return [[[NSImage allocWithZone:NULL] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broken" ofType:@"png"]] autorelease];
		}
		if(image && [image isValid]){
			return image;
		}
	}
	return [[[NSImage allocWithZone:NULL] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"broken" ofType:@"png"]] autorelease];
	return nil;
}

#pragma mark -
- (int)nextFolder:(int)now
{
	int i = now-1;
	//NSLog(@"next startAt  %@",[contentPathArray objectAtIndex:now-1]);
	NSString *currentFolder = [[contentPathArray objectAtIndex:i] stringByDeletingLastPathComponent];
	for (i+=1;i<[contentPathArray count];i++) {
		NSString *nextFolder = [[contentPathArray objectAtIndex:i] stringByDeletingLastPathComponent];
		//NSLog(@"%@",[contentPathArray objectAtIndex:i]);
		if (![currentFolder isEqualToString:nextFolder]) {
			//NSLog(@"found1");
			return i;
		}
	}
	for (i=0;i<[contentPathArray count];i++) {
		if (i==now-1) {
			//NSLog(@"notFound");
			return 0;
		}
		NSString *nextFolder = [[contentPathArray objectAtIndex:i] stringByDeletingLastPathComponent];
		//NSLog(@"%@",[contentPathArray objectAtIndex:i]);
		if (![currentFolder isEqualToString:nextFolder]) {
			//NSLog(@"found2");
			return i;
		}
	}
	return 0;
	//NSLog(@"next end");
}
- (int)prevFolder:(int)now
{
	//NSLog(@"prev startAt %@",[contentPathArray objectAtIndex:now-1]);
	NSString *currentFolder = [[contentPathArray objectAtIndex:now-1] stringByDeletingLastPathComponent];
	if (now-2>0 && [currentFolder isEqualToString:[[contentPathArray objectAtIndex:now-2] stringByDeletingLastPathComponent]]) {
		//1つ前も同じフォルダだったらこのフォルダの先頭を検索
		NSString *prevFolder;
		int i = now-1;
		for (i;i>=0;i--) {
			if (i == 0) return 0;
			prevFolder = [[contentPathArray objectAtIndex:i] stringByDeletingLastPathComponent];
			if (![currentFolder isEqualToString:prevFolder]) {
				return i+1;
			}
		}
	} else {
		//1つ前が違うフォルダだったらそっちの先頭を検索
		NSString *prevFolder,*prevFolderHead;
		int i = now-1;
		for (i;i>=0;i--) {
			prevFolder = [[contentPathArray objectAtIndex:i] stringByDeletingLastPathComponent];
			//NSLog(@"%@ %i",[contentPathArray objectAtIndex:i],i);
			if (![currentFolder isEqualToString:prevFolder]) {
				int ii;
				for (ii=i;ii>=0;ii--) {
					if (ii == 0) return 0;
					prevFolderHead = [[contentPathArray objectAtIndex:ii] stringByDeletingLastPathComponent];
					//NSLog(@"%@",[contentPathArray objectAtIndex:ii]);
					if (![prevFolder isEqualToString:prevFolderHead]) {
						//NSLog(@"found1 %i",ii+1);
						return ii+1;
					}
				}
			}
		}
		i=[contentPathArray count]-1;
		for (i;i>=0;i--) {
			if (i==now) {
				//NSLog(@"notFound");
				return now-1;
			}
			prevFolder = [[contentPathArray objectAtIndex:i] stringByDeletingLastPathComponent];
			//NSLog(@"%@",[contentPathArray objectAtIndex:i]);
			if (![currentFolder isEqualToString:prevFolder]) {
				int ii;
				for (ii=i;ii>=0;ii--) {
					if (ii == 0) return 0;
					prevFolderHead = [[contentPathArray objectAtIndex:ii] stringByDeletingLastPathComponent];
					if (![prevFolder isEqualToString:prevFolderHead]) {
						//NSLog(@"found2 %i",ii+1);
						return ii+1;
					}
				}
			}
		}
	}
	//NSLog(@"prev end");
	return now-1;
}
#pragma mark -

- (BOOL)crypted
{
	if (mode==1 || mode==2) 
		return [archiveContainer crypted];
	
	return NO;
}

- (void)setPassword:(NSString *)inStr
{
	if (mode==0 || mode==3) {
		return;
	}
	if(password)[password release];
	password=nil;
	if(inStr){
		password=[inStr retain];
		[archiveContainer setPassword:password];
	}
}

- (BOOL)checkPassword
{
	if (rightPassward) return YES;
	if (mode==0 || mode==3) return YES;
	if (![self crypted]) return YES;
	if ([self crypted] && password==nil) return NO;
	
	id tempData = [[[archiveContainer contents] objectAtIndex:0] data];
	//tempData = nil;
	if (!tempData || [tempData length]<=0 || [[[archiveContainer contents] objectAtIndex:0] path]==nil) {
		if(([[filePath pathExtension] compare:@"zip" options:NSCaseInsensitiveSearch] == NSOrderedSame)
		   || ([[filePath pathExtension] compare:@"cbz" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
			HetimaUnZipContainer *tempArchiveContainer=[[HetimaUnZipContainer unZipContainerWithZipFile:filePath listOnlyRealFile:YES extensionFilter:nil] retain];
			if ([[[tempArchiveContainer contents] objectAtIndex:0] path] == nil) {
				[tempArchiveContainer setEncoding:NSShiftJISStringEncoding];
				NSTimeInterval start;
				start=[NSDate timeIntervalSinceReferenceDate];
				while ([[[tempArchiveContainer contents] objectAtIndex:0] path] == nil) {
					if ([NSDate timeIntervalSinceReferenceDate]-start > 1.0) {
						mode = -1;
						return NO;
					}
					[tempArchiveContainer release];
					tempArchiveContainer=[[HetimaUnZipContainer unZipContainerWithZipFile:filePath listOnlyRealFile:YES extensionFilter:nil]retain];
				}
			}
			
			[tempArchiveContainer setKeepData:NO];
			[tempArchiveContainer setPassword:password];
			tempData = [[[tempArchiveContainer contents] objectAtIndex:0] data];
			if (!tempData || [tempData length]<=0) {
				[tempArchiveContainer release];
			} else {
				[archiveContainer release];
				archiveContainer = tempArchiveContainer;
				mode = 1;
				rightPassward = YES;
				return YES;
			}
		}
	} else {
		rightPassward = YES;
		return YES;
	}
	return NO;
}

- (BOOL)checkAndSetPassword:(NSString *)newPassword
{
	[self setPassword:newPassword];
	return [self checkPassword];
}
@end

@implementation COImageLoader(private)
- (void)content
{
	NSMutableArray *pathArray = [NSMutableArray array];
	if ([[filePath pathExtension] compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
		mode=4;
		pdfRep = [[COPDFImageRep imageRepWithContentsOfFile:filePath] retain];
		int pages = [pdfRep pageCount];
		
		int i;
		for (i=0;pages>i;i++) {
			[contentPathArray addObject:[NSString stringWithFormat:@"%@/%i.pdf",filePath,i+1]];
		}
		return;
		
		
	} /*else if(([[filePath pathExtension] compare:@"zip" options:NSCaseInsensitiveSearch] == NSOrderedSame)
			  || ([[filePath pathExtension] compare:@"cbz" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
		mode=1;
		//archiveContainer=[[HetimaUnZipContainer unZipContainerWithZipFile:filePath listOnlyRealFile:YES extensionFilter:filterArray]retain];
		archiveContainer=[[HetimaUnZipContainer unZipContainerWithZipFile:filePath listOnlyRealFile:YES extensionFilter:nil]retain];
		[archiveContainer setKeepData:NO];
		[self checkArchiveContainer:0];
		return;
		
		
	} */else if([[COImageLoader archiveTypes] containsObject:[[filePath pathExtension] lowercaseString]]) {
		mode=2;
		archiveContainer=[[XADWrapper alloc] initWithPath:filePath nameEncoding:NSShiftJISStringEncoding];
		[self checkArchiveContainer:0];
		return;
		
	} else if([[filePath pathExtension] compare:@"savedSearch" options:NSCaseInsensitiveSearch] == NSOrderedSame){
		mode=-1;
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1040
		if([NSObject respondsToSelector:@selector(finalize)]){
			mode=3;
			NSDictionary *doc = [NSDictionary dictionaryWithContentsOfFile:filePath];
			NSString *raw = [doc objectForKey:@"RawQuery"];
			NSArray *scope = [[doc objectForKey:@"SearchCriteria"] objectForKey:@"FXScopeArrayOfPaths"];
			
			MDQueryRef query = MDQueryCreate(kCFAllocatorDefault, (CFStringRef)raw, NULL, NULL);
			MDQuerySetSearchScope (query,(CFArrayRef)scope,0);
			
			MDQueryExecute(query, kMDQuerySynchronous);
			
			CFIndex count = MDQueryGetResultCount(query);
			int i;
			NSMutableArray *temp = [NSMutableArray array];
			for (i = 0; i < count; i++) {
				MDItemRef item = (MDItemRef)MDQueryGetResultAtIndex(query,i);
				CFStringRef itemPath = MDItemCopyAttribute(item,kMDItemPath);
				
				BOOL isDir;
				[[NSFileManager defaultManager] fileExistsAtPath:((NSString *) itemPath) isDirectory:&isDir];
				if (isDir && readSubFolder) {
					NSArray *ar = [[NSFileManager defaultManager] subpathsAtPath:((NSString *) itemPath)];
					int ii;
					for (ii=0; ii<[ar count]; ii++) {
						[temp addObject:[((NSString *) itemPath) stringByAppendingPathComponent:[ar objectAtIndex:ii]]];
					}
				} else {
					[temp addObject:((NSString *) itemPath)];
				} 
				CFRelease(itemPath);
			}
			CFRelease(query);
			NSArray *completeArray;
			completeArray = [temp pathsMatchingExtensions:filterArray];
			
			NSEnumerator *enu=[completeArray objectEnumerator];
			id path;
			while (path = [enu nextObject]) {
				if([[COImageLoader fileTypes] containsObject:[[path pathExtension] lowercaseString]]){
					COImageLoader *inLoader = [[[COImageLoader alloc] initWithPath:path readSubFolder:NO controller:controller] autorelease];
					[pathArray addObjectsFromArray:[inLoader pathArray]];
					[inArchiveArray addObject:inLoader];
				} else if (path) {
					[pathArray addObject:path];
				}
			}
			[contentPathArray addObjectsFromArray:pathArray];
		}
#endif
	} else {
		mode=0;
		BOOL isDir;
		[[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
		if (isDir) {
			NSArray *completeArray;
			if (readSubFolder) {
				completeArray = [NSArray arrayWithArray:[[NSFileManager defaultManager] subpathsAtPath:filePath]];
			} else {
				completeArray = [NSArray arrayWithArray:[[NSFileManager defaultManager] directoryContentsAtPath:filePath]];
			}
			completeArray = [completeArray pathsMatchingExtensions:filterArray];
			
			NSEnumerator *enu=[completeArray objectEnumerator];
			id path;
			while (path = [enu nextObject]) {
				path = [filePath stringByAppendingPathComponent:path];
				if([[COImageLoader fileTypes] containsObject:[[path pathExtension] lowercaseString]]){
					COImageLoader *inLoader = [[[COImageLoader alloc] initWithPath:path readSubFolder:NO controller:controller] autorelease];
					[pathArray addObjectsFromArray:[inLoader pathArray]];
					[inArchiveArray addObject:inLoader];
				} else if (path) {
					[pathArray addObject:path];
				}
			}
			[contentPathArray addObjectsFromArray:pathArray];
		} else {
			mode=-1;
		}
	}
	[contentPathArray sortUsingSelector:@selector(finderCompareS:)];
}

- (BOOL)checkArchiveContainer:(int)index
{
	if (![self checkPassword]) [controller askInArchivePassword:self];	//pass聞きに行く
	if (![self checkPassword]) return NO;	//諦めた
	if (!rightPassward) {
		id tempData = [[[archiveContainer contents] objectAtIndex:index] data];
		//tempData = nil;
		if (!tempData || [tempData length]<=0){
			if(([[filePath pathExtension] compare:@"zip" options:NSCaseInsensitiveSearch] == NSOrderedSame)
			   || ([[filePath pathExtension] compare:@"cbz" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
				NSLog(@"noPassArchive_useHetima");
				HetimaUnZipContainer *tempArchiveContainer=[[HetimaUnZipContainer unZipContainerWithZipFile:filePath listOnlyRealFile:YES extensionFilter:nil] retain];
				
				if ([[[tempArchiveContainer contents] objectAtIndex:index] path] == nil) {
					NSLog(@"noPassArchive_pathNil");
					[tempArchiveContainer setEncoding:NSShiftJISStringEncoding];
					NSTimeInterval start;
					start=[NSDate timeIntervalSinceReferenceDate];
					while ([[[tempArchiveContainer contents] objectAtIndex:index] path] == nil) {
						NSLog(@"noPassArchive_loop");
						if ([NSDate timeIntervalSinceReferenceDate]-start > 1.0) {
							mode = -1;
							return NO;
						}
						[tempArchiveContainer release];
						tempArchiveContainer=[[HetimaUnZipContainer unZipContainerWithZipFile:filePath listOnlyRealFile:YES extensionFilter:nil]retain];
					}
				}
				[tempArchiveContainer setKeepData:NO];
				tempData = [[[tempArchiveContainer contents] objectAtIndex:0] data];
				if (!tempData || [tempData length]<=0) {
					NSLog(@"noPassArchive_nodata");
					[tempArchiveContainer release];
				} else {
					NSLog(@"noPassArchive_hasdata");
					[archiveContainer release];
					archiveContainer = tempArchiveContainer;
					mode = 1;
				}
			}
			
			if (!tempData || [tempData length]<=0 || [[[archiveContainer contents] objectAtIndex:index] path]==nil) {
				NSLog(@"noPassArchive_no");
				mode = -1;
				return NO;
			}
		}
	}
	
	[rawContentPathArray removeAllObjects];
	[contentPathArray removeAllObjects];
	[contentPathDic removeAllObjects];
	NSMutableArray *pathArray = [NSMutableArray array];
	NSArray *items=[archiveContainer contents];
	NSEnumerator *enu = [items objectEnumerator];
	id object;
	while (object = [enu nextObject]) {
		NSString *path = [object path];
		if (path) {
			[rawContentPathArray addObject:path];
			if([[COImageLoader fileTypes] containsObject:[[path pathExtension] lowercaseString]]){
				if ([self checkPassword]) {
					[self uncompressToTempDir:path];
					COImageLoader *inLoader = [[[COImageLoader alloc] initWithPath:[tempDir stringByAppendingPathComponent:path]
																	   displayPath:[displayPath stringByAppendingPathComponent:path]
																	 readSubFolder:NO
																		controller:controller] autorelease];
					[pathArray addObjectsFromArray:[inLoader pathArray]];
					[inArchiveArray addObject:inLoader];
				}
			} else {
				NSString *inPath = [NSString stringWithFormat:@"%@/%@",displayPath,path];
				[pathArray addObject:inPath];
				[contentPathDic setObject:path forKey:inPath];
			}
		}
	}
	
	
	
	[contentPathArray addObjectsFromArray:[pathArray pathsMatchingExtensions:filterArray]];
	[contentPathArray sortUsingSelector:@selector(finderCompareS:)];
	//NSLog(@"%@",contentPathDic);
	return YES;
}

- (void)createDir:(NSString*)dir
{
	NSFileManager *manager = [NSFileManager defaultManager];
	if (![manager fileExistsAtPath:dir]) {
		if (![manager fileExistsAtPath:[dir stringByDeletingLastPathComponent]]) {
			[self createDir:[dir stringByDeletingLastPathComponent]];
		}
		[manager createDirectoryAtPath:dir attributes:nil];
	}
}

- (void)uncompressToTempDir:(NSString*)fileName
{
	if (!tempDir) {
		const char *buffer = [[NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),@"cooViewer.XXXXXX"] fileSystemRepresentation];
		mkdtemp(buffer);
		tempDir = [[NSString stringWithFormat:@"%s", buffer] retain];
	}
	
	NSArray* items=[archiveContainer contents];
	NSData* data;
	if ([rawContentPathArray indexOfObject:fileName] != NSNotFound) {
		[self createDir:[[tempDir stringByAppendingPathComponent:fileName] stringByDeletingLastPathComponent]];
		
		if (mode == 1) {
			NSFileManager *manager = [NSFileManager defaultManager];
			data =[[items objectAtIndex:[rawContentPathArray indexOfObject:fileName]] data];
			BOOL temp = [manager createFileAtPath:[tempDir stringByAppendingPathComponent:fileName] contents:data attributes:nil];
		} else if (mode == 2) {
			BOOL temp = [archiveContainer uncompress:[rawContentPathArray indexOfObject:fileName] as:[tempDir stringByAppendingPathComponent:fileName]];			
		}
	} else {
		//NSLog(@"notFound");
	}
}
@end
