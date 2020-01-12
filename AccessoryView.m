//
//  AccessoryView.m
//  cooViewer
//
//  Created by coo on 08/02/12.
//  Copyright 2008 coo. All rights reserved.
//

#import "AccessoryView.h"
#import "Controller.h"
#import "CustomImageView.h"
#import "NSBezierPath_Adding.h"
#import "NSAttributedString_Adding.h"


@implementation AccessoryView
NSRect COIntRect(NSRect aRect)
{
	NSRect tempRect = aRect;
	tempRect.origin.x = (int)(tempRect.origin.x+0.5);
	tempRect.origin.y = (int)(tempRect.origin.y+0.5);
	tempRect.size.width = (int)(tempRect.size.width+0.5);
	tempRect.size.height = (int)(tempRect.size.height+0.5);
	return tempRect;
}
- (void)setPreferences
{
	if (!didFirst) {
		didFirst = YES;
		
		pageBarBGColor = nil;
		pageBarBorderColor = nil;
		pageBarReadedColor = nil;
		pageBarFontColor = nil;
		pageBarFont = nil; 
		textFontColor = nil;
		textFont = nil;
		textBGColor = nil;
		textBorderColor = nil;
		
		autoHidePageBar = NO;
		autoHidedPageBar = NO;
		autoHidePageString = NO;
		autoHidedPageString = NO;
		pageString = nil;
		infoString = nil;
		
		pageBarRect = NSZeroRect;	
		pageStringRect = NSZeroRect;
		infoStringRect = NSZeroRect;
		pageMoverRect = NSZeroRect;
		pageBarStringRect = NSZeroRect;
		
		pageStringPosition = 0;
		
		pageBarBezierPath = nil;
		//pageStringBezierPath = nil;
		pageStringAttr = nil;
		//pageBarStringAttr = nil;
		
		accessoryTimer = nil;
	} else {
		[pageBarBGColor release];
		[pageBarBorderColor release];
		[pageBarReadedColor release];
		[pageBarFontColor release];
		[pageBarFont release];
		[textFontColor release];
		[textFont release];
		[textBGColor release];
		[textBorderColor release];
		
		[pageBarBezierPath release];
		//[pageStringBezierPath release];
		[pageStringAttr release];
		//[pageBarStringAttr release];
	}
	
	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	autoHidePageBar = [defaults boolForKey:@"PageBarAutoHide"];
	autoHidePageString = [defaults boolForKey:@"PageNumAutoHide"];
	pageBarShowThumbnail = (int)[defaults integerForKey:@"PageBarShowThumbnail"];
	pageBarPosition = (int)[defaults integerForKey:@"PageBarPosition"];
	
	
	NSDictionary *dic = [defaults dictionaryForKey:@"PageBarSize"];
	pageBarWidth = [[dic objectForKey:@"width"] intValue];
	pageBarHeight = [[dic objectForKey:@"height"] intValue];
	

	if ([defaults objectForKey:@"PageBarFontColor"]) {
		pageBarFontColor = [[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"PageBarFontColor"]] retain];
	} else {
		pageBarFontColor = [[NSColor whiteColor] retain];
	}
	if ([defaults objectForKey:@"PageBarTextFont"]) {
		pageBarFont = [[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"PageBarTextFont"]] retain];
	} else {
		pageBarFont = [[NSFont userFontOfSize:14] retain];
	}	
	if ([defaults objectForKey:@"PageBarBGColor"]) {
		pageBarBGColor = [[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"PageBarBGColor"]] retain];
	} else {
		pageBarBGColor = [[[NSColor blackColor] colorWithAlphaComponent:0.8] retain];
	}
	if ([defaults objectForKey:@"PageBarBorderColor"]) {
		pageBarBorderColor = [[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"PageBarBorderColor"]] retain];
	} else {
		pageBarBorderColor = [[NSColor whiteColor] retain];
	}
	if ([defaults objectForKey:@"PageBarReadedColor"]) {
		pageBarReadedColor = [[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"PageBarReadedColor"]] retain];
	} else {
		pageBarReadedColor = [[[NSColor whiteColor] colorWithAlphaComponent:0.5] retain];
	}
	

	if ([defaults objectForKey:@"TextFont"]) {
		textFont = [[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"TextFont"]] retain];
	} else {
		textFont = [[NSFont controlContentFontOfSize:11] retain];
	}
	if ([defaults objectForKey:@"TextColor"]) {
		textFontColor = [[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"TextColor"]] retain];
	} else {
		textFontColor = [[NSColor whiteColor] retain];
	}
	if ([defaults objectForKey:@"TextBGColor"]) {
		textBGColor = [[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"TextBGColor"]] retain];
	} else {
		textBGColor = [[[NSColor blackColor] colorWithAlphaComponent:0.8] retain];
	}
	if ([defaults objectForKey:@"TextBorderColor"]) {
		textBorderColor = [[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"TextBorderColor"]] retain];
	} else {
		textBorderColor = [[NSColor whiteColor] retain];
	}
	
	
	pageStringPosition = (int)[defaults integerForKey:@"PageNumPosition"];
	
	pageMargin = NSZeroPoint;
	if ([defaults dictionaryForKey:@"Margin_Page"]) {
		pageMargin.x=[[[defaults dictionaryForKey:@"Margin_Page"] objectForKey:@"x"] intValue];
		pageMargin.y=[[[defaults dictionaryForKey:@"Margin_Page"] objectForKey:@"y"] intValue];
	} else {
		[defaults setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"x",[NSNumber numberWithInt:0],@"y",nil] 
					 forKey:@"Margin_Page"];
	}
	pageBarMargin=NSZeroPoint;
	if ([defaults dictionaryForKey:@"Margin_PageBar"]) {
		pageBarMargin.x=[[[defaults dictionaryForKey:@"Margin_PageBar"] objectForKey:@"x"] intValue];
		pageBarMargin.y=[[[defaults dictionaryForKey:@"Margin_PageBar"] objectForKey:@"y"] intValue];
	} else {
		[defaults setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"x",[NSNumber numberWithInt:0],@"y",nil] 
					 forKey:@"Margin_PageBar"];
	}
	
	pageBarRect = [self pageBarRect];
	NSRect innerRect = NSInsetRect(pageBarRect,1,1);
	pageBarBezierPath = [[NSBezierPath bezierPathWithRectWithDoubleArc:innerRect] retain];
	[pageBarBezierPath closePath];
	
	
	if ([textBGColor isEqualTo:[NSColor clearColor]]) {
		NSColor *shadowColor = [textFontColor colorUsingColorSpaceName:NSCalibratedWhiteColorSpace];
		CGFloat white,alpha;
		[shadowColor getWhite:&white alpha:&alpha];
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowBlurRadius:white];
		[shadow setShadowColor:textFontColor];
		pageStringAttr = [[NSDictionary dictionaryWithObjectsAndKeys:
			textFontColor,NSForegroundColorAttributeName,
			textFont,NSFontAttributeName,
			shadow,NSShadowAttributeName,
			nil] retain];
		[shadow release];
	} else {
		pageStringAttr = [[NSDictionary dictionaryWithObjectsAndKeys:
			textFontColor,NSForegroundColorAttributeName,
			textFont,NSFontAttributeName,
			nil] retain];
	}
	if (didFirst) [self setPageString:[self pageString]];
	if (autoHidePageBar) {
		autoHidedPageBar=YES;
	} else {
		autoHidedPageBar=NO;
	}
	if (autoHidePageString) {
		autoHidedPageString=YES;
	} else {
		autoHidedPageString=NO;
	}
	[self setPageString:[pageString string]];
	[self display];
}




