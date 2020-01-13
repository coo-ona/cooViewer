/*****************************************************************************
 * HIDRemoteControlDevice.m
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
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *****************************************************************************/

#import "HIDRemoteControlDevice.h"

#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/hid/IOHIDKeys.h>

@interface HIDRemoteControlDevice (PrivateMethods) 
- (NSDictionary*) cookieToButtonMapping;
- (IOHIDQueueInterface**) queue;
- (IOHIDDeviceInterface**) hidDeviceInterface;
- (void) handleEventWithCookieString: (NSString*) cookieString sumOfValues: (SInt32) sumOfValues; 
- (void) removeNotifcationObserver;
- (void) remoteControlAvailable:(NSNotification *)notification;

@end

@interface HIDRemoteControlDevice (IOKitMethods) 
- (IOHIDDeviceInterface**) createInterfaceForDevice: (io_object_t) hidDevice;
- (BOOL) initializeCookies;
- (BOOL) openDevice;
@end

@implementation HIDRemoteControlDevice

// This class acts as an abstract base class - therefore subclasses have to override this method
+ (const char*) remoteControlDeviceName {
	return "";
}

+ (BOOL) isRemoteAvailable {	
	io_object_t hidDevice = [self findRemoteDevice];
	if (hidDevice != 0) {
		IOObjectRelease(hidDevice);
		return YES;
	} else {
		return NO;		
	}
}

+ (io_object_t) findRemoteDevice {
	CFMutableDictionaryRef hidMatchDictionary = NULL;
	IOReturn ioReturnValue = kIOReturnSuccess;	
	io_iterator_t hidObjectIterator = 0;
	io_object_t	hidDevice = 0;
	
	// Set up a matching dictionary to search the I/O Registry by class
	// name for all HID class devices
	hidMatchDictionary = IOServiceMatching([self remoteControlDeviceName]);
	
	// Now search I/O Registry for matching devices.
	ioReturnValue = IOServiceGetMatchingServices(kIOMasterPortDefault, hidMatchDictionary, &hidObjectIterator);
	
	if (hidObjectIterator != 0) {
		if (ioReturnValue == kIOReturnSuccess) {
			hidDevice = IOIteratorNext(hidObjectIterator);
		}
		// release the iterator
		IOObjectRelease(hidObjectIterator);
	}
	
	// Returned value must be released by the caller when it is finished
	return hidDevice;
}

- (id) initWithDelegate: (id) _remoteControlDelegate {	
	if ([[self class] isRemoteAvailable] == NO) {
		[super dealloc];
		self = nil;
	} else if ( (self = [super initWithDelegate: _remoteControlDelegate]) ) {
		openInExclusiveMode = YES;
		queue = NULL;
		hidDeviceInterface = NULL;
		cookieToButtonMapping = [[NSMutableDictionary alloc] init];
		
		[self setCookieMappingInDictionary: cookieToButtonMapping];

		NSEnumerator* enumerator = [cookieToButtonMapping objectEnumerator];
		NSNumber* identifier;
		supportedButtonEvents = 0;
		while( (identifier = [enumerator nextObject]) ) {
			supportedButtonEvents |= [identifier intValue];
		}		
	}
	
	return self;
}

- (void) dealloc {
	[self removeNotifcationObserver];
	[self stopListening:self];
	[cookieToButtonMapping release]; cookieToButtonMapping = nil;
	[super dealloc];
}

- (void) sendRemoteButtonEvent: (RemoteControlEventIdentifier) event pressedDown: (BOOL) pressedDown {
	[delegate sendRemoteButtonEvent: event pressedDown: pressedDown remoteControl:self];
}

- (void) setCookieMappingInDictionary: (NSMutableDictionary*) aCookieToButtonMapping {
	(void)aCookieToButtonMapping;
}
- (int) remoteIdSwitchCookie {
	return 0;
}

- (BOOL) sendsEventForButtonIdentifier: (RemoteControlEventIdentifier) identifier {
	return (supportedButtonEvents & identifier) == identifier;
}
	
- (BOOL) isListeningToRemote {
	return (hidDeviceInterface != NULL && allCookies != NULL && queue != NULL);	
}

- (void) setListeningToRemote: (BOOL) value {
	if (value == NO) {
		[self stopListening:self];
	} else {
		[self startListening:self];
	}
}

- (BOOL) isOpenInExclusiveMode {
	return openInExclusiveMode;
}
- (void) setOpenInExclusiveMode: (BOOL) value {
	openInExclusiveMode = value;
}

