#import "CustomImageView.h"
#import "NSBezierPath_Adding.h"
#import "NSAttributedString_Adding.h"
#import "AccessoryView.h"
//#import "QuartzCore/CIFilter.h"

@interface CustomImageView(private)
-(void)setUrlRect;
-(NSURL*)urlWithPoint:(NSPoint)pt;
@end

@implementation CustomImageView
-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(filterValueDidChange:)
                                                 name:@"FilterUIValueDidChange"
                                               object:nil];
}
- (void)setTarget:(id)tar
{
	target = tar;
}

- (void)viewDidEndLiveResize
{
	[super viewDidEndLiveResize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidEndLiveResize" object:self];
}

#pragma mark preferences
- (void)setPreferences
{
	if (!didFirst) {
		didFirst = YES;
		[accessoryWindow setBackgroundColor:[NSColor clearColor]];
		//[accessoryWindow setBackgroundColor:[[NSColor grayColor] colorWithAlphaComponent:0.5]];
		[accessoryWindow setOpaque:NO];
		[accessoryWindow setIgnoresMouseEvents:YES];
		NSRect temp = [[[self window] contentView] frame];
		temp.origin = [[self window] frame].origin;
		[accessoryWindow setFrame:temp display:YES];
		[[self window] addChildWindow:accessoryWindow ordered:NSWindowAbove];
//		[accessoryWindow orderFront:self];
		
		dragScrollDic = [[NSMutableDictionary alloc] init];
		fitScreenMode = 0;
		setting = 0;
		inDragScroll = NO;
		didDragScroll = NO;
		startFromEnd = NO;
		
		tempPageNum = 0;
		rotateMode = 0;
		
		urlRectArray = [[NSMutableArray alloc] init];
	} else {
		[dragScrollDic removeAllObjects];
	}
	[accessoryView setPreferences];
	

	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	
	maxEnlargement = [target maxEnlargement];
	
	
	lensSize=(int)[defaults integerForKey:@"LoupeSize"];
	lensRate=[defaults floatForKey:@"LoupeRate"];
	
	[self display];
}
-(void)setInterpolation:(int)index
{
	interpolation = index;
}
-(void)setDragScroll:(NSArray*)array mode:(int)mode
{
	[dragScrollDic setObject:array forKey:[NSString stringWithFormat:@"%i",mode]];
}
-(void)setStartFromEnd:(BOOL)boo
{
	startFromEnd = boo;
}


#pragma mark mouse
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	[self mouseDown:theEvent];
	return nil;
}

- (void)mouseMoved:(NSEvent *)theEvent
{	
	[self drawLoupe];
	if (!lensWindow && !NSContainsRect([[[self window] contentView] frame],[self frame]) && ![accessoryView isMouseInPageBar]) {
		[NSCursor pop];
	}
	[[self window] invalidateCursorRectsForView: self];
	[accessoryView mouseMoved:theEvent];
	//[self resetCursorRects];
	//[self resetCursorRects];
}


- (void)dragScroll:(NSEvent *)event
{
	float newY =  [event locationInWindow].y - oldPoint.y;
	float newX = [event locationInWindow].x - oldPoint.x;
	[self scrollTo:NSMakePoint(newX,newY)];
	oldPoint=[event locationInWindow];
}

- (void)otherMouseDragged:(NSEvent *)event
{
	[self mouseDragged:event];
}
- (void)otherMouseDown:(NSEvent *)event
{
	[self mouseDown:event];
}
- (void)otherMouseUp:(NSEvent *)event
{
	[self mouseUp:event];
}


-(void)mouseDown:(NSEvent *)event
{
	time = [event timestamp];
	cursorMoved = NSMakePoint(0,0);
	oldPoint=[event locationInWindow];
	
	int button = (int)[event buttonNumber];
	
	unsigned int cMod = 100;
	if (([event modifierFlags] & NSShiftKeyMask))
		cMod += 1;
	if (([event modifierFlags] & NSAlternateKeyMask))
		cMod += 2;
	if (([event modifierFlags] & NSControlKeyMask))
		cMod += 4;
	
	NSArray *array =[dragScrollDic objectForKey:[NSString stringWithFormat:@"%i",fitScreenMode]];
	NSEnumerator *enu = [array objectEnumerator];
	id object;
	while (object = [enu nextObject]) {
		if (button == [[object objectForKey:@"button"] intValue] && cMod == [[object objectForKey:@"modifier"] intValue]){
			inDragScroll = YES;
			if (!lensWindow && ![accessoryView isMouseInPageBar]) {
				[[NSCursor closedHandCursor] set];
			} 
		}
	}
}

- (void)mouseDragged:(NSEvent *)event
{	
	if (inDragScroll) {
		[self dragScroll:event];
		didDragScroll = YES;
		return;
	}
	float newY = [event locationInWindow].y - oldPoint.y;
	float newX = [event locationInWindow].x - oldPoint.x;
	cursorMoved = NSMakePoint(newY,newX);
}

-(void)mouseUp:(NSEvent *)event
{	
	if (inDragScroll) {
		if (!lensWindow && !NSContainsRect([[[self window] contentView] frame],[self frame]) && ![accessoryView isMouseInPageBar]) {
			[NSCursor pop];
		} 
		inDragScroll = NO;
		if (didDragScroll) {
			didDragScroll = NO;
			return;
		}
	}
	if ([event timestamp] - time > 1){
		return;
	}
	
	
	if (cursorMoved.y < -30 || cursorMoved.y > 30 || cursorMoved.x > 30 || cursorMoved.x < -30) {
		float lr=0;
		float ud=0;
		if (cursorMoved.y < -30) {
			lr = -1*cursorMoved.y;
		}
		if (cursorMoved.y > 30) {
			lr = cursorMoved.y;
		}
		if (cursorMoved.x > 30) {
			ud = cursorMoved.x;
		}
		if (cursorMoved.x < -30) {
			ud = -1*cursorMoved.x;
		}
		if (ud > lr) {
			if (cursorMoved.x > 30) {
				//up
				[target gestureAction:event moved:2];
			} else if (cursorMoved.x < -30) {
				//down
				[target gestureAction:event moved:3];
			}
		} else {
			if (cursorMoved.y < -30) {
				//left
				[target gestureAction:event moved:0];
			} else if (cursorMoved.y > 30) {
				//right
				[target gestureAction:event moved:1];
			}
		}
	} else {
		if (NSPointInRect([event locationInWindow], [accessoryView pageBarRect])){
			if ([target indicator] && ![lensWindow isVisible]) {
				NSPoint tempPoint = [event locationInWindow];
				NSRect tempRect = NSInsetRect([accessoryView pageBarRect],2,2);
				float temp = tempPoint.x - tempRect.origin.x;
				if (![target readFromLeft]) {
					temp = tempRect.size.width - temp-1;
				}
				temp = temp/tempRect.size.width;		
				[target goToPar:temp];
			} else {
				[target mouseAction:event];
			}
		} else {
			if ([event buttonNumber]==0) {
				NSURL *url = [self urlWithPoint:[event locationInWindow]];
				if (url!=nil) {
					[target openLink:url];
					cursorMoved = NSMakePoint(0,0);
					return;
				}
			}
			[target mouseAction:event];
		}
	}
	cursorMoved = NSMakePoint(0,0);
}


-(void)rightMouseDown:(NSEvent *)event
{
	[self mouseDown:event];
	/*
	rightClick = YES;
	time = [event timestamp];
	cursorMoved = NSMakePoint(0,0);
	oldPoint=[event locationInWindow];
	
	[super rightMouseDown:event];
	*/
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
	[self mouseDragged:theEvent];
}
- (void)rightMouseUp:(NSEvent *)theEvent
{
	[self mouseUp:theEvent];
}

- (void)beginGestureWithEvent:(NSEvent *)event
{
//  NSLog(@"beginGestureWithEvent %@",event);
	mt_rotation = 0;
	mt_deltaZ = 0;
	mt_didAction = NO;
}
- (void)endGestureWithEvent:(NSEvent *)event
{
//	NSLog(@"endGestureWithEvent %@",event);
//	NSLog(@"mt_rotation = %f",mt_rotation);
//	NSLog(@"mt_deltaZ = %f",mt_deltaZ);
}