- (void)setFrame:(NSRect)frameRect
{
	[super setFrame:frameRect];
	[pageBarBezierPath release];
	pageBarRect = [self pageBarRect];
	NSRect innerRect = NSInsetRect(pageBarRect,1,1);
	pageBarBezierPath = [[NSBezierPath bezierPathWithRectWithDoubleArc:innerRect] retain];
	[pageBarBezierPath closePath];
}
- (void)mouseMoved:(NSEvent *)theEvent
{
    //NSDisableScreenUpdates();
    NSPoint lensOldPoint;
    if ([controller indicator] && ![imageView loupeIsVisible]) {
        lensOldPoint = [[self window] mouseLocationOutsideOfEventStream];
        
        if (autoHidedPageBar) {
            autoHidedPageBar = NO;
            [self setNeedsDisplayInRect:[self pageBarRect]];
        }
    
        if (autoHidedPageString) {
            autoHidedPageString = NO;
            [self setNeedsDisplayInRect:[self pageStringRect]];
            [self setInfoString:[infoString string]];
        }
        
        if (autoHidePageBar || autoHidePageString) {
            [accessoryTimer invalidate];
            accessoryTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                               target:self
                                                             selector:@selector(hideAccessory)
                                                             userInfo:nil
                                                              repeats:NO];
        }
        
        NSRect tempPageBarRect = NSInsetRect([self pageBarRect],2,2);
        if (NSPointInRect(lensOldPoint, tempPageBarRect)) {
            [self setNeedsDisplay:YES];
        } else {
            if (!NSIsEmptyRect(pageBarStringRect)) {
                [self setNeedsDisplay:YES];
            }
        }
    }
    //NSEnableScreenUpdates();
}
- (void)drawPageBarBubble
{
	NSPoint lensOldPoint;
	if (!NSIsEmptyRect(pageBarStringRect)) {
		pageBarStringRect = NSZeroRect;
	}
	if ([controller indicator] && ![imageView loupeIsVisible]) {
		lensOldPoint = [[self window] mouseLocationOutsideOfEventStream];
		
		NSRect tempPageBarRect = NSInsetRect([self pageBarRect],2,2);
		if (NSPointInRect(lensOldPoint, tempPageBarRect)) {
			[self resetCursorRects];
			NSPoint tempPoint = lensOldPoint;
			NSRect tempRect = tempPageBarRect;
			float temp = tempPoint.x - tempRect.origin.x;
			if (![controller readFromLeft]) {
				temp = tempRect.size.width - temp-1;
			}
			temp = temp/tempRect.size.width;
			
			float fPage = [(Controller *)controller pageCount]*temp;
			int page = (int)fPage;
			
			NSMutableDictionary* attr = [NSMutableDictionary dictionary];
			[attr setObject:pageBarFontColor forKey:NSForegroundColorAttributeName];
			[attr setObject:pageBarFont forKey:NSFontAttributeName];
			
			if ([pageBarBGColor isEqualTo:[NSColor clearColor]]) {
				NSColor *shadowColor = [pageBarFontColor colorUsingColorSpaceName:NSCalibratedWhiteColorSpace];
				CGFloat white,alpha;
				[shadowColor getWhite:&white alpha:&alpha];
				NSShadow *shadow = [[NSShadow alloc] init];
				[shadow setShadowBlurRadius:white];
				[shadow setShadowColor:pageBarFontColor];
				[attr setObject:shadow forKey:NSShadowAttributeName];
				[shadow release];
			}
			NSAttributedString *string = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %i ",page+1] attributes:attr] autorelease];
			NSPoint mouseOrigin = [[[self window] contentView] convertPoint:lensOldPoint fromView:self];
			mouseOrigin.x = (int)mouseOrigin.x;
			mouseOrigin.y = (int)mouseOrigin.y;
			NSPoint pt = mouseOrigin;
			pt.y = tempRect.origin.y;
			
			
			int twidth = 6;
			int theight = 6;
			int tMargin = 10;
			int basemargin=7;
			if (pageBarShowThumbnail) {
				switch (pageBarPosition) {
					case 0:case 1:
						pt.y+=tempRect.size.height/2;
						break;
					case 2:case 3:
						pt.y-=5+tempRect.size.height/2;
						break;
				}
				twidth = 10;
				theight = 10;
				float rad = 10.0;
				NSImage *thumbnail = [controller loadThumbnailImage:page];
				
				NSInteger widthValue = [thumbnail size].width;
				NSInteger heightValue = [thumbnail size].height;
				float imageRectWidth = 200;
				float imageRectHeight = 200;
				float width,height;
				float rate = imageRectWidth/widthValue;
				
				width = widthValue*rate;
				height = heightValue*rate;
				if (height>imageRectHeight) {
					rate = imageRectHeight/heightValue;
					width = widthValue*rate;
					height = heightValue*rate;
				}
				width = (int)width;
				height = (int)height;
				
				NSRect thumbnailRect=NSMakeRect(pt.x,pt.y,width+4+4,height+5+1+1+[string size].height);
				NSRect imageRect = NSZeroRect;
				
				switch (pageBarPosition) {
					case 0:
						thumbnailRect.origin.y -= thumbnailRect.size.height+theight;
						thumbnailRect.origin.x -= tMargin+rad+twidth/2-basemargin;
						break;
					case 1:
						thumbnailRect.origin.y -= thumbnailRect.size.height+theight;
						thumbnailRect.origin.x -= thumbnailRect.size.width-tMargin-rad-twidth/2+basemargin;
						break;
					case 2:
						thumbnailRect.origin.y += [self pageBarRect].size.height+theight;
						thumbnailRect.origin.x -= tMargin+rad+twidth/2-basemargin;
						break;
					case 3:
						thumbnailRect.origin.y += [self pageBarRect].size.height+theight;
						thumbnailRect.origin.x -= thumbnailRect.size.width-tMargin-rad-twidth/2+basemargin;
						break;
					default:
						break;
				}
				if ([string size].width > thumbnailRect.size.width) thumbnailRect.size.width=(int)[string size].width;
				if (thumbnailRect.origin.x < 5) thumbnailRect.origin.x = 5;
				if (thumbnailRect.origin.x+thumbnailRect.size.width+5 > [self frame].size.width) {
					float x = [self frame].size.width - (thumbnailRect.size.width+5);
					thumbnailRect.origin.x = x;
				}
				pt.x=thumbnailRect.origin.x+2;
				pt.y=thumbnailRect.origin.y+thumbnailRect.size.height-2-[string size].height;
				imageRect = thumbnailRect;
				imageRect.origin.x += 5;
				imageRect.origin.y += 5;
				imageRect.size.width = width;
				imageRect.size.height = height;
				
				
				NSBezierPath *bezier;				
				NSPoint tl,tt,tr;
				if (pageBarPosition < 2) {		
					bezier = [NSBezierPath bezierPathWithRectWithArc:thumbnailRect rad:rad open:1];		
					tt = NSMakePoint(mouseOrigin.x,thumbnailRect.origin.y+thumbnailRect.size.height+theight);	
					switch (pageBarPosition) {
						case 0://左上
							tl = NSMakePoint(thumbnailRect.origin.x+rad+tMargin,tt.y-theight);
							tr = NSMakePoint(tl.x+twidth,tl.y);
							break;
						case 1://右上
							tr = NSMakePoint(thumbnailRect.origin.x+thumbnailRect.size.width-rad-tMargin,tt.y-theight);
							tl = NSMakePoint(tr.x-twidth,tr.y);
							break;
						default:
							break;
					}
					[bezier appendBezierPathWithPoints:&tr count:1];
					[bezier appendBezierPathWithPoints:&tt count:1];
					[bezier appendBezierPathWithPoints:&tl count:1];
				} else {
					bezier = [NSBezierPath bezierPathWithRectWithArc:thumbnailRect rad:rad open:3];	
					tt = NSMakePoint(mouseOrigin.x,thumbnailRect.origin.y-theight);
					switch (pageBarPosition) {
						case 2://左下
							tl = NSMakePoint(thumbnailRect.origin.x+rad+tMargin,tt.y+theight);
							tr = NSMakePoint(tl.x+twidth,tl.y);
							break;
						case 3://右下
							tr = NSMakePoint(thumbnailRect.origin.x+thumbnailRect.size.width-rad-tMargin,tt.y+theight);
							tl = NSMakePoint(tr.x-twidth,tr.y);
							break;
						default:
							break;
					}
					[bezier appendBezierPathWithPoints:&tl count:1];
					[bezier appendBezierPathWithPoints:&tt count:1];
					[bezier appendBezierPathWithPoints:&tr count:1];
				}				
				[bezier closePath];
				pageBarStringRect = NSInsetRect(COIntRect([bezier bounds]),-3,-3);
				
                if (![pageBarBGColor isEqualTo:[NSColor clearColor]]) {
					[pageBarBGColor set];
					[bezier fill];
				}
				if (![pageBarBorderColor isEqualTo:[NSColor clearColor]]) {
					[pageBarBorderColor set];
					[bezier stroke];
				}
				[thumbnail drawInRect:imageRect
							 fromRect:NSMakeRect(0,0,widthValue,heightValue)
							operation:NSCompositeSourceOver fraction:1.0];
				[string drawAtPoint:pt];
			} else {
				switch (pageBarPosition) {
					case 0:case 1:
						pt.y+=tempRect.size.height/2;
						break;
					case 2:case 3:
						pt.y-=tempRect.size.height/2;
						break;
				}
				int stringSize = [string size].width;
				if (stringSize < twidth+tMargin*2) tMargin = (stringSize-twidth)/2;
				switch (pageBarPosition) {
					case 0:
						pt.x += basemargin;
						pt.y -= [string size].height+theight;
						pt.x -= tMargin+twidth/2;
						//pt.x += 15;
						break;
					case 1:
						pt.x -= basemargin;
						pt.y -= [string size].height+theight;
						pt.x += tMargin+twidth/2;
						pt.x -= stringSize;
						//pt.x -= 10;
						break;
					case 2:
						pt.x += basemargin;
						pt.y += [self pageBarRect].size.height+1;
						pt.x -= tMargin+twidth/2;
						break;
					case 3:
						pt.x -= basemargin;
						pt.y += [self pageBarRect].size.height+1;
						pt.x += tMargin+twidth/2;
						pt.x -= stringSize;
						break;
					default:
						break;
				}
				if (pt.x < 5) pt.x = 5;
				if (pt.x + stringSize + 5> [self frame].size.width) {
					float x = [self frame].size.width - (stringSize+5);
					pt.x = x;
				}
				
				NSBezierPath *bezier;
				NSRect temp = NSMakeRect(pt.x,pt.y,[string size].width,[string size].height);
				NSPoint tl,tt,tr;
				if (pageBarPosition >= 2) {
					bezier = [NSBezierPath bezierPathWithRectWithArc:temp rad:0 open:3];
					tt = NSMakePoint(mouseOrigin.x,pt.y-theight);
					switch (pageBarPosition) {
						case 2://左下
							tl = NSMakePoint(pt.x+tMargin,tt.y+theight);
							tr = NSMakePoint(tl.x+twidth,tl.y);
							break;
						case 3://右下
							tr = NSMakePoint(pt.x+stringSize-tMargin,tt.y+theight);
							tl = NSMakePoint(tr.x-twidth,tr.y);
							break;
						default:
							break;
					}
					[bezier appendBezierPathWithPoints:&tl count:1];
					[bezier appendBezierPathWithPoints:&tt count:1];
					[bezier appendBezierPathWithPoints:&tr count:1];
				} else {					
					bezier = [NSBezierPath bezierPathWithRectWithArc:temp rad:0 open:1];
					tt = NSMakePoint(mouseOrigin.x,pt.y+[string size].height+theight);
					switch (pageBarPosition) {
						case 0://左上
							tl = NSMakePoint(pt.x+tMargin,tt.y-theight);
							tr = NSMakePoint(tl.x+twidth,tl.y);
							break;
						case 1://右上
							tr = NSMakePoint(pt.x+stringSize-tMargin,tt.y-theight);
							tl = NSMakePoint(tr.x-twidth,tr.y);
							break;
						default:
							break;
					}
					[bezier appendBezierPathWithPoints:&tr count:1];
					[bezier appendBezierPathWithPoints:&tt count:1];
					[bezier appendBezierPathWithPoints:&tl count:1];
				}
				
				[bezier closePath];
				pageBarStringRect = NSInsetRect(COIntRect([bezier bounds]),-5,-5);
				
                if (![pageBarBGColor isEqualTo:[NSColor clearColor]]) {
					[pageBarBGColor set];
					[bezier fill];
				}
				if (![pageBarBorderColor isEqualTo:[NSColor clearColor]]) {
					[pageBarBorderColor set];
					[bezier stroke];
				}
                [string drawAtPoint:pt];
			}
		} else {
			[self resetCursorRects];
		}
	}
}

