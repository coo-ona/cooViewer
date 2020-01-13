#import "Controller.h"
#import "CustomWindow.h"
#import "BookmarkController.h"
#import "CustomImageView.h"
#import "FullImagePanel.h"
@implementation Controller (Input)

static BOOL appleRemoteHoldDown = NO;

#pragma mark action
- (void)remoteButton:(RemoteControlEventIdentifier)buttonIdentifier pressedDown: (BOOL) pressedDown clickCount: (unsigned int)clickCount
{
	appleRemoteHoldDown = NO;
	if (!pressedDown) {
		return;
	}
	UpdateSystemActivity( OverallAct );
	//UpdateSystemActivity(UsrActivity);
	
    unichar character = buttonIdentifier;
	switch(buttonIdentifier) {
		case kRemoteButtonRight_Hold:
			appleRemoteHoldDown = YES;
			character = kRemoteButtonRight;
			break;	
		case kRemoteButtonLeft_Hold:
			appleRemoteHoldDown = YES;
			character = kRemoteButtonLeft;
			break;			
		case kRemoteButtonPlus_Hold:
			appleRemoteHoldDown = YES;
			character = kRemoteButtonPlus;
			break;				
		case kRemoteButtonMinus_Hold:
			appleRemoteHoldDown = YES;
			character = kRemoteButtonMinus;
			break;				
		case kRemoteButtonPlay_Hold:
			appleRemoteHoldDown = YES;
			character = kRemoteButtonPlay;
			break;			
		case kRemoteButtonMenu_Hold:
			appleRemoteHoldDown = YES;
			character = kRemoteButtonMenu;
			break;
		default:
			break;
	}
	NSString *characters = [NSString stringWithCharacters:&character length:1];
	
	if (![window isVisible] || ![window isKeyWindow]) {
		if ([prefController inKeyEdit]) {
			[prefController setKeyCharacters:characters];
			appleRemoteHoldDown = NO;
			return;
		}
		if (![thumController isVisible]) {
			appleRemoteHoldDown = NO;
			return;
		}
	}
	[self timeredRemoteButtonEvent:characters];
}
- (void)timeredRemoteButtonEvent:(NSString*)characters;
{	
	if ([thumController isVisible]) {
		[thumController appleRemoteAction:characters];
	} else {
		BOOL slideshow = NO;
		if (timerSwitch) {
			[timer invalidate];
			timerSwitch = NO;
			slideshow = YES;
			[imageView setSlideshow:NO];
		}
		useComposedImage = NO;
		threadStop = NO;
		unichar character = [characters characterAtIndex:0];
		unsigned int cMod = 100;
		if (fitScreenMode == 0) {
			[self getKeyAction:character mod:cMod mode:0 slideshow:slideshow];
		} else if (fitScreenMode == 1) {
			if (![self getKeyAction:character mod:cMod mode:1 slideshow:slideshow]) {
				[self getKeyAction:character mod:cMod mode:0 slideshow:slideshow];
			}
		} else if (fitScreenMode == 2 || fitScreenMode == 3) {
			if (![self getKeyAction:character mod:cMod mode:2 slideshow:slideshow]) {
				[self getKeyAction:character mod:cMod mode:0 slideshow:slideshow];
			}
		}
	}
	if (!appleRemoteHoldDown) return;
	[self performSelector:@selector(timeredRemoteButtonEvent:) withObject:characters afterDelay:0.1];
}

- (void)keyAction:(NSEvent*)sender
{	
	BOOL slideshow = NO;
	if (timerSwitch) {
		[timer invalidate];
		timerSwitch = NO;
		slideshow = YES;
		[imageView setSlideshow:NO];
		//return;
	}
	useComposedImage = NO;
	threadStop = NO;
	NSString *characters = [sender charactersIgnoringModifiers];
    unichar character = [characters characterAtIndex: 0];
	
	if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:character]){
		if ([imageView pageMover]) {
			if ([imageView tempPageNum] > 99999) {
				return;
			}
			[imageView drawPageMover:[characters intValue]];
			return;
		}
	} else if (character == 0x1B) {
		//esc
		if ([imageView pageMover]) {
			[imageView drawPageMover:-1];
			return;
		} else {
			threadStop = YES;
			[lock lock];
			[lock unlock];
			threadStop = NO;
			[window performClose:self];
			return;
		}
	} else if (character == NSDeleteCharacter) {
		if ([imageView pageMover]) {
			if ([imageView tempPageNum]<=0) {
				return;
			} else {
				[imageView drawPageMover:-2];
				return;
			}
		}
	} 
	
	unsigned int cMod = 0;
	BOOL shift = ([sender modifierFlags] & NSShiftKeyMask) ? YES : NO;
	BOOL option = ([sender modifierFlags] & NSAlternateKeyMask) ? YES : NO;
	BOOL control = ([sender modifierFlags] & NSControlKeyMask) ? YES : NO;
	BOOL numeric = ([sender modifierFlags] & NSNumericPadKeyMask) ? YES : NO;
	
	if (shift) cMod += 1;
	if (option) cMod += 2;
	if (control) cMod += 4;
	if (numeric) {
		if (character == NSLeftArrowFunctionKey||character == NSRightArrowFunctionKey||character == NSUpArrowFunctionKey||character == NSDownArrowFunctionKey) {
		} else {
			cMod += 8;
		}
	}
	
	if (fitScreenMode == 0) {
		[self getKeyAction:character mod:cMod mode:0 slideshow:slideshow];
	} else if (fitScreenMode == 1) {
		if (![self getKeyAction:character mod:cMod mode:1 slideshow:slideshow]) {
			[self getKeyAction:character mod:cMod mode:0 slideshow:slideshow];
		}
	} else if (fitScreenMode == 2 || fitScreenMode == 3) {
		if (![self getKeyAction:character mod:cMod mode:2 slideshow:slideshow]) {
			[self getKeyAction:character mod:cMod mode:0 slideshow:slideshow];
		}
	}
}

