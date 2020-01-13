#import "ThumbnailController.h"
#import "Controller.h"
#import "ThumbnailMatrix.h"


@implementation ThumbnailController

- (void)awakeFromNib
{
	bookmarkMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"ThumbnailOnlyBookmark"];	
	if (bookmarkMode) [onlyBookmarkButton setState:NSOnState];
	
	mangaMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"ThumbnailComicMode"];
	if (mangaMode) [comicModeButton setState:NSOnState];
	
	
	doCount = 0;
	keyArray = nil;
	cellCount = 0;
	sortMode = 0;
	now = 0;
	maxCacheCount = 0;
	thumImageArray = [[NSMutableArray allocWithZone:NULL] init];
	
	[panel setBackgroundColor:[NSColor clearColor]];
	[panel setOpaque:NO];
	[panel setTarget:self];
	[panel setAction:@selector(clearCell)];
	
	
    id	prototype;
	prototype = [matrix cellAtRow:0 column:0];
	
	[prototype setHighlightsBy:NSNoCellMask];
	[prototype setImagePosition:NSImageOnly];
	[prototype setFocusRingType:NSFocusRingTypeNone];
	
    [matrix setPrototype:prototype];
	[matrix setIntercellSpacing:NSMakeSize(3,3)];
	
	
	NSSize max = [nameTextField frame].size;
	max = NSMakeSize([[NSScreen mainScreen] frame].size.width-497-33,max.height);
	[nameTextField setMaxSize:max];
	

}

-(void)setImageLoader:(COImageLoader*)loader
{
	[sortPopUpButton setEnabled:YES];
	sortMode = 0;
	//mangaMode = NO;
	[sortPopUpButton selectItemAtIndex:0];
	if (loader != imageLoader) [thumImageArray removeAllObjects];
	pathArray = [loader pathArray];
	imageLoader = loader;
	now = 0;
}

-(void)setmaxCacheCount:(int)size
{
	if (maxCacheCount != size && size>=0) {
		maxCacheCount = size;
		while ([thumImageArray count] > maxCacheCount) [thumImageArray removeObjectAtIndex:0];
	}
}
#pragma mark -




-(id)loadImage:(int)index
{
	NSEnumerator *enu;
	enu = [thumImageArray objectEnumerator];
	NSDictionary *object;
	while (object = [enu nextObject]) {
		if ([[object objectForKey:@"page"] intValue] == index) {
			[object retain];
			[thumImageArray removeObject:object];
			[thumImageArray addObject:object];
			[object release];
			return [object objectForKey:@"image"];
		}
	}
	
	
	NSImage *image;
	image = [[controller loadImage:index] retain];
	
	int widthValue = [image size].width;
	int heightValue = [image size].height;
	float wRate = widthValue/[matrix cellSize].width;
	float hRate = heightValue/[matrix cellSize].height;
	float newWidth;
	float newHeight;
	if (wRate > hRate) {
		newWidth = widthValue/wRate;
		newHeight = heightValue/wRate;
	} else {
		newWidth = widthValue/hRate;
		newHeight = heightValue/hRate;
	}
	/*
	BOOL b = NO;
	enu = [[controller bookmarkArray] objectEnumerator];
	while (object = [enu nextObject]) {
		if ([[object objectForKey:@"page"] intValue] == index+1) {
			b = YES;
			break;
		}
	}*/
	NSImage *newImage = [[[NSImage alloc] initWithSize:NSMakeSize(newWidth,newHeight)] autorelease];
	[newImage lockFocus];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationLow];
    [image drawInRect:NSMakeRect(0,0,(int)newWidth,(int)newHeight)
              fromRect:NSMakeRect(0, 0, [image size].width, [image size].height)
             operation:NSCompositeSourceOver fraction:1.0];
	
	/*
	if (b) {
		NSRect rect = NSMakeRect(0,0,(int)newWidth,(int)newHeight);
		rect.origin.x = rect.size.width-28;
		rect.origin.y = rect.size.height-28;
		rect.size.width = 24;
		rect.size.height = 24;
		
		NSBezierPath *bezier = [NSBezierPath bezierPath];
		float rad = 7.0;
		[bezier appendBezierPathWithArcWithCenter:NSMakePoint(rect.origin.x+rad,rect.origin.y+rect.size.height-rad)
										   radius:rad startAngle:90 endAngle:180];
		[bezier appendBezierPathWithArcWithCenter:NSMakePoint(rect.origin.x+rad,rect.origin.y+rad)
										   radius:rad startAngle:180 endAngle:270];
		[bezier appendBezierPathWithArcWithCenter:NSMakePoint(rect.origin.x+rect.size.width-rad,rect.origin.y+rad)
										   radius:rad startAngle:270  endAngle:0];
		[bezier appendBezierPathWithArcWithCenter:NSMakePoint(rect.origin.x+rect.size.width-rad,rect.origin.y+rect.size.height-rad)
										   radius:rad startAngle:0 endAngle:90];
		[bezier closePath];
		[[[NSColor blackColor] colorWithAlphaComponent:0.8] set];
		[bezier fill];
		
		NSImage *image = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bookmark" ofType:@"tiff"]] autorelease];
		
		[image drawInRect:rect
				 fromRect:NSMakeRect(0,0,[image size].width,[image size].height)
				operation:NSCompositeSourceOver
				 fraction:1.0];
	}*/
	
	[newImage unlockFocus];
	[image release];
	[thumImageArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:newImage,@"image",[NSString stringWithFormat:@"%i",index],@"page",nil]];
	while ([thumImageArray count] > maxCacheCount) [thumImageArray removeObjectAtIndex:0];
	return newImage;
}

