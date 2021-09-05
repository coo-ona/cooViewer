//
//  AccessorySettingView.m
//  cooViewer
//
//  Created by coo on 08/02/15.
//  Copyright 2008 coo. All rights reserved.
//

#import "AccessorySettingView.h"
#import "NSBezierPath_Adding.h"
#import "NSAttributedString_Adding.h"
#import "Controller.h"


@implementation AccessorySettingView
-(void)setPreferences
{
	[super setPreferences];
	autoHidePageBar = NO;
	autoHidedPageBar = NO;
	autoHidePageString = NO;
	autoHidedPageString = NO;
}
-(void)setPageBarBGColor:(NSColor*)color
{
	[pageBarBGColor release];
	pageBarBGColor = [color retain];
}
-(void)setPageBarBorderColor:(NSColor*)color
{
	[pageBarBorderColor release];
	pageBarBorderColor = [color retain];
}
-(void)setPageBarReadedColor:(NSColor*)color
{
	[pageBarReadedColor release];
	pageBarReadedColor = [color retain];
}

-(void)setTextFontColor:(NSColor*)color
{
	[textFontColor release];
	textFontColor = [color retain];
}
-(void)setTextBGColor:(NSColor*)color
{
	[textBGColor release];
	textBGColor = [color retain];
}
-(void)setTextBorderColor:(NSColor*)color
{
	[textBorderColor release];
	textBorderColor = [color retain];
}
-(void)setTextFont:(NSFont*)font
{
	[textFont release];
	textFont = [font retain];
}