- (BOOL)getKeyAction:(unichar)character mod:(int)cMod mode:(int)mode slideshow:(BOOL)slideshow
{
	
	NSEnumerator *enu;
	switch (mode) {
		case 0:
			enu = [keyArray objectEnumerator];
			break;
		case 1:
			enu = [keyArrayMode2 objectEnumerator];
			break;
		case 2:
			enu = [keyArrayMode3 objectEnumerator];
			break;
		default:break;
	}
	id dic;
	while (dic = [enu nextObject]) {
		if (character == [[dic objectForKey:@"key"] characterAtIndex:0] && cMod == [[dic objectForKey:@"modifier"] intValue]){
			int action = [[dic objectForKey:@"action"] intValue];
			if ([[dic objectForKey:@"switchAction"] boolValue] == YES && [self readFromLeft]) {
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
					//nextpage
					[lock lock];
					[lock unlock];
					useComposedImage = YES;
					[self imageDisplay];
					break;
					
					
				case 1:
					//prevpage
					//[lock lock];
					//[lock unlock];
					[self prevPage];
					break;
					
					
					
				case 2:
					//halfnext
					[lock lock];
					[lock unlock];
					if (nowPage < [completeMutableArray count]) {
						if (secondImage){
							nowPage--;
							[lock lock];
							[lock unlock];
							[imageMutableArray insertObject:[self loadImage:nowPage] atIndex:0];
							//[imageMutableArray insertObject:secondImage atIndex:0];
						}
					}
						[self imageDisplay];
					break;
					
					
					
				case 3:
					//halfprev
					[lock lock];
					[lock unlock];
					[self halfprevPage];
					break;
					
					
					
				case 4:
					//lastpage
					[self goToLast];
					break;
					
					
					
				case 5:
					//toppage
					if (secondImage) {
						if (nowPage > 2) {
							threadStop = YES;
							[lock lock];
							[lock unlock];
							threadStop = NO;
							[imageMutableArray removeAllObjects];
							nowPage = 0;
							[self lookahead];
							[self imageDisplay];
						}
					} else {
						if (nowPage > 1) {
							threadStop = YES;
							[lock lock];
							[lock unlock];
							threadStop = NO;
							[imageMutableArray removeAllObjects];
							nowPage = 0;
							[self lookahead];
							[self imageDisplay];
						}
					}		
					break;
					
					
					
				case 6:
					//nextbookmark
					[lock lock];
					[lock unlock];
					[self nextBookmark];
					break;
					
					
				case 7:
					//prevbookmark
					[lock lock];
					[lock unlock];
					[self backBookmark];	
					break;
					
					
					
				case 8:
					//nextfolder
					[lock lock];
					[lock unlock];
					[self nextFolder];
					break;
					
					
					
				case 9:
					//prevfolder
					[lock lock];
					[lock unlock];
					[self backFolder];
					break;
					
					
				case 10:
					//add/removebookmark
					if ([self removeBookmark]) {
					} else {
						[self addBookmark];
					}
					break;
					
					
				case 11:
					//switchSingle
					[lock lock];
					[lock unlock];
					[self switchSingle:nil];
					break;
					
					
					
				case 12:
					//shownumber
					if (numberSwitch) {
						[imageView setPageString:nil];
						numberSwitch = NO;
						[defaults setBool:numberSwitch forKey:@"ShowNumber"];
					} else {
						if (!secondImage) {
							int i = nowPage - 1;
							[imageView setPageString:[NSString stringWithFormat:@"#%d/%d (%@)",nowPage,[completeMutableArray count],[[completeMutableArray objectAtIndex:i] lastPathComponent]]];
							numberSwitch = YES;
						} else if (secondImage) {
							int i = nowPage - 1;
							int iS = i - 1;
							[imageView setPageString:[NSString stringWithFormat:@"#%d-%d/%d (%@ / %@)",i,nowPage,[completeMutableArray count],[[completeMutableArray objectAtIndex:iS] lastPathComponent],[[completeMutableArray objectAtIndex:i] lastPathComponent]]];
							numberSwitch = YES;
						}
						[defaults setBool:numberSwitch forKey:@"ShowNumber"];
					}
					//[imageView setNeedsDisplay];					
					break;
					
					
					
				case 13:
					//skip
					threadStop = YES;
					[lock lock];
					[lock unlock];
					threadStop = NO;
					[imageMutableArray removeAllObjects];
					int skipI = [[dic objectForKey:@"value"] intValue];
					skipI -= 2;
					if (!secondImage) {
						//skipI += 1;
					}
						nowPage += skipI;
					if (nowPage >= [completeMutableArray count]) {
						nowPage = [completeMutableArray count];
						nowPage -= 2;
					}
						[self lookahead];
					if ([imageMutableArray count] > 1) {
						if ([self isSmallImage:[imageMutableArray objectAtIndex:0] page:nowPage+1] == NO) {
							[imageMutableArray removeObjectAtIndex:0];
							nowPage++;
						} else if ([self isSmallImage:[imageMutableArray objectAtIndex:1] page:nowPage+2] == NO) {
							[imageMutableArray removeObjectAtIndex:0];
							nowPage++;
						}
					}
						
						[self imageDisplay];
					
					break;
					
					
					
				case 14:
					//backskip
					threadStop = YES;
					[lock lock];
					[lock unlock];
					threadStop = NO;
					[imageMutableArray removeAllObjects];
					int bskipI = [[dic objectForKey:@"value"] intValue];
					bskipI += 2;
					if (!secondImage) {
						//bskipI -= 1;
					}
						nowPage -= bskipI;
					if (nowPage < 0) {
						nowPage = 0;
					}
						[self lookahead];
					[self imageDisplay];
					
					break;
					
					
					
				case 15:
					//origRight
					switch (readMode) {
						case 0:
							[self viewAtOriginalSizeFirst:self];
							break;
						case 1:
							[self viewAtOriginalSizeSecond:self];
							break;
						case 2:
							[self viewAtOriginalSizeFirst:self];
							break;
						case 3:
							[self viewAtOriginalSizeSecond:self];
							break;
						default:
							break;
					}
					
					break;
					
					
					
				case 16:
					//origLeft
					switch (readMode) {
						case 0:
							[self viewAtOriginalSizeSecond:self];
							break;
						case 1:
							[self viewAtOriginalSizeFirst:self];
							break;
						case 2:
							[self viewAtOriginalSizeSecond:self];
							break;
						case 3:
							[self viewAtOriginalSizeFirst:self];
							break;
						default:
							break;
					}
					break;
					
					
					
				case 17:
					//slideshow
					if (!slideshow) {
						[self slideshow:nil];
					}
					[self setPageTextField];
					break;
					
					
					
				case 18:
					//showThumbnail
					if (secondImage) {
						int temp = nowPage;
						temp--;
						[thumController showThumbnail:temp];
					} else {
						[thumController showThumbnail:nowPage];
					}
					break;
					
					
					
				case 19:
					//changeReadMode 
					[lock lock];
					[lock unlock];
					if (readMode == 0) {
						[self changeReadMode:1];
					} else if (readMode == 1) {
						[self changeReadMode:2];
					} else if (readMode == 2) {
						[self changeReadMode:3];
					} else if (readMode == 3) {
						[self changeReadMode:0];
					}
					break;
					
				case 20:
					//showPageBar
					if (pageBar) {
						pageBar = NO;
					} else {
						pageBar = YES;
					}
					[defaults setBool:pageBar forKey:@"ShowPageBar"];
					[imageView drawPageBar];
					break;
				case 21:
					//showPageMover
					if (![imageView pageMover]) {
						[imageView drawPageMover:0];
					} else {
						if ([imageView tempPageNum]<=0) {
							[imageView drawPageMover:-1];
							break;
						} else {
							[lock lock];
							[lock unlock];
							int tempPageNum = [imageView tempPageNum];
							tempPageNum--;
							[self goTo:tempPageNum array:nil];
							[imageView drawPageMover:-1];
						}
					}
					break;
				case 22:
					//show in finder R
					switch (readMode) {
						case 0:
							[self showInFinderFirst:self];
							break;
						case 1:
							[self showInFinderSecond:self];
							break;
						case 2:
							[self showInFinderFirst:self];
							break;
						case 3:
							[self showInFinderSecond:self];
							break;
						default:
							break;
					}
					break;
				case 23:
					//showInFinderL
					switch (readMode) {
						case 0:
							[self showInFinderSecond:self];
							break;
						case 1:
							[self showInFinderFirst:self];
							break;
						case 2:
							[self showInFinderSecond:self];
							break;
						case 3:
							[self showInFinderFirst:self];
							break;
						default:
							break;
					}
					break;
				case 24:
					//PageUp
					[imageView scrollUp];
					break;
				case 25:
					//PageDown
					[imageView scrollDown];
					break;
				case 26:
					//PageUp + PrevPage
					if ([imageView prev] == YES) {
						//[lock lock];
						//[lock unlock];
						if (prevPageMode == 1) [imageView setStartFromEnd:YES];
						[self prevPage];
					}
					break;
				case 27:
					//PageDown + NextPage
					if ([imageView next] == YES) {
						[lock lock];
						[lock unlock];
						useComposedImage = YES;
						[self imageDisplay];
					}
					break;
				case 28:
					//ScrollToTop
					[imageView scrollToTop];
					break;
				case 29:
					//ScrollToEnd
					[imageView scrollToLast];
					break;
				case 30:
					//ScrollUp
					[imageView scrollTo:NSMakePoint(0,-1*([[dic objectForKey:@"value"] intValue]))];
					break;
				case 31:
					//ScrollDown
					[imageView scrollTo:NSMakePoint(0,[[dic objectForKey:@"value"] intValue])];
					break;
				case 32:
					//ScrollLeft
					[imageView scrollTo:NSMakePoint([[dic objectForKey:@"value"] intValue],0)];
					break;
				case 33:
					//ScrollRight
					[imageView scrollTo:NSMakePoint((-1*[[dic objectForKey:@"value"] intValue]),0)];
					break;
				case 34:
					//loupe
					[imageView setLoupe];
					break;
				case 35:
					//nextSubFolder
					[self nextSubFolder];
					break;
				case 36:
					//prevSubFolder
					[self prevSubFolder];
					break;
				case 37:
					//loupeRatePlus
					[defaults setFloat:[defaults floatForKey:@"LoupeRate"]+[[dic objectForKey:@"value"] floatValue] forKey:@"LoupeRate"];
					[imageView setLoupeRate];
					break;
				case 38:
					//loupeRateMinus
					if ([defaults floatForKey:@"LoupeRate"]-[[dic objectForKey:@"value"] floatValue]>1.0) {
						[defaults setFloat:[defaults floatForKey:@"LoupeRate"]-[[dic objectForKey:@"value"] floatValue] forKey:@"LoupeRate"];
					} else {
						[defaults setFloat:1.0 forKey:@"LoupeRate"];
					}
					[imageView setLoupeRate];
					break;
				case 39:
					//goto%
					[self goToPar:([[dic objectForKey:@"value"] floatValue]/100)];
					break;
				case 40:
					//rotateRight
					[self rotateRight:nil];
					break;
				case 41:
					//rotateLeft
					[self rotateLeft:nil];
					break;
				case 42:
					//changeViewMode
					[self setPageTextField];
					switch (fitScreenMode) {
						case 0:
							[self fitToScreenWidth:nil];
							break;
						case 1:
							[self fitToScreenWidthDivide:nil];
							break;
						case 2:
							[self fitToScreen:nil];
							break;
						case 3:
							[self noScale:nil];
							break;
						default:
							break;
					}
					break;
				case 51:
					//enlargeViewMode
					[self setPageTextField];
					switch (fitScreenMode) {
						case 0:
							[self fitToScreenWidth:nil];
							break;
						case 1:
							[self fitToScreenWidthDivide:nil];
							break;
						case 3:
							[self noScale:nil];
							break;
						default:
							break;
					}
					break;
				case 52:
					//reduceViewMode
					[self setPageTextField];
					switch (fitScreenMode) {
						case 1:
							[self fitToScreen:nil];
							break;
						case 2:
							[self fitToScreenWidthDivide:nil];
							break;
						case 3:
							[self fitToScreenWidth:nil];
							break;
						default:
							break;
					}
					break;
				case 43:
					//trashRight
					[self trashRight];
					break;
				case 44:
					//trashLeft
					[self trashLeft];
					break;
				case 45:
					//changeSortMode
					if ([imageLoader canSortByDate]) {
						switch (sortMode) {
							case 0:sortMode = 2;break;
							case 1:sortMode = 0;break;
							case 2:sortMode = 3;break;
							case 3:sortMode = 1;break;
							default:break;
						}
						[self setSortMode:sortMode page:0];
					} else {
						switch (sortMode) {
							case 0:sortMode = 1;break;
							case 1:sortMode = 0;break;
							case 2:sortMode = 0;break;
							case 3:sortMode = 0;break;
							default:break;
						}
						[self setSortMode:sortMode page:0];
					}	
					break;
				case 46:
					//close
					threadStop = YES;
					[lock lock];
					[lock unlock];
					threadStop = NO;
					[window performClose:self];
					break;
				case 47:
					//randam
					[self setSortMode:1 page:0];
					break;
				case 48:
					//openTheLastPage
					{
						NSMenu *menu = [[[NSApp mainMenu] itemWithTitle:NSLocalizedString(@"File", @"")] submenu];
						NSMenuItem *item = [menu itemWithTitle:NSLocalizedString(@"Open the last page", @"")];
						if ([item isEnabled]) {
							[menu performActionForItemAtIndex:[menu indexOfItem:item]];
						}
					}
					break;
				case 49:
					//switchFullScreen
					{
						NSMenu *menu = [[[NSApp mainMenu] itemWithTitle:NSLocalizedString(@"Window", @"")] submenu];
						NSMenuItem *item = [menu itemWithTitle:NSLocalizedString(@"Fullscreen", @"")];
						if ([item isEnabled]) {
							[menu performActionForItemAtIndex:[menu indexOfItem:item]];
						}
					}
					break;
				case 50:
					//minimizeWindow
					{
						NSMenu *menu = [[[NSApp mainMenu] itemWithTitle:NSLocalizedString(@"Window", @"")] submenu];
						NSMenuItem *item = [menu itemWithTitle:NSLocalizedString(@"Minimize", @"")];
						if ([item isEnabled]) {
							[menu performActionForItemAtIndex:[menu indexOfItem:item]];
						}
					}
					break;
				default:
					break;
			}
			return YES;
		}
	}
	return NO;
}


- (void)mouseAction:(NSEvent*)sender
{
	if (timerSwitch) {
		[timer invalidate];
		timerSwitch=NO;
		[imageView setSlideshow:NO];
	}
	
	int button = [sender buttonNumber];
	unsigned int cMod = 0;
	BOOL shift = ([sender modifierFlags] & NSShiftKeyMask) ? YES : NO;
	BOOL option = ([sender modifierFlags] & NSAlternateKeyMask) ? YES : NO;
	BOOL control = ([sender modifierFlags] & NSControlKeyMask) ? YES : NO;
	
	if (shift) {
		cMod += 1;
	}
	if (option) {
		cMod += 2;
	}
	if (control) {
		cMod += 4;
	}
	
	
	useComposedImage = NO;
	threadStop = NO;
	NSRect left,right;
	switch (readMode) {
		case 0:
			NSDivideRect ([[window contentView] frame], &left, &right, [[window contentView] frame].size.width/2, NSMinXEdge);
			break;
		case 1:
			NSDivideRect ([[window contentView] frame], &right, &left, [[window contentView] frame].size.width/2, NSMinXEdge);
			break;
		case 2:
			NSDivideRect ([[window contentView] frame], &left, &right, [[window contentView] frame].size.width/2, NSMinXEdge);
			break;
		case 3:
			NSDivideRect ([[window contentView] frame], &right, &left, [[window contentView] frame].size.width/2, NSMinXEdge);
			break;
		default:
			NSDivideRect ([[window contentView] frame], &left, &right, [[window contentView] frame].size.width/2, NSMinXEdge);
			break;
	}
	BOOL leftBool = NSPointInRect([sender locationInWindow], left);
	if (fitScreenMode == 0) {
		[self getMouseAction:button mod:cMod mode:0 left:leftBool];
	} else if (fitScreenMode == 1 || fitScreenMode == 3) {
		if (![self getMouseAction:button mod:cMod mode:1 left:leftBool]) {
			[self getMouseAction:button mod:cMod mode:0 left:leftBool];
		}
	} else if (fitScreenMode == 2) {
		if (![self getMouseAction:button mod:cMod mode:2 left:leftBool]) {
			[self getMouseAction:button mod:cMod mode:0 left:leftBool];
		}
	}
}