- (BOOL) processesBacklog {
	return processesBacklog;
}
- (void) setProcessesBacklog: (BOOL) value {
	processesBacklog = value;
}

- (void) openRemoteControlDevice {
	io_object_t hidDevice = [[self class] findRemoteDevice];
	if (hidDevice == 0) return;
	
	if ([self createInterfaceForDevice:hidDevice] == NULL) {
		goto error;
	}
	
	if ([self initializeCookies]==NO) {
		goto error;
	}
	
	if ([self openDevice]==NO) {
		goto error;
	}
	goto cleanup;
	
error:
	[self stopListening:self];
	
cleanup:	
	IOObjectRelease(hidDevice);	
}

- (void) closeRemoteControlDevice: (BOOL) shallSendNotifications {
	BOOL sendNotification = NO;
	
	if (eventSource != NULL) {
		CFRunLoopRemoveSource(CFRunLoopGetCurrent(), eventSource, kCFRunLoopDefaultMode);
		CFRelease(eventSource);
		eventSource = NULL;
	}
	if (queue != NULL) {
		(*queue)->stop(queue);		
		
		//dispose of queue
		(*queue)->dispose(queue);		
		
		//release the queue we allocated
		(*queue)->Release(queue);	
		
		queue = NULL;
		
		sendNotification = YES;
	}
	
	if (allCookies != nil) {
		[allCookies autorelease];
		allCookies = nil;
	}
	
	if (hidDeviceInterface != NULL) {
		//close the device
		(*hidDeviceInterface)->close(hidDeviceInterface);
		
		//release the interface	
		(*hidDeviceInterface)->Release(hidDeviceInterface);
		
		hidDeviceInterface = NULL;
	}
		
	if (shallSendNotifications && [self isOpenInExclusiveMode] && sendNotification) {
		[[self class] sendFinishedNotifcationForAppIdentifier: nil];		
	}		
}

- (IBAction) startListening: (id) sender {	
	(void)sender;
	
	if ([self isListeningToRemote]) return;

	[self willChangeValueForKey:@"listeningToRemote"];	

	[self openRemoteControlDevice];
	
	[self didChangeValueForKey:@"listeningToRemote"];				
}

- (IBAction) stopListening: (id) sender {
	(void)sender;

	if ([self isListeningToRemote]==NO) return;
	
	[self willChangeValueForKey:@"listeningToRemote"];
	
	[self closeRemoteControlDevice: YES];
	
	[self didChangeValueForKey:@"listeningToRemote"];	
}

@end

@implementation HIDRemoteControlDevice (PrivateMethods) 

- (IOHIDQueueInterface**) queue {
	return queue;
}

- (IOHIDDeviceInterface**) hidDeviceInterface {
	return hidDeviceInterface;
}


- (NSDictionary*) cookieToButtonMapping {
	return cookieToButtonMapping;
}

- (NSString*) validCookieSubstring: (NSString*) cookieString {
	if (cookieString == nil || [cookieString length] == 0) return nil;
	NSEnumerator* keyEnum = [[self cookieToButtonMapping] keyEnumerator];
	NSString* key;
	
	// find the best match
	while( (key = [keyEnum nextObject]) ) {
		NSRange range = [cookieString rangeOfString:key];
		if (range.location == 0) return key; 
	}
	return nil;
}

- (void) handleEventWithCookieString: (NSString*) cookieString sumOfValues: (SInt32) sumOfValues {
	/*
	if (previousRemainingCookieString) {
		cookieString = [previousRemainingCookieString stringByAppendingString: cookieString];
		NSLog(@"New cookie string is %@", cookieString);
		[previousRemainingCookieString release], previousRemainingCookieString=nil;							
	}*/
	if (cookieString == nil || [cookieString length] == 0) return;
			
	NSNumber* buttonId = [[self cookieToButtonMapping] objectForKey: cookieString];
	if (buttonId != nil) {
		[self sendRemoteButtonEvent: [buttonId intValue] pressedDown: (sumOfValues>0)];
	} else {
		// let's see if this is the first event after a restart of the OS. 
		// In this case the event has a prefix that we can ignore and we just get the down event but no up event
		NSEnumerator* keyEnum = [[self cookieToButtonMapping] keyEnumerator];
		NSString* key;
		while( (key = [keyEnum nextObject]) ) {
			NSRange range = [cookieString rangeOfString:key];
			if (range.location != NSNotFound && range.location > 0) {
				buttonId = [[self cookieToButtonMapping] objectForKey: key];
				if (buttonId != nil) {
					[self sendRemoteButtonEvent: [buttonId intValue] pressedDown: YES];
					[self sendRemoteButtonEvent: [buttonId intValue] pressedDown: NO];
					return;
				}				
				return;
			}
		}					
		
		// let's see if a number of events are stored in the cookie string. this does
		// happen when the main thread is too busy to handle all incoming events in time.
		NSString* subCookieString;
		NSString* lastSubCookieString=nil;
		while( (subCookieString = [self validCookieSubstring: cookieString]) ) {
			cookieString = [cookieString substringFromIndex: [subCookieString length]];
			lastSubCookieString = subCookieString;
			if (processesBacklog) [self handleEventWithCookieString: subCookieString sumOfValues:sumOfValues];
		}
		if (processesBacklog == NO && lastSubCookieString != nil) {
			// process the last event of the backlog and assume that the button is not pressed down any longer.
			// The events in the backlog do not seem to be in order and therefore (in rare cases) the last event might be 
			// a button pressed down event while in reality the user has released it. 
			// NSLog(@"processing last event of backlog");
			[self handleEventWithCookieString: lastSubCookieString sumOfValues:0];
		}
		if ([cookieString length] > 0) {
			NSLog(@"Unknown button for cookiestring %@", cookieString);
		}		
	}
}