- (void)magnifyWithEvent:(NSEvent *)event
{
//  NSLog(@"magnification=%f",[event magnification]);
    if ([event phase] == NSEventPhaseBegan) {
        mt_rotation = 0;
        mt_deltaZ = 0;
        mt_didAction = NO;
    }
	if (mt_didAction == NO) {
		mt_deltaZ += [event magnification];
		if (mt_deltaZ<-0.2) {
			[target multiTouchAction:event action:4];
			mt_didAction = YES;
		} else if (mt_deltaZ>0.2) {
			[target multiTouchAction:event action:5];
			mt_didAction = YES;
		}
	}
}

- (void)rotateWithEvent:(NSEvent *)event
{
//  NSLog(@"rotation=%f",[event rotation]);
    if ([event phase] == NSEventPhaseBegan) {
        mt_rotation = 0;
        mt_deltaZ = 0;
        mt_didAction = NO;
    }
	if (mt_didAction == NO) {
		mt_rotation += [event rotation];
		if (mt_rotation<-15) {
			[target multiTouchAction:event action:6];
			mt_didAction = YES;
		} else if (mt_rotation>15) {
			[target multiTouchAction:event action:7];
			mt_didAction = YES;
		}
	}
	
}

- (void)swipeWithEvent:(NSEvent *)event
{
//  NSLog(@"deltaX=%f,deltaY=%f",[event deltaX],[event deltaY]);
    if ([event phase] == NSEventPhaseBegan) {
        mt_rotation = 0;
        mt_deltaZ = 0;
        mt_didAction = NO;
    }
	if ([event deltaX]<0) {
		[target multiTouchAction:event action:0];
	} else if ([event deltaX]>0) {
		[target multiTouchAction:event action:1];
	} else if ([event deltaY]<0) {
		[target multiTouchAction:event action:2];
	} else if ([event deltaY]>0) {
		[target multiTouchAction:event action:3];
	}
}

#pragma mark scroll

- (void)scrollWheel:(NSEvent *)theEvent
{
	[target wheelAction:theEvent];
}

-(void)wheelSetting:(float)set
{
	setting = set;
}


-(BOOL)firstScroll
{
	if (fitScreenMode == 0) return false;
	
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) return false;
	float x,y;
	if (startFromEnd) {
		if ([target readFromLeft]) {
			x = [clipView documentRect].size.width - [clipView documentVisibleRect].size.width;
			y = 0;
		} else {
			x = 0;
			y = 0;
		}
		startFromEnd = NO;
	} else {
		if ([target readFromLeft]) {
			x = 0;
			y = [clipView documentRect].size.height - [clipView documentVisibleRect].size.height;
		} else {
			x = [clipView documentRect].size.width - [clipView documentVisibleRect].size.width;
			y = [clipView documentRect].size.height - [clipView documentVisibleRect].size.height;
		}
	}
	if (x < 0) x = 0;
	if (y < 0) y = 0;
	if ((x + [clipView documentVisibleRect].size.width) > [clipView documentRect].size.width) {
		x = ([clipView documentRect].size.width - [clipView documentVisibleRect].size.width);
	}
	if ((y + [clipView documentVisibleRect].size.height) > [clipView documentRect].size.height) {
		y = ([clipView documentRect].size.height - [clipView documentVisibleRect].size.height);
	}
	if (x == [self visibleRect].origin.x && y == [self visibleRect].origin.y) {
		return NO;
	}
	[self _scrollToPoint:NSMakePoint(x,y)];
	return YES;
}

-(void)scrollToPoint:(NSPoint)newOrigin
{
	//scrollupとか。newOriginまで動かす。
	if (fitScreenMode == 0) return;
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) return;
	
	float x = newOrigin.x;
	float y = newOrigin.y;
	if (x < 0) x = 0;
	if (y < 0) y = 0;
	if ((x + [clipView documentVisibleRect].size.width) > [clipView documentRect].size.width) {
		x = ([clipView documentRect].size.width - [clipView documentVisibleRect].size.width);
	}
	if ((y + [clipView documentVisibleRect].size.height) > [clipView documentRect].size.height) {
		y = ([clipView documentRect].size.height - [clipView documentVisibleRect].size.height);
	}
	if (x == [self visibleRect].origin.x && y == [self visibleRect].origin.y) {
		return;
	}
	[self _scrollToPoint:NSMakePoint(x,y)];
}


- (BOOL)scrollTo:(NSPoint)point
{
	//ドラッグスクロールとかキー操作。point分動かす
	if (fitScreenMode == 0) return YES;
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) return YES;
	
	NSPoint visiblePoint = [clipView documentVisibleRect].origin;
	float newY = visiblePoint.y - point.y;
	float newX = visiblePoint.x - point.x;
	if (newY < 0) newY = 0;
	if (newX < 0) newX = 0;
	if (newX > [self bounds].size.width - [clipView documentVisibleRect].size.width){
		newX = [self bounds].size.width - [clipView documentVisibleRect].size.width;
	}
	if (newY > [self bounds].size.height - [clipView documentVisibleRect].size.height) {
		newY = [self bounds].size.height - [clipView documentVisibleRect].size.height;
	}
	if (newY < 0) newY = 0;
	if (newX < 0) newX = 0;
	newX = (int)newX;
	newY = (int)newY;
	
	if (point.x == 0 && newY == [self visibleRect].origin.y) {
		return YES;
	} else if (newX == [self visibleRect].origin.x && newY == [self visibleRect].origin.y) {
		return NO;
	}
	[self _scrollToPoint:NSMakePoint(newX,newY)];
	return NO;
}

NSTimeInterval elapsed=0;
- (void)_scrollToPoint:(NSPoint)point
{
	/*
	NSTimeInterval start,stop;
	start=[NSDate timeIntervalSinceReferenceDate];
	*/
	
	
	NSClipView *clipView = [[self enclosingScrollView] contentView];
	
	[clipView scrollToPoint:point];
	//[self setNeedsDisplayInRect:[self visibleRect]];
	//[self displayIfNeededInRect:[self visibleRect]];
	 
	/*
	stop=[NSDate timeIntervalSinceReferenceDate];
	elapsed+=stop-start;
	NSLog(@"%f",elapsed);
	*/
}

- (void)scrollUp
{
	if (fitScreenMode == 0) {
		return;
	}
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return;
	}
	float x = [clipView documentVisibleRect].origin.x;
	float y = [clipView documentVisibleRect].origin.y + [clipView documentVisibleRect].size.height;
	float max = [clipView documentRect].size.height - [clipView documentVisibleRect].size.height;
	if (y > max) {
		y = max;
	}
	[self scrollToPoint:NSMakePoint(x,y)];
}

- (void)scrollDown
{
	if (fitScreenMode == 0) return;
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return;
	}
	float x = [clipView documentVisibleRect].origin.x;
	float y = [clipView documentVisibleRect].origin.y - [clipView documentVisibleRect].size.height;
	if (y < 0) {
		y = 0;
	}
	[self scrollToPoint:NSMakePoint(x,y)];
}

- (void)scrollToTop
{
	if (fitScreenMode == 0) return;
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) return;
	
	float x,y;
	if ([target readFromLeft]) {
		x = 0;
		y = [clipView documentRect].size.height - [clipView documentVisibleRect].size.height;
	} else {
		x = [clipView documentRect].size.width - [clipView documentVisibleRect].size.width;
		y = [clipView documentRect].size.height - [clipView documentVisibleRect].size.height;
	}
	[self scrollToPoint:NSMakePoint(x,y)];
}

- (void)scrollToLast
{
	if (fitScreenMode == 0) return;
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return;
	}
	float x,y;
	if ([target readFromLeft]) {
		x = [clipView documentRect].size.width - [clipView documentVisibleRect].size.width;
		y = 0;
	} else {
		x = 0;
		y = 0;
	}
	[self scrollToPoint:NSMakePoint(x,y)];
}