- (void)multiTouchAction:(NSEvent*)sender action:(int)action
{
	unsigned int cMod = 0;
	int button = 0;
	switch (action) {
		case 0:
			//swipe right
			button += 1000;
			break;
		case 1:
			//swipe left
			button += 2000;
			break;
		case 2:
			//swipe up
			button += 3000;
			break;
		case 3:
			//swipe down
			button += 4000;
			break;
		case 4:
			//pinch in
			button += 5000;
			break;
		case 5:
			//pinch out
			button += 6000;
			break;
		case 6:
			//rotate right
			button += 7000;
			break;
		case 7:
			//rotate left
			button += 8000;
			break;
		default:
			break;
	}
	BOOL shift = ([sender modifierFlags] & NSShiftKeyMask) ? YES : NO;
	BOOL option = ([sender modifierFlags] & NSAlternateKeyMask) ? YES : NO;
	BOOL control = ([sender modifierFlags] & NSControlKeyMask) ? YES : NO;
	
	if (shift) {
		cMod += 1;
	}
	if (option) {
		cMod += 2;
	}
	if (control) {
		cMod += 4;
	}
	
	
	useComposedImage = NO;
	threadStop = NO;
	NSRect left,right;
	switch (readMode) {
		case 0:
			NSDivideRect ([imageView frame], &left, &right, [imageView frame].size.width/2, NSMinXEdge);
			break;
		case 1:
			NSDivideRect ([imageView frame], &right, &left, [imageView frame].size.width/2, NSMinXEdge);
			break;
		case 2:
			NSDivideRect ([imageView frame], &left, &right, [imageView frame].size.width/2, NSMinXEdge);
			break;
		case 3:
			NSDivideRect ([imageView frame], &right, &left, [imageView frame].size.width/2, NSMinXEdge);
			break;
		default:
			NSDivideRect ([imageView frame], &left, &right, [imageView frame].size.width/2, NSMinXEdge);
			break;
	}
	BOOL leftBool = NSPointInRect([sender locationInWindow], left);
	if (fitScreenMode == 0) {
		[self getMouseAction:button mod:cMod mode:0 left:leftBool];
	} else if (fitScreenMode == 1) {
		if (![self getMouseAction:button mod:cMod mode:1 left:leftBool]) {
			[self getMouseAction:button mod:cMod mode:0 left:leftBool];
		}
	} else if (fitScreenMode == 2 || fitScreenMode == 3) {
		if (![self getMouseAction:button mod:cMod mode:2 left:leftBool]) {
			![self getMouseAction:button mod:cMod mode:0 left:leftBool];
		}
	}
}

- (void)gestureAction:(NSEvent*)sender moved:(int)moved
{
	int button = [sender buttonNumber];
	unsigned int cMod = 0;
	switch (moved) {
		case 0:
			//left
			cMod += 200;
			break;
		case 1:
			//right
			cMod += 300;
			break;
		case 2:
			//up
			cMod += 400;
			break;
		case 3:
			//down
			cMod += 500;
			break;
		default:
			break;
	}
	BOOL shift = ([sender modifierFlags] & NSShiftKeyMask) ? YES : NO;
	BOOL option = ([sender modifierFlags] & NSAlternateKeyMask) ? YES : NO;
	BOOL control = ([sender modifierFlags] & NSControlKeyMask) ? YES : NO;
	
	if (shift) {
		cMod += 1;
	}
	if (option) {
		cMod += 2;
	}
	if (control) {
		cMod += 4;
	}
	
	
	useComposedImage = NO;
	threadStop = NO;
	NSRect left,right;
	switch (readMode) {
		case 0:
			NSDivideRect ([imageView frame], &left, &right, [imageView frame].size.width/2, NSMinXEdge);
			break;
		case 1:
			NSDivideRect ([imageView frame], &right, &left, [imageView frame].size.width/2, NSMinXEdge);
			break;
		case 2:
			NSDivideRect ([imageView frame], &left, &right, [imageView frame].size.width/2, NSMinXEdge);
			break;
		case 3:
			NSDivideRect ([imageView frame], &right, &left, [imageView frame].size.width/2, NSMinXEdge);
			break;
		default:
			NSDivideRect ([imageView frame], &left, &right, [imageView frame].size.width/2, NSMinXEdge);
			break;
	}
	BOOL leftBool = NSPointInRect([sender locationInWindow], left);
	if (fitScreenMode == 0) {
		if (![self getMouseAction:button mod:cMod mode:0 left:leftBool]) {
			[self getMouseAction:button mod:100 mode:0 left:leftBool];
		}
	} else if (fitScreenMode == 1) {
		if (![self getMouseAction:button mod:cMod mode:1 left:leftBool]) {
			if (![self getMouseAction:button mod:cMod mode:0 left:leftBool]) {
				if (![self getMouseAction:button mod:100 mode:1 left:leftBool]) {
					[self getMouseAction:button mod:100 mode:0 left:leftBool];
				}
			}
		}
	} else if (fitScreenMode == 2 || fitScreenMode == 3) {
		if (![self getMouseAction:button mod:cMod mode:2 left:leftBool]) {
			if (![self getMouseAction:button mod:cMod mode:0 left:leftBool]) {
				if (![self getMouseAction:button mod:100 mode:2 left:leftBool]) {
					[self getMouseAction:button mod:100 mode:0 left:leftBool];
				}
			}
		}
	}
}

//- (void)getMouseAction:(int)button mod:(int)cMod left:(BOOL)left