-(id)loadMangaImage:(int)index back:(BOOL)back
{
	NSImage *image,*image2;
	if (!back) {
		image = [[self loadImage:index] retain];
		if (![controller isSmallImage:image page:index+1] || [controller readMode] > 1 || index == [pathArray count]-1) {
			return [image autorelease];
		} else {
			image2 = [[self loadImage:index+1] retain];
			if ([controller isSmallImage:image page:index+1] && [controller isSmallImage:image2 page:index+2]) {
				int widthValue1 = [image size].width;
				int heightValue1 = [image size].height;
				int widthValue2 = [image2 size].width;
				int heightValue2 = [image2 size].height;
				float screenWidthValue = [matrix cellSize].width;
				float screenHeightValue = [matrix cellSize].height;
				screenWidthValue /= 2;
				float rate1 = screenWidthValue/widthValue1;
				float sRate1 = screenHeightValue/heightValue1;
				
				float rate2 = screenWidthValue/widthValue2;
				float sRate2 = screenHeightValue/heightValue2;
				
				if (rate1 > sRate1) {
					rate1 = sRate1;
				}
				if (rate2 > sRate2) {
					rate2 = sRate2;
				}
				
				widthValue1 = widthValue1*rate1;
				heightValue1 = heightValue1*rate1;
				
				widthValue2 = widthValue2*rate2;
				heightValue2 = heightValue2*rate2;
				
				if (widthValue1+widthValue2 < [matrix cellSize].width){
					if (heightValue1 != screenHeightValue) {
						rate1 = screenHeightValue/[image size].height;
						widthValue1 = [image size].width*rate1;
						heightValue1 = [image size].height*rate1;
					}
					if (heightValue2 != screenHeightValue) {
						rate2 = screenHeightValue/[image2 size].height;
						widthValue2 = [image2 size].width*rate2;
						heightValue2 = [image2 size].height*rate2;
					}
					if (widthValue1+widthValue2 > [matrix cellSize].width){
						float rates = [matrix cellSize].width/(widthValue1+widthValue2);
						
						widthValue1 = widthValue1*rates;
						heightValue1 = heightValue1*rates;
						widthValue2 = widthValue2*rates;
						heightValue2 = heightValue2*rates;
					}
				}
				int height;
				if (heightValue1 > heightValue2) {
					height = heightValue1;
				} else {
					height = heightValue2;
				}
				int center1 = (height-heightValue1)/2;
				int center2 = (height-heightValue2)/2;
				
				NSImage *newImage = [[[NSImage alloc] initWithSize:NSMakeSize(widthValue1+widthValue2,height)] autorelease];
				[ newImage lockFocus ];
				[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationLow];
				if ([controller readMode] == 1) {
                    [image drawInRect:NSMakeRect(0,(int)center1,(int)widthValue1,(int)heightValue1)
                             fromRect:NSMakeRect(0, 0, [image size].width, [image size].height)
                            operation:NSCompositeSourceOver fraction:1.0];
                    [image2 drawInRect:NSMakeRect((int)widthValue1,(int)center2,(int)widthValue2,(int)heightValue2)
                              fromRect:NSMakeRect(0, 0, [image2 size].width, [image2 size].height)
                             operation:NSCompositeSourceOver fraction:1.0];
				} else if ([controller readMode] == 0) {
                    [image2 drawInRect:NSMakeRect(0,(int)center2,(int)widthValue2,(int)heightValue2)
                             fromRect:NSMakeRect(0, 0, [image2 size].width, [image2 size].height)
                            operation:NSCompositeSourceOver fraction:1.0];
                    [image drawInRect:NSMakeRect((int)widthValue2,(int)center1,(int)widthValue1,(int)heightValue1)
                              fromRect:NSMakeRect(0, 0, [image size].width, [image size].height)
                             operation:NSCompositeSourceOver fraction:1.0];
				}
				[ newImage unlockFocus ];
				[image release];
				[image2 release];
				
				now++;
				return newImage;
			} else {
				[image2 release];
				return [image autorelease];
			}
		}
	} else if (back) {
		image = [[self loadImage:index] retain];
		if (![controller isSmallImage:image page:index+1] || [controller readMode] > 1 || index == 0) {
			return [image autorelease];

		} else {
			image2 = [[self loadImage:index-1] retain];
			if ([controller isSmallImage:image page:index+1] && [controller isSmallImage:image2 page:index]) {
                int widthValue1 = [image size].width;
                int heightValue1 = [image size].height;
                int widthValue2 = [image2 size].width;
                int heightValue2 = [image2 size].height;
				float screenWidthValue = [matrix cellSize].width;
				float screenHeightValue = [matrix cellSize].height;
				screenWidthValue /= 2;
				float rate1 = screenWidthValue/widthValue1;
				float sRate1 = screenHeightValue/heightValue1;
				
				float rate2 = screenWidthValue/widthValue2;
				float sRate2 = screenHeightValue/heightValue2;
				
				if (rate1 > sRate1) {
					rate1 = sRate1;
				}
				if (rate2 > sRate2) {
					rate2 = sRate2;
				}
				
				widthValue1 = widthValue1*rate1;
				heightValue1 = heightValue1*rate1;
				
				widthValue2 = widthValue2*rate2;
				heightValue2 = heightValue2*rate2;
				
				if (widthValue1+widthValue2 < [matrix cellSize].width){
					if (heightValue1 != screenHeightValue) {
						rate1 = screenHeightValue/[image size].height;
						widthValue1 = [image size].width*rate1;
						heightValue1 = [image size].height*rate1;
					}
					if (heightValue2 != screenHeightValue) {
						rate2 = screenHeightValue/[image2 size].height;
						widthValue2 = [image2 size].width*rate2;
						heightValue2 = [image2 size].height*rate2;
					}
					if (widthValue1+widthValue2 > [matrix cellSize].width){
						float rates = [matrix cellSize].width/(widthValue1+widthValue2);
						
						widthValue1 = widthValue1*rates;
						heightValue1 = heightValue1*rates;
						widthValue2 = widthValue2*rates;
						heightValue2 = heightValue2*rates;
					}
				}
				int height;
				if (heightValue1 > heightValue2) {
					height = heightValue1;
				} else {
					height = heightValue2;
				}
				int center1 = (height-heightValue1)/2;
				int center2 = (height-heightValue2)/2;
				
				NSImage *newImage = [[[NSImage alloc] initWithSize:NSMakeSize(widthValue1+widthValue2,height)] autorelease];
				[ newImage lockFocus ];
				[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationLow];
				if ([controller readMode] == 1) {
					[ image2 drawInRect:NSMakeRect(0,(int)center2,(int)widthValue2,(int)heightValue2)
                     fromRect:NSMakeRect(0, 0, [image2 size].width, [image2 size].height)
                    operation:NSCompositeSourceOver fraction:1.0];
					[ image drawInRect:NSMakeRect((int)widthValue2,(int)center1,(int)widthValue1,(int)heightValue1)
                     fromRect:NSMakeRect(0, 0, [image size].width, [image size].height)
                    operation:NSCompositeSourceOver fraction:1.0];
				} else if ([controller readMode] == 0) {
                    [image drawInRect:NSMakeRect(0,(int)center1,(int)widthValue1,(int)heightValue1)
                             fromRect:NSMakeRect(0, 0, [image size].width, [image size].height)
                            operation:NSCompositeSourceOver fraction:1.0];
                    [image2 drawInRect:NSMakeRect((int)widthValue1,(int)center2,(int)widthValue2,(int)heightValue2)
                              fromRect:NSMakeRect(0, 0, [image2 size].width, [image2 size].height)
                             operation:NSCompositeSourceOver fraction:1.0];
				}
				[ newImage unlockFocus ];
				[image release];
				[image2 release];
				
				now--;
				return newImage;
			} else {
				return [image autorelease];
			}
		}
		
	}
}