-(void)drawAccessory
{
	if (!NSIsEmptyRect(pageBarStringRect)) {
		[self setNeedsDisplayInRect:pageBarStringRect];
		pageBarStringRect = NSZeroRect;
	}
	if (!autoHidedPageBar) [self setNeedsDisplayInRect:[self pageBarRect]];
	if (!autoHidedPageString) [self setNeedsDisplayInRect:[self pageStringRect]];
	/*
	if (!slideshow) {
		[infoString release];
		infoString = nil;
		[self setNeedsDisplayInRect:infoStringRect];
	}*/
}

-(void)drawRect:(NSRect)frameRect
{
	if ([controller indicator] && [imageView image]) {
		if (!autoHidedPageBar) {
			pageBarRect = [self pageBarRect];
			
			float nowPar = [controller nowPar];
			float now = pageBarRect.size.width*nowPar;
			
			
			NSBezierPath *base = pageBarBezierPath;
			if (![pageBarBGColor isEqualTo:[NSColor clearColor]]) {
				[pageBarBGColor set];
				[base fill];
			}
			if (![pageBarReadedColor isEqualTo:[NSColor clearColor]]) {
				NSRect rect = NSInsetRect(pageBarRect,1,1);
				NSRect slice,remainder;
				if ([controller readFromLeft]) {
					NSDivideRect(rect, &slice, &remainder, now, NSMinXEdge);
				} else {
					NSDivideRect(rect, &slice, &remainder, now, NSMaxXEdge);
				}
				
				[NSGraphicsContext saveGraphicsState]; 		
				[base addClip]; 
				[pageBarReadedColor set];
				NSRectFillUsingOperation(slice,NSCompositeSourceOver);
				[NSGraphicsContext restoreGraphicsState]; 		
			}
			if (![pageBarBorderColor isEqualTo:[NSColor clearColor]]) {
				[pageBarBorderColor set];
				[base stroke];
			}
		} else {
			pageBarRect = NSZeroRect;
		}
	} else {
		//pageBarRect = NSZeroRect;
	}
	
	if (pageMover && tempPageNum>=0) {
		pageMoverRect = [self pageMoverRect];
		pageMoverRect = NSInsetRect(pageMoverRect,4,4);
		float rad = 10.0;
		NSBezierPath *bezier = [NSBezierPath bezierPathWithRectWithArc:pageMoverRect rad:rad open:0];
		[bezier closePath];
		if (![pageBarBGColor isEqualTo:[NSColor clearColor]]) {
			[pageBarBGColor set];
			[bezier fill];
		}
		if (![pageBarBorderColor isEqualTo:[NSColor clearColor]]) {
			[pageBarBorderColor set];
			[bezier stroke];
		}
		pageMoverRect = NSInsetRect([bezier bounds],-4,-4);
		if (tempPageNum != 0) {
			NSMutableDictionary* attr = [NSMutableDictionary dictionary];
			[attr setObject:pageBarFontColor forKey:NSForegroundColorAttributeName];
			[attr setObject:[NSFont fontWithName:[pageBarFont fontName] size:[pageBarFont pointSize]+10] forKey:NSFontAttributeName];
			
			NSAttributedString *string = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",tempPageNum] attributes:attr] autorelease];
			
			NSRect tempRect = pageMoverRect;
			NSPoint pt;
			pt = NSMakePoint((tempRect.size.width-[string size].width)/2+tempRect.origin.x,tempRect.origin.y+(tempRect.size.height-[string size].height)/2);
			[string drawAtPoint:pt];
		}
	} else if (!pageMover) {
		pageMoverRect = NSZeroRect;
	}
	
	if (pageString && [imageView image]) {
		if (!autoHidedPageString) {			
			pageStringRect = [self pageStringRect];
			[pageString drawAtPoint:pageStringRect.origin bg:textBGColor border:textBorderColor];
		} else {
			pageStringRect = NSZeroRect;
		}
	} else {
		//pageStringRect = NSZeroRect;
	}
	if (infoString && [imageView image]) {
		if (![[infoString string] isEqualToString:@""]) {
			infoStringRect = [self infoStringRect];
			[infoString drawAtPoint:infoStringRect.origin bg:textBGColor border:textBorderColor];
			
			if (![[infoString string] isEqualToString:[infoStringTimer userInfo]]) {
				[infoStringTimer invalidate];
				infoStringTimer = [NSTimer scheduledTimerWithTimeInterval:2
																   target:self
																 selector:@selector(setZeroInfoString)
																 userInfo:[infoString string]
																  repeats:NO];
			}
		}
	} else {
		//infoStringRect = NSZeroRect;
	}
    
    [self drawPageBarBubble];
    
}