- (BOOL)getMouseAction:(int)button mod:(int)cMod mode:(int)mode left:(BOOL)left
{
	NSEnumerator *enu;
	switch (mode) {
		case 0:
			enu = [mouseArray objectEnumerator];
			break;
		case 1:
			enu = [mouseArrayMode2 objectEnumerator];
			break;
		case 2:
			enu = [mouseArrayMode3 objectEnumerator];
			break;
		default:break;
	}
	id dic;	
	while (dic = [enu nextObject]) {
		if (button == [[dic objectForKey:@"button"] intValue] && cMod == [[dic objectForKey:@"modifier"] intValue]){
			int action = [[dic objectForKey:@"action"] intValue];
			if ([[dic objectForKey:@"switchAction"] boolValue] == YES && [self readFromLeft]) {
				switch (action) {
					case 6: action=7; break;
					case 7: action=6; break;
					case 8: action=9; break;
					case 9: action=8; break;
					case 10: action=11; break;
					case 11: action=10; break;
					case 12: action=13; break;
					case 13: action=12; break;
					case 14: action=15; break;
					case 15: action=14; break;
					case 19: action=20; break;
					case 20: action=19; break;
					case 33: action=34; break;
					case 34: action=33; break;
					case 44: action=45; break;
					case 45: action=44; break;
					default:
						break;
				}
			}
			switch (action) {
				case 0:
					//next/prevpage
					if (left) {
						[lock lock];
						[lock unlock];
						useComposedImage = YES;
						[self imageDisplay];
					} else {
						//[lock lock];
						//[lock unlock];
						[self prevPage];
					}
						break;
				case 1:
					//halfnext/prevpage
					[lock lock];
					[lock unlock];
					if (left) {
						if (nowPage < [completeMutableArray count]) {
							if (secondImage){
								nowPage--;
								[imageMutableArray insertObject:[self loadImage:nowPage] atIndex:0];
								//[imageMutableArray insertObject:secondImage atIndex:0];
							}
						}
						[self imageDisplay];
					} else {
						[self halfprevPage];
					}
						break;
				case 2:
					//lastpage/toppage
					if (left) {
						if (nowPage < [completeMutableArray count]) {
							threadStop = YES;
							[lock lock];
							[lock unlock];
							threadStop = NO;
							[imageMutableArray removeAllObjects];
							nowPage = [completeMutableArray count];
							if (readMode > 1) {
								nowPage--;
								[self lookahead];
							} else {
								nowPage -= 2;
								[self lookahead];
								if ([self isSmallImage:[imageMutableArray objectAtIndex:0] page:nowPage+1] == NO) {
									[imageMutableArray removeObjectAtIndex:0];
									nowPage++;
								} else if ([self isSmallImage:[imageMutableArray objectAtIndex:1] page:nowPage+2] == NO) {
									[imageMutableArray removeObjectAtIndex:0];
									nowPage++;
								}
							}
							[self imageDisplay];
						}
					} else {
						if (secondImage) {
							if (nowPage > 2) {
								threadStop = YES;
								[lock lock];
								[lock unlock];
								threadStop = NO;
								[imageMutableArray removeAllObjects];
								nowPage = 0;
								[self lookahead];
								[self imageDisplay];
							}
						} else {
							if (nowPage > 1) {
								threadStop = YES;
								[lock lock];
								[lock unlock];
								threadStop = NO;
								[imageMutableArray removeAllObjects];
								nowPage = 0;
								[self lookahead];
								[self imageDisplay];
							}
						}	
					}
					break;
				case 3:
					//next/prevbookmark
					[lock lock];
					[lock unlock];
					if (left) {
						[self nextBookmark];
					} else {
						[self backBookmark];
					}
						break;
				case 4:
					//next/prevfolder
					[lock lock];
					[lock unlock];
					if (left) {
						[self nextFolder];
					} else {
						[self backFolder];
					}
						break;
				case 5:
					//skip/backskip
					if (left) {
						threadStop = YES;
						[lock lock];
						[lock unlock];
						threadStop = NO;
						[imageMutableArray removeAllObjects];
						int skipI = [[dic objectForKey:@"value"] intValue];
						skipI -= 2;
						nowPage += skipI;
						if (nowPage >= [completeMutableArray count]) {
							nowPage = [completeMutableArray count];
							nowPage -= 2;
						}
						[self lookahead];
						if ([imageMutableArray count] > 1) {
							if ([self isSmallImage:[imageMutableArray objectAtIndex:0] page:nowPage+1] == NO) {
								[imageMutableArray removeObjectAtIndex:0];
								nowPage++;
							} else if ([self isSmallImage:[imageMutableArray objectAtIndex:1] page:nowPage+2] == NO) {
								[imageMutableArray removeObjectAtIndex:0];
								nowPage++;
							}
						}
						[self imageDisplay];
					} else {
						threadStop = YES;
						[lock lock];
						[lock unlock];
						threadStop = NO;
						[imageMutableArray removeAllObjects];
						int bskipI = [[dic objectForKey:@"value"] intValue];
						bskipI += 2;
						nowPage -= bskipI;
						if (nowPage < 0) {
							nowPage = 0;
						}
						[self lookahead];
						[self imageDisplay];
					}
				case 6:
					//nextpage
					[lock lock];
					[lock unlock];
					useComposedImage = YES;
					[self imageDisplay];
					break;
				case 7:
					//prevpage 
					//[lock lock];
					//[lock unlock];
					[self prevPage];
					break;
				case 8:
					//halfnext
					[lock lock];
					[lock unlock];
					if (nowPage < [completeMutableArray count]) {
						if (secondImage){
							nowPage--;
							[imageMutableArray insertObject:[self loadImage:nowPage] atIndex:0];
							//[imageMutableArray insertObject:secondImage atIndex:0];
						}
					}
					[self imageDisplay];
					break;
				case 9:
					//halfprev
					[lock lock];
					[lock unlock];
					[self halfprevPage];
					break;
				case 10:
					//lastpage
					[self goToLast];
					break;
				case 11:
					//toppage
					if (secondImage) {
						if (nowPage > 2) {
							threadStop = YES;
							[lock lock];
							[lock unlock];
							threadStop = NO;
							[imageMutableArray removeAllObjects];
							nowPage = 0;
							[self lookahead];
							[self imageDisplay];
						}
					} else {
						if (nowPage > 1) {
							threadStop = YES;
							[lock lock];
							[lock unlock];
							threadStop = NO;
							[imageMutableArray removeAllObjects];
							nowPage = 0;
							[self lookahead];
							[self imageDisplay];
						}
					}		
					
					break;
				case 12:
					//nextbookmark	
					[lock lock];
					[lock unlock];
					[self nextBookmark];
					break;
				case 13:
					//prevbookmark
					[lock lock];
					[lock unlock];
					[self backBookmark];		
					break;
				case 14:
					//nextfolder	
					[lock lock];
					[lock unlock];
					[self nextFolder];
					break;
				case 15:
					//prevfolder
					[lock lock];
					[lock unlock];
					[self backFolder];
					break;
				case 16:
					//add/removebookmark
					if ([self removeBookmark]) {
					} else {
						[self addBookmark];
					}
					break;
				case 17:
					//switchSingle
					[lock lock];
					[lock unlock];
					[self switchSingle:nil];
					
					break;
				case 18:
					//shownumber
					if (numberSwitch) {
						[imageView setPageString:nil];
						numberSwitch = NO;
						[defaults setBool:numberSwitch forKey:@"ShowNumber"];
					} else {
						if (!secondImage) {
							int i = nowPage - 1;
							[imageView setPageString:[NSString stringWithFormat:@"#%d/%d (%@)",nowPage,[completeMutableArray count],[[completeMutableArray objectAtIndex:i] lastPathComponent]]];
							numberSwitch = YES;
						} else if (secondImage) {
							int i = nowPage - 1;
							int iS = i - 1;
							[imageView setPageString:[NSString stringWithFormat:@"#%d-%d/%d (%@ / %@)",i,nowPage,[completeMutableArray count],[[completeMutableArray objectAtIndex:iS] lastPathComponent],[[completeMutableArray objectAtIndex:i] lastPathComponent]]];
							numberSwitch = YES;
						}
						[defaults setBool:numberSwitch forKey:@"ShowNumber"];
					}
					//[imageView setNeedsDisplay];		
					break;
				case 19:
					//skip
					threadStop = YES;
					[lock lock];
					[lock unlock];
					threadStop = NO;
					[imageMutableArray removeAllObjects];
					int skipI = [[dic objectForKey:@"value"] intValue];
					skipI -= 2;
					nowPage += skipI;
					if (nowPage >= [completeMutableArray count]) {
						nowPage = [completeMutableArray count];
						nowPage -= 2;
					}
						[self lookahead];
					if ([imageMutableArray count] > 1) {
						if ([self isSmallImage:[imageMutableArray objectAtIndex:0] page:nowPage+1] == NO) {
							[imageMutableArray removeObjectAtIndex:0];
							nowPage++;
						} else if ([self isSmallImage:[imageMutableArray objectAtIndex:1] page:nowPage+2] == NO) {
							[imageMutableArray removeObjectAtIndex:0];
							nowPage++;
						}
					}
						
						[self imageDisplay];
					
					
					break;
				case 20:
					//backskip
					threadStop = YES;
					[lock lock];
					[lock unlock];
					threadStop = NO;
					[imageMutableArray removeAllObjects];
					int bskipI = [[dic objectForKey:@"value"] intValue];
					bskipI += 2;
					nowPage -= bskipI;
					if (nowPage < 0) {
						nowPage = 0;
					}
						[self lookahead];
					[self imageDisplay];
					
					
					break;
				case 21:
					//origRight
					switch (readMode) {
						case 0:
							[self viewAtOriginalSizeFirst:self];
							break;
						case 1:
							[self viewAtOriginalSizeSecond:self];
							break;
						case 2:
							[self viewAtOriginalSizeFirst:self];
							break;
						case 3:
							[self viewAtOriginalSizeSecond:self];
							break;
						default:
							break;
					}
					break;
				case 22:
					//origLeft
					switch (readMode) {
						case 0:
							[self viewAtOriginalSizeSecond:self];
							break;
						case 1:
							[self viewAtOriginalSizeFirst:self];
							break;
						case 2:
							[self viewAtOriginalSizeSecond:self];
							break;
						case 3:
							[self viewAtOriginalSizeFirst:self];
							break;
						default:
							break;
					}
					
					break;
				case 23:
					//slideshow	
					[self slideshow:nil];
					[self setPageTextField];
					break;
				case 24:
					//showThumbnail
					if (secondImage) {
						int temp = nowPage;
						temp--;
						[thumController showThumbnail:temp];
					} else {
						[thumController showThumbnail:nowPage];
					}
					
					break;
				case 25:
					//changeReadMode 
					[lock lock];
					[lock unlock];
					if (readMode == 0) {
						[self changeReadMode:1];
					} else if (readMode == 1) {
						[self changeReadMode:2];
					} else if (readMode == 2) {
						[self changeReadMode:3];
					} else if (readMode == 3) {
						[self changeReadMode:0];
					}
					break;
				case 26:
					//showPageBar
					if (pageBar) {
						pageBar = NO;
					} else {
						pageBar = YES;
					}
					[defaults setBool:pageBar forKey:@"ShowPageBar"];
					[imageView drawPageBar];
					break;
				case 27:
					//viewOriginalL/R
					if (left) {
						[self viewAtOriginalSizeSecond:self];
					} else {
						[self viewAtOriginalSizeFirst:self];
					}
					break;
				case 28:
					//showInFinderR
					switch (readMode) {
						case 0:
							[self showInFinderFirst:self];
							break;
						case 1:
							[self showInFinderSecond:self];
							break;
						case 2:
							[self showInFinderFirst:self];
							break;
						case 3:
							[self showInFinderSecond:self];
							break;
						default:
							break;
					}
					break;
				case 29:
					//showInFinderL
					switch (readMode) {
						case 0:
							[self showInFinderSecond:self];
							break;
						case 1:
							[self showInFinderFirst:self];
							break;
						case 2:
							[self showInFinderSecond:self];
							break;
						case 3:
							[self showInFinderFirst:self];
							break;
						default:
							break;
					}
					break;
				case 30:
					//showInFinderL/R
					if (left) {
						[self showInFinderSecond:self];
					} else {
						[self showInFinderFirst:self];
					}
					break;
				case 31:
					//PageUp
					[imageView scrollUp];
					break;
				case 32:
					//PageDown
					[imageView scrollDown];
					break;
				case 33:
					//PageUp + PrevPage
					if ([imageView prev] == YES) {
						//[lock lock];
						//[lock unlock];
						if (prevPageMode == 1) [imageView setStartFromEnd:YES];
						[self prevPage];
					}
					break;
				case 34:
					//PageDown + NextPage
					if ([imageView next] == YES) {
						[lock lock];
						[lock unlock];
						useComposedImage = YES;
						[self imageDisplay];
					}
					break;
				case 35:
					//ScrollToTop
					[imageView scrollToTop];
					break;
				case 36:
					//ScrollToEnd
					[imageView scrollToLast];
					break;
				case 37:
					//ScrollUp
					[imageView scrollTo:NSMakePoint(0,-1*([[dic objectForKey:@"value"] intValue]))];
					break;
				case 38:
					//ScrollDown
					[imageView scrollTo:NSMakePoint(0,[[dic objectForKey:@"value"] intValue])];
					break;
				case 39:
					//ScrollLeft
					[imageView scrollTo:NSMakePoint([[dic objectForKey:@"value"] intValue],0)];
					break;
				case 40:
					//ScrollRight
					[imageView scrollTo:NSMakePoint((-1*[[dic objectForKey:@"value"] intValue]),0)];
					break;
				case 41:
					//DragScroll
					break;
				case 42:
					//PageUp/Down + Prev/NextPage
					if (left) {
						if ([imageView next] == YES) {
							[lock lock];
							[lock unlock];
							useComposedImage = YES;
							[self imageDisplay];
						}
					} else {
						if ([imageView prev] == YES) {
							//[lock lock];
							//[lock unlock];
							if (prevPageMode == 1) [imageView setStartFromEnd:YES];
							[self prevPage];
						}
					}
					break;
				case 43:
					//loupe
					[imageView setLoupe];
					break;
				case 44:
					//nextSubFolder
					[self nextSubFolder];
					break;
				case 45:
					//prevSubFolder
					[self prevSubFolder];
					break;
				case 46:
					//next/prevSubFolder
					if (left) {
						[self nextSubFolder];
					} else {
						[self prevSubFolder];
					}
					break;
				case 47:
					//loupeRatePlus
					[defaults setFloat:[defaults floatForKey:@"LoupeRate"]+[[dic objectForKey:@"value"] floatValue] forKey:@"LoupeRate"];
					[imageView setLoupeRate];
					break;
				case 48:
					//loupeRateMinus
					if ([defaults floatForKey:@"LoupeRate"]-[[dic objectForKey:@"value"] floatValue]>1.0) {
						[defaults setFloat:[defaults floatForKey:@"LoupeRate"]-[[dic objectForKey:@"value"] floatValue] forKey:@"LoupeRate"];
					} else {
						[defaults setFloat:1.0 forKey:@"LoupeRate"];
					}
					[imageView setLoupeRate];
					break;
				
				case 49:
					//rotateRight
					[self rotateRight:nil];
					break;
				case 50:
					//rotateLeft
					[self rotateLeft:nil];
					break;
				case 51:
					//changeViewMode
					[self setPageTextField];
					switch (fitScreenMode) {
						case 0:
							[self fitToScreenWidth:nil];
							break;
						case 1:
							[self fitToScreenWidthDivide:nil];
							break;
						case 2:
							[self fitToScreen:nil];
							break;
						case 3:
							[self noScale:nil];
							break;
						default:
							break;
					}
					break;
				case 63:
					//enlargeViewMode
					[self setPageTextField];
					switch (fitScreenMode) {
						case 0:
							[self fitToScreenWidth:nil];
							break;
						case 1:
							[self fitToScreenWidthDivide:nil];
							break;
						case 3:
							[self noScale:nil];
							break;
						default:
							break;
					}
					break;
				case 64:
					//reduceViewMode
					[self setPageTextField];
					switch (fitScreenMode) {
						case 1:
							[self fitToScreen:nil];
							break;
						case 2:
							[self fitToScreenWidthDivide:nil];
							break;
						case 3:
							[self fitToScreenWidth:nil];
							break;
						default:
							break;
					}
					break;
				case 52:
					//trashRight
					[self trashRight];
					break;
				case 53:
					//trashLeft
					[self trashLeft];
					break;
				case 54:
					//trashL/R
					if (left) {
						[self trashLeft];
					} else {
						[self trashRight];
					}
					break;
				case 55:
					//rotateL/R
					if (left) {
						[self rotateLeft:nil];
					} else {
						[self rotateRight:nil];
					}
					break;
				case 56:
					//changeSortMode
					if ([imageLoader canSortByDate]) {
						switch (sortMode) {
							case 0:sortMode = 2;break;
							case 1:sortMode = 0;break;
							case 2:sortMode = 3;break;
							case 3:sortMode = 1;break;
							default:break;
						}
						[self setSortMode:sortMode page:0];
					} else {
						switch (sortMode) {
							case 0:sortMode = 1;break;
							case 1:sortMode = 0;break;
							case 2:sortMode = 0;break;
							case 3:sortMode = 0;break;
							default:break;
						}
						[self setSortMode:sortMode page:0];
					}					
					break;	
				case 57:
					//close
					threadStop = YES;
					[lock lock];
					[lock unlock];
					threadStop = NO;
					[window performClose:self];
					break;	
				case 58:
					//random
					[self setSortMode:1 page:0];
					break;
				case 59:
					//ContextualMenu
					[NSMenu popUpContextMenu:[imageView menu] withEvent:[NSApp currentEvent] forView:imageView];
					break;
				case 60:
					//openTheLastPage
				{
					NSMenu *menu = [[[NSApp mainMenu] itemWithTitle:NSLocalizedString(@"File", @"")] submenu];
					NSMenuItem *item = [menu itemWithTitle:NSLocalizedString(@"Open the last page", @"")];
					if ([item isEnabled]) {
						[menu performActionForItemAtIndex:[menu indexOfItem:item]];
					}
				}
					break;
				case 61:
					//switchFullScreen
				{
					NSMenu *menu = [[[NSApp mainMenu] itemWithTitle:NSLocalizedString(@"Window", @"")] submenu];
					NSMenuItem *item = [menu itemWithTitle:NSLocalizedString(@"Fullscreen", @"")];
					if ([item isEnabled]) {
						[menu performActionForItemAtIndex:[menu indexOfItem:item]];
					}
				}
					break;
				case 62:
					//minimizeWindow
				{
					NSMenu *menu = [[[NSApp mainMenu] itemWithTitle:NSLocalizedString(@"Window", @"")] submenu];
					NSMenuItem *item = [menu itemWithTitle:NSLocalizedString(@"Minimize", @"")];
					if ([item isEnabled]) {
						[menu performActionForItemAtIndex:[menu indexOfItem:item]];
					}
				}
					break;
				default:
					break;
			}
			return YES;
		}
	}
	return NO;
}