#pragma mark -
-(void)showBookmarkThumbnail
{
	[self clearCell];
	nowBookmarkPage = 1;
	[panel makeKeyAndOrderFront:self];
	
	[nameTextField setStringValue:[[imageLoader displayPath] lastPathComponent]];
	[nameTextField setMenu:[controller openSameFolderMenuItem]];
	[nameTextField sizeToFit];
	
	[self setBookmarkImageCells:NO];
}

-(void)setBookmarkImageCells:(BOOL)back
{	
	doCount++;
	[self performSelector:@selector(setBookmarkImageCellsMethod:) withObject:[NSNumber numberWithBool:back] afterDelay:0.001];
}

-(void)setBookmarkImageCellsMethod:(NSNumber*)backValue
{
	if (now < 0) now = 0;
	if (doCount == 1) stop = NO;
	NSArray *bookmarkArray = [controller bookmarkArray];
	if ([bookmarkArray count] == 0) {
		doCount--;
		[stateTextField setStringValue:@"no bookmark"];
		return;
	}
	
	cellCount = 0;
	NSArray *cells = [matrix cells];
	NSEnumerator *enu = [cells objectEnumerator];
	id object;
	while (object = [enu nextObject]) {
		[object setImage:nil];
		[object setAlternateTitle:@""];
		[object setRepresentedObject:nil];
	}
	[matrix resetBookMarkIcon];
	if (![panel isVisible]) [panel makeKeyAndOrderFront:self];
	
	int all = (int)[(NSMatrix*)matrix numberOfColumns]*(int)[matrix numberOfRows];
	int maxPage = (int)[bookmarkArray count]/all;
	if ([bookmarkArray count]%all != 0) {
		maxPage++;
	}
	[stateTextField setStringValue:[NSString stringWithFormat:@"%i/%i",nowBookmarkPage,maxPage]];
	
	int rowCount = 0;
	int colCount = 0;
	
	if (![controller readFromLeft]) {
		colCount = (int)[(NSMatrix*)matrix numberOfColumns]-1;
	}
	
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:colCount],@"colCount",
		[NSNumber numberWithInt:rowCount],@"rowCount",
		//[NSNumber numberWithBool:back],@"back",
		nil];
	[self setBookmarkImageCellWithInfo:info];	
}

-(void)setBookmarkImageCellWithInfo:(id)infoDic
{
	
	if (doCount > 1) {
		doCount--;
		return;
	}
	if (stop) {
		doCount--;
		stop = NO;
		return;
	}
	
	int colCount = [[infoDic objectForKey:@"colCount"] intValue];
	int rowCount = [[infoDic objectForKey:@"rowCount"] intValue];
	//BOOL back = [[infoDic objectForKey:@"back"] boolValue];
	int all = (int)[(NSMatrix*)matrix numberOfColumns]*(int)[matrix numberOfRows];
	int max = all*nowBookmarkPage;
	int start = max-all;
	
	
	NSArray *bookmarkArray = [controller bookmarkArray];
	now = [[[bookmarkArray objectAtIndex:start+cellCount] objectForKey:@"page"] intValue];
	now--;
	
	[self setImageToCellAtRow:rowCount column:colCount back:NO];
	
	if (![controller readFromLeft]) {
		colCount--;
		cellCount++;
		if (colCount < 0) {
			rowCount++;
			colCount = (int)[(NSMatrix*)matrix numberOfColumns]-1;
			if (rowCount == [matrix numberOfRows]) {
				doCount--;
				return;
			}
		}
	} else {
		colCount++;
		cellCount++;
		if (colCount == [(NSMatrix*)matrix numberOfColumns]) {
			rowCount++;
			colCount=0;
			if (rowCount == [matrix numberOfRows]) {
				doCount--;
				return;
			}
		}
	}
	if (cellCount < all && [bookmarkArray count] > start+cellCount) {
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:colCount],@"colCount",
			[NSNumber numberWithInt:rowCount],@"rowCount",
			nil];
		[self performSelector:@selector(setBookmarkImageCellWithInfo:) withObject:info afterDelay:0.001];
		return;
	} else {
		doCount--;
		return;
	}
}


#pragma mark -
-(void)showThumbnail:(int)nowPage
{
	if ([controller sortMode] == 0) {
		sortMode = 0;
		[sortPopUpButton selectItemAtIndex:0];
	} else if ([controller sortMode] == 2) {
		sortMode = 1;
		[sortPopUpButton selectItemAtIndex:1];
	} else if ([controller sortMode] == 3) {
		sortMode = 2;
		[sortPopUpButton selectItemAtIndex:2];
	}
	
	 if (bookmarkMode) {
		 [self showBookmarkThumbnail];
		 return;
	 }
	[self clearCell];
	if (mangaMode) {
		now = nowPage-1;
	} else {
		int all = (int)[(NSMatrix*)matrix numberOfColumns]*(int)[matrix numberOfRows];
		int temp = 0;
		int i;
		for (i = 0; i < [pathArray count]; i++) {
			temp = all*i;
			if (nowPage <= temp) {
				now = temp-all;
				break;
			}
		}
	}
	
	
	[panel makeKeyAndOrderFront:self];
	
	[nameTextField setStringValue:[[imageLoader displayPath] lastPathComponent]];	
	//[nameTextField setStringValue:[imageLoader itemPathAtIndex:0]]; //ながーい
	[nameTextField setMenu:[controller openSameFolderMenuItem]];
	[nameTextField sizeToFit];
	
	[self setImageCells:NO];
}