- (BOOL)next
{
	if (fitScreenMode == 0) {
		return YES;
	}
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return YES;
	}
	if ([target readFromLeft]) {
		if ([clipView documentVisibleRect].origin.y == 0) {
			if ([clipView documentVisibleRect].origin.x == ([clipView documentRect].size.width - [clipView documentVisibleRect].size.width)) {
				return YES;
			} else {
				float x,y;
				x = [clipView documentVisibleRect].origin.x + [clipView documentVisibleRect].size.width;
				y = [clipView documentRect].size.height - [clipView documentVisibleRect].size.height;
				[self scrollToPoint:NSMakePoint(x,y)];
				return NO;
			}
		} else {
			[self scrollDown];
			return NO;
		}
	} else {
		if ([clipView documentVisibleRect].origin.y == 0) {
			if ([clipView documentVisibleRect].origin.x == 0) {
				return YES;
			} else {
				float x,y;
				x = [clipView documentVisibleRect].origin.x - [clipView documentVisibleRect].size.width;
				y = [clipView documentRect].size.height - [clipView documentVisibleRect].size.height;
				[self scrollToPoint:NSMakePoint(x,y)];
				return NO;
			}
		} else {
			[self scrollDown];
			return NO;
		}
	}
	return NO;
}

- (BOOL)prev
{
	if (fitScreenMode == 0) {
		return YES;
	}
	NSScrollView *scrollView = [self enclosingScrollView];
	NSClipView *clipView = [scrollView contentView];
	if (NSEqualRects([clipView documentVisibleRect],[clipView documentRect])) {
		return YES;
	}
	if ([target readFromLeft]) {
		if ([clipView documentVisibleRect].origin.y == ([clipView documentRect].size.height - [clipView documentVisibleRect].size.height)) {
			if ([clipView documentVisibleRect].origin.x == 0) {
				return YES;
			} else {
				float x,y;
				x = [clipView documentVisibleRect].origin.x - [clipView documentVisibleRect].size.width;
				y = 0;
				[self scrollToPoint:NSMakePoint(x,y)];
				return NO;
			}
		} else {
			[self scrollUp];
			return NO;
		}
	} else {
		if ([clipView documentVisibleRect].origin.y == ([clipView documentRect].size.height - [clipView documentVisibleRect].size.height)) {
			if ([clipView documentVisibleRect].origin.x == ([clipView documentRect].size.width - [clipView documentVisibleRect].size.width)) {
				return YES;
			} else {
				float x,y;
				x = [clipView documentVisibleRect].origin.x + [clipView documentVisibleRect].size.width;
				y = 0;
				[self scrollToPoint:NSMakePoint(x,y)];
				return NO;
			}
		} else {
			[self scrollUp];
			return NO;
		}
	}
}




#pragma mark image
-(NSImage *)image
{
	return _image;
}
/*
 -(void)display
 {
	 [self displayRect:[self visibleRect]];
 }
 */

-(void)setImage:(NSImage *)image
{		
	images = NO;
	[_image autorelease];
	_image = [image retain];
    if (image == nil) {
        [super setImage:_image];
        return;
    }
    [self imageDisplay];
}

-(void)setImages:(NSImage *)image
{
	images = YES;
	[_image autorelease];
	_image = [image retain];
    if (image == nil) {
        [super setImage:_image];
        return;
    }
    [self imageDisplay];
}

-(void)imageDisplay
{
    if ([[[self layer] sublayers] count]==0) {
        fLayer = [[CALayer alloc] init];
        sLayer = [[CALayer alloc] init];
        [[self layer] addSublayer:fLayer];
        [[self layer] addSublayer:sLayer];
        [fLayer setSpeed:1];
        [sLayer setSpeed:1];
        [fLayer setContentsScale:[[NSScreen mainScreen] backingScaleFactor]];
        [sLayer setContentsScale:[[NSScreen mainScreen] backingScaleFactor]];
        [fLayer setShouldRasterize:YES];
        [sLayer setShouldRasterize:YES];
        [fLayer setRasterizationScale:2];
        [sLayer setRasterizationScale:2];
        [fLayer setMinificationFilter:kCAFilterLinear];
        [sLayer setMinificationFilter:kCAFilterLinear];
        [fLayer setMagnificationFilter:kCAFilterLinear];
        [sLayer setMagnificationFilter:kCAFilterLinear];
        [fLayer setContentsGravity:kCAGravityResize];
        [sLayer setContentsGravity:kCAGravityResize];
        
        /*
        //CoreImage Filterも使えるよ！
        CIFilter *sepiaFilter = [CIFilter filterWithName:@"CISepiaTone"];
        [sepiaFilter setValue:[NSNumber numberWithFloat:0.8] forKey:@"inputIntensity"];
        [sLayer setFilters:[NSArray arrayWithObject:sepiaFilter]];
        [fLayer setFilters:[NSArray arrayWithObject:sepiaFilter]];
        */
        
        /*
        [fLayer setBorderColor:CGColorCreateGenericRGB(1, 0, 0, 1)];
        [fLayer setBorderWidth:3];
        [sLayer setBorderColor:CGColorCreateGenericRGB(0, 1, 0, 1)];
        [sLayer setBorderWidth:3];
        */
    }
    if (![accessoryWindow isVisible]) [accessoryWindow orderFront:self];
    if (fitScreenMode > 0) {
        if (images) {
            NSDictionary *infodic = [self getDrawImagesInfo:[target image1] and:[target image2]];
            NSSize frameSize = NSSizeFromString([infodic objectForKey:@"frameSize"]);
            [self setFrameSize:frameSize];
            [self firstScroll];
            [self setNeedsDisplayInRect:[self frame]];
        } else {
            NSDictionary *infodic = [self getDrawImageInfo:_image];
            NSSize frameSize = NSSizeFromString([infodic objectForKey:@"frameSize"]);
            [self setFrameSize:frameSize];
            [self firstScroll];
            [self setNeedsDisplayInRect:[self frame]];
        }
    } else {
    }
    if (images) {
        [self drawImages:[target image1] and:[target image2]];
    } else {
        //single & oldscroll
        [self drawImage:_image];
    }
    [accessoryView drawAccessory];
//    [self displayIfNeededInRect:[self visibleRect]];
//    [accessoryView displayIfNeeded];
}

- (void)filterValueDidChange:(NSNotification *)aNotification
{
    [sLayer setFilters:nil];
    [fLayer setFilters:nil];
    [sLayer setFilters:[aNotification object]];
    [fLayer setFilters:[aNotification object]];
}

#pragma mark draw

-(void)drawRect:(NSRect)frameRect
{
    [super drawRect:frameRect];
    if ([self inLiveResize]) {
        [self imageDisplay];
    }
    
	if (lensWindow) [self drawLoupe];
}