-(void)drawRect:(NSRect)frameRect
{	
	if (positionSettingMode>=0) {
		pageBarRect = [self pageBarRect];
		float pbWidth = pageBarRect.size.width;
		
		float nowPar = 0.3;
		float now = nowPar*pbWidth;
		
		NSRect innerRect = NSInsetRect(pageBarRect,1,1);
		NSBezierPath *base = [NSBezierPath bezierPathWithRectWithDoubleArc:innerRect];
		[base closePath];
		if (![pageBarBGColor isEqualTo:[NSColor clearColor]]) {
			[pageBarBGColor set];
			[base fill];
		}
		if (![pageBarReadedColor isEqualTo:[NSColor clearColor]]) {
			NSRect slice,remainder;
			if ([controller readFromLeft]) {
				NSDivideRect(innerRect, &slice, &remainder, now, NSMinXEdge);
			} else {
				NSDivideRect(innerRect, &slice, &remainder, now, NSMaxXEdge);
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
		NSImage *resizeIndicator = [NSImage imageNamed:@"NSGrayResizeCorner"];
		
		NSRect tempRect = pageBarRect;
		tempRect.origin.x += tempRect.size.width-10;
		tempRect.size.width = 10;
		tempRect.size.height = 10;
		[resizeIndicator drawInRect:tempRect fromRect:NSMakeRect(0,0,15,15) operation:NSCompositeSourceOver fraction:1.0];
		
		NSBezierPath *path = [NSBezierPath bezierPath];
		switch (pageBarPosition) {
			case 0:
				[path moveToPoint:NSMakePoint(0,pageBarRect.origin.y+pageBarRect.size.height)];
				[path lineToPoint:NSMakePoint(pageBarRect.origin.x,pageBarRect.origin.y+pageBarRect.size.height)];
				[path moveToPoint:NSMakePoint(pageBarRect.origin.x,[self visibleRect].size.height)];
				[path lineToPoint:NSMakePoint(pageBarRect.origin.x,pageBarRect.origin.y+pageBarRect.size.height)];
				break;
			case 1:
				[path moveToPoint:NSMakePoint([self visibleRect].size.width,pageBarRect.origin.y+pageBarRect.size.height)];
				[path lineToPoint:NSMakePoint(pageBarRect.origin.x+pageBarRect.size.width,pageBarRect.origin.y+pageBarRect.size.height)];
				[path moveToPoint:NSMakePoint(pageBarRect.origin.x+pageBarRect.size.width,[self visibleRect].size.height)];
				[path lineToPoint:NSMakePoint(pageBarRect.origin.x+pageBarRect.size.width,pageBarRect.origin.y+pageBarRect.size.height)];
				break;
			case 2:
				[path moveToPoint:NSMakePoint(0,pageBarRect.origin.y)];
				[path lineToPoint:NSMakePoint(pageBarRect.origin.x,pageBarRect.origin.y)];
				[path moveToPoint:NSMakePoint(pageBarRect.origin.x,0)];
				[path lineToPoint:NSMakePoint(pageBarRect.origin.x,pageBarRect.origin.y)];
				break;
			case 3:
				[path moveToPoint:NSMakePoint([self visibleRect].size.width,pageBarRect.origin.y)];
				[path lineToPoint:NSMakePoint(pageBarRect.origin.x+pageBarRect.size.width,pageBarRect.origin.y)];
				[path moveToPoint:NSMakePoint(pageBarRect.origin.x+pageBarRect.size.width,0)];
				[path lineToPoint:NSMakePoint(pageBarRect.origin.x+pageBarRect.size.width,pageBarRect.origin.y)];
				break;
			default:
				break;
		}
		[[[NSColor grayColor] colorWithAlphaComponent:0.8] set];
		CGFloat array[2];
		array[0] = 3.0;
		array[1] = 5.0;
		[path setLineDash:array count:2 phase:0.0];
		[path stroke];
		
		
		pageStringRect = [self pageStringRect];
		[pageString drawAtPoint:pageStringRect.origin bg:textBGColor border:textBorderColor];
		path = [NSBezierPath bezierPath];
		switch (pageStringPosition) {
			case 0:
				[path moveToPoint:NSMakePoint(0,pageStringRect.origin.y+pageStringRect.size.height)];
				[path lineToPoint:NSMakePoint(pageStringRect.origin.x,pageStringRect.origin.y+pageStringRect.size.height)];
				[path moveToPoint:NSMakePoint(pageStringRect.origin.x,[self visibleRect].size.height)];
				[path lineToPoint:NSMakePoint(pageStringRect.origin.x,pageStringRect.origin.y+pageStringRect.size.height)];
				break;
			case 1:
				[path moveToPoint:NSMakePoint([self visibleRect].size.width,pageStringRect.origin.y+pageStringRect.size.height)];
				[path lineToPoint:NSMakePoint(pageStringRect.origin.x+pageStringRect.size.width,pageStringRect.origin.y+pageStringRect.size.height)];
				[path moveToPoint:NSMakePoint(pageStringRect.origin.x+pageStringRect.size.width,[self visibleRect].size.height)];
				[path lineToPoint:NSMakePoint(pageStringRect.origin.x+pageStringRect.size.width,pageStringRect.origin.y+pageStringRect.size.height)];
				break;
			case 2:
				[path moveToPoint:NSMakePoint(0,pageStringRect.origin.y)];
				[path lineToPoint:NSMakePoint(pageStringRect.origin.x,pageStringRect.origin.y)];
				[path moveToPoint:NSMakePoint(pageStringRect.origin.x,0)];
				[path lineToPoint:NSMakePoint(pageStringRect.origin.x,pageStringRect.origin.y)];
				break;
			case 3:
				[path moveToPoint:NSMakePoint([self visibleRect].size.width,pageStringRect.origin.y)];
				[path lineToPoint:NSMakePoint(pageStringRect.origin.x+pageStringRect.size.width,pageStringRect.origin.y)];
				[path moveToPoint:NSMakePoint(pageStringRect.origin.x+pageStringRect.size.width,0)];
				[path lineToPoint:NSMakePoint(pageStringRect.origin.x+pageStringRect.size.width,pageStringRect.origin.y)];
				break;
			default:
				break;
		}
		[[[NSColor grayColor] colorWithAlphaComponent:0.8] set];
		[path setLineDash:array count:2 phase:0.0];
		[path stroke];
		
		
		return;
	}
	[super drawRect:frameRect];
}

-(NSRect)pageBarRect
{	
	float width = pageBarWidth+1;
	float height = pageBarHeight+1;
	NSRect rect;
	NSRect contentFrame = [self frame];
	switch (pageBarPosition) {
		case 0:
			rect = NSMakeRect(contentFrame.origin.x+pageBarMargin.x+2,
							  contentFrame.origin.y-17-height+contentFrame.size.height-pageBarMargin.y-3,
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
-(void)setPositionSettingMode:(BOOL)b
{
	if (b) {
		positionSettingMode = 1;
	} else {
		positionSettingMode = 0;
	}
	[pageStringAttr release];
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
	[self setPageString:[pageString string]];
}

-(BOOL)positionSettingMode
{
	if (positionSettingMode>0) {
		return YES;
	}
	return NO;
}


#pragma mark PositionSetting
-(void)mouseDown:(NSEvent*)event
{
	NSRect tempRect = pageBarRect;
	tempRect.origin.x += tempRect.size.width-10;
	tempRect.size.width = 10;
	tempRect.size.height = 10;
	
	mouseOldPoint = [event locationInWindow];
	if (NSPointInRect(mouseOldPoint,[self pageStringRect])) {
		positionSettingMode = 2;
	} else if (NSPointInRect(mouseOldPoint,tempRect)) {
		positionSettingMode = 3;
	} else if (NSPointInRect(mouseOldPoint,pageBarRect)) {
		positionSettingMode = 4;
	} else {
		positionSettingMode = 1;
	}
	
	//NSLog(@"mouseDown %i",positionSettingMode);
}
-(void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint newMousePoint = [theEvent locationInWindow];
	if (!NSPointInRect(newMousePoint,[self visibleRect])) return;;
	NSRect luRect,ruRect,ldRect,rdRect;
	
	NSRect tmpL,tmpR;
	NSDivideRect([self frame],&tmpL,&tmpR,[self frame].size.width/2,NSMinXEdge);
	NSDivideRect(tmpL,&luRect,&ldRect,[self frame].size.height/2,NSMaxYEdge);
	NSDivideRect(tmpR,&ruRect,&rdRect,[self frame].size.height/2,NSMaxYEdge);
	
	//NSLog(@"%@,%@",NSStringFromRect(luRect),NSStringFromRect(rdRect));
	NSRect newRect,oldRect,tempRect;
	NSPoint tempPageMargin = pageMargin;
	NSPoint tempPageBarMargin = pageBarMargin;
	NSPoint temppoint;
	float xMoved = newMousePoint.x-mouseOldPoint.x;
	float yMoved = newMousePoint.y-mouseOldPoint.y;
	switch (positionSettingMode) {
		case 2:
			switch (pageStringPosition) {
				case 0:
					pageMargin.x += xMoved;
					pageMargin.y -= yMoved;
					break;
				case 1:
					pageMargin.x -= xMoved;
					pageMargin.y -= yMoved;
					break;
				case 2:
					pageMargin.x += xMoved;
					pageMargin.y += yMoved;
					break;
				case 3:
					pageMargin.x -= xMoved;
					pageMargin.y += yMoved;
					break;
				default:
					break;
			}
			oldRect = pageStringRect;
			tempRect = [self pageStringRect];		
			if (!NSContainsRect([self visibleRect],tempRect)) {
				pageMargin = tempPageMargin;
				
				return;
			}
			pageMargin.x = 0;
			pageMargin.y = 0;
			temppoint = NSMakePoint(tempRect.origin.x+tempRect.size.width/2,tempRect.origin.y+tempRect.size.height/2);
			if (NSPointInRect(temppoint,luRect)) {
				pageStringPosition = 0;
				newRect = [self pageStringRect];
				pageMargin.x += tempRect.origin.x-newRect.origin.x;
				pageMargin.y += newRect.origin.y-tempRect.origin.y;
			} else if (NSPointInRect(temppoint,ruRect)) {
				pageStringPosition = 1;
				newRect = [self pageStringRect];
				pageMargin.x -= tempRect.origin.x-newRect.origin.x;
				pageMargin.y += newRect.origin.y-tempRect.origin.y;
			} else if (NSPointInRect(temppoint,ldRect)) {
				pageStringPosition = 2;
				newRect = [self pageStringRect];
				pageMargin.x += tempRect.origin.x-newRect.origin.x;
				pageMargin.y -= newRect.origin.y-tempRect.origin.y;
			} else if (NSPointInRect(temppoint,rdRect)) {
				pageStringPosition = 3;
				newRect = [self pageStringRect];
				pageMargin.x -= tempRect.origin.x-newRect.origin.x;
				pageMargin.y -= newRect.origin.y-tempRect.origin.y;
			}
			newRect = [self pageStringRect];
			break;
		case 3:
			pageBarWidth += xMoved;
			pageBarHeight -= yMoved;
			if (pageBarHeight<=0) {
				pageBarHeight += yMoved;
			} 
			if (pageBarWidth < pageBarHeight) {
				pageBarWidth = pageBarHeight;
			} 
			oldRect = pageBarRect;
			tempRect = [self pageBarRect];
			temppoint = NSMakePoint(tempRect.origin.x+tempRect.size.width/2,tempRect.origin.y+tempRect.size.height/2);
			if (NSPointInRect(temppoint,luRect)) {
				pageBarPosition = 0;
			} else if (NSPointInRect(temppoint,ruRect)) {
				pageBarPosition = 1;
				pageBarMargin.x -= xMoved;
			} else if (NSPointInRect(temppoint,ldRect)) {
				pageBarPosition = 2;
				pageBarMargin.y += yMoved;
			} else if (NSPointInRect(temppoint,rdRect)) {
				pageBarPosition = 3;
				pageBarMargin.y += yMoved;
				pageBarMargin.x -= xMoved;
			}
				
			newRect = [self pageBarRect];
			break;
		case 4:
			switch (pageBarPosition) {
				case 0:
					pageBarMargin.x += xMoved;
					pageBarMargin.y -= yMoved;
					break;
				case 1:
					pageBarMargin.x -= xMoved;
					pageBarMargin.y -= yMoved;
					break;
				case 2:
					pageBarMargin.x += xMoved;
					pageBarMargin.y += yMoved;
					break;
				case 3:
					pageBarMargin.x -= xMoved;
					pageBarMargin.y += yMoved;
					break;
				default:
					break;
			}
			oldRect = pageBarRect;
			tempRect = [self pageBarRect];		
			
			if (!NSContainsRect([self visibleRect],tempRect)) {
				pageBarMargin = tempPageBarMargin;
				return;
			}
			pageBarMargin.x = 0;
			pageBarMargin.y = 0;
			temppoint = NSMakePoint(tempRect.origin.x+tempRect.size.width/2,tempRect.origin.y+tempRect.size.height/2);
			if (NSPointInRect(temppoint,luRect)) {
				pageBarPosition = 0;
				newRect = [self pageBarRect];
				pageBarMargin.x += tempRect.origin.x-newRect.origin.x;
				pageBarMargin.y += newRect.origin.y-tempRect.origin.y;
			} else if (NSPointInRect(temppoint,ruRect)) {
				pageBarPosition = 1;
				newRect = [self pageBarRect];
				pageBarMargin.x -= tempRect.origin.x-newRect.origin.x;
				pageBarMargin.y += newRect.origin.y-tempRect.origin.y;
			} else if (NSPointInRect(temppoint,ldRect)) {
				pageBarPosition = 2;
				newRect = [self pageBarRect];
				pageBarMargin.x += tempRect.origin.x-newRect.origin.x;
				pageBarMargin.y -= newRect.origin.y-tempRect.origin.y;
			} else if (NSPointInRect(temppoint,rdRect)) {
				pageBarPosition = 3;
				newRect = [self pageBarRect];
				pageBarMargin.x -= tempRect.origin.x-newRect.origin.x;
				pageBarMargin.y -= newRect.origin.y-tempRect.origin.y;
			}
			newRect = [self pageBarRect];
			break;			
		default:
			break;
	}
	[self display];
	
	mouseOldPoint = [theEvent locationInWindow];
	//NSLog(@"mouseDragged %i",positionSettingMode);
}
-(void)mouseUp:(NSEvent *)theEvent
{
	positionSettingMode = 0;
	//NSLog(@"mouseUp %i",positionSettingMode);
}


#pragma mark return
-(int)pageBarPosition
{
	return pageBarPosition;
}
-(int)pageNumPosition
{
	return pageStringPosition;
}
-(NSDictionary*)pageMargin
{
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:pageMargin.x],@"x",
		[NSNumber numberWithInt:pageMargin.y],@"y",nil];
	return dic;
}
-(NSDictionary*)pageBarMargin
{
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:pageBarMargin.x],@"x",
		[NSNumber numberWithInt:pageBarMargin.y],@"y",nil];
	return dic;
}
-(NSDictionary*)pageBarSize
{
	NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:pageBarWidth],@"width",
		[NSNumber numberWithInt:pageBarHeight],@"height",nil];
	return dic;
}
@end