- (IBAction)contextAction:(id)sender
{
	if (timerSwitch) {
		[timer invalidate];
		timerSwitch=NO;
	}
	[lock lock];
	[lock unlock];
	if ([[sender title] isEqualToString:NSLocalizedString(@"Add Bookmark", @"")]){
		[self addBookmark];
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Remove Bookmark", @"")]){
		[self removeBookmark];
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Go to LastPage", @"")]){
		[self goToLast];
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Go to FirstPage", @"")]){
		[self goToFirst];
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Next Bookmark", @"")]){
		[self nextBookmark];	
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Previous Bookmark", @"")]){
		[self backBookmark];
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Previous Folder", @"")]){
		[self backFolder];
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Next Folder", @"")]){
		[self nextFolder];
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Show Thumbnail", @"")]){
		[self showThumbnail];
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"View at Original Size", @"")]){
		if ([sender tag] == 0) {
			[self viewAtOriginalSizeFirst:self];
		} else {
			[self viewAtOriginalSizeSecond:self];
		}
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Show in Finder", @"")]){
		if ([sender tag] == 0) {
			[self showInFinderFirst:self];
		} else {
			[self showInFinderSecond:self];
		}
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Start Slideshow", @"")]) {
		[self slideshow:self];
	} else if ([[sender title] isEqualToString:NSLocalizedString(@"Stop Slideshow", @"")]) {
		[self setPageTextField];
		/*既に止まってる*/
	}
}
/*
- (IBAction)nextFolder:(id)sender{
}
- (IBAction)addBookmark:(id)sender{
}
- (IBAction)backFolder:(id)sender{
}
- (IBAction)nextBookmark:(id)sender{
}
- (IBAction)backBookmark:(id)sender{
}
- (IBAction)showThumbnail:(id)sender{
}*/


- (void)wheelAction:(NSEvent*)event
{
	if (timerSwitch) {
		[timer invalidate];
		timerSwitch=NO;
	}

	threadStop = NO;
	if (fitScreenMode > 0) {
		switch (canScrollMode) {
			case 0:
				[imageView scrollTo:NSMakePoint(([event deltaX]*10),([event deltaY]*10*-1))];
				return;
			case 1:
				if (![imageView scrollTo:NSMakePoint(([event deltaX]*10),([event deltaY]*10*-1))]) {
					return;
				} else {
					if ([event deltaY] < 0) {
						[imageView next];
					} else if ([event deltaY] > 0) {
						[imageView prev];
					}
				}
				return;
			case 2:
				if (![imageView scrollTo:NSMakePoint(([event deltaX]*10),([event deltaY]*10*-1))]) {
					return;
				} else {
					if ([event deltaY] < 0) {
						if (![imageView next]) {
							return;
						} else {
							useComposedImage = YES;
							[self imageDisplay];
						}
					} else if ([event deltaY] > 0) {
						if (![imageView prev]) {
							return;
						} else {
							useComposedImage = NO;
							if (prevPageMode == 1) [imageView setStartFromEnd:YES];
							[self prevPage];
						}
					}
				}
				return;
			case 3:
				break;
			default:break;
		}
	}
	
	if (wheelSensitivity == 0.0) {
		return;
	}
	float wheelCount = [event deltaY];
	
	float temp = wheelSensitivity;
	if (wheelCount < 0) {
		temp = -1*wheelSensitivity;
		if (wheelCount <= temp) {
			if (wheelUpTimer) {
				return;
			} else {
				wheelDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self
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
				wheelUpTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self
															  selector:@selector(wheelUp)
															  userInfo:NULL
															   repeats:NO];
			}
		}
	}
}


#pragma mark inAction

- (IBAction)showInFinderSecond:(id)sender
{
	int i = nowPage;
	i--;
	NSString *currentFilePath = [imageLoader itemPathAtIndex:i];
	[[NSWorkspace sharedWorkspace] selectFile:currentFilePath inFileViewerRootedAtPath:nil];
	/*
	if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:[currentFilePath stringByDeletingLastPathComponent]]) {
		[[NSWorkspace sharedWorkspace] selectFile:[currentFilePath stringByDeletingLastPathComponent] inFileViewerRootedAtPath:nil];
	} else {
		[[NSWorkspace sharedWorkspace] selectFile:currentFilePath inFileViewerRootedAtPath:nil];
	}*/
}

- (IBAction)showInFinderFirst:(id)sender
{
	int i = nowPage;
	i--;
	if (secondImage) i--;
	NSString *currentFilePath = [imageLoader itemPathAtIndex:i];
	[[NSWorkspace sharedWorkspace] selectFile:currentFilePath inFileViewerRootedAtPath:nil];
	/*
	if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:[currentFilePath stringByDeletingLastPathComponent]]) {
		[[NSWorkspace sharedWorkspace] selectFile:[currentFilePath stringByDeletingLastPathComponent] inFileViewerRootedAtPath:nil];
	} else {
		[[NSWorkspace sharedWorkspace] selectFile:currentFilePath inFileViewerRootedAtPath:nil];
	}*/
}

- (IBAction)viewAtOriginalSizeFirst:(id)sender
{
	if (timerSwitch) {
		[timer invalidate];
		timerSwitch=NO;
	}
	id scrollView = [fullImageView enclosingScrollView];
	
	[fullImageView setImage:nil];
	[fullImageView setImageScaling:NSScaleNone];
	int i;
	if (!secondImage) {
		i = nowPage - 1;
		[fullImageView setImage:firstImage];
	} else {
		i = nowPage - 2;
		[fullImageView setImage:firstImage];
	}
	
	NSSize theScrollViewSize = [NSScrollView
				  frameSizeForContentSize:[fullImageView frame].size
					hasHorizontalScroller:[scrollView hasHorizontalScroller]
					  hasVerticalScroller:[scrollView hasVerticalScroller]
							   borderType:[scrollView borderType]
		];
	[fullImagePanel setContentSize:theScrollViewSize];
	
	NSRect theScrollViewRect;
	theScrollViewRect.origin = NSZeroPoint;
	theScrollViewRect.size = theScrollViewSize;
	NSRect theWindowMaxRect = [ NSWindow
				 frameRectForContentRect:theScrollViewRect
							   styleMask:[ fullImagePanel styleMask]
		];
	NSRect fullscreenRect = [[NSScreen mainScreen] frame];
	if (theWindowMaxRect.size.width > fullscreenRect.size.width) {
		theWindowMaxRect.size.width = fullscreenRect.size.width;
	}
	[fullImagePanel setMaxSize:theWindowMaxRect.size];
	
	[fullImagePanel setTitle:[NSString stringWithFormat:@"original %@",[[completeMutableArray objectAtIndex:i] lastPathComponent]]];
	
	if (readMode == 0 || readMode == 2) {
		[fullImagePanel setFrameOrigin:NSMakePoint(fullscreenRect.size.width - theWindowMaxRect.size.width,0)];
	} else {
		[fullImagePanel setFrameOrigin:NSMakePoint(0,5)];
	}
	
	[fullImagePanel makeKeyAndOrderFront:self];
}

- (IBAction)viewAtOriginalSizeSecond:(id)sender
{
	if (timerSwitch) {
		[timer invalidate];
		timerSwitch=NO;
	}
	id scrollView = [fullImageView enclosingScrollView];
	[fullImageView setImage:nil];
	[fullImageView setImageScaling:NSScaleNone];
	int i;
	if (!secondImage) {
		i = nowPage - 1;
		[fullImageView setImage:firstImage];
	} else {
		i = nowPage - 1;
		[fullImageView setImage:secondImage];
	}
	NSSize theScrollViewSize = [NSScrollView
                      frameSizeForContentSize:[fullImageView frame].size
						hasHorizontalScroller:[scrollView hasHorizontalScroller]
						  hasVerticalScroller:[scrollView hasVerticalScroller]
								   borderType:[scrollView borderType]
		];
	[fullImagePanel setContentSize:theScrollViewSize];
	NSRect theScrollViewRect;
	theScrollViewRect.origin = NSZeroPoint;
	theScrollViewRect.size = theScrollViewSize;
	NSRect theWindowMaxRect = [ NSWindow
                     frameRectForContentRect:theScrollViewRect
								   styleMask:[ fullImagePanel styleMask]
		];
	NSRect fullscreenRect = [[NSScreen mainScreen] frame];
	if (theWindowMaxRect.size.width > fullscreenRect.size.width) {
		theWindowMaxRect.size.width = fullscreenRect.size.width;
	}
	[fullImagePanel setMaxSize:theWindowMaxRect.size];
	
	[fullImagePanel setTitle:[NSString stringWithFormat:@"original %@",[[completeMutableArray objectAtIndex:i] lastPathComponent]]];
	
	if (readMode == 0 || readMode == 2) {
		[fullImagePanel setFrameOrigin:NSMakePoint(0,5)];
	} else {
		[fullImagePanel setFrameOrigin:NSMakePoint(fullscreenRect.size.width - theWindowMaxRect.size.width,0)];
	}
	
	[fullImagePanel makeKeyAndOrderFront:self];
}