#pragma mark infoString
-(void)setZeroInfoString
{
	infoStringTimer = nil;
	NSRect oldRect=NSUnionRect(infoStringRect,pageStringRect);
	[infoString release];
	infoString = nil;
	[self setNeedsDisplayInRect:NSUnionRect(NSUnionRect([self infoStringRect],[self pageStringRect]),oldRect)];
}

-(void)setSlideshow:(BOOL)b
{
	slideshow = b;
	if (slideshow == NO) {
		[self setInfoString:@"stop slideshow"];
		[self setNeedsDisplayInRect:NSUnionRect([self infoStringRect],[self pageStringRect])];
		/*
		NSRect temp = NSUnionRect(infoStringRect,[self pageStringRect]);
		[infoString release];
		infoString = nil;
		infoStringRect = NSZeroRect;
		[self displayRect:temp];
		 */
	} else {
		[self setInfoString:@"start slideshow"];
		[self setNeedsDisplayInRect:NSUnionRect([self infoStringRect],[self pageStringRect])];
	}
}

-(void)setInfoString:(NSString*)string
{
	if (!string) {
		return;
	}
	NSRect oldRect=NSUnionRect(infoStringRect,pageStringRect);
	
	if (!infoString) {
		infoString = [[NSAttributedString alloc] initWithString:string attributes:pageStringAttr];
	} else {
		[infoString initWithString:string attributes:pageStringAttr];
	}
	if (NSIsEmptyRect(oldRect)) {
		[self setNeedsDisplayInRect:NSUnionRect([self infoStringRect],[self pageStringRect])];
	} else {
		[self setNeedsDisplayInRect:NSUnionRect(NSUnionRect([self infoStringRect],[self pageStringRect]),oldRect)];
	}
}

