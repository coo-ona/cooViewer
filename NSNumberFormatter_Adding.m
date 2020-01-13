//
//  NSNumberFormatter_Adding.m
//  cooViewer
//
//  Created by coo on 08/01/20.
//  Copyright 2008 coo. All rights reserved.
//

#import "NSNumberFormatter_Adding.h"


@implementation NSNumberFormatter (Adding)

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error
{
	NSCharacterSet *nonDigits = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
	if ([partialString rangeOfCharacterFromSet:nonDigits].location != NSNotFound){
        *error = @"Input is not an integer";
        return (NO);
    } else {
        *error = nil;
        return (YES);
	}
}
/*
- (BOOL) isPartialStringValid: (NSString **) partialStringPtr
        proposedSelectedRange: (NSRangePointer) proposedSelRangePtr
               originalString: (NSString *) origString
        originalSelectedRange: (NSRange) origSelRange
             errorDescription: (NSString **) error
{
    NSCharacterSet *nonDigits = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
	if ([*partialStringPtr rangeOfCharacterFromSet:nonDigits].location != NSNotFound){
        *error = @"Input is not an integer";
        return (NO);
    } else {
        *error = nil;
        return (YES);
	}	
	
} */
/*
- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
	   proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
			  originalString:(NSString *)origString
	   originalSelectedRange:(NSRange)origSelRange
			errorDescription:(NSString **)error
{
	[super isPartialStringValid:&partialStringPtr
		  proposedSelectedRange:proposedSelRangePtr
				 originalString:origString
		  originalSelectedRange:origSelRange
			   errorDescription:&error
		];
}*/
@end