- (void) removeNotifcationObserver {
	NSDistributedNotificationCenter* defaultCenter = [NSDistributedNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self name:FINISHED_USING_REMOTE_CONTROL_NOTIFICATION object:nil];
}

- (void) remoteControlAvailable:(NSNotification *)notification {
	(void)notification;
	[self removeNotifcationObserver];
	[self startListening: self];
}

@end

/*	Callback method for the device queue
Will be called for any event of any type (cookie) to which we subscribe
*/
static void QueueCallbackFunction(void* target,  IOReturn result, void* refcon, void* sender) {	
	(void)refcon;
	(void)sender;
	
	if (target == NULL) {
		NSLog(@"QueueCallbackFunction called with invalid target!");
		return;
	}
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	HIDRemoteControlDevice* remote = (HIDRemoteControlDevice*)target;	
	IOHIDEventStruct event;	
	AbsoluteTime 	 zeroTime = {0,0};
	NSMutableString* cookieString = [NSMutableString string];
	SInt32			 sumOfValues = 0;
	while (result == kIOReturnSuccess)
	{
		result = (*[remote queue])->getNextEvent([remote queue], &event, zeroTime, 0);		
		if ( result != kIOReturnSuccess )
			continue;
	
		//printf("%u %d %p\n", event.elementCookie, event.value, event.longValue);		
		
		if (((int)event.elementCookie)!=5) {
			sumOfValues+=event.value;
			[cookieString appendString:[NSString stringWithFormat:@"%u_", event.elementCookie]];
		}
	}

	[remote handleEventWithCookieString: cookieString sumOfValues: sumOfValues];
	
	[pool release];
}

@implementation HIDRemoteControlDevice (IOKitMethods)

- (IOHIDDeviceInterface**) createInterfaceForDevice: (io_object_t) hidDevice {
	io_name_t				className;
	IOCFPlugInInterface**   plugInInterface = NULL;
	HRESULT					plugInResult = S_OK;
	SInt32					score = 0;
	IOReturn				ioReturnValue = kIOReturnSuccess;
	
	hidDeviceInterface = NULL;
	
	ioReturnValue = IOObjectGetClass(hidDevice, className);
	
	if (ioReturnValue != kIOReturnSuccess) {
		NSLog(@"Error: Failed to get class name.");
		return NULL;
	}
	
	ioReturnValue = IOCreatePlugInInterfaceForService(hidDevice,
													  kIOHIDDeviceUserClientTypeID,
													  kIOCFPlugInInterfaceID,
													  &plugInInterface,
													  &score);
	if (ioReturnValue == kIOReturnSuccess)
	{
		//Call a method of the intermediate plug-in to create the device interface
		plugInResult = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID), (LPVOID) &hidDeviceInterface);
		
		if (plugInResult != S_OK) {
			NSLog(@"Error: Couldn't create HID class device interface");
		}
		// Release
		if (plugInInterface) (*plugInInterface)->Release(plugInInterface);
	}
	return hidDeviceInterface;
}

