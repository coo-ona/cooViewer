#import "BookmarkController.h"

@implementation BookmarkController

//const int ITEM_DELETE = 1;
static const int DIALOG_OK		= 128;
static const int DIALOG_CANCEL	= 129;


-(void)awakeFromNib
{
	NSArray *tableRowTypes = [NSArray arrayWithObject:@"row"];
	[bookmarkTableView registerForDraggedTypes:tableRowTypes];
	[allBookmarkTableView registerForDraggedTypes:tableRowTypes];
	
	
	
	defaults = [NSUserDefaults standardUserDefaults];
	
	[bookmarkPanel setFrameAutosaveName:@"Bookmark"];
	[allBookmarkPanel setFrameAutosaveName:@"AllBookmark"];
	if ([defaults stringForKey:@"AllBookmarkSplitPotision"]) {
		[self setSplitViewPosition:allBookmarkSplitView position:[defaults stringForKey:@"AllBookmarkSplitPotision"]];
	}
}

-(void)setPathDic:(NSDictionary*)dic
{
	directoryPath = [dic objectForKey:@"dirPath"];
}

- (NSString *)splitViewPosition:(NSSplitView *)splitView
{
    NSArray *subViews = [splitView subviews];
    int     lenFirst, lenSecond;
	
    lenFirst = [[subViews objectAtIndex: 0] frame].size.width;
    lenSecond = [[subViews objectAtIndex: 1] frame].size.width;
	
	return [NSString stringWithFormat: @"%i %i", lenFirst, lenSecond];
}

- (void)setSplitViewPosition:(NSSplitView *)splitView position:(NSString *)s
{
    NSArray *subViews = [splitView subviews];
    NSRect  newBounds;
    float   dividerWidth = [splitView dividerThickness];
    NSView  *viewZero = [subViews objectAtIndex: 0];
    NSView  *viewOne = [subViews objectAtIndex: 1];
    NSArray *stringComponents = [s componentsSeparatedByString: @" "];
    int     valueZero, valueOne;
	
    valueZero = [[stringComponents objectAtIndex: 0] intValue];
    valueOne = [[stringComponents objectAtIndex: 1] intValue];
	
    int left = valueZero;
    int right = valueOne;
	
    if ((left + right + dividerWidth) != [splitView frame].size.width)
        left = [splitView frame].size.width - dividerWidth - right;
	
    newBounds = [viewZero frame]; 
    newBounds.size.width = left;
    newBounds.origin.x = 0;
    [viewZero setFrame: newBounds];
	
    newBounds = [viewOne frame];
    newBounds.size.width = right;
    newBounds.origin.x = left + dividerWidth;
    [viewOne setFrame: newBounds];
}


#pragma mark editBookmark
-(void)editBookmark:(NSArray*)array
{
	[bookmarkPanel setTarget:self];
    [bookmarkPanel setAction:@selector(keyDown:)];
	bookName = [[directoryPath lastPathComponent] retain];
	//	bookmarkArray = [[defaults objectForKey:bookName] retain];
	bookmarkArray = [array retain];
	
    [bookmarkTableView setDataSource:self];
    [bookmarkTableView setDelegate:self];
	[bookmarkTableView reloadData];
	
	
	window = [NSApp keyWindow];
    [[NSApplication sharedApplication] beginSheet:bookmarkPanel 
								   modalForWindow:window 
									modalDelegate:self 
								   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
									  contextInfo:nil];	
}


- (void)sheetDidEnd:(NSWindow*)sheet 
		 returnCode:(int)returnCode 
		contextInfo:(void*)contextInfo
{
    [bookmarkPanel orderOut:self];
	[window makeKeyWindow];
    
    if(returnCode == DIALOG_CANCEL) {
		[bookName release];
		[bookmarkArray release];
		bookmarkArray = nil;
    } else if(returnCode == DIALOG_OK) {
		[bookName release];
		[bookmarkArray release];
		bookmarkArray = nil;
		[controller setBookmarkMenu];
    }
}