-(void)setImageCells:(BOOL)back
{	
	doCount++;
	[self performSelector:@selector(setImageCellsMethod:) withObject:[NSNumber numberWithBool:back] afterDelay:0.001];
}

-(void)setImageCellsMethod:(NSNumber*)backValue
{
	if (now < 0) now = 0;
	if (doCount == 1) stop = NO;
	
	BOOL back = [backValue boolValue];
	cellCount = 0;
	NSArray *cells = [matrix cells];
	NSEnumerator *enu = [cells objectEnumerator];
	id object;
	while (object = [enu nextObject]) {
		[object setImage:nil];
		[object setAlternateTitle:@""];
		[object setRepresentedObject:nil];
	}
	[matrix resetBookMarkIcon];
	if (![panel isVisible]) [panel makeKeyAndOrderFront:self];
	
    int rowCount = 0;
	int colCount = 0;
	
	int all = (int)[(NSMatrix*)matrix numberOfColumns]*(int)[matrix numberOfRows];
	int last = now+all;
	if (last > [pathArray count]) {
		last = (int)[pathArray count];
	}

	if (mangaMode) {
		if (!back) {
			[stateTextField setStringValue:[NSString stringWithFormat:@"%i-",now+1]];
			//[stateTextField display];
			if (![controller readFromLeft]) {
				colCount = (int)[(NSMatrix*)matrix numberOfColumns]-1;
			}
			NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:all],@"all",
				[NSNumber numberWithInt:last],@"last",
				[NSNumber numberWithInt:colCount],@"colCount",
				[NSNumber numberWithInt:rowCount],@"rowCount",
				[NSNumber numberWithBool:back],@"back",
				nil];
			[self setImageCellWithInfo:info];
		} else {
			[stateTextField setStringValue:[NSString stringWithFormat:@"-%i/%i",now,(int)[pathArray count]]];
			//[stateTextField display];
			int oldNow = now;
			if (![controller readFromLeft]) {
				rowCount = (int)[matrix numberOfRows]-1;
			} else {
				rowCount = (int)[matrix numberOfRows]-1;
				colCount = (int)[(NSMatrix*)matrix numberOfColumns]-1;
			}
			NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:all],@"all",
				[NSNumber numberWithInt:last],@"last",
				[NSNumber numberWithInt:colCount],@"colCount",
				[NSNumber numberWithInt:rowCount],@"rowCount",
				[NSNumber numberWithInt:oldNow],@"oldNow",
				[NSNumber numberWithBool:back],@"back",
				nil];
			[self setImageCellWithInfo:info];
		}
	} else {
		if (![controller readFromLeft]) {
			colCount = (int)[(NSMatrix*)matrix numberOfColumns]-1;
		}
		[stateTextField setStringValue:[NSString stringWithFormat:@"%i-%i/%i",now+1,last,(int)[pathArray count]]];
		//[stateTextField display];
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:all],@"all",
			[NSNumber numberWithInt:last],@"last",
			[NSNumber numberWithInt:colCount],@"colCount",
			[NSNumber numberWithInt:rowCount],@"rowCount",
			[NSNumber numberWithBool:back],@"back",
			nil];
		[self setImageCellWithInfo:info];
	}
}

