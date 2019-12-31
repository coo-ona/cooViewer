#import "NSDictionary_Adding.h"


@implementation NSDictionary (Adding)

/*
 0:nextpage	1:prevpage	2:halfnext	3:halfprev	4:lastpage	5:toppage
 6:nextbookmark	7:prevbookmark	8:nextfolder	9:prevfolder	10:add/removebookmark
 11:switchSingle	12:shownumber	13:skip	14:backskip	15:origRight	16:origLeft
 17:slideshow	18:showThumbnail	19:changeReadMode 20:showPageBar 21:Go to Page
 22:show in FinderR 23:show in finderL 
 24:PageUp 25:PageDown 26:PageUp+PrevPage 27:PageDown+NextPage
 28:ScrollToTop 29:ScrollToEnd 30:ScrollUp 31:ScrollDown
 32:scrollLeft 33:Scrollright
 34:loupe
 35:nextSubFolder 36:prevSubFolder
 37:loupeRatePlus 38loupeRateMinus
 39:goto%
 
 40:rotateRight 41:rotateLeft
 42:changeViewMode 
 51:enlargeViewMode
 52:reduceViewMode
 43:trashRight 44:trashLeft
 45:changeSortMode
 46:close
 47:random
 
 48:openTheLastPage
 49:switchFullScreen
 50:minimizeWindow
 */
- (NSComparisonResult)keyArrayCompare:(NSDictionary*)otherDic
{
	id action = [NSString stringWithFormat:@"%i",[[self objectForKey:@"action"] intValue]];
	id otherAction = [NSString stringWithFormat:@"%i",[[otherDic objectForKey:@"action"] intValue]];
	NSArray *array = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"13",@"14",@"21",@"39",@"48",@"17",
		@"6",@"7",@"10",@"8",@"9",@"35",@"36",
		@"18",@"40",@"41",@"42",@"51",@"52",@"15",@"16",@"22",
		@"23",@"43",@"44",@"11",@"19",@"45",@"47",@"12",
		@"20",@"34",@"37",@"38",@"24",@"25",@"26",
		@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"46",@"49",@"50",nil];
	if ([array indexOfObject:action] != NSNotFound) {
		if ([array indexOfObject:action] < [array indexOfObject:otherAction]) return NSOrderedAscending;
		if ([array indexOfObject:action] == [array indexOfObject:otherAction]) {
			NSComparisonResult result = [[self objectForKey:@"key"] compare:[otherDic objectForKey:@"key"] options:NSCaseInsensitiveSearch];
			if (result == NSOrderedSame) {
				result = [(NSNumber*)[self objectForKey:@"modifier"] compare:(NSNumber*)[otherDic objectForKey:@"modifier"]];
			}
			return result;
		}
		if ([array indexOfObject:action] > [array indexOfObject:otherAction]) return NSOrderedDescending;
	}
	if (action < otherAction) return NSOrderedAscending;
	if (action == otherAction) return NSOrderedSame;
	if (action > otherAction) return NSOrderedDescending;
	return NSOrderedSame;
}


/*
 0:next/prevpage 1:halfnext/prevpage 2:last/toppage 3:next/prevbookmark
 4:next/prevfolder 5:skip/backskip 6:nextpage 7:prevpage 8:halfnext
 9:halfprev 10:lastpage	11:toppage 12:nextbookmark	
 13:prevbookmark	14:nextfolder 15:prevfolder 16:add/removebookmark
 17:switchSingle 18:shownumber 19:skip 20:backskip
 21:origRight 22:origLeft 23:slideshow 24:showThumbnail
 25:changeReadMode 26:showPageBar 27:ViewOriginal(L/R) 28:Show in Finder(right)
 29:Show in Finder(left) 30:Show in Finder(L/R)
 
 31:PageUp 32:PageDown 33:PageUp+PrevPage 34:PageDown+NextPage
 35:ScrollToTop 36:ScrollToEnd 37:ScrollUp 38:ScrollDown
 39:scrollLeft 40:Scrollright 41:DragScroll 42:PageUp/down+Prev/nextPage
 43:loupe
 44:nextSubFolder 45:prevSubFolder 46:nextprevSubFolder
 47:loupeRatePlus 48loupeRateMinus 
 
 49:rotateRight 50:rotateLeft
 51:changeViewMode
 63:enlargeViewMode
 64:reduceViewMode
 52:trashRight 53:trashLeft
 54:trash(L/R)
 55:rotate(L/R)
 56:changeSortMode
 57:close
 58:random
 59:ContextualMenu
 
 60:openTheLastPage
 61:switchFullScreen
 62:minimizeWindow
 */
- (NSComparisonResult)mouseArrayCompare:(NSDictionary*)otherDic
{
	id action = [NSString stringWithFormat:@"%i",[[self objectForKey:@"action"] intValue]];
	id otherAction = [NSString stringWithFormat:@"%i",[[otherDic objectForKey:@"action"] intValue]];
	NSArray *array = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"46",@"5",@"27",@"30",@"54",@"55",@"42",
		@"6",@"7",@"8",@"9",@"10",@"11",@"19",@"20",@"60",@"23",@"12",@"13",@"16",@"14",@"15",@"44",@"45",
		@"24",@"49",@"50",@"51",@"63",@"64",@"21",@"22",@"28",@"29",@"52",@"53",@"17",@"25",@"56",@"58",@"18",@"26",@"43",@"47",@"48",@"41",@"31",@"32",@"33",@"34",
		@"35",@"36",@"37",@"38",@"39",@"40",@"57",@"61",@"62",@"59",nil];
	if ([array indexOfObject:action] != NSNotFound) {
		if ([array indexOfObject:action] < [array indexOfObject:otherAction]) return NSOrderedAscending;
		if ([array indexOfObject:action] == [array indexOfObject:otherAction]) {
			return [(NSNumber*)[self objectForKey:@"modifier"] compare:(NSNumber*)[otherDic objectForKey:@"modifier"]];
		}
		if ([array indexOfObject:action] > [array indexOfObject:otherAction]) return NSOrderedDescending;
	}
	if (action < otherAction) return NSOrderedAscending;
	if (action == otherAction) return NSOrderedSame;
	if (action > otherAction) return NSOrderedDescending;
	return NSOrderedSame;
}
@end