- (IBAction)ok:(id)sender;
{
	if ([bookmarkPanel isVisible]) {
		[[NSApplication sharedApplication] endSheet:bookmarkPanel returnCode:DIALOG_OK];
	} else {
		[[NSApplication sharedApplication] stopModalWithCode:DIALOG_OK];
	}
}


- (IBAction)cancel:(id)sender;
{
	if ([bookmarkPanel isVisible]) {
		[[NSApplication sharedApplication] endSheet:bookmarkPanel returnCode:DIALOG_CANCEL];
	} else {
		[[NSApplication sharedApplication] stopModalWithCode:DIALOG_CANCEL];
	}
}


- (void)keyDown:(NSEvent *)theEvent
{
	int selectedRow;
	selectedRow = [bookmarkTableView selectedRow];
	if (0 <= selectedRow) {
		[bookmarkArray removeObjectAtIndex:selectedRow];
		[bookmarkTableView reloadData];
		
	} else {
		NSBeep();
	}
}

#pragma mark editAllBookmark
-(void)editAllBookmark:(NSArray*)array
{
	[allBookmarkPanel setTarget:self];
    [allBookmarkPanel setAction:@selector(keyDownAll:)];
	
    [allBookmarkTableView setDataSource:self];
    [allBookmarkTableView setDelegate:self];

    [allBookNameTableView setDataSource:self];
    [allBookNameTableView setDelegate:self];
	
	if (![defaults dictionaryForKey:@"BookSettings"]) {
		allBookmark = [[NSMutableDictionary dictionary] retain];
	} else {
		allBookmark = [[NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"BookSettings"]] retain];
	}
	
	bookNameArray = [[NSMutableArray array] retain];
	NSEnumerator *enu = [allBookmark keyEnumerator];
	id object;
	while (object = [enu nextObject]) {
		if ([[[allBookmark objectForKey:object] allKeys] containsObject:@"bookmarks"]) {
			[bookNameArray addObject:object];
		}
	}
	[bookNameArray sortUsingSelector:@selector(finderCompareS:)];
	
	[allBookmarkTableView reloadData];
	[allBookNameTableView reloadData];
	int result;
	result = [[NSApplication sharedApplication] runModalForWindow:allBookmarkPanel];
	[allBookmarkPanel orderOut:self];
	
	
	[defaults setObject:[self splitViewPosition:allBookmarkSplitView] forKey:@"AllBookmarkSplitPotision"];
	if(result == DIALOG_OK) {
		[defaults setObject:allBookmark forKey:@"BookSettings"];
		[defaults synchronize];
		[allBookmark release];
		allBookmark = nil;
		[bookNameArray release];
		bookNameArray = nil;
		[controller strongSetBookmark];
		return;
	} else if(result == DIALOG_CANCEL) {
		[allBookmark release];
		allBookmark = nil;
		[bookNameArray release];
		bookNameArray = nil;
        return;
    } else {
		return;
	}
}