-(void)setImageCellWithInfo:(id)infoDic
{
	if (doCount > 1) {
		doCount--;
		return;
	}
	if (stop) {
		doCount--;
		stop = NO;
		return;
	}
	int all = [[infoDic objectForKey:@"all"] intValue];
	int last = [[infoDic objectForKey:@"last"] intValue];	
	int colCount = [[infoDic objectForKey:@"colCount"] intValue];
	int rowCount = [[infoDic objectForKey:@"rowCount"] intValue];
	BOOL back = [[infoDic objectForKey:@"back"] boolValue];
	if (!back) {
		if (![controller readFromLeft]) {
			[self setImageToCellAtRow:rowCount column:colCount back:NO];
			colCount--;
			now++;
			cellCount++;
			if (now == [pathArray count]) {
				if (mangaMode) [stateTextField setStringValue:[NSString stringWithFormat:@"%@%i/%i",[stateTextField stringValue],now,(int)[pathArray count]]];
				doCount--;
				return;
			}
			if (colCount < 0) {
				rowCount++;
				colCount = (int)[(NSMatrix*)matrix numberOfColumns]-1;
				if (rowCount == [matrix numberOfRows]) {
					if (mangaMode) [stateTextField setStringValue:[NSString stringWithFormat:@"%@%i/%i",[stateTextField stringValue],now,(int)[pathArray count]]];
					doCount--;
					return;
				}
			}
			if (cellCount < all) {
				NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInt:all],@"all",
					[NSNumber numberWithInt:last],@"last",
					[NSNumber numberWithInt:colCount],@"colCount",
					[NSNumber numberWithInt:rowCount],@"rowCount",
					[NSNumber numberWithBool:back],@"back",
					nil];
				[self performSelector:@selector(setImageCellWithInfo:) withObject:info afterDelay:0.001];
				return;
			}
		} else {
			[self setImageToCellAtRow:rowCount column:colCount back:NO];
			colCount++;
			now++;
			cellCount++;
			if (now == [pathArray count]) {
				if (mangaMode) [stateTextField setStringValue:[NSString stringWithFormat:@"%@%i/%i",[stateTextField stringValue],now,(int)[pathArray count]]];
				doCount--;
				return;
			}
			if (colCount == [(NSMatrix*)matrix numberOfColumns]) {
				rowCount++;
				colCount=0;
				if (rowCount == [matrix numberOfRows]) {
					if (mangaMode) [stateTextField setStringValue:[NSString stringWithFormat:@"%@%i/%i",[stateTextField stringValue],now,(int)[pathArray count]]];
					doCount--;
					return;
				}
			}
			if (cellCount < all) {
				NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInt:all],@"all",
					[NSNumber numberWithInt:last],@"last",
					[NSNumber numberWithInt:colCount],@"colCount",
					[NSNumber numberWithInt:rowCount],@"rowCount",
					[NSNumber numberWithBool:back],@"back",
					nil];
				[self performSelector:@selector(setImageCellWithInfo:) withObject:info afterDelay:0.001];
				return;
			}
		}
	} else if (mangaMode && back) {
		int oldNow = [[infoDic objectForKey:@"oldNow"] intValue];
		if (![controller readFromLeft]) {
			now--;
			[self setImageToCellAtRow:rowCount column:colCount back:YES];
			colCount++;
			cellCount++;
			if (now == 0) {
				[stateTextField setStringValue:[NSString stringWithFormat:@"%i%@",now+1,[stateTextField stringValue]]];
				doCount--;
				now = oldNow;
				return;
			}
			
			if (colCount == [(NSMatrix*)matrix numberOfColumns]) {
				rowCount--;
				colCount = 0;
				if (rowCount < 0) {
					[stateTextField setStringValue:[NSString stringWithFormat:@"%i%@",now+1,[stateTextField stringValue]]];
					doCount--;
					now = oldNow;
					return;
				}
			}
			if (cellCount < all) {
				NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInt:all],@"all",
					[NSNumber numberWithInt:last],@"last",
					[NSNumber numberWithInt:colCount],@"colCount",
					[NSNumber numberWithInt:rowCount],@"rowCount",
					[NSNumber numberWithInt:oldNow],@"oldNow",
					[NSNumber numberWithBool:back],@"back",
					nil];
				[self performSelector:@selector(setImageCellWithInfo:) withObject:info afterDelay:0.001];
				return;
			}
		} else {
			now--;
			[self setImageToCellAtRow:rowCount column:colCount back:YES];
			colCount--;
			cellCount++;
			if (now == 0) {
				[stateTextField setStringValue:[NSString stringWithFormat:@"%i%@",now+1,[stateTextField stringValue]]];
				doCount--;
				now = oldNow;
				return;
			}
			
			if (colCount < 0) {
				rowCount--;
				colCount = (int)[(NSMatrix*)matrix numberOfColumns]-1;
				if (rowCount < 0) {
					[stateTextField setStringValue:[NSString stringWithFormat:@"%i%@",now+1,[stateTextField stringValue]]];
					doCount--;
					now = oldNow;
					return;
				}
			}
			if (cellCount < all) {
				NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInt:all],@"all",
					[NSNumber numberWithInt:last],@"last",
					[NSNumber numberWithInt:colCount],@"colCount",
					[NSNumber numberWithInt:rowCount],@"rowCount",
					[NSNumber numberWithInt:oldNow],@"oldNow",
					[NSNumber numberWithBool:back],@"back",
					nil];
				[self performSelector:@selector(setImageCellWithInfo:) withObject:info afterDelay:0.001];
				return;
			}
		}
	}
}

#pragma mark -
-(void)setImageToCellAtRow:(int)row column:(int)col back:(BOOL)back
{
	if (![panel isVisible]) return;
	[matrix displayIfNeeded];
	
	int nowI = now;
	NSImage *image;
	NSString *string;
	
	if (mangaMode) {
		image = [[self loadMangaImage:nowI back:back] retain];
		if (nowI == now) {
			string = [NSString stringWithFormat:@"%@",
				[[imageLoader itemNameAtIndex:nowI] lastPathComponent]
				];
		} else {
			
			int leftI,rightI;
			if (back) {
				if ([controller readFromLeft]) {
					leftI = nowI-1;
					rightI = nowI;
				} else {
					leftI = nowI;
					rightI = nowI-1;
				}
			} else {
				if ([controller readFromLeft]) {
					leftI = nowI;
					rightI = nowI+1;
				} else {
					leftI = nowI+1;
					rightI = nowI;
				}
			}
			string = [NSString stringWithFormat:@"%@ | %@",
				[[imageLoader itemNameAtIndex:leftI] lastPathComponent],
				[[imageLoader itemNameAtIndex:rightI] lastPathComponent]
				];
		}
	} else {
		image = [[self loadImage:nowI] retain];
		string = [NSString stringWithFormat:@"%@",
			[[imageLoader itemNameAtIndex:nowI] lastPathComponent]
			];
	}
	if (bookmarkMode) {
		int index = nowBookmarkPage-1;
		index = index*(int)[(NSMatrix*)matrix numberOfColumns]*(int)[matrix numberOfRows];
		index = index+cellCount;
		id object = [[controller bookmarkArray] objectAtIndex:index];
		string = [NSString stringWithFormat:@"%@\n%@",[object objectForKey:@"name"],string];
		if (![controller readFromLeft]) {
			[matrix setBookmarkIconAtRow:row column:col left:NO];
		} else {
			[matrix setBookmarkIconAtRow:row column:col left:YES];
		}
	} else {
		NSString *bmName1 = nil;
		NSString *bmName2 = nil;
		id object;
		NSEnumerator *enu = [[controller bookmarkArray] objectEnumerator];
		while (object=[enu nextObject]) {
			if (mangaMode) {
				if (!back) {
					if (nowI == now) {
						if (nowI+1 == [[object objectForKey:@"page"] intValue]) {
							bmName1 = [object objectForKey:@"name"];
							break;
						}
					} else {
						if (nowI+1 == [[object objectForKey:@"page"] intValue]) {
							bmName1 = [object objectForKey:@"name"];
						} else if (nowI+2 == [[object objectForKey:@"page"] intValue]) {
							bmName2 = [object objectForKey:@"name"];
						}
						if (bmName1 && bmName2) break;
					}
				} else {
					if (nowI == now) {
						if (nowI+1 == [[object objectForKey:@"page"] intValue]) {
							bmName1 = [object objectForKey:@"name"];
							break;
						}
					} else {
						if (nowI == [[object objectForKey:@"page"] intValue]) {
							bmName1 = [object objectForKey:@"name"];
						} else if (nowI+1 == [[object objectForKey:@"page"] intValue]) {
							bmName2 = [object objectForKey:@"name"];
							//break;
						}
						if (bmName1 && bmName2) break;
					}
				}
			} else {
				if (nowI+1 == [[object objectForKey:@"page"] intValue]) {
					bmName1 = [object objectForKey:@"name"];
					break;
				}
			}
		}
		if (bmName1 && bmName2) {
			[matrix setBookmarkIconAtRow:row column:col left:NO];
			[matrix setBookmarkIconAtRow:row column:col left:YES];
			string = [NSString stringWithFormat:@"%@\n%@\n%@",bmName1,bmName2,string];
		} else if (bmName1) {
			if (![controller readFromLeft]) {
				[matrix setBookmarkIconAtRow:row column:col left:NO];
			} else {
				[matrix setBookmarkIconAtRow:row column:col left:YES];
			}
			string = [NSString stringWithFormat:@"%@\n%@",bmName1,string];
		} else if (bmName2) {
			if (![controller readFromLeft]) {
				[matrix setBookmarkIconAtRow:row column:col left:YES];
			} else {
				[matrix setBookmarkIconAtRow:row column:col left:NO];
			}
			string = [NSString stringWithFormat:@"%@\n%@",bmName2,string];
		}
	}	
	if (mangaMode) {
		if (back) {
			nowI = now;
		}
	}
	id cell = [matrix cellAtRow:row column:col];
	[cell setImage:image];
	[cell setTarget:self];
	[cell setAction:@selector(imageSelected:)];
	[cell setAlternateTitle:[NSString stringWithFormat:@"%i",nowI]];
	[cell setRepresentedObject:string];
	
	[matrix setNeedsDisplayInRect:[matrix cellFrameAtRow:row column:col]];
	[image release];
}