- (NSMutableDictionary *)getDrawImageInfo:(NSImage*)image
{
    NSMutableDictionary *infodic = [NSMutableDictionary dictionary];
    
    int widthValue,heightValue;
    if (rotateMode==1||rotateMode==3) {
        widthValue = [image size].height;
        heightValue = [image size].width;
    } else {
        widthValue = [image size].width;
        heightValue = [image size].height;
    }

    float screenWidthValue = NSWidth([[[self window] contentView] frame]);
    float screenHeightValue = NSHeight([[[self window] contentView] frame]);
    
    float x,y,width,height;
    if (fitScreenMode == 1) {
        float rate = screenWidthValue/widthValue;
        if (maxEnlargement != 0 && rate > maxEnlargement) {
            rate = maxEnlargement;
        }
        width = widthValue*rate;
        height = heightValue*rate;
        x = screenWidthValue-width;
        x = x/2;
        y = screenHeightValue-height;
        y = y/2;
        if (height < screenHeightValue) {
            [infodic setObject:NSStringFromSize(NSMakeSize(screenWidthValue,screenHeightValue)) forKey:@"frameSize"];
        } else {
            [infodic setObject:NSStringFromSize(NSMakeSize(screenWidthValue,(int)height)) forKey:@"frameSize"];
            y = 0;
        }
    } else if (fitScreenMode == 2) {
        width = widthValue;
        height = heightValue;
        x = screenWidthValue-width;
        x = x/2;
        y = screenHeightValue-height;
        y = y/2;
        
        if (height < screenHeightValue) {
            if (width < screenWidthValue) {
                [infodic setObject:NSStringFromSize(NSMakeSize(screenWidthValue,screenHeightValue)) forKey:@"frameSize"];
            } else {
                [infodic setObject:NSStringFromSize(NSMakeSize((int)width,screenHeightValue)) forKey:@"frameSize"];
                x = 0;
            }
            //y = 0;
        } else {
            if (width < screenWidthValue) {
                [infodic setObject:NSStringFromSize(NSMakeSize((int)screenWidthValue,(int)height)) forKey:@"frameSize"];
            } else {
                [infodic setObject:NSStringFromSize(NSMakeSize((int)width,(int)height)) forKey:@"frameSize"];
                x = 0;
            }
            y = 0;
        }
    } else if (fitScreenMode == 3) {
        if ([target isSmallImage:image page:-1] || (rotateMode==1||rotateMode==3)) {
            //(readmode:single && smallImage) || (90回転)
            //とりあえずfitScreenMode==1と同じ
            float rate = screenWidthValue/widthValue;
            if (maxEnlargement != 0 && rate > maxEnlargement) {
                rate = maxEnlargement;
            }
            width = widthValue*rate;
            height = heightValue*rate;
            x = screenWidthValue-width;
            x = x/2;
            y = screenHeightValue-height;
            y = y/2;
            if (height < screenHeightValue) {
                [infodic setObject:NSStringFromSize(NSMakeSize(screenWidthValue,screenHeightValue)) forKey:@"frameSize"];
            } else {
                [infodic setObject:NSStringFromSize(NSMakeSize(screenWidthValue,(int)height)) forKey:@"frameSize"];
                y = 0;
            }
        } else {
            float rate = screenWidthValue/(widthValue/2);
            if (maxEnlargement != 0 && rate > maxEnlargement) {
                rate = maxEnlargement;
            }
            width = widthValue*rate;
            height = heightValue*rate;
            x = screenWidthValue*2-width;
            x = x/2;
            y = screenHeightValue-height;
            y = y/2;
            if (height < screenHeightValue) {
                [infodic setObject:NSStringFromSize(NSMakeSize(screenWidthValue*2,screenHeightValue)) forKey:@"frameSize"];
            } else {
                [infodic setObject:NSStringFromSize(NSMakeSize(screenWidthValue*2,(int)height)) forKey:@"frameSize"];
                y = 0;
                x = 0;
            }
        }
    } else {
        float rate = screenWidthValue/widthValue;
        float sRate = screenHeightValue/heightValue;
        if (rate > sRate) {
            rate = sRate;
        }
        if (maxEnlargement != 0 && rate > maxEnlargement) {
            rate = maxEnlargement;
        }
        width = widthValue*rate;
        height = heightValue*rate;
        x = screenWidthValue-width;
        x = x/2;
        y = screenHeightValue-height;
        y = y/2;
    }
    NSRect drawRect;
    if (rotateMode==1||rotateMode==3) {
        drawRect = NSMakeRect((int)y,(int)x,(int)height,(int)width);
    } else {
        drawRect = NSMakeRect((int)x,(int)y,(int)width,(int)height);
    }
    [infodic setObject:[NSString stringWithFormat:@"%f",x] forKey:@"x"];
    [infodic setObject:[NSString stringWithFormat:@"%f",y] forKey:@"y"];
    [infodic setObject:[NSString stringWithFormat:@"%f",width] forKey:@"width"];
    [infodic setObject:[NSString stringWithFormat:@"%f",height] forKey:@"height"];
    [infodic setObject:NSStringFromRect(drawRect) forKey:@"drawRect"];
    return infodic;
}
- (void)drawImage:(NSImage*)image
{
    NSDictionary *infodic = [self getDrawImageInfo:image];
    NSRect drawRect = NSRectFromString([infodic objectForKey:@"drawRect"]);
    
    CGAffineTransform cgtransform;
    switch (rotateMode) {
        case 1:
            cgtransform = CGAffineTransformMakeTranslation(NSWidth([self bounds]),0);
            cgtransform = CGAffineTransformRotate(cgtransform, 90 / 180.0 * M_PI);
            break;
        case 2:
            cgtransform = CGAffineTransformMakeTranslation(NSWidth([self bounds]),NSHeight([self bounds]));
            cgtransform = CGAffineTransformRotate(cgtransform, 180 / 180.0 * M_PI);
            break;
        case 3:
            cgtransform = CGAffineTransformMakeTranslation(0,NSHeight([self bounds]));
            cgtransform = CGAffineTransformRotate(cgtransform, 270 / 180.0 * M_PI);
            break;
        default:
            cgtransform = CGAffineTransformMakeTranslation(0,0);
            cgtransform = CGAffineTransformRotate(cgtransform, 360 / 180.0 * M_PI);
            break;
    }
    drawRect = COIntRect(CGRectApplyAffineTransform(drawRect, cgtransform));
    [sLayer setFrame:drawRect];
    [sLayer setContents:nil];
    [sLayer setHidden:YES];
    [sLayer removeAllAnimations];
    [fLayer setAffineTransform:cgtransform];
    [fLayer setFrame:drawRect];
    [fLayer setContents:image];
    [fLayer removeAllAnimations];
    

    
    float x = [[infodic objectForKey:@"x"] floatValue];
    float y = [[infodic objectForKey:@"y"] floatValue];
    float width = [[infodic objectForKey:@"width"] floatValue];
    float height = [[infodic objectForKey:@"height"] floatValue];
	fRect = NSMakeRect((int)x,(int)y,(int)width,(int)height);
	sRect = NSZeroRect;
}

