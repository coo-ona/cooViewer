//
//  AccessorySettingView.h
//  cooViewer
//
//  Created by coo on 08/02/15.
//  Copyright 2008 coo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AccessoryView.h"


@interface AccessorySettingView : AccessoryView {
	int positionSettingMode;
}
-(void)setPositionSettingMode:(BOOL)b;
-(BOOL)positionSettingMode;

-(int)pageBarPosition;
-(int)pageNumPosition;
-(NSDictionary*)pageBarSize;
-(NSDictionary*)pageMargin;
-(NSDictionary*)pageBarMargin;

-(void)setPageBarBGColor:(NSColor*)color;
-(void)setPageBarBorderColor:(NSColor*)color;
-(void)setPageBarReadedColor:(NSColor*)color;
-(void)setTextFontColor:(NSColor*)color;
-(void)setTextBGColor:(NSColor*)color;
-(void)setTextBorderColor:(NSColor*)color;
-(void)setTextFont:(NSFont*)font;

@end