-(NSRect)infoStringRect
{
	if (!infoString) return NSZeroRect;
	
	NSRect contentFrame = [self frame];
	NSRect rect = NSMakeRect(0,0,[infoString sizeWithBG].width,[infoString sizeWithBG].height);
	rect.size.width = (int)rect.size.width + 1;
	rect.size.height = (int)rect.size.height + 1;
	switch (pageStringPosition) {
		case 0:
			rect.origin.x = pageMargin.x+2;
			rect.origin.y = contentFrame.size.height-(int)rect.size.height-pageMargin.y;
			break;
		case 1:
			rect.origin.x = contentFrame.size.width-(int)rect.size.width-pageMargin.x-2;
			rect.origin.y = contentFrame.size.height-(int)rect.size.height-pageMargin.y;
			break;
		case 2:
			rect.origin.x = pageMargin.x+2;
			rect.origin.y = 17+pageMargin.y+2;
			break;
		case 3:
			rect.origin.x = contentFrame.size.width-(int)rect.size.width-pageMargin.x-2;
			rect.origin.y = 17+pageMargin.y+2;
			break;
		default:
			break;
	}
	return COIntRect(rect);
}

#pragma mark accessory
-(void)hideAccessory
{
	accessoryTimer = nil;
	
	NSRect updateRect = NSZeroRect;
	if (autoHidePageBar) {
		autoHidedPageBar = YES;
		if (NSEqualRects(updateRect,NSZeroRect)) {
			updateRect = [self pageBarRect];
		} else {
			updateRect = NSUnionRect(updateRect,[self pageBarRect]);
		}
	}
	if (autoHidePageString) {
		autoHidedPageString = YES;
		[self setInfoString:[infoString string]];
		if (NSEqualRects(updateRect,NSZeroRect)) {
			updateRect = [self pageStringRect];
		} else {
			updateRect = NSUnionRect(updateRect,[self pageStringRect]);
		}
	}
	
	if (!NSEqualRects(updateRect,NSZeroRect)) {
		[self setNeedsDisplayInRect:updateRect];
	}
}

