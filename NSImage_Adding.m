//
//  NSImage_Adding.m
//  cooViewer
//

#import "NSImage_Adding.h"

@implementation NSImage (Adding)

- (NSSize)pixelsSize {
    NSImageRep *imagerep = [[self representations] firstObject];
    return NSMakeSize([imagerep pixelsWide], [imagerep pixelsHigh]);
}

@end
