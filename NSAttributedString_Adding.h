//
//  NSAttributedString_Adding.h
//  cooViewer
//
//  Created by coo on 08/02/11.
//  Copyright 2008 coo. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAttributedString (Adding)
-(void)drawInRect:(NSRect)rect bg:(NSColor*)bg border:(NSColor*)border;
-(void)drawInRect:(NSRect)rect bg:(NSColor*)bg;
-(void)drawAtPoint:(NSPoint)pt bg:(NSColor*)bg border:(NSColor*)border;
-(void)drawAtPoint:(NSPoint)pt bg:(NSColor*)bg;
-(NSSize)sizeWithBG;
@end