- (void)changeReadMode:(int)mode
{
	if (readMode == mode) {
		return;
	}
	readMode = mode;
	
	if (secondImage){
		nowPage -= 2;
		[imageMutableArray insertObject:secondImage atIndex:0];
		[imageMutableArray insertObject:firstImage atIndex:0];
	} else if ([imageView image]) {
		nowPage--;
		[imageMutableArray insertObject:firstImage atIndex:0];
	} else {
		return;
	}
	
	
	if (rememberBookSettings) {
		[currentBookSetting setObject:[NSNumber numberWithInt:mode] forKey:@"readMode"];
	}
	
	[self viewSet];
	[self imageDisplay];
	
	
	if (readMode == 1) {
		[imageView setInfoString:[NSString stringWithFormat:@"read:left to right"]];
	} else if (readMode == 2) {
		[imageView setInfoString:[NSString stringWithFormat:@"read:right to left(single)"]];
	} else if (readMode == 3) {
		[imageView setInfoString:[NSString stringWithFormat:@"read:left to right(single)"]];
	} else if (readMode == 0) {
		[imageView setInfoString:[NSString stringWithFormat:@"read:right to left"]];
	}
}
- (void)setSortMode:(int)mode page:(int)p
{
	//if (sortMode != mode) {
	sortMode = mode;
	[completeMutableArray sortUsingSelector:@selector(finderCompareS:)];
	switch (mode) {
		case 0:
			//name
			//[completeMutableArray sortUsingSelector:@selector(finderCompareS:)];
			[imageView setInfoString:[NSString stringWithFormat:@"sort:name"]];
			break;
		case 1:
			//random
			[completeMutableArray sortUsingSelector:@selector(randomCompare:)];
			[imageView setInfoString:[NSString stringWithFormat:@"sort:shuffle"]];
			break;
		case 2:
			//creation
			if ([imageLoader canSortByDate]) {
				[completeMutableArray sortUsingSelector:@selector(fileCreationDateCompare:)];
				[imageView setInfoString:[NSString stringWithFormat:@"sort:Creation Date"]];
			}
			break;
		case 3:
			//modification
			if ([imageLoader canSortByDate]) {
				[completeMutableArray sortUsingSelector:@selector(fileModificationDateCompare:)];
				[imageView setInfoString:[NSString stringWithFormat:@"sort:Modification Date"]];
			}
			break;
		default:
			//[completeMutableArray sortUsingSelector:@selector(finderCompareS:)];
			break;
	}
	if (rememberBookSettings && p>-1) {
		[currentBookSetting setObject:[NSNumber numberWithInt:mode] forKey:@"sortMode"];
	}
	
	if (p >= 0) [self goTo:p array:nil];
	//}
}



- (void)prevPage
{
	if (readMode > 1) {
		if (nowPage < 2) {
			if (loopCheck == 0) {
				threadStop = YES;
				[lock lock];
				[lock unlock];
				threadStop = NO;
				[imageMutableArray removeAllObjects];
				nowPage = [completeMutableArray count];
				nowPage --;
				[self lookahead];
			} else if (loopCheck == 1) {
				[lock lock];
				[lock unlock];
				[self backFolder];
				return;
			} else if (loopCheck == 2) {
				[lock lock];
				[lock unlock];
				[self backFolderLast];
				return;
			} else {
				return;
			}
		} else {
			threadStop = YES;
			[lock lock];
			[lock unlock];
			threadStop = NO;
			[imageMutableArray removeAllObjects];
			nowPage -= 2;
			[self lookahead];
		}
		[self imageDisplay];
	} else {
		if (!secondImage) {
			if (nowPage < 2) {
				if (loopCheck == 0) {
					threadStop = YES;
					[lock lock];
					[lock unlock];
					threadStop = NO;
					[imageMutableArray removeAllObjects];
					nowPage = [completeMutableArray count];
					nowPage -= 2;
					if (bufferingMode == 0 && screenCache>0) [self imageDisplayIfHasScreenCache];
					[self lookahead];
					if ([self isSmallImage:[imageMutableArray objectAtIndex:0] page:nowPage+1] == NO) {
						[imageMutableArray removeObjectAtIndex:0];
						nowPage++;
					} else if ([self isSmallImage:[imageMutableArray objectAtIndex:1] page:nowPage+2] == NO) {
						[imageMutableArray removeObjectAtIndex:0];
						nowPage++;
					}
					[self imageDisplay];
					return;
				} else if (loopCheck == 1) {
					[lock lock];
					[lock unlock];
					[self backFolder];
					return;
				} else if (loopCheck == 2) {
					[lock lock];
					[lock unlock];
					[self backFolderLast];
					return;
				} else {
					return;
				}
			} else if (nowPage == 2) {
				[lock lock];
				[lock unlock];
				nowPage = 0;
				[imageMutableArray insertObject:[self loadImage:nowPage] atIndex:0];
				//[imageMutableArray insertObject:[imageView image] atIndex:1];
				//[imageMutableArray insertObject:[self loadImage:nowPage+1] atIndex:1];
				nowPage += 2;
				[imageMutableArray insertObject:[self loadImage:nowPage-1] atIndex:1];
				nowPage -= 2;
			} else if (nowPage > 2) {
				threadStop = YES;
				[lock lock];
				[lock unlock];
				threadStop = NO;
				[imageMutableArray removeAllObjects];
				nowPage -= 3;
				if (bufferingMode == 0 && screenCache>0) [self imageDisplayIfHasScreenCache];
				[self lookahead];
				//NSLog(@"1 %@",imageMutableArray);
				//[imageMutableArray addObject:[imageView image]];
				//[imageMutableArray addObject:[self loadImage:nowPage+2]];
				nowPage += 3;
				[imageMutableArray addObject:[self loadImage:nowPage-1]];
				nowPage -= 3;
				//NSLog(@"2 %@",imageMutableArray);
				if ([self isSmallImage:[imageMutableArray objectAtIndex:0] page:nowPage+1] == NO){
					nowPage++;
					[imageMutableArray removeObjectAtIndex:0];
				} else if ([self isSmallImage:[imageMutableArray objectAtIndex:1] page:nowPage+2] == NO) {
					nowPage++;
					[imageMutableArray removeObjectAtIndex:0];
				}
				[self imageDisplay];
				return;
			}
		} else {
			if (nowPage < 3) {
				if (loopCheck == 0) {
					threadStop = YES;
					[lock lock];
					[lock unlock];
					threadStop = NO;
					[imageMutableArray removeAllObjects];
					nowPage = [completeMutableArray count];
					nowPage -= 2;
					if (bufferingMode == 0 && screenCache>0) [self imageDisplayIfHasScreenCache];
					[self lookahead];
					if ([self isSmallImage:[imageMutableArray objectAtIndex:0] page:nowPage+1] == NO) {
						[imageMutableArray removeObjectAtIndex:0];
						nowPage++;
					} else if ([self isSmallImage:[imageMutableArray objectAtIndex:1] page:nowPage+2] == NO) {
						[imageMutableArray removeObjectAtIndex:0];
						nowPage++;
					}
					[self imageDisplay];
					return;
				} else if (loopCheck == 1) {
					[lock lock];
					[lock unlock];
					[self backFolder];
					return;
				} else if (loopCheck == 2) {
					[lock lock];
					[lock unlock];
					[self backFolderLast];
					return;
				} else {
					return;
				}
			} else if (nowPage < 4) {
				threadStop = YES;
				[lock lock];
				[lock unlock];
				threadStop = NO;
				[imageMutableArray removeAllObjects];
				nowPage -= 3;
				if (bufferingMode == 0 && screenCache>0) [self imageDisplayIfHasScreenCache];
				[imageMutableArray addObject:[self loadImage:nowPage]];
				//[imageMutableArray addObject:firstImage];
				//[imageMutableArray addObject:secondImage];
				//[imageMutableArray addObject:[self loadImage:nowPage+1]];
				//[imageMutableArray addObject:[self loadImage:nowPage+2]];
				nowPage += 3;
				[imageMutableArray addObject:[self loadImage:nowPage-2]];
				[imageMutableArray addObject:[self loadImage:nowPage-1]];
				nowPage -= 3;
				[self imageDisplay];
				return;
			} else if (nowPage > 3) {
				threadStop = YES;
				[lock lock];
				[lock unlock];
				threadStop = NO;
				[imageMutableArray removeAllObjects];
				nowPage -= 4;
				if (bufferingMode == 0 && screenCache>0) [self imageDisplayIfHasScreenCache];				
				[self lookahead];
				//[imageMutableArray addObject:firstImage];
				//[imageMutableArray addObject:secondImage];
				//[imageMutableArray addObject:[self loadImage:nowPage+2]];
				//[imageMutableArray addObject:[self loadImage:nowPage+3]];
				nowPage += 4;
				[imageMutableArray addObject:[self loadImage:nowPage-2]];
				[imageMutableArray addObject:[self loadImage:nowPage-1]];
				nowPage -= 4;
				
				if ([self isSmallImage:[imageMutableArray objectAtIndex:0] page:nowPage+1] == NO){
					nowPage++;
					[imageMutableArray removeObjectAtIndex:0];
				} else if ([self isSmallImage:[imageMutableArray objectAtIndex:1] page:nowPage+2] == NO) {
					nowPage++;
					[imageMutableArray removeObjectAtIndex:0];
				}
				[self imageDisplay];
				return;
			}
		}
		[self imageDisplay];
	}
}

