#import "NSString_Compare.h"
#include <sys/param.h>


const UCCollateOptions FINDER_COMPARE_OPTIONS =
kUCCollateComposeInsensitiveMask
| kUCCollateWidthInsensitiveMask
| kUCCollateCaseInsensitiveMask
| kUCCollateDigitsOverrideMask
| kUCCollateDigitsAsNumberMask
| kUCCollatePunctuationSignificantMask;

@implementation NSString (AddingCompare)
- (NSComparisonResult)finderCompareS:(NSString *)aString
{
	SInt32 compareResult;
	UniChar buff1[MAXPATHLEN];
	UniChar buff2[MAXPATHLEN];
	
	[self getCharacters:buff1];
	[aString getCharacters:buff2];
	
	UCCompareTextDefault(FINDER_COMPARE_OPTIONS, buff1, [self length], buff2, [aString length], NULL, &compareResult);
	
	return((NSComparisonResult)compareResult);      
}

- (NSComparisonResult)randomCompare:(NSString *)otherString
{
    int n;
	
    srand(rand()%time(NULL));
	//srand((unsigned)time(NULL));
    n = rand()%3;
	
    switch(n) {
        case 0: return NSOrderedAscending; break; //左小さい
        case 1: return NSOrderedSame; break; //同じ
        case 2: return NSOrderedDescending; break; //右小さい
    }
	
    return NSOrderedSame;
}

- (NSComparisonResult)fileCreationDateCompare:(NSString *)otherString
{
	NSFileManager *manager = [NSFileManager defaultManager];
	NSDate *sourceDate = [[manager fileAttributesAtPath:self traverseLink:YES] fileCreationDate];
	NSDate *otherDate = [[manager fileAttributesAtPath:otherString traverseLink:YES] fileCreationDate];
	NSComparisonResult res = [sourceDate compare:otherDate];
	if (res == NSOrderedSame) {
		return [self finderCompareS:otherString];
	} else {
		return res;
	}
}

- (NSComparisonResult)fileModificationDateCompare:(NSString *)otherString
{
	NSFileManager *manager = [NSFileManager defaultManager];
	NSDate *sourceDate = [[manager fileAttributesAtPath:self traverseLink:YES] fileModificationDate];
	NSDate *otherDate = [[manager fileAttributesAtPath:otherString traverseLink:YES] fileModificationDate];
	NSComparisonResult res = [sourceDate compare:otherDate];
	if (res == NSOrderedSame) {
		return [self finderCompareS:otherString];
	} else {
		return res;
	}
}

- (NSComparisonResult)versionCompare:(NSString *)otherString
{
	NSArray *selfArray = [self componentsSeparatedByString:@"b"];
	NSArray *otherArray = [otherString componentsSeparatedByString:@"b"];
	NSString *ver=[selfArray objectAtIndex:0];
	NSString *beta=nil;
	NSString *otherVer=[otherArray objectAtIndex:0];
	NSString *otherBeta=nil;
	if ([selfArray count] == 2) beta = [selfArray objectAtIndex:1];
	if ([otherArray count] == 2) otherBeta = [otherArray objectAtIndex:1];
	
	NSComparisonResult res = [ver compare:otherVer];
	if (res == NSOrderedSame) {
		if (beta == nil) return NSOrderedDescending;
		if (otherBeta == nil) return NSOrderedAscending;
		return [beta compare:otherBeta];
	} else {
		return res;
	}
}
@end