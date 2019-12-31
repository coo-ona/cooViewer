//
//  AccessoryView.h
//  cooViewer
//
//  Created by coo on 08/02/12.
//  Copyright 2008 coo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AccessoryView : NSView 
{	
	NSTimer *infoStringTimer;
	NSTimer *accessoryTimer;
	NSDictionary*pageStringAttr;
	
	NSBezierPath *pageBarBezierPath;
	
	NSCursor *pageBarCursor;
	
	NSRect pageMoverRect;
	NSRect pageStringRect;
	NSRect infoStringRect;
	BOOL slideshow;
	
	
	BOOL drawAccessory;
	BOOL didFirst;
	
	IBOutlet id controller;
	IBOutlet id imageView;
	
	
	NSPoint pageMargin;
	NSPoint pageBarMargin;
	BOOL pageMover;
	int pageMoverNum;
	
	BOOL drawPageBar;
	NSPoint mouseOldPoint;
	NSRect pageBarStringRect;
	BOOL pageBarShowThumbnail;
	NSRect pageBarRect;	
	float pageBarWidth;
	float pageBarHeight;
	int pageBarPosition;
	
	NSFont *pageBarFont; 
	NSColor *pageBarFontColor;	
	NSColor *pageBarBGColor;
	NSColor *pageBarBorderColor;
	NSColor *pageBarReadedColor;

	
	NSFont *textFont;
	NSColor *textFontColor;
	NSColor *textBGColor;
	NSColor *textBorderColor;
	
	BOOL autoHidePageBar;
	BOOL autoHidedPageBar;
	BOOL autoHidePageString;
	BOOL autoHidedPageString;
	NSAttributedString *pageString;
	NSAttributedString *infoString;
	
	int tempPageNum;
	int pageStringPosition;
}
NSRect COIntRect(NSRect aRect);
-(void)setPreferences;

-(void)drawAccessory;

-(void)mouseMoved:(NSEvent*)theEvent;
-(void)setSlideshow:(BOOL)b;
-(void)setInfoString:(NSString*)string;
-(NSRect)infoStringRect;

-(void)hideAccessory;

-(void)setPageString:(NSString*)string;
-(NSString*)pageString;
-(NSRect)pageStringRect;

-(void)drawPageBar;
-(NSRect)pageBarRect;
-(NSRect)pageMoverRect;
-(void)drawPageMover:(int)page;
-(BOOL)pageMover;
-(int)tempPageNum;

-(BOOL)isMouseInPageBar;



@end