- (void)halfprevPage
{
	if (readMode > 1) {
		if (nowPage <2) {
			if (loopCheck == 0) {
				[imageMutableArray removeAllObjects];
				nowPage = [completeMutableArray count];
				nowPage --;
				[self lookahead];
			} else if (loopCheck == 1) {
				[self backFolder];
				return;
			} else if (loopCheck == 2) {
				[self backFolderLast];
				return;
			} else {
				return;
			}
		} else {
			[imageMutableArray removeAllObjects];
			nowPage -= 2;
			[self lookahead];
		}
		[self imageDisplay];
	} else {
		if (!secondImage) {
			if (nowPage <2) {
				if (loopCheck == 0) {
					[imageMutableArray removeAllObjects];
					nowPage = [completeMutableArray count];
					nowPage --;
					[self lookahead];
				} else if (loopCheck == 1) {
					[self backFolder];
					return;
				} else if (loopCheck == 2) {
					[self backFolderLast];
					return;
				} else {
					return;
				}
			} else if (nowPage == 2) {
				nowPage = 0;
				[imageMutableArray insertObject:[self loadImage:nowPage] atIndex:0];
				//[imageMutableArray insertObject:[imageView image] atIndex:1];
				//[imageMutableArray insertObject:[self loadImage:nowPage+1] atIndex:1];
				nowPage += 2;
				[imageMutableArray insertObject:[self loadImage:nowPage-1] atIndex:1];
				nowPage -= 2;
			} else if (nowPage > 2) {
				[imageMutableArray removeAllObjects];
				nowPage -= 3;
				[self lookahead];
				//[imageMutableArray addObject:[imageView image]];
				//[imageMutableArray addObject:[self loadImage:nowPage+2]];
				nowPage += 3;
				[imageMutableArray addObject:[self loadImage:nowPage-1]];
				nowPage -= 3;
				if ([self isSmallImage:[imageMutableArray objectAtIndex:0] page:nowPage+1] == NO){
					nowPage++;
					[imageMutableArray removeObjectAtIndex:0];
				} else if ([self isSmallImage:[imageMutableArray objectAtIndex:1] page:nowPage+2] == NO) {
					nowPage++;
					[imageMutableArray removeObjectAtIndex:0];
				} else {
				}
				
			}
		} else {
			if (nowPage < 3) {
				if (loopCheck == 0) {
					[imageMutableArray removeAllObjects];
					nowPage = [completeMutableArray count];
					nowPage -= 2;
					[self lookahead];
					if ([self isSmallImage:[imageMutableArray objectAtIndex:0] page:nowPage+1] == NO) {
						[imageMutableArray removeObjectAtIndex:0];
						nowPage++;
					} else if ([self isSmallImage:[imageMutableArray objectAtIndex:1] page:nowPage+2] == NO) {
						[imageMutableArray removeObjectAtIndex:0];
						nowPage++;
					}
				} else if (loopCheck == 1) {
					[self backFolder];
					return;
				} else if (loopCheck == 2) {
					[self backFolderLast];
					return;
				} else {
					return;
				}
			} else if (nowPage > 2) {
				[imageMutableArray removeAllObjects];
				nowPage -= 3;
				
				[imageMutableArray addObject:[self loadImage:nowPage]];
				//[imageMutableArray addObject:firstImage];
				//[imageMutableArray addObject:[self loadImage:nowPage+1]];
				nowPage += 3;
				[imageMutableArray addObject:[self loadImage:nowPage-2]];
				nowPage -= 3;
			}
		}	
		[self imageDisplay];
	}
}

-(void)goToLast
{
	if (nowPage < [completeMutableArray count]) {
		useComposedImage = NO;
		[imageMutableArray removeAllObjects];
		nowPage = [completeMutableArray count];
		if (readMode > 1) {
			nowPage--;
			[self lookahead];
		} else {
			nowPage -= 2;
			[self lookahead];
			if ([self isSmallImage:[imageMutableArray objectAtIndex:0] page:nowPage+1] == NO) {
				[imageMutableArray removeObjectAtIndex:0];
				nowPage++;
			} else if ([self isSmallImage:[imageMutableArray objectAtIndex:1] page:nowPage+2] == NO) {
				[imageMutableArray removeObjectAtIndex:0];
				nowPage++;
			}
		}
		[self imageDisplay];
	}
}
-(void)goToFirst
{
	useComposedImage = NO;
	[imageMutableArray removeAllObjects];
	nowPage = 0;
	[self lookahead];
	[self imageDisplay];
}
-(void)showThumbnail
{	
	if (secondImage) {
		int temp = nowPage;
		temp--;
		[thumController showThumbnail:temp];
	} else {
		[thumController showThumbnail:nowPage];
	}
}

-(void)nextBookmark
{
	useComposedImage = NO;
	NSMutableArray *oldArray = [NSMutableArray array];
	int i;
	for (i = 0; i < [bookmarkArray count]; i++) {
		NSNumber *number = [NSNumber numberWithInt:[ [[bookmarkArray objectAtIndex:i] objectForKey:@"page"] intValue]];
		[oldArray addObject:number];
	}
	NSArray *newArray = [oldArray sortedArrayUsingSelector:@selector(compare:)];
	for (i = 0; i<[newArray count]; i++) {
		int iS = [[newArray objectAtIndex:i] intValue];
		int iSS = nowPage;
		if (secondImage) {
			iSS--;
		}
		if (iS > iSS) {
			NSEnumerator *enumerator = [bookmarkArray objectEnumerator];
			id object;
			NSString *bookmarkTitle;
			while (object = [enumerator nextObject]) {
				if ([[object objectForKey:@"page"] intValue] == iS){
					bookmarkTitle = [object objectForKey:@"name"];
					break;
				}
			}
			
			nowPage = iS - 1;
			[imageMutableArray removeAllObjects];
			[self lookahead];
			[self imageDisplay];
			[imageView setInfoString:bookmarkTitle];
			break;
		}
	}
}

-(void)backBookmark
{
	useComposedImage = NO;
	NSMutableArray *oldArray = [NSMutableArray array];
	int i;
	for (i = 0; i < [bookmarkArray count]; i++) {
		NSNumber *number = [NSNumber numberWithInt:[ [[bookmarkArray objectAtIndex:i] objectForKey:@"page"] intValue]];
		[oldArray addObject:number];
	}
	NSArray *newArray = [oldArray sortedArrayUsingSelector:@selector(compare:)];
	for (i = [newArray count]-1; i >= 0; i--) {
		int iS = [[newArray objectAtIndex:i] intValue];
		int iSS = nowPage;
		if (secondImage) {
			iSS--;
		}
		if (iS < iSS) {
			
			NSEnumerator *enumerator = [bookmarkArray objectEnumerator];
			id object;
			NSString *bookmarkTitle;
			while (object = [enumerator nextObject]) {
				if ([[object objectForKey:@"page"] intValue] == iS){
					bookmarkTitle = [object objectForKey:@"name"];
					break;
				}
			}
			
			nowPage = iS - 1;
			[imageMutableArray removeAllObjects];
			[self lookahead];
			[self imageDisplay];
			[imageView setInfoString:bookmarkTitle];
			break;
		}
	}
}

-(void)nextFolder
{
	if ([[[openSameFolderMenuItem submenu] itemArray] count] > 0) {
		NSEnumerator *enumerator = [[[openSameFolderMenuItem submenu] itemArray] objectEnumerator];
		id object;
		while (object = [enumerator nextObject]) {
			if ([object state] == NSOnState){
				[object setState:NSOffState];
				while (object = [enumerator nextObject]) {
					if ([object isEnabled]) {
						break;
					}
				}
				if (!object) {
					object = [[[openSameFolderMenuItem submenu] itemArray] objectAtIndex:0];
				}
				[object setState:NSOnState];
				break;
			}
		}
		[self openFromSameDir:object];
	}
}

-(void)backFolder
{
	if ([[[openSameFolderMenuItem submenu] itemArray] count] > 0) {
		NSEnumerator *enumerator = [[[openSameFolderMenuItem submenu] itemArray] reverseObjectEnumerator];
		id object;
		while (object = [enumerator nextObject]) {
			if ([object state] == NSOnState){
				[object setState:NSOffState];
				while (object = [enumerator nextObject]) {
					if ([object isEnabled]) {
						break;
					}
				}				
				if (!object) {
					object = [[[openSameFolderMenuItem submenu] itemArray] lastObject];
				}
				[object setState:NSOnState];
				break;
			}
		}
		[self openFromSameDir:object];
	}
}

-(void)backFolderLast
{
	if ([[[openSameFolderMenuItem submenu] itemArray] count] > 0) {
		NSEnumerator *enumerator = [[[openSameFolderMenuItem submenu] itemArray] reverseObjectEnumerator];
		id object;
		while (object = [enumerator nextObject]) {
			if ([object state] == NSOnState){
				[object setState:NSOffState];
				while (object = [enumerator nextObject]) {
					if ([object isEnabled]) {
						break;
					}
				}				
				if (!object) {
					object = [[[openSameFolderMenuItem submenu] itemArray] lastObject];
				}
				[object setState:NSOnState];
				break;
			}
		}
		[self openFromSameDir:object last:YES];
	}
}

- (void)nextSubFolder
{
	[lock lock];
	[lock unlock];
	int nextNow = [imageLoader nextFolder:nowPage];
	[self goTo:nextNow array:nil];
}

- (void)prevSubFolder
{
	[lock lock];
	[lock unlock];
	int prevNow;
	if (secondImage) {
		prevNow = [imageLoader prevFolder:nowPage-1];
	} else {
		prevNow = [imageLoader prevFolder:nowPage];
	}
	[self goTo:prevNow array:nil];
}

-(void)nextOriginal
{
	int i;
	if ([fullImageView image] == secondImage) {
		[self imageDisplay];
		if (secondImage){
			[fullImageView setImage:firstImage];
			i = nowPage;
			i-=2;
		} else {
			[fullImageView setImage:firstImage];
			i = nowPage;
			i--;
		}
	} else {
		if (secondImage){
			[fullImageView setImage:secondImage];
			i = nowPage;
			i--;
		} else {
			[self imageDisplay];
			if (secondImage){
				[fullImageView setImage:firstImage];
				i = nowPage;
				i -=2;
			} else {
				[fullImageView setImage:firstImage];
				i = nowPage;
				i--;
			}
		}
	}
	
	[fullImagePanel setTitle:[NSString stringWithFormat:@"original %@",[[completeMutableArray objectAtIndex:i] lastPathComponent]]];
}

-(void)prevOriginal
{
	int i;
	if ([fullImageView image] == secondImage) {
		[fullImageView setImage:firstImage];
		i = nowPage;
		i-=2;
	} else {
		[self prevPage];
		if (secondImage){
			[fullImageView setImage:secondImage];
			i = nowPage;
			i--;
		} else {
			[fullImageView setImage:firstImage];
			i = nowPage;
			i--;
		}
	}
	[fullImagePanel setTitle:[NSString stringWithFormat:@"original %@",[[completeMutableArray objectAtIndex:i] lastPathComponent]]];
}



- (void)wheelUp
{
	useComposedImage = NO;
	[self prevPage];
	wheelUpTimer = nil;
}
- (void)wheelDown
{
	useComposedImage = YES;
	[self imageDisplay];
	wheelDownTimer = nil;
}

- (void)goTo:(int)page array:(NSArray*)array
{
	//[completeMutableArray autorelease];
	if (array == nil) {
		//[completeMutableArray retain];
	} else {
		//[completeMutableArray removeAllObjects];
		//[completeMutableArray addObjectsFromArray:array];
	}
	[composedImage release];
	composedImage = nil;
	nowPage = page;
	if (nowPage < 0) {
		nowPage = 0;
	} else if (nowPage >= [completeMutableArray count]) {
		nowPage = [completeMutableArray count]-1;
	}
	[imageMutableArray removeAllObjects];
	[self lookahead];
	[self imageDisplay];
}

- (void)addBookmark
{
	if (!secondImage) {
		[self addBookmarkWithPage:nowPage];
	} else {
		[self addBookmarkWithPage:nowPage-1];
	}
	[imageView setInfoString:@"Add bookmark"];
}
- (BOOL)isBookmarkedPage:(int)page
{
	id bookmark;
	int index;
	for (index=0; index<[bookmarkArray count]; index++) {
		bookmark = [bookmarkArray objectAtIndex:index];
		if ([[bookmark objectForKey:@"page"] intValue] == page) {
			return YES;
		}
	}
	return NO;
}
- (BOOL)removeBookmark
{
	BOOL b = NO;
	if (!secondImage) {
		b = [self removeBookmarkWithPage:nowPage];
	} else {
		b = [self removeBookmarkWithPage:nowPage-1];
		if (!b) {
			b = [self removeBookmarkWithPage:nowPage];
		}
	}
	if (b) [imageView setInfoString:[NSString stringWithFormat:@"Remove bookmark"]];
	return b;
}

