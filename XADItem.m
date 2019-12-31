//
//  XADItem.m
//  cooViewer
//
//  Created by coo on 08/01/20.
//  Copyright 2008 coo. All rights reserved.
//

#import "XADItem.h"


@implementation XADItem

- (id)initWithPath:(NSString *)inStr andWrapper:(XADWrapper*)inWrapper
{
    self = [super init];
    if (self) {
		path=[inStr retain];
		wrapper = [inWrapper retain];
	}
    return self;
}
- (void)dealloc
{
	if(path)[path release];
	if(wrapper)[wrapper release];
	
	[super dealloc];
}

-(NSString*)path
{
	return path;
}
-(NSData*)data
{
	return [wrapper itemForPath:path];
}
@end