#pragma mark pageString
-(void)setPageString:(NSString*)string
{
	if (!string) {
		[pageString release];
		pageString = nil;
		[self setNeedsDisplayInRect:pageStringRect];
		pageStringRect = NSZeroRect;
		return;
	}
	NSRect oldRect=pageStringRect;

	if (!pageString) {
		pageString = [[NSAttributedString alloc] initWithString:string attributes:pageStringAttr];
	} else {
		[pageString initWithString:string attributes:pageStringAttr];
	}
	if (!autoHidedPageString) {
		if (NSIsEmptyRect(oldRect)) {
			[self setNeedsDisplayInRect:[self pageStringRect]];
		} else {
			[self setNeedsDisplayInRect:NSUnionRect([self pageStringRect],oldRect)];
		}
	}
}

-(NSString*)pageString
{
	return [pageString string];
}
-(NSRect)pageStringRect
{
	NSRect contentFrame = [self frame];
	NSRect rect = NSMakeRect(0,0,[pageString sizeWithBG].width,[pageString sizeWithBG].height);
	rect.size.width = rect.size.width + 1;
	rect.size.height = rect.size.height + 1;
	switch (pageStringPosition) {
		case 0:
			rect.origin.x = pageMargin.x+2 +[self infoStringRect].size.width;
			rect.origin.y = contentFrame.size.height-rect.size.height-pageMargin.y;
			break;
		case 1:
			rect.origin.x = contentFrame.size.width-rect.size.width-pageMargin.x-2 -[self infoStringRect].size.width;
			rect.origin.y = contentFrame.size.height-rect.size.height-pageMargin.y;
			break;
		case 2:
			rect.origin.x = pageMargin.x+2 +[self infoStringRect].size.width;
			rect.origin.y = 17+pageMargin.y+2;
			break;
		case 3:
			rect.origin.x = contentFrame.size.width-rect.size.width-pageMargin.x-2 -[self infoStringRect].size.width;
			rect.origin.y = 17+pageMargin.y+2;
			break;
		default:
			break;
	}
	return COIntRect(rect);
}