#pragma mark -
-(void)clearCell
{
	NSArray *cells = [matrix cells];
	NSEnumerator *enu = [cells objectEnumerator];
	id object;
	while (object = [enu nextObject]) {
		[object setImage:nil];
		[object setAlternateTitle:@""];
		[object setRepresentedObject:nil];
	}
	
	int colCount = (int)[(NSMatrix*)matrix numberOfColumns];
	int rowCount = (int)[matrix numberOfRows];
	int num = (int)[matrix numberOfRows];
    while (num--) {
        [matrix removeRow:0];
    }
	[self setCellRow:rowCount column:colCount];
	
	now = 0;

	/*
	if (pathArray) {
		[pathArray release];
		pathArray = nil;
	}
	if (pathDic) {
		[pathDic release]
		pathDic = nil;
	}
	 */
}

-(void)setCellRow:(int)rowI column:(int)columnI
{	
	int num = (int)[matrix numberOfRows];
    while (num--) {
        [matrix removeRow:0];
    }
	
	[panel setFrame:[[NSScreen mainScreen] frame] display:NO];
	[matrix renewRows:rowI columns:columnI];
	
	NSRect rect = [matrix frame];
	[matrix sizeToFit];
	[matrix setFrame:rect];
}

-(void)clearAll
{
	if (pathArray) {
		//[pathArray release];
		pathArray = nil;
	}
	if (pathDic) {
		[pathDic release];
		pathDic = nil;
	}
}





#pragma mark -
-(BOOL)isVisible
{
	if ([panel isVisible]) return YES;
	return NO;
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	if ([[anItem title] isEqualToString:NSLocalizedString(@"Creation Date", @"")] == YES) {
		if (![imageLoader canSortByDate]) {
			return NO;
		} else {
			return YES;
		}
	} else if ([[anItem title] isEqualToString:NSLocalizedString(@"Modification Date", @"")] == YES) {
		if (![imageLoader canSortByDate]) {
			return NO;
		} else {
			return YES;
		}
	} else if ([[anItem title] isEqualToString:NSLocalizedString(@"Switch Single/Bind", @"")] == YES) {
		if (mangaMode && [controller readMode]<2) {
			return YES;
		} else {
			return NO;
		}
	} else {
		return YES;
	}
}
#pragma mark -
#pragma mark action
-(IBAction)contextAction:(id)sender
{
	id lastCell;
    int row,col;
	NSInteger tmprow,tmpcol;
	NSEvent *theEvent = [NSApp currentEvent];
	NSPoint point = [matrix convertPoint:[theEvent locationInWindow] fromView:nil];
	if ([matrix getRow:&tmprow column:&tmpcol forPoint:point]) {
		lastCell = [matrix cellAtRow:tmprow column:tmpcol];
	}
    row = (int)tmprow;
    col = (int)tmpcol;
	
	if ([[sender title] isEqualToString:NSLocalizedString(@"Remove Bookmark", @"")]){
		if (bookmarkMode) {
			int page = [[lastCell alternateTitle] intValue];
			page++;
			if (![controller removeBookmarkWithPage:page]) {
				page++;
				[controller removeBookmarkWithPage:page];
				page--;
			}
			[matrix removeBookmarkIconAtRow:row column:col];
			[self showBookmarkThumbnail];
		} else {
			int page = [[lastCell alternateTitle] intValue];
			page++;
			if (![controller removeBookmarkWithPage:page]) {
				page++;
				[controller removeBookmarkWithPage:page];
				page--;
			}
			[matrix removeBookmarkIconAtRow:row column:col];
			int tempNow = now;
			now = page-1;
			[self setImageToCellAtRow:row column:col back:NO];
			now = tempNow;
		}
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Add Bookmark", @"")]){
		int page = [[lastCell alternateTitle] intValue];
		page++;
		[controller addBookmarkWithPage:page];
		int tempNow = now;
		now = page-1;
		[self setImageToCellAtRow:row column:col back:NO];
		now = tempNow;
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Switch Single/Bind", @"")]){
		int page = [[lastCell alternateTitle] intValue];
		if ([[[[lastCell representedObject] componentsSeparatedByString:@"\n"] lastObject] isEqualToString:[[imageLoader itemNameAtIndex:page] lastPathComponent]]) {
			//NSLog(@"single %@ %@",[lastCell representedObject],[lastCell alternateTitle]);
			[controller switchBindWithPage:page+1];
		} else {
			//NSLog(@"bind %@ %@",[lastCell representedObject],[lastCell alternateTitle]);
			[controller switchSingleWithPage:page+1];
		}
		page++;
		
		
		NSMutableArray *mArray = [NSMutableArray array];
		NSEnumerator *enu = [[matrix cells] objectEnumerator];
		id object;
		while (object = [enu nextObject]) {
			if ([object image]) [mArray addObject:[object alternateTitle]];
		}
		
		[mArray sortUsingSelector:@selector(finderCompareS:)];
		page = [[mArray objectAtIndex:0] intValue]+1;
		
		
		[self showThumbnail:page];
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Show in Finder", @"")]){
		int page = [[lastCell alternateTitle] intValue];
		[[NSWorkspace sharedWorkspace] selectFile:[imageLoader itemPathAtIndex:page] inFileViewerRootedAtPath:@""];
		[panel performClose:self];
	}
}


