//
//  COTextView.h
//  cooViewer
//
//  Created by coo on 08/02/17.
//  Copyright 2008 coo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RemoteControl;

@interface COTextView : NSTextView
{
	id target;
	SEL selector;
}
@end