- (BOOL) initializeCookies {
	IOHIDDeviceInterface122** handle = (IOHIDDeviceInterface122**)hidDeviceInterface;
	IOHIDElementCookie		cookie;
	//long					usage;
	//long					usagePage;
	id						object;
	CFArrayRef				elements = nil;
	NSDictionary*			element;
	IOReturn success;
	
	if (!handle || !(*handle)) return NO;
	
	// Copy all elements, since we're grabbing most of the elements
	// for this device anyway, and thus, it's faster to iterate them
	// ourselves. When grabbing only one or two elements, a matching
	// dictionary should be passed in here instead of NULL.
	
	success = (*handle)->copyMatchingElements(handle, NULL, &elements);
	
	if ( (success == kIOReturnSuccess) && elements ) {		
		/*
		cookies = calloc(NUMBER_OF_APPLE_REMOTE_ACTIONS, sizeof(IOHIDElementCookie)); 
		memset(cookies, 0, sizeof(IOHIDElementCookie) * NUMBER_OF_APPLE_REMOTE_ACTIONS);
		*/
		allCookies = [[NSMutableArray alloc] init];
		
		NSEnumerator *elementsEnumerator = [(NSArray*)elements objectEnumerator];
		
		while ( (element = [elementsEnumerator nextObject]) ) {						
			//Get cookie
			object = [element valueForKey: @kIOHIDElementCookieKey ];
			if (object == nil || ![object isKindOfClass:[NSNumber class]]) continue;
			if (object == 0 || CFGetTypeID(object) != CFNumberGetTypeID()) continue;
			cookie = (IOHIDElementCookie) [object longValue];
			
			//Get usage
			object = [element valueForKey: @kIOHIDElementUsageKey ];
			if (object == nil || ![object isKindOfClass:[NSNumber class]]) continue;			
			//usage = [object longValue];
			
			//Get usage page
			object = [element valueForKey: @kIOHIDElementUsagePageKey ];
			if (object == nil || ![object isKindOfClass:[NSNumber class]]) continue;			
			//usagePage = [object longValue];
			
			//It seems wrong to cast a cookie to a 32 bit integer since it is a void*, but in 64 bit it's actually a uint32_t!  So in both 32 and 64 bit it is 32 bit in size.
			[allCookies addObject: [NSNumber numberWithUnsignedInt:(uint32_t)cookie]];
		}
		
		CFRelease(elements);
	} else {
		return NO;
	}
	
	return YES;
}

- (BOOL) openDevice {
	HRESULT  result;
	
	IOHIDOptionsType openMode = kIOHIDOptionsTypeNone;
	if ([self isOpenInExclusiveMode]) openMode = kIOHIDOptionsTypeSeizeDevice;	
	IOReturn ioReturnValue = (*hidDeviceInterface)->open(hidDeviceInterface, openMode);	
	
	if (ioReturnValue == KERN_SUCCESS) {		
		queue = (*hidDeviceInterface)->allocQueue(hidDeviceInterface);
		if (queue) {
			result = (*queue)->create(queue, 0, 12);	//depth: maximum number of elements in queue before oldest elements in queue begin to be lost.
			if (result == kIOReturnSuccess) {
				IOHIDElementCookie cookie;
				NSEnumerator *allCookiesEnumerator = [allCookies objectEnumerator];
				
				while ( (cookie = (IOHIDElementCookie)[[allCookiesEnumerator nextObject] unsignedIntValue]) ) {
					(*queue)->addElement(queue, cookie, 0);
				}			
										  
				// add callback for async events			
				ioReturnValue = (*queue)->createAsyncEventSource(queue, &eventSource);			
				if (ioReturnValue == KERN_SUCCESS) {
					ioReturnValue = (*queue)->setEventCallout(queue,QueueCallbackFunction, self, NULL);
					if (ioReturnValue == KERN_SUCCESS) {
						CFRunLoopAddSource(CFRunLoopGetCurrent(), eventSource, kCFRunLoopDefaultMode);
						
						//start data delivery to queue
						(*queue)->start(queue);	
						return YES;
					} else {
						NSLog(@"Error when setting event callback");
					}
				} else {
					NSLog(@"Error when creating async event source");
				}
			} else {
				NSLog(@"Error when creating queue");
			}
		} else {
			NSLog(@"Error when opening device");
		}
	} else if (ioReturnValue == kIOReturnExclusiveAccess) {
		// the device is used exclusive by another application
		
		// 1. we register for the FINISHED_USING_REMOTE_CONTROL_NOTIFICATION notification
		NSDistributedNotificationCenter* defaultCenter = [NSDistributedNotificationCenter defaultCenter];
		[defaultCenter addObserver:self selector:@selector(remoteControlAvailable:) name:FINISHED_USING_REMOTE_CONTROL_NOTIFICATION object:nil];
		
		// 2. send a distributed notification that we wanted to use the remote control				
		[[self class] sendRequestForRemoteControlNotification];
	}
	return NO;				
}

@end