-(IBAction)next:(id)sender
{
	if (![panel isVisible]) return; 
	if (bookmarkMode) {
		nowBookmarkPage++;
		
		int all = (int)[(NSMatrix*)matrix numberOfColumns]*(int)[matrix numberOfRows];
		int maxPage = (int)[[controller bookmarkArray] count]/all;
		if ([[controller bookmarkArray] count]%all != 0) maxPage++;
		
		if (nowBookmarkPage > maxPage) {
			nowBookmarkPage = 1;
		}
		
		//NSLog(@"next %i",nowBookmarkPage);
		[self setBookmarkImageCells:NO];
		return;
	}
	
	int all = (int)[(NSMatrix*)matrix numberOfColumns]*(int)[matrix numberOfRows];
	if ([pathArray count] <= all) return;
	
	if (mangaMode) {
		if (doCount > 0) {
			[self performSelector:@selector(next:) withObject:sender afterDelay:0.001];
			return;
		}
	} else {
		now = now-cellCount+(int)[(NSMatrix*)matrix numberOfColumns]*(int)[matrix numberOfRows];
	}
	
	if (now >= [pathArray count]) now = 0;
	
	[self setImageCells:NO];
}

-(IBAction)prev:(id)sender
{
	if (![panel isVisible]) return; 
	if (bookmarkMode) {
		nowBookmarkPage--;
		if (nowBookmarkPage == 0) {
			int all = (int)[(NSMatrix*)matrix numberOfColumns]*(int)[matrix numberOfRows];
			int maxPage = (int)[[controller bookmarkArray] count]/all;
			if ([[controller bookmarkArray] count]%all != 0) maxPage++;
			
			nowBookmarkPage = maxPage;
		}
		//NSLog(@"prev %i",nowBookmarkPage);
		[self setBookmarkImageCells:NO];
		return;
	}
	if (mangaMode) {
		[self mangaModePrev];
		return;
	}	
	int all = (int)[(NSMatrix*)matrix numberOfColumns]*(int)[matrix numberOfRows];
	
	if ([pathArray count] <= all) return;
	
	now -= cellCount;
	if (now == 0) {
		now = (int)[pathArray count];
		if (now%all > 0) {
			now -= now%all;
		} else {
			now -= cellCount;
		}
		now += all;
	} 
	now -= [(NSMatrix*)matrix numberOfColumns]*[matrix numberOfRows];
	if (now < 0) now = 0;
	
	[self setImageCells:NO];
}


-(void)mangaModePrev
{
	if (![panel isVisible]) return; 
	if (doCount > 0) {
		[self performSelector:@selector(mangaModePrev) withObject:nil afterDelay:0.001];
		return;
	}
	
	NSMutableArray *mArray = [NSMutableArray array];
	NSArray *cells = [matrix cells];
	NSEnumerator *enu = [cells objectEnumerator];
	id object;
	while (object = [enu nextObject]) {
		if ([[object alternateTitle] isEqualToString:@"0"]) {
			now = (int)[pathArray count];
			[self setImageCells:YES];
			
			return;
		}
		if ([object image]) {
			[mArray addObject:[object alternateTitle]];
		}
	}
	
	[mArray sortUsingSelector:@selector(finderCompareS:)];
	now = [[mArray objectAtIndex:0] intValue];
	[self setImageCells:YES];
	
}


- (void)imageSelected:(id)sender
{
	if (![[sender keyCell] image]) {
		return;
	}
	stop = YES;
	int temp = now;
	temp -= cellCount;
	[controller goTo:[[[sender keyCell] alternateTitle] intValue] array:pathArray];
	[panel performClose:self];
	now = temp;
}






-(void)appleRemoteAction:(NSString*)characters
{
    unichar character = [characters characterAtIndex:0];
	int cMod = 100;
	NSEnumerator *enu = [keyArray objectEnumerator];
	id dic;
	while (dic = [enu nextObject]) {
		if (character == [[dic objectForKey:@"key"] characterAtIndex:0] && cMod == [[dic objectForKey:@"modifier"] intValue]){
			int action = [[dic objectForKey:@"action"] intValue];
			if ([[dic objectForKey:@"switchAction"] boolValue] == YES && [controller readFromLeft]) {
				switch (action) {
					case 0: action=1; break;
					case 1: action=0; break;
					case 2: action=3; break;
					case 3: action=2; break;
					case 4: action=5; break;
					case 5: action=4; break;
					case 6: action=7; break;
					case 7: action=6; break;
					case 8: action=9; break;
					case 9: action=8; break;
					case 13: action=14; break;
					case 14: action=13; break;
					case 26: action=27; break;
					case 27: action=26; break;
					case 35: action=36; break;
					case 36: action=35; break;
					default:
						break;
				}
			}
			switch (action) {
				case 0:
					[self next:self];
					break;
				case 1:
					[self prev:self];
					break;
				case 4:
					[controller goToLast];
					[self showThumbnail:[controller nowPage]];
					break;
				case 5:
					[controller goToFirst];
					[self showThumbnail:[controller nowPage]];
					break;
				case 35:
					[controller nextSubFolder];
					[self showThumbnail:[controller nowPage]];
					break;
				case 36:
					[controller prevSubFolder];
					[self showThumbnail:[controller nowPage]];
					break;
				case 8:
					[controller nextFolder];
					break;
				case 9:
					[controller backFolder];
					break;
				case 18: case 46:
					[panel performClose:self];
					break;
				default:
					break;
			}
			return;
		}
	}
}