- (NSMutableDictionary *)getDrawImagesInfo:(NSImage*)image1 and:(NSImage*)image2
{
    NSMutableDictionary *infodic = [NSMutableDictionary dictionary];
    
    NSRect fullscreenRect,leftRect,rightRect;
    fullscreenRect = [[[self window] contentView] frame];
    if (rotateMode==1||rotateMode==3) {
        fullscreenRect = NSMakeRect(fullscreenRect.origin.x,fullscreenRect.origin.y,fullscreenRect.size.height,fullscreenRect.size.width);
    }
    
    int w = fullscreenRect.size.width;
    if (w%2) {
        fullscreenRect = NSMakeRect(fullscreenRect.origin.x,fullscreenRect.origin.y,fullscreenRect.size.width-1,fullscreenRect.size.height);
    }
    int h = fullscreenRect.size.height;
    if (h%2) {
        fullscreenRect = NSMakeRect(fullscreenRect.origin.x,fullscreenRect.origin.y,fullscreenRect.size.width,fullscreenRect.size.height-1);
    }
    NSDivideRect (fullscreenRect, &leftRect, &rightRect, fullscreenRect.size.width/2, NSMinXEdge);

    
    int widthValue01 = [image1 size].width;
    int heightValue01 = [image1 size].height;
    
    int widthValue02 = [image2 size].width;
    int heightValue02 = [image2 size].height;
    
    int widthValue1 = widthValue01;
    int heightValue1 = heightValue01;
    int widthValue2 = widthValue02;
    int heightValue2 = heightValue02;
    
    float screenWidthValue = leftRect.size.width;
    float screenHeightValue = leftRect.size.height;
    
    if (fitScreenMode == 2) {
        float highest = heightValue1;
        if (heightValue2 > heightValue1) highest=heightValue2;
        
        if (rotateMode==1||rotateMode==3) {
            if (((int)widthValue1+(int)widthValue2) < fullscreenRect.size.width) {
                if (highest < screenHeightValue) {
                    [infodic setObject:NSStringFromSize(NSMakeSize((int)fullscreenRect.size.height,(int)fullscreenRect.size.width)) forKey:@"frameSize"];
                } else {
                    [infodic setObject:NSStringFromSize(NSMakeSize((int)highest,(int)fullscreenRect.size.width)) forKey:@"frameSize"];
                }
            } else {
                if (highest < screenHeightValue) {
                    [infodic setObject:NSStringFromSize(NSMakeSize((int)fullscreenRect.size.height,((int)widthValue1+(int)widthValue2))) forKey:@"frameSize"];
                } else {
                    [infodic setObject:NSStringFromSize(NSMakeSize((int)highest,((int)widthValue1+(int)widthValue2))) forKey:@"frameSize"];
                }
            }
            fullscreenRect = [self frame];
            fullscreenRect = NSMakeRect(fullscreenRect.origin.x,fullscreenRect.origin.y,fullscreenRect.size.height,fullscreenRect.size.width);
        } else {
            if (((int)widthValue1+(int)widthValue2) < fullscreenRect.size.width) {
                if (highest < screenHeightValue) {
                    [infodic setObject:NSStringFromSize(NSMakeSize((int)fullscreenRect.size.width,(int)fullscreenRect.size.height)) forKey:@"frameSize"];
                } else {
                    [infodic setObject:NSStringFromSize(NSMakeSize((int)fullscreenRect.size.width,(int)highest)) forKey:@"frameSize"];
                }
            } else {
                if (highest < screenHeightValue) {
                    [infodic setObject:NSStringFromSize(NSMakeSize(((int)widthValue1+(int)widthValue2),(int)fullscreenRect.size.height)) forKey:@"frameSize"];
                } else {
                    [infodic setObject:NSStringFromSize(NSMakeSize(((int)widthValue1+(int)widthValue2),(int)highest)) forKey:@"frameSize"];
                }
            }
            fullscreenRect = [self frame];
        }
    } else {
        float rate1 = screenWidthValue/widthValue01;
        float rate2 = screenWidthValue/widthValue02;
        float sRate1 = screenHeightValue/heightValue01;
        float sRate2 = screenHeightValue/heightValue02;
        
        if (rate1 > sRate1) rate1 = sRate1;
        if (rate2 > sRate2) rate2 = sRate2;
        if (maxEnlargement != 0 && rate1 > maxEnlargement) rate1 = maxEnlargement;
        if (maxEnlargement != 0 && rate2 > maxEnlargement) rate2 = maxEnlargement;
        
        widthValue1 = widthValue01*rate1;
        heightValue1 = heightValue01*rate1;
        widthValue2 = widthValue02*rate2;
        heightValue2 = heightValue02*rate2;
        //NSLog(@"%i,%f",widthValue2,widthValue02*rate2);
            
        if (rotateMode==1||rotateMode==3) {
            //90,270度回転
            if (fitScreenMode == 0){
                if (heightValue1 != screenHeightValue) {
                    rate1 = screenHeightValue/heightValue01;
                    if (maxEnlargement != 0 && rate1 > maxEnlargement) {
                        rate1 = maxEnlargement;
                    }
                    widthValue1 = widthValue01*rate1;
                    heightValue1 = heightValue01*rate1;
                }
                if (heightValue2 != screenHeightValue) {
                    rate2 = screenHeightValue/heightValue02;
                    if (maxEnlargement != 0 && rate2 > maxEnlargement) {
                        rate2 = maxEnlargement;
                    }
                    widthValue2 = widthValue02*rate2;
                    heightValue2 = heightValue02*rate2;
                }
                if (widthValue1+widthValue2 > fullscreenRect.size.width){
                    float rates = fullscreenRect.size.width/(widthValue1+widthValue2);
                    
                    widthValue1 = widthValue1*rates;
                    heightValue1 = heightValue1*rates;
                    widthValue2 = widthValue2*rates;
                    heightValue2 = heightValue2*rates;
                }
            } else if (fitScreenMode == 1) {
                widthValue1 = widthValue01*sRate1;
                heightValue1 = heightValue01*sRate1;
                widthValue2 = widthValue02*sRate2;
                heightValue2 = heightValue02*sRate2;
                if (maxEnlargement != 0) {
                    if (widthValue1 > (widthValue01*maxEnlargement)) {
                        widthValue1 = widthValue01;
                        heightValue1 = heightValue01;
                    }
                    if (heightValue1 > (heightValue01*maxEnlargement)) {
                        widthValue1 = widthValue01;
                        heightValue1 = heightValue01;
                    }
                    if (widthValue2 > (widthValue02*maxEnlargement)) {
                        widthValue2 = widthValue02;
                        heightValue2 = heightValue02;
                    }
                    if (heightValue2 > (heightValue02*maxEnlargement)) {
                        widthValue2 = widthValue02;
                        heightValue2 = heightValue02;
                    }
                }
                
                [infodic setObject:NSStringFromSize(NSMakeSize((int)fullscreenRect.size.height,(int)(widthValue1+widthValue2))) forKey:@"frameSize"];
                fullscreenRect = [self frame];
                fullscreenRect = NSMakeRect(fullscreenRect.origin.x,fullscreenRect.origin.y,fullscreenRect.size.height,fullscreenRect.size.width);
            } else if (fitScreenMode == 3) {
                //とりあえずfitScreenMode==1と同じ
                widthValue1 = widthValue01*sRate1;
                heightValue1 = heightValue01*sRate1;
                widthValue2 = widthValue02*sRate2;
                heightValue2 = heightValue02*sRate2;
                if (maxEnlargement != 0) {
                    if (widthValue1 > (widthValue01*maxEnlargement)) {
                        widthValue1 = widthValue01;
                        heightValue1 = heightValue01;
                    }
                    if (heightValue1 > (heightValue01*maxEnlargement)) {
                        widthValue1 = widthValue01;
                        heightValue1 = heightValue01;
                    }
                    if (widthValue2 > (widthValue02*maxEnlargement)) {
                        widthValue2 = widthValue02;
                        heightValue2 = heightValue02;
                    }
                    if (heightValue2 > (heightValue02*maxEnlargement)) {
                        widthValue2 = widthValue02;
                        heightValue2 = heightValue02;
                    }
                }
                
                [infodic setObject:NSStringFromSize(NSMakeSize((int)fullscreenRect.size.height,(int)(widthValue1+widthValue2))) forKey:@"frameSize"];
                fullscreenRect = [self frame];
                fullscreenRect = NSMakeRect(fullscreenRect.origin.x,fullscreenRect.origin.y,fullscreenRect.size.height,fullscreenRect.size.width);
            }
        } else {
            //0,180度回転
            if (heightValue1 != screenHeightValue) {
                rate1 = screenHeightValue/heightValue01;
                if (maxEnlargement != 0 && rate1 > maxEnlargement) {
                    rate1 = maxEnlargement;
                }
                widthValue1 = widthValue01*rate1;
                heightValue1 = heightValue01*rate1;
            }
            if (heightValue2 != screenHeightValue) {
                rate2 = screenHeightValue/heightValue02;
                if (maxEnlargement != 0 && rate2 > maxEnlargement) {
                    rate2 = maxEnlargement;
                }
                widthValue2 = widthValue02*rate2;
                heightValue2 = heightValue02*rate2;
            }
            if (widthValue1+widthValue2 > fullscreenRect.size.width){
                float rates = fullscreenRect.size.width/(widthValue1+widthValue2);
                
                widthValue1 = widthValue1*rates;
                heightValue1 = heightValue1*rates;
                widthValue2 = widthValue2*rates;
                heightValue2 = heightValue2*rates;
            }
            if (fitScreenMode == 1) {
                float rates = fullscreenRect.size.width/(widthValue1+widthValue2);
                widthValue1 = widthValue1*rates;
                heightValue1 = heightValue1*rates;
                widthValue2 = widthValue2*rates;
                heightValue2 = heightValue2*rates;
                if (maxEnlargement != 0) {
                    if (widthValue1 > (widthValue01*maxEnlargement)) {
                        widthValue1 = widthValue01;
                        heightValue1 = heightValue01;
                    }
                    if (heightValue1 > (heightValue01*maxEnlargement)) {
                        widthValue1 = widthValue01;
                        heightValue1 = heightValue01;
                    }
                    if (widthValue2 > (widthValue02*maxEnlargement)) {
                        widthValue2 = widthValue02;
                        heightValue2 = heightValue02;
                    }
                    if (heightValue2 > (heightValue02*maxEnlargement)) {
                        widthValue2 = widthValue02;
                        heightValue2 = heightValue02;
                    }
                }
                float highest = heightValue1;
                if (heightValue2 > heightValue1) highest=heightValue2;
                if (highest < screenHeightValue) {
                    [infodic setObject:NSStringFromSize(NSMakeSize((int)fullscreenRect.size.width,(int)fullscreenRect.size.height)) forKey:@"frameSize"];
                } else {
                    [infodic setObject:NSStringFromSize(NSMakeSize((int)fullscreenRect.size.width,(int)highest)) forKey:@"frameSize"];
                }
                fullscreenRect = [self frame];
            } else if (fitScreenMode == 3) {
                float rates = fullscreenRect.size.width/((widthValue1+widthValue2)/2);
                widthValue1 = widthValue1*rates;
                heightValue1 = heightValue1*rates;
                widthValue2 = widthValue2*rates;
                heightValue2 = heightValue2*rates;
                if (maxEnlargement != 0) {
                    if (widthValue1 > (widthValue01*maxEnlargement)) {
                        widthValue1 = widthValue01;
                        heightValue1 = heightValue01;
                    }
                    if (heightValue1 > (heightValue01*maxEnlargement)) {
                        widthValue1 = widthValue01;
                        heightValue1 = heightValue01;
                    }
                    if (widthValue2 > (widthValue02*maxEnlargement)) {
                        widthValue2 = widthValue02;
                        heightValue2 = heightValue02;
                    }
                    if (heightValue2 > (heightValue02*maxEnlargement)) {
                        widthValue2 = widthValue02;
                        heightValue2 = heightValue02;
                    }
                }
                float highest = heightValue1;
                if (heightValue2 > heightValue1) highest=heightValue2;
                if (highest < screenHeightValue) {
                    [infodic setObject:NSStringFromSize(NSMakeSize((int)fullscreenRect.size.width*2,(int)fullscreenRect.size.height)) forKey:@"frameSize"];
                } else {
                    [infodic setObject:NSStringFromSize(NSMakeSize((int)fullscreenRect.size.width*2,(int)highest)) forKey:@"frameSize"];
                }
                fullscreenRect = [self frame];
            }
            
        }
    }
    
    int height = fullscreenRect.size.height;
    int center1,center2;
    center1 = (height-heightValue1);
    center2 = (height-heightValue2);
    if (center1 >= 0) {
        center1 = center1 / 2;
    } else {
        center1 = 0;
    }
    if (center2 >= 0) {
        center2 = center2 / 2;
    } else {
        center2 = 0;
    }
    
    
    int x = fullscreenRect.size.width-widthValue1-widthValue2;
    x = x/2;
    
    if (rotateMode==1) {
        if ([target readFromLeft]) {
            fRect = NSMakeRect(center1,x,heightValue1,widthValue1);
            sRect = NSMakeRect(center2,x+widthValue1,heightValue2,widthValue2);
        } else {
            fRect = NSMakeRect(center2,x,heightValue2,widthValue2);
            sRect = NSMakeRect(center1,x+widthValue2,heightValue1,widthValue1);
        }
    } else if (rotateMode==3) {
        if ([target readFromLeft]) {
            sRect = NSMakeRect(center2,x,heightValue2,widthValue2);
            fRect = NSMakeRect(center1,x+widthValue2,heightValue1,widthValue1);
        } else {
            sRect = NSMakeRect(center1,x,heightValue1,widthValue1);
            fRect = NSMakeRect(center2,x+widthValue1,heightValue2,widthValue2);
        }
    } else if (rotateMode==2) {
        if ([target readFromLeft]) {
            fRect = NSMakeRect(x,center2,widthValue2,heightValue2);
            sRect = NSMakeRect(x+widthValue2,center1,widthValue1,heightValue1);
        } else {
            sRect = NSMakeRect(x,center1,widthValue1,heightValue1);
            fRect = NSMakeRect(x+widthValue1,center2,widthValue2,heightValue2);
        }
    } else {
        if ([target readFromLeft]) {
            fRect = NSMakeRect(x,center1,widthValue1,heightValue1);
            sRect = NSMakeRect(x+widthValue1,center2,widthValue2,heightValue2);
        } else {
            fRect = NSMakeRect(x,center2,widthValue2,heightValue2);
            sRect = NSMakeRect(x+widthValue2,center1,widthValue1,heightValue1);
        }
    }
    NSRect drawRect1;
    NSRect drawRect2;
    if ([target readFromLeft]) {
        drawRect1=NSMakeRect(x,center1,widthValue1,heightValue1);
        drawRect2=NSMakeRect(x+widthValue1,center2,widthValue2,heightValue2);
    } else {
        drawRect1=NSMakeRect(x+widthValue2,center1,widthValue1,heightValue1);
        drawRect2=NSMakeRect(x,center2,widthValue2,heightValue2);
    }
    
    [infodic setObject:[NSString stringWithFormat:@"%i",widthValue01] forKey:@"widthValue01"];
    [infodic setObject:[NSString stringWithFormat:@"%i",widthValue02] forKey:@"widthValue02"];
    [infodic setObject:[NSString stringWithFormat:@"%i",heightValue01] forKey:@"heightValue01"];
    [infodic setObject:[NSString stringWithFormat:@"%i",heightValue02] forKey:@"heightValue02"];
    [infodic setObject:NSStringFromRect(drawRect1) forKey:@"drawRect1"];
    [infodic setObject:NSStringFromRect(drawRect2) forKey:@"drawRect2"];
    [infodic setObject:NSStringFromRect(fullscreenRect) forKey:@"fullscreenRect"];
    return infodic;
}
- (void)drawImages:(NSImage*)image1 and:(NSImage*)image2
{
    NSDictionary *infodic = [self getDrawImagesInfo:image1 and:image2];
    int widthValue01 = [[infodic objectForKey:@"widthValue01"] intValue];
    int widthValue02 = [[infodic objectForKey:@"widthValue02"] intValue];
    int heightValue01 = [[infodic objectForKey:@"heightValue01"] intValue];
    int heightValue02 = [[infodic objectForKey:@"heightValue02"] intValue];
    NSRect drawRect1 = NSRectFromString([infodic objectForKey:@"drawRect1"]);
    NSRect drawRect2 = NSRectFromString([infodic objectForKey:@"drawRect2"]);
    NSRect fullscreenRect = NSRectFromString([infodic objectForKey:@"fullscreenRect"]);
    
    CGAffineTransform cgtransform;
    switch (rotateMode) {
        case 1:
            cgtransform = CGAffineTransformMakeTranslation(NSWidth([self bounds]),0);
            cgtransform = CGAffineTransformRotate(cgtransform, 90 / 180.0 * M_PI);
            break;
        case 2:
            cgtransform = CGAffineTransformMakeTranslation(NSWidth([self bounds]),NSHeight([self bounds]));
            cgtransform = CGAffineTransformRotate(cgtransform, 180 / 180.0 * M_PI);
            break;
        case 3:
            cgtransform = CGAffineTransformMakeTranslation(0,NSHeight([self bounds]));
            cgtransform = CGAffineTransformRotate(cgtransform, 270 / 180.0 * M_PI);
            break;
        default:
            cgtransform = CGAffineTransformMakeTranslation(0,0);
            cgtransform = CGAffineTransformRotate(cgtransform, 360 / 180.0 * M_PI);
            break;
    }
    drawRect1 = COIntRect(CGRectApplyAffineTransform(drawRect1, cgtransform));
    drawRect2 = COIntRect(CGRectApplyAffineTransform(drawRect2, cgtransform));
    [fLayer setContents:image1];
    [fLayer removeAllAnimations];
    [fLayer setAffineTransform:cgtransform];
    [fLayer setFrame:drawRect1];
    [fLayer removeAllAnimations];
    [sLayer setHidden:NO];
    [sLayer setContents:image2];
    [sLayer removeAllAnimations];
    [sLayer setAffineTransform:cgtransform];
    [sLayer setFrame:drawRect2];
    [sLayer removeAllAnimations];

}