#pragma mark pageBar
-(void)drawPageBar
{
	if (NSIsEmptyRect(pageBarRect)) {
		[self setNeedsDisplayInRect:[self pageBarRect]];
	} else {
		[self setNeedsDisplayInRect:pageBarRect];
	}
}
-(NSRect)pageBarRect
{
	if ([controller indicator]) {		
		float width = pageBarWidth+1;
		float height = pageBarHeight+1;
		NSRect rect;
		NSRect contentFrame = [self frame];
		switch (pageBarPosition) {
			case 0:
				rect = NSMakeRect(contentFrame.origin.x+pageBarMargin.x+2,
								  contentFrame.size.height-17-height-pageBarMargin.y-3,
								  width,height);
				break;
			case 1:
				rect = NSMakeRect(contentFrame.origin.x+contentFrame.size.width-width-pageBarMargin.x-3,
								  contentFrame.origin.y-17-height+contentFrame.size.height-pageBarMargin.y-3,
								  width,height);
				break;
			case 2:
				rect = NSMakeRect(contentFrame.origin.x+pageBarMargin.x+2,
								  contentFrame.origin.y+pageBarMargin.y+2,
								  width,height);
				break;
			case 3:
				rect = NSMakeRect(contentFrame.origin.x+contentFrame.size.width-width-pageBarMargin.x-3,
								  contentFrame.origin.y+pageBarMargin.y+2,
								  width,height);
				break;
			default:
				rect = NSMakeRect(0,0,width,height);
				break;
		}
		return COIntRect(rect);
	}
	return NSZeroRect;
}

