//
//  XADItem.h
//  cooViewer
//
//  Created by coo on 08/01/20.
//  Copyright 2008 coo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XADWrapper.h"


@interface XADItem : NSObject {

	NSString *path;
	XADWrapper *wrapper;
}
- (id)initWithPath:(NSString *)inStr andWrapper:(XADWrapper*)inWrapper;
-(NSString*)path;
-(NSData*)data;
@end
