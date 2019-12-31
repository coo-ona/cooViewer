#import <Foundation/Foundation.h>

@interface NSString (AddingCompare)

- (NSComparisonResult)finderCompareS:(NSString *)aString;
- (NSComparisonResult)randomCompare:(NSString *)aString;
- (NSComparisonResult)fileCreationDateCompare:(NSString *)otherString;
- (NSComparisonResult)fileModificationDateCompare:(NSString *)otherString;

- (NSComparisonResult)versionCompare:(NSString *)aString;
@end