#pragma mark slideshow
-(void)setSlideshow:(BOOL)b
{
	[accessoryView setSlideshow:b];
}

#pragma mark infoString
-(void)setInfoString:(NSString*)string
{
	[accessoryView setInfoString:string];
}

#pragma mark pageString
-(void)setPageString:(NSString*)string
{
	[accessoryView setPageString:string];
}

-(NSString*)pageString
{
	return [accessoryView pageString];
}

#pragma mark accessory

-(void)drawPageBar
{
	[accessoryView drawPageBar];
}
-(void)drawLoupe
{
	if (lensWindow) {
		LoupeView *winContentView = [lensWindow contentView];
		lensOldPoint = [[self window] mouseLocationOutsideOfEventStream];
		if (!NSPointInRect([[[self window] contentView] convertPoint:lensOldPoint toView:self],[self visibleRect])) {
			[winContentView setHidden:YES];
			return;
		} else {
			[winContentView setHidden:NO];
		}
		lensOldPoint.x += [[self window] frame].origin.x;
		lensOldPoint.y += [[self window] frame].origin.y;
		
		NSRect selfContentRect = [[[self window] contentView] frame];
		selfContentRect.origin.x += [[self window] frame].origin.x;
		selfContentRect.origin.y += [[self window] frame].origin.y;
		
		NSRect lensWindowRect = NSMakeRect((int)(lensOldPoint.x-lensSize/2),(int)(lensOldPoint.y-lensSize/2),lensSize,lensSize);
		
		NSPoint mPoint;
		mPoint = [[[self window] contentView] convertPoint:[[self window] mouseLocationOutsideOfEventStream] toView:self];
		if (NSPointInRect(mPoint,fRect) || NSPointInRect(mPoint,sRect)) {
			[winContentView setHidden:NO];
		} else {
			[winContentView setHidden:YES];
			return;
		}
        
        [winContentView setTargetController:target];
        [winContentView setMPoint:mPoint];
        [winContentView setFRect:fRect];
        [winContentView setSRect:sRect];
        [winContentView setLensRate:lensRate];
        [winContentView setLensSize:lensSize];
        [winContentView setRotateMode:rotateMode];
        [winContentView setInterpolation:interpolation];
        [winContentView setParentFrame:[self frame]];
        [winContentView display];
        
        [lensWindow setFrame:lensWindowRect display:true];
    }
	
}