- (void)keyDownAll:(NSEvent *)theEvent
{
	int selectedRow;
	if (selectedView == allBookNameTableView) {
		selectedRow = [allBookNameTableView selectedRow];
		if (selectedRow > -1) {
			NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[allBookmark objectForKey:[bookNameArray objectAtIndex:selectedRow]]];
			[dic removeObjectForKey:@"bookmarks"];
			
			if ([dic count] == 1 && [dic objectForKey:@"alias"]) {
				[allBookmark removeObjectForKey:[bookNameArray objectAtIndex:selectedRow]];
			} else {
				[allBookmark setObject:dic forKey:[bookNameArray objectAtIndex:selectedRow]];
			}
			[bookNameArray removeObjectAtIndex:selectedRow];
			
			[allBookNameTableView reloadData];
			[allBookmarkTableView reloadData];
		} else {
			NSBeep();
		}
		
	} else {
		selectedRow = [allBookmarkTableView selectedRow];
		if (selectedRow > -1) {
			
			id dic = [allBookmark objectForKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
			NSMutableDictionary *cDic = [NSMutableDictionary dictionaryWithDictionary:dic];
			id array = [cDic objectForKey:@"bookmarks"];
			NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
			
			[newArray removeObjectAtIndex:selectedRow];
			
			[cDic setObject:newArray forKey:@"bookmarks"];
			[allBookmark setObject:cDic forKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
			

			
			[allBookmarkTableView reloadData];
		} else {
			NSBeep();
		}
	}
}

#pragma mark -
- (IBAction)deleteRow:(id)sender;
{
	int selectedRow;
	selectedRow = [bookmarkTableView selectedRow];
	if (0 <= selectedRow) {
		[bookmarkArray removeObjectAtIndex:selectedRow];
		[bookmarkTableView reloadData];
		
	}
}

-(IBAction)addNewBookmark:(id)sender
{
	if ([bookmarkPanel isVisible]) {
		int count = [bookmarkArray count];
		
		NSString *bookmarkCountName = [NSString stringWithFormat:@"bookmark%i",count + 1];
		
		int bookmarkPage;
		bookmarkPage = [newBookmarkTextField intValue];
		if (bookmarkPage < 1) {
			NSBeep();
			return;
		}
		NSString *bookmarkNowPageString = [NSString stringWithFormat:@"%i",bookmarkPage];
		
		NSDictionary *bookmarkDic = [NSDictionary dictionaryWithObjectsAndKeys:
			bookmarkCountName, @"name", 
			bookmarkNowPageString, @"page",
			nil];
		
		[bookmarkArray insertObject:bookmarkDic atIndex:count];
		[bookmarkTableView reloadData];
	} else {
		if (allBookmark && [allBookNameTableView selectedRow] > -1) {
			id dic = [allBookmark objectForKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
			NSMutableDictionary *cDic = [NSMutableDictionary dictionaryWithDictionary:dic];
			id array = [cDic objectForKey:@"bookmarks"];
			NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
			
			
			int count = [newArray count];
			NSString *bookmarkCountName = [NSString stringWithFormat:@"bookmark%i",count + 1];
			int bookmarkPage;
			bookmarkPage = [newBookmarkTextField intValue];
			if (bookmarkPage < 1) {
				NSBeep();
				return;
			}
			NSString *bookmarkNowPageString = [NSString stringWithFormat:@"%i",bookmarkPage];
			
			NSDictionary *bookmarkDic = [NSDictionary dictionaryWithObjectsAndKeys:
				bookmarkCountName, @"name", 
				bookmarkNowPageString, @"page",
				nil];
			
			[newArray insertObject:bookmarkDic atIndex:count];
			[cDic setObject:newArray forKey:@"bookmarks"];
			[allBookmark setObject:cDic forKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
			
			[allBookmarkTableView reloadData];
		} else {
			NSBeep();
		}
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
    int selectedRow;
    selectedRow = [bookmarkTableView selectedRow];
	
    if( [[anItem title] isEqualToString:NSLocalizedString(@"Delete this Bookmark", @"")] == YES){
		if (selectedRow > -1) {
			return YES;
		} else {
			return NO;
		}
    }
	return NO;

}


- (IBAction)openInFinder:(id)sender
{
	if ([allBookNameTableView selectedRow] > -1) {
		NSData *alias = [[allBookmark objectForKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]] objectForKey:@"alias"];
		[[NSWorkspace sharedWorkspace] selectFile:[controller pathFromAliasData:alias]
						 inFileViewerRootedAtPath:@""];
	} else {
		NSBeep();
	}

}

- (IBAction)openInSelf:(id)sender
{
	if ([allBookNameTableView selectedRow] > -1) {
		NSData *alias = [[allBookmark objectForKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]] objectForKey:@"alias"];
		[controller application:nil openFile:[controller pathFromAliasData:alias]];
		[allBookmarkPanel makeKeyAndOrderFront:self];
	} else {
		NSBeep();
	}
	
}

#pragma mark -
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ([aNotification object] == allBookNameTableView) {
		[allBookmarkTableView reloadData];
	}
	selectedView = [aNotification object];
}

#pragma mark Table Delegate

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if (aTableView == allBookNameTableView) {
		//[self openInSelf:self];
		return YES;
	}
    return YES;
}


- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
	return YES;
}

#pragma mark tableDataSource

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if (aTableView == bookmarkTableView) {
		return [bookmarkArray count];
	} else if (aTableView == allBookmarkTableView) {
		if (allBookmark && [allBookNameTableView selectedRow] > -1) {
			id dic = [allBookmark objectForKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
			
			//NSLog(@"%i,%i",[allBookNameTableView selectedRow],[[dic objectForKey:@"bookmarks"] count]);
			return [[dic objectForKey:@"bookmarks"] count];
		} else {
			return 0;
		}
	} else if (aTableView == allBookNameTableView) {
		return [bookNameArray count];
	}
	return 0;
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(int)rowIndex
{
	[[aTableColumn dataCell] setWraps:YES];
	static NSDictionary *info = nil;
	static NSDictionary *pageInfo = nil;
    if (nil == info) {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingMiddle];
        info = [[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, nil];
        [style release];
    }
    if (nil == pageInfo) {
        NSMutableParagraphStyle *pageStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [pageStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [pageStyle setAlignment:NSRightTextAlignment];
        pageInfo = [[NSDictionary alloc] initWithObjectsAndKeys:pageStyle, NSParagraphStyleAttributeName, nil];
        [pageStyle release];
    }
	
	if (aTableView == bookmarkTableView) {
		if([[aTableColumn identifier] isEqualToString:@"name"]) {
			if (bookmarkArray) {
				//return [[bookmarkArray objectAtIndex:rowIndex] objectForKey:@"name"];
				return [[[NSAttributedString alloc] initWithString:[[bookmarkArray objectAtIndex:rowIndex] objectForKey:@"name"]
														attributes:info] autorelease];
			} else {
				return nil;
			}
		} else if([[aTableColumn identifier] isEqualToString:@"page"]) {
			
			if (bookmarkArray) {
				//return [[bookmarkArray objectAtIndex:rowIndex] objectForKey:@"page"];
				return [[[NSAttributedString alloc] initWithString:[[bookmarkArray objectAtIndex:rowIndex] objectForKey:@"page"]
														attributes:pageInfo] autorelease];
			} else {
				return nil;
			}
		}
	} else if (aTableView == allBookmarkTableView) {
		if([[aTableColumn identifier] isEqualToString:@"name"]) {
			if (allBookmark && rowIndex > -1 && [allBookNameTableView selectedRow] > -1) {
				id dic = [allBookmark objectForKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
				//return [[[dic objectForKey:@"bookmarks"] objectAtIndex:rowIndex] objectForKey:@"name"];
				
				
				//NSLog(@"%i",rowIndex);
				//NSLog(@"%@",dic);
				if (rowIndex >= [[dic objectForKey:@"bookmarks"] count]) {
					return nil;
				}
				return [[[NSAttributedString alloc] initWithString:[[[dic objectForKey:@"bookmarks"] objectAtIndex:rowIndex] objectForKey:@"name"]
														attributes:info] autorelease];
			} else {
				return nil;
			}
		} else if([[aTableColumn identifier] isEqualToString:@"page"]) {
			
			if (allBookmark && rowIndex > -1 && [allBookNameTableView selectedRow] > -1) {
				id dic = [allBookmark objectForKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
				//return [[[dic objectForKey:@"bookmarks"] objectAtIndex:rowIndex] objectForKey:@"page"];
				
				if (rowIndex >= [[dic objectForKey:@"bookmarks"] count]) {
					return nil;
				}
				return [[[NSAttributedString alloc] initWithString:[[[dic objectForKey:@"bookmarks"] objectAtIndex:rowIndex] objectForKey:@"page"]
														attributes:pageInfo] autorelease];
			} else {
				return nil;
			}
		}		
	} else if (aTableView == allBookNameTableView) {
		if([[aTableColumn identifier] isEqualToString:@"folder"]) {
			if (bookNameArray) {
				//return [bookNameArray objectAtIndex:rowIndex];
				return [[[NSAttributedString alloc] initWithString:[bookNameArray objectAtIndex:rowIndex]
														attributes:info] autorelease];
			} else {
				return nil;
			}
		}	
//		return [booknameArray objectAtIndex:rowIndex];
	}
	return nil;
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex
{
	if (!anObject) {
		return;
	}
	if (aTableView == bookmarkTableView) {
		if([[aTableColumn identifier] isEqualToString:@"name"]) {
			if (bookmarkArray) {
				NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
					anObject,@"name",
					[[bookmarkArray objectAtIndex:rowIndex] objectForKey:@"page"],@"page",
					nil];
				[bookmarkArray insertObject:dic atIndex:rowIndex+1];
				[bookmarkArray removeObjectAtIndex:rowIndex];
			}
		} else if([[aTableColumn identifier] isEqualToString:@"page"]) {
			if (bookmarkArray) {
				NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
					[[bookmarkArray objectAtIndex:rowIndex] objectForKey:@"name"],@"name",
					[NSString stringWithFormat:@"%@",anObject],@"page",
					nil];
				[bookmarkArray insertObject:dic atIndex:rowIndex+1];
				[bookmarkArray removeObjectAtIndex:rowIndex];
			}
		}
	} else if (aTableView == allBookmarkTableView) {
		if([[aTableColumn identifier] isEqualToString:@"name"]) {
			id dic = [allBookmark objectForKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
			NSMutableDictionary *cDic = [NSMutableDictionary dictionaryWithDictionary:dic];
			id array = [cDic objectForKey:@"bookmarks"];
			NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
			
			
			NSDictionary *bookmarkDic = [NSDictionary dictionaryWithObjectsAndKeys:
				anObject,@"name",
				[[newArray objectAtIndex:rowIndex] objectForKey:@"page"],@"page",
				nil];
			[newArray insertObject:bookmarkDic atIndex:rowIndex+1];
			[newArray removeObjectAtIndex:rowIndex];
			
			[cDic setObject:newArray forKey:@"bookmarks"];
			[allBookmark setObject:cDic forKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
		} else if([[aTableColumn identifier] isEqualToString:@"page"]) {
			id dic = [allBookmark objectForKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
			NSMutableDictionary *cDic = [NSMutableDictionary dictionaryWithDictionary:dic];
			id array = [cDic objectForKey:@"bookmarks"];
			NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
			
			
			NSDictionary *bookmarkDic = [NSDictionary dictionaryWithObjectsAndKeys:
				[[newArray objectAtIndex:rowIndex] objectForKey:@"name"],@"name",
				[NSString stringWithFormat:@"%@",anObject],@"page",
				nil];
			[newArray insertObject:bookmarkDic atIndex:rowIndex+1];
			[newArray removeObjectAtIndex:rowIndex];
			
			[cDic setObject:newArray forKey:@"bookmarks"];
			[allBookmark setObject:cDic forKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
		}
	} else if (aTableView == allBookNameTableView) {
		if([[aTableColumn identifier] isEqualToString:@"folder"]) {
			NSString *string = [bookNameArray objectAtIndex:rowIndex];
			
			if ([string isEqualToString:anObject]) {
				return;
			}
			
			if ([allBookmark objectForKey:anObject]) {
				NSBeep();
				return;
			}
			
			
			id dic = [allBookmark objectForKey:string];
			[bookNameArray insertObject:anObject atIndex:rowIndex+1];
			[bookNameArray removeObjectAtIndex:rowIndex];
			
			[allBookmark removeObjectForKey:string];
			[allBookmark setObject:dic forKey:[bookNameArray objectAtIndex:rowIndex]];
		}
	}
}


#pragma mark tableDataSource_drag&drop

-(BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
	if (tv == allBookmarkTableView || tv == bookmarkTableView) {
		[pboard declareTypes:[NSArray arrayWithObject:@"row"] owner:self];
		[pboard setPropertyList:rows forType:@"row"];
		return YES;
	}
	return NO;
}
-(NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
	NSPasteboard *pboard=[info draggingPasteboard];
	
	if (op == NSTableViewDropAbove && [pboard availableTypeFromArray:[NSArray arrayWithObject:@"row"]] != nil) {
		return NSDragOperationGeneric;
	} else {
		return NSDragOperationNone;
	}
}
-(BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op
{
	NSPasteboard *pboard=[info draggingPasteboard];
	NSEnumerator *e=[[pboard propertyListForType:@"row"] objectEnumerator];
	NSNumber *number;
	
	if (tv == bookmarkTableView) {
		if (bookmarkArray) {			
			NSMutableArray *upperArray=[NSMutableArray arrayWithArray:[bookmarkArray subarrayWithRange:NSMakeRange(0,row)]];
			NSMutableArray *lowerArray=[NSMutableArray arrayWithArray:[bookmarkArray subarrayWithRange:NSMakeRange(row,([bookmarkArray count] - row))]];
			NSMutableArray *middleArray=[NSMutableArray arrayWithCapacity:0];
			id object;
			int i;
			
			if (op == NSTableViewDropAbove && [pboard availableTypeFromArray:[NSArray arrayWithObject:@"row"]] != nil) {
				while ((number=[e nextObject]) != nil) {
					object=[bookmarkArray objectAtIndex:[number intValue]];
					[middleArray addObject:object];
					[upperArray removeObject:object];
					[lowerArray removeObject:object];
				}
				
				[bookmarkArray removeAllObjects];
				
				[bookmarkArray addObjectsFromArray:upperArray];
				[bookmarkArray addObjectsFromArray:middleArray];
				[bookmarkArray addObjectsFromArray:lowerArray];
				
				[tv reloadData];
				[tv deselectAll:nil];
				
				for (i=[upperArray count];i<([upperArray count] + [middleArray count]);i++) {
					[tv selectRow:i byExtendingSelection:[tv allowsMultipleSelection]];
				}
				
				return YES;
			} else {
				return NO;
			}
		}
	} else if (tv == allBookmarkTableView) {
		id dic = [allBookmark objectForKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
		NSMutableDictionary *cDic = [NSMutableDictionary dictionaryWithDictionary:dic];
		id array = [cDic objectForKey:@"bookmarks"];
		NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
		
		
		NSMutableArray *upperArray=[NSMutableArray arrayWithArray:[newArray subarrayWithRange:NSMakeRange(0,row)]];
		NSMutableArray *lowerArray=[NSMutableArray arrayWithArray:[newArray subarrayWithRange:NSMakeRange(row,([newArray count] - row))]];
		NSMutableArray *middleArray=[NSMutableArray arrayWithCapacity:0];
		id object;
		int i;	
		if (op == NSTableViewDropAbove && [pboard availableTypeFromArray:[NSArray arrayWithObject:@"row"]] != nil) {
			while ((number=[e nextObject]) != nil) {
				object=[newArray objectAtIndex:[number intValue]];
				[middleArray addObject:object];
				[upperArray removeObject:object];
				[lowerArray removeObject:object];
			}
			
			[newArray removeAllObjects];
			
			[newArray addObjectsFromArray:upperArray];
			[newArray addObjectsFromArray:middleArray];
			[newArray addObjectsFromArray:lowerArray];
			[cDic setObject:newArray forKey:@"bookmarks"];
			[allBookmark setObject:cDic forKey:[bookNameArray objectAtIndex:[allBookNameTableView selectedRow]]];
			
			[tv reloadData];
			[tv deselectAll:nil];
			
			for (i=[upperArray count];i<([upperArray count] + [middleArray count]);i++) {
				[tv selectRow:i byExtendingSelection:[tv allowsMultipleSelection]];
			}
			
			return YES;
		} else {
			return NO;
		}
		
		
	}
	return NO;
}
@end