- (void)goToPar:(float)par
{
	threadStop = YES;
	[lock lock];
	[lock unlock];
	threadStop = NO;
	
	float temp = [completeMutableArray count]*par;
	int page = (int)temp;
	nowPage = page;
	if (nowPage < 0) {
		nowPage = 0;
	}
	[composedImage release];
	composedImage = nil;
	[imageMutableArray removeAllObjects];
	[self lookahead];
	[self imageDisplay];
}


- (IBAction)switchSingle:(id)sender
{
	NSString *string;
	if (secondImage) {
		[imageMutableArray insertObject:secondImage atIndex:0];
		[secondImage release];
		secondImage = nil;
		[imageView setImage:firstImage];
		/*
		NSImage* temp = firstImage;
		firstImage = nil;
		[imageView setImage:temp];
		[temp release];*/
		nowPage--;
		if ([marksArray containsObject:[NSString stringWithFormat:@"%i",nowPage]]) {
			[marksArray removeObject:[NSString stringWithFormat:@"%i",nowPage]];
		}
		if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",nowPage-1,nowPage]]) {
			[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",nowPage-1,nowPage]];
		}
		if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",nowPage,nowPage+1]]) {
			[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",nowPage,nowPage+1]];
		}
		string = [NSString stringWithFormat:@"%i",nowPage];
		[marksArray addObject:string];
		
		if (readMode > 1) {
			[NSThread detachNewThreadSelector:@selector(lookahead) toTarget:self withObject:nil];
		} else {
			[NSThread detachNewThreadSelector:@selector(lookaheadAndCompose) toTarget:self withObject:nil];
		}
	} else {
		if (nowPage == [completeMutableArray count]) {
			if ([self isSmallImage:firstImage page:nowPage]) {
				if ([marksArray containsObject:[NSString stringWithFormat:@"%i",nowPage]]) {
					[marksArray removeObject:[NSString stringWithFormat:@"%i",nowPage]];
				}
				if ([marksArray containsObject:[NSString stringWithFormat:@"%i",nowPage-1]]) {
					[marksArray removeObject:[NSString stringWithFormat:@"%i",nowPage-1]];
				}
				if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",nowPage-1,nowPage]]) {
					[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",nowPage-1,nowPage]];
				}
				if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",nowPage,nowPage+1]]) {
					[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",nowPage,nowPage+1]];
				}
				string = [NSString stringWithFormat:@"%i",nowPage];
				[marksArray addObject:string];
			} else {
				if ([marksArray containsObject:[NSString stringWithFormat:@"%i",nowPage]]) {
					[marksArray removeObject:[NSString stringWithFormat:@"%i",nowPage]];
				}
				if ([marksArray containsObject:[NSString stringWithFormat:@"%i",nowPage-1]]) {
					[marksArray removeObject:[NSString stringWithFormat:@"%i",nowPage-1]];
				}
				if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",nowPage-1,nowPage]]) {
					[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",nowPage-1,nowPage]];
				}
				if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",nowPage,nowPage+1]]) {
					[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",nowPage,nowPage+1]];
				}
				string = [NSString stringWithFormat:@"%i-%i",nowPage,nowPage+1];
				[marksArray addObject:string];
			}
			return;
		}
		//firstImage = [[imageView image] retain];
		secondImage = [[imageMutableArray objectAtIndex:0] retain];
		[imageMutableArray removeObjectAtIndex:0];
		[self composeImage];
		nowPage++;
		if ([marksArray containsObject:[NSString stringWithFormat:@"%i",nowPage]]) {
			[marksArray removeObject:[NSString stringWithFormat:@"%i",nowPage]];
		}
		if ([marksArray containsObject:[NSString stringWithFormat:@"%i",nowPage-1]]) {
			[marksArray removeObject:[NSString stringWithFormat:@"%i",nowPage-1]];
		}
		if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",nowPage-1,nowPage]]) {
			[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",nowPage-1,nowPage]];
		}
		if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",nowPage,nowPage+1]]) {
			[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",nowPage,nowPage+1]];
		}
		string = [NSString stringWithFormat:@"%i-%i",nowPage-1,nowPage];
		[marksArray addObject:string];
		if (readMode > 1) {
			[NSThread detachNewThreadSelector:@selector(lookahead) toTarget:self withObject:nil];
		} else {
			[NSThread detachNewThreadSelector:@selector(lookaheadAndCompose) toTarget:self withObject:nil];
		}
	}
	[self setPageTextField];
	
	if (rememberBookSettings && [marksArray count] > 0) {
		[currentBookSetting setObject:marksArray forKey:@"marks"];
	}
	
}


static NSTimer* dontSleepTimer = nil;

-(IBAction)slideshow:(id)sender
{
	if ([window isVisible]) {		
		[NSCursor setHiddenUntilMouseMoves:YES];
		if (timerSwitch) {
			[dontSleepTimer invalidate];
			dontSleepTimer = nil;
			[timer invalidate];
			timerSwitch=NO;
			[imageView setSlideshow:NO];
		} else {
			timer = [NSTimer scheduledTimerWithTimeInterval:sliderValue
													 target:self
												   selector:@selector(doSlideshow)
												   userInfo:NULL
													repeats:YES];
			timerSwitch=YES;
			if (dontSleepTimer == nil) {
				dontSleepTimer = [NSTimer scheduledTimerWithTimeInterval:25.0
																  target:self
																selector:@selector(dontSleep)
																userInfo:NULL
																 repeats:YES];
			}
			[imageView setSlideshow:YES];
		}
	}
}

-(void)doSlideshow
{
	[lock lock];
	[lock unlock];
	useComposedImage = YES;
	[self imageDisplay];
}

-(void)dontSleep
{
	UpdateSystemActivity( OverallAct );
	//UpdateSystemActivity( UsrActivity );
}

- (void)switchSingleWithPage:(int)page
{
	//NSLog(@"single %i,%i",page,nowPage);
	if (page == nowPage-1) {
		[self switchSingle:nil];
		return;
	}
	NSString *string;
	if ([marksArray containsObject:[NSString stringWithFormat:@"%i",page]]) {
		[marksArray removeObject:[NSString stringWithFormat:@"%i",page]];
	}
	if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",page-1,page]]) {
		[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",page-1,page]];
	}
	if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",page,page+1]]) {
		[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",page,page+1]];
	}
	string = [NSString stringWithFormat:@"%i",page];
	[marksArray addObject:string];
	
	if (rememberBookSettings && [marksArray count] > 0) {
		[currentBookSetting setObject:marksArray forKey:@"marks"];
	}
}

- (void)switchBindWithPage:(int)page
{
	//NSLog(@"bind %i,%i",page,nowPage);
	if (page == nowPage) {
		[self switchSingle:nil];
		return;
	}
	NSString *string;
	if (page == [completeMutableArray count]) {
		if ([marksArray containsObject:[NSString stringWithFormat:@"%i",page-1]]) {
			[marksArray removeObject:[NSString stringWithFormat:@"%i",page-1]];
		}
		string = [NSString stringWithFormat:@"%i-%i",page-1,page];
	} else {
		string = [NSString stringWithFormat:@"%i-%i",page,page+1];
	}
	if ([marksArray containsObject:[NSString stringWithFormat:@"%i",page]]) {
		[marksArray removeObject:[NSString stringWithFormat:@"%i",page]];
	}
	if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",page-1,page]]) {
		[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",page-1,page]];
	}
	if ([marksArray containsObject:[NSString stringWithFormat:@"%i-%i",page,page+1]]) {
		[marksArray removeObject:[NSString stringWithFormat:@"%i-%i",page,page+1]];
	}
	
	[marksArray addObject:string];
	
	if (rememberBookSettings && [marksArray count] > 0) {
		[currentBookSetting setObject:marksArray forKey:@"marks"];
	}
	
}

- (BOOL)removeBookmarkWithPage:(int)page
{	
	BOOL result = NO;
	if ([self isBookmarkedPage:page]) {
		result = YES;
	}
	
	if (!result) return result;
	
	id bookmark;
	int index;
	for (index=0; index<[bookmarkArray count]; index++) {
		bookmark = [bookmarkArray objectAtIndex:index];
		if ([[bookmark objectForKey:@"page"] intValue] == page) {
			[bookmarkArray removeObject:bookmark];
		}
	}
	
	[self setBookmarkMenu];
	return result;
}

- (void)addBookmarkWithPage:(int)page
{
	int bookmarkCount = [bookmarkArray count];
	NSString *bookmarkCountName = [NSString stringWithFormat:@"bookmark%d",bookmarkCount + 1];
	NSString *bookmarkNowPageString = [NSString stringWithFormat:@"%d",page];
	
	NSDictionary *bookmarkDic = [NSDictionary dictionaryWithObjectsAndKeys:
		bookmarkCountName, @"name",
		bookmarkNowPageString, @"page",
		nil];
	
	
	[bookmarkArray addObject:bookmarkDic];	
	[self setBookmarkMenu];
}
- (void)trashLeft
{
	int i;
	if (!secondImage) {
		i = nowPage - 1;
	} else {
		i = nowPage - 1;
	}
	[self trashFile:[imageLoader itemPathAtIndex:i]];
}
- (void)trashRight
{
	int i;
	if (!secondImage) {
		i = nowPage - 1;
	} else {
		i = nowPage - 2;
	}
	[self trashFile:[imageLoader itemPathAtIndex:i]];
	
	
}
- (void)trashFile:(NSString*)path
{
	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Do you really want to move %@ to the trash?",@""),
		[path lastPathComponent]];
	int result = NSRunAlertPanel(NSLocalizedString(@"Move to Trash",@""),
								 message,
								 NSLocalizedString(@"OK",@""), 
								 NSLocalizedString(@"Cancel",@""), 
								 nil);
	
	if(result == NSAlertDefaultReturn || result == NSAlertFirstButtonReturn) {
		BOOL b = NO;
		b = [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
														 source:[path stringByDeletingLastPathComponent]
													destination: @""
														  files: [NSArray arrayWithObject:[path lastPathComponent]]
															tag: nil];
		if(!b) {
			NSAppleScript*          script;
			NSAppleEventDescriptor* desc;
			NSDictionary*           error;
			NSString *string;
			//string = [NSString stringWithFormat:@"tell application \"Finder\" to delete POSIX file \"%@\"", [path precomposedStringWithCompatibilityMapping]]; 
			string = [NSString stringWithFormat:@"tell application \"Finder\" to delete selection"];
			script = [[NSAppleScript alloc] initWithSource:string];
			[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];
			desc = [script executeAndReturnError:&error];
			//NSLog(@"1 %@ %@",desc,error);
			[script release];
			string = [NSString stringWithFormat:@"tell application \"cooViewer\" to activate"]; 
			script = [[NSAppleScript alloc] initWithSource:string];
			desc = [script executeAndReturnError:&error];
			//NSLog(@"2 %@ %@",desc,error);
			[script release];
			
		}
	}
}
@end