#pragma mark set
-(void)setScreenFitMode:(int)mode
{
    if (mode != fitScreenMode) {
        fitScreenMode = mode;
        if (mode == 0) {
            [self setFrameSize:NSMakeSize([[[self window] contentView] frame].size.width,[[[self window] contentView] frame].size.height)];
        }        
        [self imageDisplay];
    }
}
- (void)setAccessoryWindowFrame
{
    NSRect temp = [[[self window] contentView] frame];
    temp.origin = [[self window] frame].origin;
    [accessoryWindow setFrame:temp display:YES];
    //[self displayIfNeededInRect:[self visibleRect]];
    //[self setNeedsDisplayInRect:[self visibleRect]];
}
-(void)setLoupe
{
	if (lensWindow) {
		[[self window] removeChildWindow:lensWindow];
		[lensWindow close];
		lensWindow = nil;
		[self resetCursorRects];
	} else {
		lensWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,lensSize,lensSize)
												 styleMask:NSBorderlessWindowMask
												   backing:NSBackingStoreBuffered
													 defer:NO];
		[lensWindow setReleasedWhenClosed:YES];
		[lensWindow setOneShot:YES];
		[lensWindow setBackgroundColor:[NSColor clearColor]];
		[lensWindow setOpaque:NO];
		[lensWindow setIgnoresMouseEvents:YES];
        [lensWindow setContentView:[[[LoupeView alloc] init] autorelease]];
		lensOldPoint = [[self window] mouseLocationOutsideOfEventStream];
		lensOldPoint.x += [[self window] frame].origin.x;
		lensOldPoint.y += [[self window] frame].origin.y;
		[lensWindow setFrame:NSMakeRect((int)(lensOldPoint.x-lensSize/2),(int)(lensOldPoint.y-lensSize/2),lensSize,lensSize) display:YES];
		
		[[self window] addChildWindow:lensWindow ordered:NSWindowAbove];
		[self resetCursorRects];
		[lensWindow orderFront:self];
		[self drawLoupe];
	}
}
-(void)setLoupeRate
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (lensRate != [defaults floatForKey:@"LoupeRate"] && lensWindow) {
		lensRate = [defaults floatForKey:@"LoupeRate"];
		
		[self drawLoupe];
        /*
		NSMutableDictionary* attr = [NSMutableDictionary dictionary];
		[attr setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[attr setObject:[NSColor darkGrayColor] forKey:NSBackgroundColorAttributeName];
		
		NSAttributedString *string;
		if (lensRate == 1) {
			string = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" Original "] attributes:attr] autorelease];
		} else {
			string = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" x%1.2f ",lensRate] attributes:attr] autorelease];
		}
		
		NSView *winContentView = [lensWindow contentView];
		[winContentView lockFocus];
		[string drawAtPoint:NSMakePoint(1,1)];
		[winContentView unlockFocus];
		
		[winContentView displayIfNeeded];
		[lensWindow displayIfNeeded];
        */
	} else {
		lensRate = [defaults floatForKey:@"LoupeRate"];
	}
}
-(BOOL)loupeIsVisible
{
	return [lensWindow isVisible];
}
#pragma mark rotate
-(void)rotateRight
{
	rotateMode--;
	if (rotateMode < 0) {
		rotateMode = 3;
	}
	[self imageDisplay];
	//[self display];
}

-(void)rotateLeft
{
	rotateMode++;
	if (rotateMode > 3) {
		rotateMode = 0;
	}
    [self imageDisplay];
	//[self display];
}


#pragma mark -
- (void)resetCursorRects
{
	[crossCursor release];
	crossCursor = nil;
	if (lensWindow || [accessoryView isMouseInPageBar]) {
		NSImage *cursorImage = [[[NSImage alloc] initWithContentsOfFile:
			[[NSBundle mainBundle] pathForResource:@"cross" ofType:@"tiff"]] autorelease];
		crossCursor = [[NSCursor alloc] initWithImage:cursorImage
											  hotSpot:NSMakePoint(7,8)];
		[crossCursor set];
		[self addCursorRect:[self visibleRect] cursor:crossCursor];
	} else {
		if (inDragScroll) {
			[self addCursorRect:[self visibleRect] cursor:[NSCursor closedHandCursor]];
		} else {
			if (!lensWindow && !NSContainsRect([[[self window] contentView] frame],[self frame])) {
				[self addCursorRect:[self visibleRect] cursor:[NSCursor openHandCursor]];
			} else {
				[super resetCursorRects];
			}
			[self setUrlRect];
		}
	}
}

#pragma mark return
-(int)tempPageNum
{
	return [accessoryView tempPageNum];
}

-(BOOL)pageMover
{
	return [accessoryView pageMover];
}
-(void)drawPageMover:(int)page
{
	[accessoryView drawPageMover:page];
}

-(id)accessoryView
{
	return accessoryView;
}

#pragma mark labo
/*
 - (void)fillBG:(NSImage*)left and:(NSImage*)right
 {
	 float r,g,b = 255;
	 NSRect rightRect,leftRect;
	 NSRect fullRect = [self bounds];
	 if (rotateMode==1||rotateMode==3) {
		 fullRect = NSMakeRect(fullRect.origin.x,fullRect.origin.y,fullRect.size.height,fullRect.size.width);
	 }
	 NSDivideRect (fullRect, &leftRect, &rightRect, fullRect.size.width/2, NSMinXEdge);
	 NSBitmapImageRep *myImageRep;
	 unsigned char *srcData;
	 int w,h,x,y;
	 if (right) {
		 NSArray *repArray = [left representations];
		 int i;
		 for (i=0;i<[repArray count];i++) {
			 if ([[repArray objectAtIndex:i] isKindOfClass:[NSBitmapImageRep class]]) {
				 break;
			 }
			 if (i==[repArray count]-1){
				 return;
			 }
		 }
		 myImageRep = [NSBitmapImageRep imageRepWithData:[left TIFFRepresentation]];
		 srcData = [myImageRep bitmapData];		
		 w = [myImageRep pixelsWide];
		 h = [myImageRep pixelsHigh];
		 x = 1;
		 y = h/2;
		 if( x < w && w > 0 && y < h && y > 0 ) {
			 int n = [myImageRep bitsPerPixel] / 8;
			 unsigned char *sample = srcData + n * ( y * w + x);
			 r = (float)*sample;
			 g = (float)*(sample + 1);
			 b = (float)*(sample + 2);
		 }
		 [[NSColor colorWithCalibratedRed:r/255 green:g/255 blue:b/255 alpha:1.0] set];
		 NSRectFillUsingOperation(leftRect,NSCompositeSourceOver);
		 
		 
		 repArray = [right representations];
		 i;
		 for (i=0;i<[repArray count];i++) {
			 if ([[repArray objectAtIndex:i] isKindOfClass:[NSBitmapImageRep class]]) {
				 break;
			 }
			 if (i==[repArray count]-1){
				 return;
			 }
		 }
		 myImageRep = [NSBitmapImageRep imageRepWithData:[right TIFFRepresentation]];
		 srcData = [myImageRep bitmapData];
		 w = [myImageRep pixelsWide];
		 h = [myImageRep pixelsHigh];
		 x = w-1;
		 y = h/2;
		 if( x < w && w > 0 && y < h && y > 0 ) {
			 int n = [myImageRep bitsPerPixel] / 8;
			 unsigned char *sample = srcData + n * ( y * w + x);
			 r = (float)*sample;
			 g = (float)*(sample + 1);
			 b = (float)*(sample + 2);
		 }
		 [[NSColor colorWithCalibratedRed:r/255 green:g/255 blue:b/255 alpha:1.0] set];
		 NSRectFillUsingOperation(rightRect,NSCompositeSourceOver);
	 } else {
		 NSArray *repArray = [left representations];
		 int i;
		 for (i=0;i<[repArray count];i++) {
			 if ([[repArray objectAtIndex:i] isKindOfClass:[NSBitmapImageRep class]]) {
				 break;
			 }
			 if (i==[repArray count]-1){
				 return;
			 }
		 }
		 myImageRep = [NSBitmapImageRep imageRepWithData:[left TIFFRepresentation]];
		 srcData = [myImageRep bitmapData];
		 w = [myImageRep pixelsWide];
		 h = [myImageRep pixelsHigh];
		 x = 1;
		 y = h/2;
		 if( x < w && w > 0 && y < h && y > 0 ) {
			 int n = [myImageRep bitsPerPixel] / 8;
			 unsigned char *sample = srcData + n * ( y * w + x);
			 r = (float)*sample;
			 g = (float)*(sample + 1);
			 b = (float)*(sample + 2);
		 }
		 [[NSColor colorWithCalibratedRed:r/255 green:g/255 blue:b/255 alpha:1.0] set];
		 NSRectFillUsingOperation(leftRect,NSCompositeSourceOver);
		 x = w-1;
		 y = h/2;
		 if( x < w && w > 0 && y < h && y > 0 ) {
			 int n = [myImageRep bitsPerPixel] / 8;
			 unsigned char *sample = srcData + n * ( y * w + x);
			 r = (float)*sample;
			 g = (float)*(sample + 1);
			 b = (float)*(sample + 2);
		 }
		 [[NSColor colorWithCalibratedRed:r/255 green:g/255 blue:b/255 alpha:1.0] set];
		 NSRectFillUsingOperation(rightRect,NSCompositeSourceOver);
	 }
 }*/