-(NSRect)pageMoverRect
{
	if (pageMover == YES) {
		NSRect contentFrame = [self frame];
        NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:pageBarFontColor,NSForegroundColorAttributeName,
			[NSFont fontWithName:[pageBarFont fontName] size:[pageBarFont pointSize]+10],NSFontAttributeName,nil];
		NSAttributedString *string = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",tempPageNum] attributes:attr] autorelease];
		
		
		NSRect rect = NSMakeRect(0,0,[string size].width+50,[string size].height+20);
		float width = rect.size.width;
		float height = rect.size.height;
		
		rect = NSMakeRect((int)(((contentFrame.size.width-width)/2)+contentFrame.origin.x),
						  (int)(((contentFrame.size.height-height)/2)+contentFrame.origin.y),
						  (int)width,(int)height);
		
		return rect;
	}
	return NSZeroRect;
	
}

-(void)drawPageMover:(int)page
{
	if (page >= 0) {
		pageMover = YES;
		tempPageNum = tempPageNum*10;
		tempPageNum = tempPageNum+page;
		pageMoverRect = [self pageMoverRect];
	} else if (page == -1) {
		pageMover = NO;
		tempPageNum = 0;
	} else if (page == -2) {
		tempPageNum = tempPageNum/10;
	}
	[self setNeedsDisplayInRect:pageMoverRect];
}
-(BOOL)pageMover
{
	return pageMover;
}
-(int)tempPageNum
{
	return tempPageNum;
}
#pragma mark -
- (void)resetCursorRects
{
	[imageView resetCursorRects];
	/*
	[pageBarCursor release];
	pageBarCursor = nil;
	if (NSPointInRect([[self window] mouseLocationOutsideOfEventStream], [self pageBarRect])) {
		NSImage *cursorImage = [[[NSImage alloc] initWithContentsOfFile:
			[[NSBundle mainBundle] pathForResource:@"cross" ofType:@"tiff"]] autorelease];
		pageBarCursor = [[NSCursor alloc] initWithImage:cursorImage
											  hotSpot:NSMakePoint(7,8)];
		[pageBarCursor set];
		//[imageView addCursorRect:[imageView bounds] cursor:pageBarCursor];
	} else {
		[[NSCursor arrowCursor] set];
		//[super resetCursorRects];
	}*/
}
- (BOOL)isMouseInPageBar
{
	return NSPointInRect([[self window] mouseLocationOutsideOfEventStream], [self pageBarRect]);
}
@end
