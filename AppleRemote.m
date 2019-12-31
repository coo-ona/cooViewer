/*****************************************************************************
 * RemoteControlWrapper.m
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

#import "AppleRemote.h"

#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/hid/IOHIDKeys.h>
#import <IOKit/IOKitLib.h>

static void IOREInterestCallback(
								 void *			refcon,
								 io_service_t	service,
								 uint32_t		messageType,
								 void *			messageArgument );


#ifndef NSAppKitVersionNumber10_4
	#define NSAppKitVersionNumber10_4 824
#endif

#ifndef NSAppKitVersionNumber10_5
	#define NSAppKitVersionNumber10_5 949
#endif

const char* AppleRemoteDeviceName = "AppleIRController";

@implementation AppleRemote

+ (const char*) remoteControlDeviceName {
	return AppleRemoteDeviceName;
}

- (id) initWithDelegate: (id) _remoteControlDelegate {
	if ((self = [super initWithDelegate: _remoteControlDelegate])) {
		// A security update in february of 2007 introduced an odd behavior.
		// Whenever SecureEventInput is activated or deactivated the exclusive access
		// to the apple remote control device is lost. This leads to very strange behavior where
		// a press on the Menu button activates FrontRow while your app still gets the event.
		// A great number of people have complained about this.	
		//
		// Finally I found a way to get the state of the SecureEventInput
		// With that information I regain access to the device each time when the SecureEventInput state
		// is changing.
		io_registry_entry_t root = IORegistryGetRootEntry( kIOMasterPortDefault );  
		if (root != MACH_PORT_NULL) {
			notifyPort = IONotificationPortCreate( kIOMasterPortDefault );
			if (notifyPort) {
				CFRunLoopSourceRef runLoopSource = IONotificationPortGetRunLoopSource(notifyPort);	
				CFRunLoopRef gRunLoop = CFRunLoopGetCurrent();
				CFRunLoopAddSource(gRunLoop, runLoopSource, kCFRunLoopDefaultMode);
				
				io_registry_entry_t entry = IORegistryEntryFromPath( kIOMasterPortDefault, kIOServicePlane ":/");
				if (entry != MACH_PORT_NULL) {
					kern_return_t kr;
					kr = IOServiceAddInterestNotification(notifyPort,
														  entry,
														  kIOBusyInterest, 
														  &IOREInterestCallback, self, &eventSecureInputNotification );
					if (kr != KERN_SUCCESS) {				
						NSLog(@"Error when installing EventSecureInput Notification");
						IONotificationPortDestroy(notifyPort);
						notifyPort = NULL;
					}
					IOObjectRelease(entry);
				}				
			}
			IOObjectRelease(root);
		}
		
		lastSecureEventInputState = [self retrieveSecureEventInputState];			
	}
	return self;
}

- (void)dealloc
{
	IONotificationPortDestroy(notifyPort);
	notifyPort = NULL;
	IOObjectRelease (eventSecureInputNotification);
	eventSecureInputNotification = MACH_PORT_NULL;		
	
	[super dealloc];
}

- (void)finalize
{
	IONotificationPortDestroy(notifyPort);	
	notifyPort = NULL;
	// Although IOObjectRelease is not documented as thread safe, I was assured at WWDC09 that it is.	
	IOObjectRelease (eventSecureInputNotification);
	eventSecureInputNotification = MACH_PORT_NULL;
	
	[super finalize];
}

- (void) setCookieMappingInDictionary: (NSMutableDictionary*) _cookieToButtonMapping	{

	// check if we are using the rb device driver instead of the one from Apple
	io_object_t foundRemoteDevice = [[self class] findRemoteDevice];
	BOOL leopardEmulation = NO;
	if (foundRemoteDevice != 0) {
		CFTypeRef leoEmuAttr = IORegistryEntryCreateCFProperty(foundRemoteDevice, CFSTR("RemoteBuddyEmulationV2"), kCFAllocatorDefault, 0);
		if (leoEmuAttr) {
			leopardEmulation = CFEqual(leoEmuAttr, kCFBooleanTrue);			
			CFRelease(leoEmuAttr);
		}
		IOObjectRelease(foundRemoteDevice);
	}

	if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_4) {
		// 10.4.x Tiger
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlus]		forKey:@"14_12_11_6_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonMinus]		forKey:@"14_13_11_6_"];		
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonMenu]		forKey:@"14_7_6_14_7_6_"];			
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlay]		forKey:@"14_8_6_14_8_6_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonRight]		forKey:@"14_9_6_14_9_6_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonLeft]		forKey:@"14_10_6_14_10_6_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonRight_Hold]	forKey:@"14_6_4_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonLeft_Hold]	forKey:@"14_6_3_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonMenu_Hold]	forKey:@"14_6_14_6_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlay_Hold]	forKey:@"18_14_6_18_14_6_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteControl_Switched]	forKey:@"19_"];			
	} else if ((floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_5) || (leopardEmulation)) {
		// 10.5.x Leopard
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlus]		forKey:@"31_29_28_19_18_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonMinus]		forKey:@"31_30_28_19_18_"];	
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonMenu]		forKey:@"31_20_19_18_31_20_19_18_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlay]		forKey:@"31_21_19_18_31_21_19_18_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonRight]		forKey:@"31_22_19_18_31_22_19_18_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonLeft]		forKey:@"31_23_19_18_31_23_19_18_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonRight_Hold]	forKey:@"31_19_18_4_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonLeft_Hold]	forKey:@"31_19_18_3_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonMenu_Hold]	forKey:@"31_19_18_31_19_18_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlay_Hold]	forKey:@"35_31_19_18_35_31_19_18_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteControl_Switched]	forKey:@"19_"];			
	} else {
		// 10.6.2 Snow Leopard
		// Note: does not work on 10.6.0 and 10.6.1		
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlus]		forKey:@"33_31_30_21_20_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonMinus]		forKey:@"33_32_30_21_20_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonMenu]		forKey:@"33_22_21_20_2_33_22_21_20_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlay]		forKey:@"33_23_21_20_2_33_23_21_20_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonRight]		forKey:@"33_24_21_20_2_33_24_21_20_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonLeft]		forKey:@"33_25_21_20_2_33_25_21_20_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonRight_Hold]	forKey:@"33_21_20_14_12_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonLeft_Hold]	forKey:@"33_21_20_13_12_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonMenu_Hold]	forKey:@"33_21_20_2_33_21_20_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlay_Hold]	forKey:@"37_33_21_20_2_37_33_21_20_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteControl_Switched]	forKey:@"19_"];		
		
		// new Aluminum model
		// Mappings changed due to addition of a 7th center button
		// Treat the new center button and play/pause button the same
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlay]		forKey:@"33_21_20_8_2_33_21_20_8_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlay]		forKey:@"33_21_20_3_2_33_21_20_3_2_"];
		[_cookieToButtonMapping setObject:[NSNumber numberWithInt:kRemoteButtonPlay_Hold]	forKey:@"33_21_20_11_2_33_21_20_11_2_"];		
	}

}

- (void) sendRemoteButtonEvent: (RemoteControlEventIdentifier) event pressedDown: (BOOL) pressedDown {
	if (pressedDown == NO && event == kRemoteButtonMenu_Hold) {
		// There is no seperate event for pressed down on menu hold. We are simulating that event here
		[super sendRemoteButtonEvent:event pressedDown:YES];
	}	
	
	[super sendRemoteButtonEvent:event pressedDown:pressedDown];
	
	if (pressedDown && (event == kRemoteButtonRight || event == kRemoteButtonLeft || event == kRemoteButtonPlay || event == kRemoteButtonMenu || event == kRemoteButtonPlay_Hold)) {
		// There is no seperate event when the button is being released. We are simulating that event here
		[super sendRemoteButtonEvent:event pressedDown:NO];
	}
}

// overwritten to handle a special case with old versions of the rb driver
+ (io_object_t) findRemoteDevice
{
	CFMutableDictionaryRef hidMatchDictionary = NULL;
	IOReturn ioReturnValue = kIOReturnSuccess;	
	io_iterator_t hidObjectIterator = 0;
	io_object_t	hidDevice = 0;
	
	// Set up a matching dictionary to search the I/O Registry by class
	// name for all HID class devices
	hidMatchDictionary = IOServiceMatching([self remoteControlDeviceName]);
	
	// Now search I/O Registry for matching devices.
	ioReturnValue = IOServiceGetMatchingServices(kIOMasterPortDefault, hidMatchDictionary, &hidObjectIterator);
	
	if ((ioReturnValue == kIOReturnSuccess) && (hidObjectIterator != 0))
	{
		io_object_t matchingService = 0, foundService = 0;
		BOOL finalMatch = NO;
		
		while (matchingService = IOIteratorNext(hidObjectIterator))
		{
			if (!finalMatch)
			{
				CFTypeRef className;
				
				if (!foundService)
				{
					if (IOObjectRetain(matchingService) == kIOReturnSuccess)
					{
						foundService = matchingService;
					}
				}
				
				if (className = IORegistryEntryCreateCFProperty((io_registry_entry_t)matchingService, CFSTR("IOClass"), kCFAllocatorDefault, 0))
				{
					if ([(NSString *)className isEqual:[NSString stringWithUTF8String:[self remoteControlDeviceName]]])
					{
						if (foundService)
						{
							IOObjectRelease(foundService);
							foundService = 0;
						}
						
						if (IOObjectRetain(matchingService) == kIOReturnSuccess)
						{
							foundService = matchingService;
							finalMatch = YES;
						}
					}
					
					CFRelease(className);
				}
			}
			
			IOObjectRelease(matchingService);
		}
		
		hidDevice = foundService;
		
		// release the iterator
		IOObjectRelease(hidObjectIterator);
	}
	
	return hidDevice;
}

- (BOOL) retrieveSecureEventInputState {
	BOOL returnValue = NO;
	
	io_registry_entry_t root = IORegistryGetRootEntry( kIOMasterPortDefault );  
	if (root != MACH_PORT_NULL) {
		CFArrayRef arrayRef = IORegistryEntrySearchCFProperty(root, kIOServicePlane, CFSTR("IOConsoleUsers"), NULL, kIORegistryIterateRecursively);
		if (arrayRef != NULL) {
			NSArray* array = (NSArray*)arrayRef;
			unsigned int i;
			for(i=0; i < [array count]; i++) {
				NSDictionary* dict = [array objectAtIndex:i];
				if ([[dict objectForKey: @"kCGSSessionUserNameKey"] isEqual: NSUserName()]) {					
					returnValue = ([dict objectForKey:@"kCGSSessionSecureInputPID"] != nil);					
				}
			}
			CFRelease(arrayRef);
		}
		IOObjectRelease(root);
	}
	return returnValue;
}

- (void) dealWithSecureEventInputChange {
	if ([self isListeningToRemote] == NO || [self isOpenInExclusiveMode] == NO) return;
	
	BOOL newState = [self retrieveSecureEventInputState];
	if (lastSecureEventInputState == newState) return;	
	
	// close and open the device again
	[self closeRemoteControlDevice: NO];
	[self openRemoteControlDevice];
	
	lastSecureEventInputState = newState;
} 

static void IOREInterestCallback(void *			refcon,
								 io_service_t	service,
								 uint32_t		messageType,
								 void *			messageArgument )
{	
	(void)service;
	(void)messageType;
	(void)messageArgument;
	
	// With garbage collection, such a cast is dangerous because the refcon parameter is not strong.  That means that, unless someone has a strong reference somewhere, the AppleRemote may have already been finalized.  But it should be pretty safe in this case, since if the AppleRemote is finalized, the callback is cancelled and should never be invoked.
	AppleRemote* remote = (AppleRemote*)refcon;
	
	[remote dealWithSecureEventInputChange];
}

@end