/*
- (CIImage *)createCIImage:(NSImage *)image
{
	NSData  *tiffData = [image TIFFRepresentation];
	NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
	CIImage *img= [[CIImage alloc] initWithBitmapImageRep:bitmap];
	return img;
}

- (CIImage *)createCIImageFromView:(NSView *)view
{
	NSBitmapImageRep *bitmap= [view bitmapImageRepForCachingDisplayInRect:[view bounds]];
	[view cacheDisplayInRect:[view bounds] toBitmapImageRep:bitmap];
	CIImage *img= [[CIImage alloc] initWithBitmapImageRep:bitmap];
	return img;
}

-(void)drawCIImageFromVIew
{
	CIImage *ciImage = [self createCIImageFromView:self];
	
	CIFilter *filter = [CIFilter filterWithName:@"CIMotionBlur"];
    [filter setDefaults];
	
	//CIFilter *filter   = [CIFilter filterWithName: @"CISharpenLuminance" keysAndValues: @"inputImage", ciImage, nil];
	//[filter setValue:[NSNumber numberWithFloat:0.4]  forKey:@"inputSharpness"];
	 
	
    [filter setValue:ciImage forKey:@"inputImage"];
    CIImage *outputImage = [filter valueForKey:@"outputImage"];
    
	[outputImage drawInRect:[self bounds] fromRect:[self bounds] operation:NSCompositeSourceOver fraction:1.0];
}

-(void)drawCIImage:(NSImage *)image inRect:(CGRect)inRect fromRect:(CGRect)fromRect
{
	CIImage *ciImage = [self createCIImage:image];
	
	CIFilter *filter = [CIFilter filterWithName:@"CIMotionBlur"];
    [filter setDefaults];
	
    [filter setValue:ciImage forKey:@"inputImage"];
    CIImage *outputImage = [filter valueForKey:@"outputImage"];
    
	
	
	CIContext *context = [[NSGraphicsContext currentContext] CIContext];
    [context drawImage:outputImage inRect:inRect  fromRect:fromRect];
}*/


@end

@implementation CustomImageView(private)
-(void)setUrlRect
{
	[urlRectArray removeAllObjects];
	if ([target openLinkMode]<2) {
		if (!NSIsEmptyRect(fRect)) {
			NSImage *image;
			if (images) {
				if ([target readFromLeft]) {
					image = [target image1];
				} else {
					image = [target image2];
				}
			} else {
				image = [target image1];
			}
			if (image && [image respondsToSelector:@selector(linkList)]) {					
				NSArray *linkList = [(COPDFImage*)image linkList];
				NSRect tempRect = fRect;
				float rate;
				if (rotateMode==1 || rotateMode==3) {
					rate = [image size].width/tempRect.size.height;
				} else {
					rate = [image size].width/tempRect.size.width;
				}
				int i;
				NSRect linkRect,newLinkRect;
				int w,h,x,y;
				for (i=0;i<[linkList count];i++) {
					linkRect = [[(NSDictionary*)[linkList objectAtIndex:i] valueForKey:@"rect"] rectValue];
					w = linkRect.size.width/rate;
					h = linkRect.size.height/rate;
					x = linkRect.origin.x/rate;
					y = linkRect.origin.y/rate;
					newLinkRect = NSMakeRect(tempRect.origin.x+x,tempRect.origin.y+y,w,h);
					if (rotateMode==1) {
						newLinkRect = NSMakeRect(tempRect.origin.x+tempRect.size.width-y-h,tempRect.origin.y+x,h,w);
					} else if (rotateMode==2) {
						newLinkRect = NSMakeRect(tempRect.origin.x+tempRect.size.width-x-w,tempRect.origin.y+tempRect.size.height-y-h,w,h);
					} else if (rotateMode==3) {
						newLinkRect = NSMakeRect(tempRect.origin.x+y,tempRect.origin.y+tempRect.size.height-x-w,h,w);
					}
					[self addCursorRect:newLinkRect cursor:[NSCursor pointingHandCursor]];	
					[urlRectArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithRect:newLinkRect],@"rect",[(NSDictionary*)[linkList objectAtIndex:i] valueForKey:@"url"],@"url",nil]];
				}
			}
		}
		if (!NSIsEmptyRect(sRect)) {
			NSImage *image;
			if (images) {
				if ([target readFromLeft]) {
					image = [target image2];
				} else {
					image = [target image1];
				}
			} else {
				image = [target image1];
			}				
			if (image && [image respondsToSelector:@selector(linkList)]) {					
				NSArray *linkList = [(COPDFImage*)image linkList];
				NSRect tempRect = sRect;
				float rate;
				if (rotateMode==1 || rotateMode==3) {
					rate = [image size].width/tempRect.size.height;
				} else {
					rate = [image size].width/tempRect.size.width;
				}
				int i;
				NSRect linkRect,newLinkRect;
				int w,h,x,y;
				for (i=0;i<[linkList count];i++) {
					linkRect = [[(NSDictionary*)[linkList objectAtIndex:i] valueForKey:@"rect"] rectValue];
					w = linkRect.size.width/rate;
					h = linkRect.size.height/rate;
					x = linkRect.origin.x/rate;
					y = linkRect.origin.y/rate;
					newLinkRect = NSMakeRect(tempRect.origin.x+x,tempRect.origin.y+y,w,h);
					if (rotateMode==1) {
						newLinkRect = NSMakeRect(tempRect.origin.x+tempRect.size.width-y-h,tempRect.origin.y+x,h,w);
					} else if (rotateMode==2) {
						newLinkRect = NSMakeRect(tempRect.origin.x+tempRect.size.width-x-w,tempRect.origin.y+tempRect.size.height-y-h,w,h);
					} else if (rotateMode==3) {
						newLinkRect = NSMakeRect(tempRect.origin.x+y,tempRect.origin.y+tempRect.size.height-x-w,h,w);
					}					
					[self addCursorRect:newLinkRect cursor:[NSCursor pointingHandCursor]];	
					[urlRectArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithRect:newLinkRect],@"rect",[(NSDictionary*)[linkList objectAtIndex:i] valueForKey:@"url"],@"url",nil]];
				}
			}						
		}
	}
}
-(NSURL*)urlWithPoint:(NSPoint)pt
{
	if ([target openLinkMode]<2) {
		NSPoint mPoint;
		mPoint = [[[self window] contentView] convertPoint:pt toView:self];
		
		int i;
		for (i=0;i<[urlRectArray count];i++) {
			if (NSPointInRect(mPoint,[[[urlRectArray objectAtIndex:i] objectForKey:@"rect"] rectValue])) {
				return [[urlRectArray objectAtIndex:i] objectForKey:@"url"];
			}
		}
	}
	return nil;
}
@end