-(void)action:(NSEvent*)event
{
	NSString *string = [event charactersIgnoringModifiers];
    unichar character = [string characterAtIndex: 0];
	

	if (character == 0x1B) {
		/*esc*/
		stop = YES;
		
		now -= cellCount;
		[panel performClose:self];
		
	} else if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:character]){
		int page = [string intValue];
		int all = (int)[matrix numberOfRows]*(int)[(NSMatrix*)matrix numberOfColumns];
		now = page*all;
		if (now < 1) {
			now = 0;
		} else if (now >= [pathArray count]) {
			now = (int)[pathArray count];
			if (now%all == 0) {
				now -=all;
			}else {
				now -= now%all;
			}
		}
		
		[self setImageCells:NO];
	} else {
		NSEnumerator *enu = [keyArray objectEnumerator];
		id dic;
		
		unsigned int cMod = 0;
		BOOL shift = ([event modifierFlags] & NSShiftKeyMask) ? YES : NO;
		BOOL option = ([event modifierFlags] & NSAlternateKeyMask) ? YES : NO;
		BOOL control = ([event modifierFlags] & NSControlKeyMask) ? YES : NO;
		
		if (shift) cMod += 1;
		if (option) cMod += 2;
		if (control) cMod += 4;
		
		//0:nextpage	1:prevpage	4:lastpage	5:toppage	8:nextfolder	9:prevfolder	35:nextSubFolder 36:prevSubFolder
		//18:showThumbnail 46:close

		while (dic = [enu nextObject]) {
			if (character == [[dic objectForKey:@"key"] characterAtIndex:0] && cMod == [[dic objectForKey:@"modifier"] intValue]){
				int action = [[dic objectForKey:@"action"] intValue];
				if ([[dic objectForKey:@"switchAction"] boolValue] == YES && [controller readFromLeft]) {
					switch (action) {
						case 0: action=1; break;
						case 1: action=0; break;
						case 2: action=3; break;
						case 3: action=2; break;
						case 4: action=5; break;
						case 5: action=4; break;
						case 6: action=7; break;
						case 7: action=6; break;
						case 8: action=9; break;
						case 9: action=8; break;
						case 13: action=14; break;
						case 14: action=13; break;
						case 26: action=27; break;
						case 27: action=26; break;
						case 35: action=36; break;
						case 36: action=35; break;
						default:
							break;
					}
				}
				switch (action) {
					case 0:
						[self next:self];
						break;
					case 1:
						[self prev:self];
						break;
					case 4:
						[controller goToLast];
						[self showThumbnail:[controller nowPage]];
						break;
					case 5:
						[controller goToFirst];
						[self showThumbnail:[controller nowPage]];
						break;
					case 35:
						[controller nextSubFolder];
						[self showThumbnail:[controller nowPage]];
						break;
					case 36:
						[controller prevSubFolder];
						[self showThumbnail:[controller nowPage]];
						break;
					case 8:
						[controller nextFolder];
						break;
					case 9:
						[controller backFolder];
						break;
					case 18: case 46:
						[panel performClose:self];
						break;
					default:
						break;
				}
				return;
			}
		}
		return;
	}
}


-(void)wheelSetting:(float)set
{
	wheelSensitivity = set;
	[panel wheelSetting:set];
}


- (void)wheelAction:(NSEvent*)event
{
	float wheelCount = [event deltaY];
	
	float temp = wheelSensitivity;
	if (wheelCount < 0) {
		temp = -1*wheelSensitivity;
		if (wheelCount <= temp) {
			if (wheelUpTimer) {
				return;
			} else {
				wheelDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self
																selector:@selector(wheelDown)
																userInfo:NULL
																 repeats:NO];
			}
		}
	} else {
		if (wheelCount >= temp) {
			if (wheelDownTimer) {
				return;
			} else {
				wheelUpTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self
															  selector:@selector(wheelUp)
															  userInfo:NULL
															   repeats:NO];
			}
		}
	}
}

- (void)wheelUp
{
	[self prev:nil];
	wheelUpTimer = nil;
}
- (void)wheelDown
{
	[self next:nil];
	wheelDownTimer = nil;
}

- (void)setPageKey:(NSArray*)array
{
	[keyArray autorelease];
	keyArray = [array retain];
}


-(IBAction)onlyBookmark:(id)sender
{
	if ([sender state] == NSOnState) {
		bookmarkMode = YES;
		[self showBookmarkThumbnail];
	} else {
		bookmarkMode = NO;
		[self showThumbnail:[controller nowPage]];
	}
	[[NSUserDefaults standardUserDefaults] setBool:bookmarkMode forKey:@"ThumbnailOnlyBookmark"];
}
-(IBAction)comicMode:(id)sender
{
	if ([sender state] == NSOnState) {
		mangaMode = YES;
		[self showThumbnail:[controller nowPage]];
	} else {
		mangaMode = NO;
		[self showThumbnail:[controller nowPage]];
	}
	[[NSUserDefaults standardUserDefaults] setBool:mangaMode forKey:@"ThumbnailComicMode"];
}

#pragma mark sort
-(IBAction)sort:(id)sender
{
	int oldSortMode = sortMode;
	sortMode = (int)[sortPopUpButton indexOfItem:sender];
	if (oldSortMode!=sortMode) {
		[thumImageArray removeAllObjects];
	} else {
		sortMode = oldSortMode;
		return;
	}
	now = 0;
	nowBookmarkPage = 1;
	if (![imageLoader canSortByDate]) {
		now = [controller nowPage];
		[self showThumbnail:now];
	} else {
		switch (sortMode) {
			case 0:
				[controller setSortMode:0 page:0];
				[self showThumbnail:now];
				break;
			case 1:
				[controller setSortMode:2 page:0];
				[self showThumbnail:now];
				break;
			case 2:
				[controller setSortMode:3 page:0];
				[self showThumbnail:now];
				break;
			default:
				[controller goTo:0 array:pathArray];
				[self showThumbnail:now];
				break;
		}
	}
}
@end
