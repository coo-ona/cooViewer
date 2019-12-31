/*****************************************************************************
 * HIDRemoteControlDevice.h
 * RemoteControlWrapper
 *
 * Created by Martin Kahr on 11.03.06 under a MIT-style license. 
 * Copyright (c) 2006 martinkahr.com. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a 
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED ‚ÄúAS IS‚Äù, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *****************************************************************************/

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

#import "RemoteControl.h"

/*
	Base class for HID based remote control devices
 */
@interface HIDRemoteControlDevice : RemoteControl {
	IOHIDDeviceInterface** hidDeviceInterface;
	IOHIDQueueInterface**  queue;
	NSMutableArray*		   allCookies;
	NSMutableDictionary*   cookieToButtonMapping;
	
	__strong CFRunLoopSourceRef	   eventSource;
	
	BOOL openInExclusiveMode;
	BOOL processesBacklog;	
	
	int supportedButtonEvents;
}

// When your application needs to much time on the main thread when processing an event other events
// may already be received which are put on a backlog. As soon as your main thread
// has some spare time this backlog is processed and may flood your delegate with calls.
// Backlog processing is turned off by default.
- (BOOL) processesBacklog;
- (void) setProcessesBacklog: (BOOL) value;

// methods that should be overridden by subclasses
- (void) setCookieMappingInDictionary: (NSMutableDictionary*) cookieToButtonMapping;

- (void) sendRemoteButtonEvent: (RemoteControlEventIdentifier) event pressedDown: (BOOL) pressedDown;

+ (const char*) remoteControlDeviceName;

// protected methods
- (void) openRemoteControlDevice;
- (void) closeRemoteControlDevice: (BOOL) shallSendNotifications;

+ (io_object_t) findRemoteDevice;
+ (BOOL) isRemoteAvailable;

@end
