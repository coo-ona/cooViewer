#import "PreferenceController.h"
#import "COColorPopUpButton.h"
#import "Controller.h"
#import "AccessorySettingView.h"
#import "NSDictionary_Adding.h"


@implementation PreferenceController

static const int DIALOG_OK		= 128;
static const int DIALOG_CANCEL	= 129;

+ (NSArray*)defaultKeyArray
{
	unichar plus = kRemoteButtonPlus;
	unichar minus = kRemoteButtonMinus;
	unichar menu = kRemoteButtonMenu;
	unichar play = kRemoteButtonPlay;
	unichar right = kRemoteButtonRight;
	unichar left = kRemoteButtonLeft;
	return [NSMutableArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:0],@"action",
				@"z",@"keyname", [NSString stringWithFormat:@"z"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:0],@"action",
				@"left arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSLeftArrowFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:0],@"action",
				@"space",@"keyname", [NSString stringWithFormat:@"%C",0x20],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:1],@"action",
				@"x",@"keyname", [NSString stringWithFormat:@"x"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:1],@"action",
				@"right arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSRightArrowFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:1],@"action",
				@"shift+space",@"keyname", [NSString stringWithFormat:@"%C",0x20],@"key",
				[NSNumber numberWithInt:1],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:2],@"action",
				@"shift+z",@"keyname", [NSString stringWithFormat:@"Z"],@"key",
				[NSNumber numberWithInt:1],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:2],@"action",
				@"shift+left arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSLeftArrowFunctionKey],@"key",
				[NSNumber numberWithInt:1],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:3],@"action",
				@"shift+x",@"keyname", [NSString stringWithFormat:@"X"],@"key",
				[NSNumber numberWithInt:1],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:3],@"action",
				@"shift+right arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSRightArrowFunctionKey],@"key",
				[NSNumber numberWithInt:1],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:4],@"action",
				@"option+z",@"keyname", [NSString stringWithFormat:@"z"],@"key",
				[NSNumber numberWithInt:2],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:4],@"action",
				@"option+left arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSLeftArrowFunctionKey],@"key",
				[NSNumber numberWithInt:2],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:5],@"action",
				@"option+x",@"keyname", [NSString stringWithFormat:@"x"],@"key",
				[NSNumber numberWithInt:2],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:5],@"action",
				@"option+right arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSRightArrowFunctionKey],@"key",
				[NSNumber numberWithInt:2],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:6],@"action",
				@"c",@"keyname", [NSString stringWithFormat:@"c"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:6],@"action",
				@"down arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSDownArrowFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:7],@"action",
				@"d",@"keyname", [NSString stringWithFormat:@"d"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:7],@"action",
				@"up arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSUpArrowFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:8],@"action",
				@"control+c",@"keyname", [NSString stringWithFormat:@"c"],@"key",
				[NSNumber numberWithInt:4],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:8],@"action",
				@"control+down arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSDownArrowFunctionKey],@"key",
				[NSNumber numberWithInt:4],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:9],@"action",
				@"control+d",@"keyname", [NSString stringWithFormat:@"d"],@"key",
				[NSNumber numberWithInt:4],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:9],@"action",
				@"control+up arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSUpArrowFunctionKey],@"key",
				[NSNumber numberWithInt:4],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:10],@"action",
				@"a",@"keyname", [NSString stringWithFormat:@"a"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:11],@"action",
				@"s",@"keyname", [NSString stringWithFormat:@"s"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:12],@"action",
				@"p",@"keyname", [NSString stringWithFormat:@"p"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:13],@"action",
				@"tab",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSTabCharacter],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:10],@"value",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:14],@"action",
				@"shift+tab",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSBackTabCharacter],@"key",
				[NSNumber numberWithInt:1],@"modifier",
				[NSNumber numberWithInt:10],@"value",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:15],@"action",
				@"w",@"keyname", [NSString stringWithFormat:@"w"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:16],@"action",
				@"q",@"keyname", [NSString stringWithFormat:@"q"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:17],@"action",
				@"g",@"keyname", [NSString stringWithFormat:@"g"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:18],@"action",
				@"t",@"keyname", [NSString stringWithFormat:@"t"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:19],@"action",
				@"r",@"keyname", [NSString stringWithFormat:@"r"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:20],@"action",
				@"o",@"keyname", [NSString stringWithFormat:@"o"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:34],@"action",
				@"l",@"keyname", [NSString stringWithFormat:@"l"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:39],@"action",
				@"0",@"keyname", [NSString stringWithFormat:@"0"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:0],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:39],@"action",
				@"1",@"keyname", [NSString stringWithFormat:@"1"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:10],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:39],@"action",
				@"2",@"keyname", [NSString stringWithFormat:@"2"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:20],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:39],@"action",
				@"3",@"keyname", [NSString stringWithFormat:@"3"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:30],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:39],@"action",
				@"4",@"keyname", [NSString stringWithFormat:@"4"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:40],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:39],@"action",
				@"5",@"keyname", [NSString stringWithFormat:@"5"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:50],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:39],@"action",
				@"6",@"keyname", [NSString stringWithFormat:@"6"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:60],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:39],@"action",
				@"7",@"keyname", [NSString stringWithFormat:@"7"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:70],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:39],@"action",
				@"8",@"keyname", [NSString stringWithFormat:@"8"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:80],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:39],@"action",
				@"9",@"keyname", [NSString stringWithFormat:@"9"],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:90],@"value",
				nil],			
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:7],@"action",
				@"AppleRemote Volume up",@"keyname", [NSString stringWithCharacters:&plus length:1],@"key",
				[NSNumber numberWithInt:100],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:6],@"action",
				@"AppleRemote Volume down",@"keyname", [NSString stringWithCharacters:&minus length:1],@"key",
				[NSNumber numberWithInt:100],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:18],@"action",
				@"AppleRemote Menu",@"keyname", [NSString stringWithCharacters:&menu length:1],@"key",
				[NSNumber numberWithInt:100],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:17],@"action",
				@"AppleRemote Play",@"keyname", [NSString stringWithCharacters:&play length:1],@"key",
				[NSNumber numberWithInt:100],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:1],@"action",
				@"AppleRemote Right",@"keyname", [NSString stringWithCharacters:&right length:1],@"key",
				[NSNumber numberWithInt:100],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:0],@"action",
				@"AppleRemote Left",@"keyname", [NSString stringWithCharacters:&left length:1],@"key",
				[NSNumber numberWithInt:100],@"modifier",
				[NSNumber numberWithBool:YES],@"switchAction",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:35],@"action",
				@"shift+control+C",@"keyname", [NSString stringWithFormat:@"C"],@"key",
				[NSNumber numberWithInt:5],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:35],@"action",
				@"shift+control+down arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSDownArrowFunctionKey],@"key",
				[NSNumber numberWithInt:5],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:36],@"action",
				@"shift+control+D",@"keyname", [NSString stringWithFormat:@"D"],@"key",
				[NSNumber numberWithInt:5],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:36],@"action",
				@"shift+control+up arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSUpArrowFunctionKey],@"key",
				[NSNumber numberWithInt:5],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:21],@"action",
				@"num enter",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSEnterCharacter],@"key",
				[NSNumber numberWithInt:8],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:21],@"action",
				@"return",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSCarriageReturnCharacter],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			nil];
}
+ (void)setDefaultKeyArray
{
	[[NSUserDefaults standardUserDefaults] setObject:[PreferenceController defaultKeyArray] forKey:@"KeyArray"];
}

+ (NSArray*)defaultKeyArrayMode2
{		
	return [NSMutableArray arrayWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:24],@"action",
			@"page up",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSPageUpFunctionKey],@"key",
			[NSNumber numberWithInt:0],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:25],@"action",
			@"page down",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSPageDownFunctionKey],@"key",
			[NSNumber numberWithInt:0],@"modifier",
			nil],
		
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:26],@"action",
			@"shift+space",@"keyname", [NSString stringWithFormat:@"%C",(unichar)0x20],@"key",
			[NSNumber numberWithInt:1],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:27],@"action",
			@"space",@"keyname", [NSString stringWithFormat:@"%C",0x20],@"key",
			[NSNumber numberWithInt:0],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:28],@"action",
			@"home",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSHomeFunctionKey],@"key",
			[NSNumber numberWithInt:0],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:29],@"action",
			@"end",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSEndFunctionKey],@"key",
			[NSNumber numberWithInt:0],@"modifier",
			nil],
		
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:30],@"action",
			@"up arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSUpArrowFunctionKey],@"key",
			[NSNumber numberWithInt:0],@"modifier",
			[NSNumber numberWithInt:20],@"value",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:31],@"action",
			@"down arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSDownArrowFunctionKey],@"key",
			[NSNumber numberWithInt:0],@"modifier",
			[NSNumber numberWithInt:20],@"value",
			nil],
		
		nil];
}
+ (void)setDefaultKeyArrayMode2
{	
	[[NSUserDefaults standardUserDefaults] setObject:[PreferenceController defaultKeyArrayMode2] forKey:@"KeyArrayMode2"];
}

+ (NSArray*)defaultKeyArrayMode3
{		
	return [NSMutableArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:24],@"action",
				@"page up",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSPageUpFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:25],@"action",
				@"page down",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSPageDownFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:26],@"action",
				@"shift+space",@"keyname", [NSString stringWithFormat:@"%C",(unichar)0x20],@"key",
				[NSNumber numberWithInt:1],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:27],@"action",
				@"space",@"keyname", [NSString stringWithFormat:@"%C",0x20],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:28],@"action",
				@"home",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSHomeFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:29],@"action",
				@"end",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSEndFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:30],@"action",
				@"up arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSUpArrowFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:20],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:31],@"action",
				@"down arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSDownArrowFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:20],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:32],@"action",
				@"left arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSLeftArrowFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:20],@"value",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:33],@"action",
				@"right arrow",@"keyname", [NSString stringWithFormat:@"%C",(unichar)NSRightArrowFunctionKey],@"key",
				[NSNumber numberWithInt:0],@"modifier",
				[NSNumber numberWithInt:20],@"value",
				nil],
			nil];
}
+ (void)setDefaultKeyArrayMode3
{
	[[NSUserDefaults standardUserDefaults] setObject:[PreferenceController defaultKeyArrayMode3] forKey:@"KeyArrayMode3"];
}

+ (NSArray*)defaultMouseArray
{	
	return [NSMutableArray arrayWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:0],@"action",
			[NSNumber numberWithInt:0],@"button",
			[NSNumber numberWithInt:0],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:1],@"action",
			[NSNumber numberWithInt:0],@"button",
			[NSNumber numberWithInt:1],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt:6],@"action",
			 [NSNumber numberWithInt:2000],@"button",
			 [NSNumber numberWithInt:0],@"modifier",
			 [NSNumber numberWithBool:YES],@"switchAction",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt:7],@"action",
			 [NSNumber numberWithInt:1000],@"button",
			 [NSNumber numberWithInt:0],@"modifier",
			 [NSNumber numberWithBool:YES],@"switchAction",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt:14],@"action",
			 [NSNumber numberWithInt:4000],@"button",
			 [NSNumber numberWithInt:0],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt:15],@"action",
			 [NSNumber numberWithInt:3000],@"button",
			 [NSNumber numberWithInt:0],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt:49],@"action",
			 [NSNumber numberWithInt:7000],@"button",
			 [NSNumber numberWithInt:0],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt:50],@"action",
			 [NSNumber numberWithInt:8000],@"button",
			 [NSNumber numberWithInt:0],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt:63],@"action",
			 [NSNumber numberWithInt:6000],@"button",
			 [NSNumber numberWithInt:0],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithInt:64],@"action",
			 [NSNumber numberWithInt:5000],@"button",
			 [NSNumber numberWithInt:0],@"modifier",
			 nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:43],@"action",
			[NSNumber numberWithInt:2],@"button",
			[NSNumber numberWithInt:0],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:59],@"action",
			[NSNumber numberWithInt:1],@"button",
			[NSNumber numberWithInt:0],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:59],@"action",
			[NSNumber numberWithInt:0],@"button",
			[NSNumber numberWithInt:4],@"modifier",
			nil],
		nil];
}
+ (void)setDefaultMouseArray
{	
	[[NSUserDefaults standardUserDefaults] setObject:[PreferenceController defaultMouseArray] forKey:@"MouseArray"];
}

+ (NSArray*)defaultMouseArrayMode2
{	
	return [NSMutableArray arrayWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:41],@"action",
			[NSNumber numberWithInt:0],@"button",
			[NSNumber numberWithInt:100],@"modifier",
			nil],
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:42],@"action",
			[NSNumber numberWithInt:0],@"button",
			[NSNumber numberWithInt:0],@"modifier",
			nil],
		nil];
}
+ (void)setDefaultMouseArrayMode2
{
	[[NSUserDefaults standardUserDefaults] setObject:[PreferenceController defaultMouseArrayMode2] forKey:@"MouseArrayMode2"];
}

+ (NSArray*)defaultMouseArrayMode3
{	
	return [NSMutableArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:41],@"action",
				[NSNumber numberWithInt:0],@"button",
				[NSNumber numberWithInt:100],@"modifier",
				nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:42],@"action",
				[NSNumber numberWithInt:0],@"button",
				[NSNumber numberWithInt:0],@"modifier",
				nil],
			nil];
}
+ (void)setDefaultMouseArrayMode3
{
	[[NSUserDefaults standardUserDefaults] setObject:[PreferenceController defaultMouseArrayMode3] forKey:@"MouseArrayMode3"];
}


-(void)awakeFromNib
{		
	defaults = [NSUserDefaults standardUserDefaults];
	[keyPanelTextView setTarget:self];
    [keyPanelTextView setAction:@selector(keyConfigAction:)];
	[keyPanelTextView setAlignment:NSCenterTextAlignment];
	
	NSRect oldFrame = [preferences frame];
	NSRect newFrame = oldFrame;
	/*
	float y = oldFrame.size.height-(534+margin)+oldFrame.origin.y;
	newFrame = NSMakeRect(oldFrame.origin.x,y, 484, (534+margin));
	 */
	newFrame.size.width = 484; 
	[preferences setFrame:newFrame display:NO];
}
#pragma mark Table Delegate:


- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
	return YES;
}
/*
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	[aCell setDrawsBackground:YES];
	[aCell setBackgroundColor:[NSColor whiteColor]];
	
	if([[aTableColumn identifier] isEqualToString:@"action"]) {
		NSLog(@"%@",[aCell stringValue]);
		if (![[aCell stringValue] isEqualToString:@""]) {
			[aCell setBackgroundColor:[NSColor lightGrayColor]];
		}
	}
}
*/

#pragma mark tableDataSource
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if (aTableView == inputTableView) {
		return (int)[currentKeyArray count];
	} else if (aTableView == mouseTableView) {
		return (int)[currentMouseArray count];
	}
	return 0;
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(int)rowIndex
{
	if (aTableView == inputTableView) {
		if (rowIndex >= [currentKeyArray count]) {
			return @"error";
		}
		if([[aTableColumn identifier] isEqualToString:@"action"]) {
			NSString *string;
			int action = [[[currentKeyArray objectAtIndex:rowIndex] objectForKey:@"action"] intValue];
			if (rowIndex > 0) {
				if (action == [[[currentKeyArray objectAtIndex:rowIndex-1] objectForKey:@"action"] intValue]) {
					return @"";
				}
			}
			switch (action) {
				case 0: string = NSLocalizedString(@"NextPage", @""); break;
				case 1: string = NSLocalizedString(@"PreviousPage", @""); break;
				case 2: string = NSLocalizedString(@"HalfNextPage", @""); break;
				case 3: string = NSLocalizedString(@"HalfPreviousPage", @""); break;
				case 4: string = NSLocalizedString(@"Go to LastPage", @""); break;
				case 5: string = NSLocalizedString(@"Go to FirstPage", @""); break;
				case 6: string = NSLocalizedString(@"NextBookmark", @""); break;
				case 7: string = NSLocalizedString(@"PreviousBookmark", @""); break;
				case 8: string = NSLocalizedString(@"NextFolder(Archive)", @""); break;
				case 9: string = NSLocalizedString(@"PreviousFolder(Archive)", @""); break;
				case 10: string = NSLocalizedString(@"Add/RemoveBookmark", @""); break;
				case 11: string = NSLocalizedString(@"SwitchSingle/Bind", @""); break;
				case 12: string = NSLocalizedString(@"ShowNumber", @""); break;
				case 13: string = NSLocalizedString(@"Skip", @""); break;
				case 14: string = NSLocalizedString(@"BackSkip", @""); break;
				case 15: string = NSLocalizedString(@"ViewOriginal(right)", @""); break;
				case 16: string = NSLocalizedString(@"ViewOriginal(left)", @""); break;
				case 17: string = NSLocalizedString(@"Slideshow", @""); break;
				case 18: string = NSLocalizedString(@"Show Thumbnail", @""); break;
				case 19: string = NSLocalizedString(@"ChangeReadMode", @""); break;
				case 20: string = NSLocalizedString(@"ShowPageBar", @""); break;
				case 21: string = NSLocalizedString(@"Go to Page", @""); break;
				case 22: string = NSLocalizedString(@"Show in Finder(right)", @""); break;
				case 23: string = NSLocalizedString(@"Show in Finder(left)", @""); break;
				case 24: string = NSLocalizedString(@"PageUp", @""); break;
				case 25: string = NSLocalizedString(@"PageDown", @""); break;
				case 26: string = NSLocalizedString(@"PageUp + PrevPage", @""); break;
				case 27: string = NSLocalizedString(@"PageDown + NextPage", @""); break;
				case 28: string = NSLocalizedString(@"ScrollToTop", @""); break;
				case 29: string = NSLocalizedString(@"ScrollToEnd", @""); break;
				case 30: string = NSLocalizedString(@"ScrollUp", @""); break;
				case 31: string = NSLocalizedString(@"ScrollDown", @""); break;
				case 32: string = NSLocalizedString(@"ScrollLeft", @""); break;
				case 33: string = NSLocalizedString(@"ScrollRight", @""); break;
				case 34: string = NSLocalizedString(@"ShowLoupe", @""); break;
				case 35: string = NSLocalizedString(@"NextSubFolder(Archive)", @""); break;
				case 36: string = NSLocalizedString(@"PreviousSubFolder(Archive)", @""); break;
				case 37: string = NSLocalizedString(@"LoupePower+", @""); break;
				case 38: string = NSLocalizedString(@"LoupePower-", @""); break;
				case 39: string = NSLocalizedString(@"Go to %", @""); break;
				case 40: string = NSLocalizedString(@"Rotate Right", @""); break;
				case 41: string = NSLocalizedString(@"Rotate Left", @""); break;
				case 42: string = NSLocalizedString(@"ChangeViewMode", @""); break;
				case 43: string = NSLocalizedString(@"Move to Trash(right)", @""); break;
				case 44: string = NSLocalizedString(@"Move to Trash(left)", @""); break;
				case 45: string = NSLocalizedString(@"ChangeSortMode", @""); break;
				case 46: string = NSLocalizedString(@"Close", @""); break;
				case 47: string = NSLocalizedString(@"Shuffle", @""); break;
				case 48: string = NSLocalizedString(@"Open the last page", @""); break;
				case 49: string = NSLocalizedString(@"SwitchFullscreen", @""); break;
				case 50: string = NSLocalizedString(@"MinimizeWindow", @""); break;
				case 51: string = NSLocalizedString(@"EnlargeViewMode", @""); break;
				case 52: string = NSLocalizedString(@"ReduceViewMode", @""); break;
				default: string = NSLocalizedString(@"unknown", @""); break;
			}
			return string;
		} else if([[aTableColumn identifier] isEqualToString:@"keyname"]) {
			return [[currentKeyArray objectAtIndex:rowIndex] objectForKey:@"keyname"];
		} else if([[aTableColumn identifier] isEqualToString:@"value"]) {
			return [[currentKeyArray objectAtIndex:rowIndex] objectForKey:@"value"];
		} else if([[aTableColumn identifier] isEqualToString:@"switchAction"]) {
			if ([[[currentKeyArray objectAtIndex:rowIndex] objectForKey:@"switchAction"] boolValue] == YES) {
				return @"*";
			}
			return nil;
		}
	} else if (aTableView == mouseTableView) {
		if (rowIndex >= [currentMouseArray count]) {
			return @"error";
		}
		if([[aTableColumn identifier] isEqualToString:@"action"]) {
			NSString *string;
			int action = [[[currentMouseArray objectAtIndex:rowIndex] objectForKey:@"action"] intValue];
			if (rowIndex > 0) {
				if (action == [[[currentMouseArray objectAtIndex:rowIndex-1] objectForKey:@"action"] intValue]) {
					return @"";
				}
			}
			switch (action) {
				case 0: string = NSLocalizedString(@"Next/PrevPage**", @""); break;
				case 1: string = NSLocalizedString(@"HalfNext/PrevPage**", @""); break;
				case 2: string = NSLocalizedString(@"Last/TopPage**", @""); break;
				case 3: string = NSLocalizedString(@"Next/PrevBookmark**", @""); break;
				case 4: string = NSLocalizedString(@"Next/PrevFolder(Archive)**", @""); break;
				case 5: string = NSLocalizedString(@"Skip/BackSkip**", @""); break;
				case 6: string = NSLocalizedString(@"NextPage", @""); break;
				case 7: string = NSLocalizedString(@"PreviousPage", @""); break;
				case 8: string = NSLocalizedString(@"HalfNextPage", @""); break;
				case 9: string = NSLocalizedString(@"HalfPreviousPage", @""); break;
				case 10: string = NSLocalizedString(@"Go to LastPage", @""); break;
				case 11: string = NSLocalizedString(@"Go to FirstPage", @""); break;
				case 12: string = NSLocalizedString(@"NextBookmark", @""); break;
				case 13: string = NSLocalizedString(@"PreviousBookmark", @""); break;
				case 14: string = NSLocalizedString(@"NextFolder(Archive)", @""); break;
				case 15: string = NSLocalizedString(@"PreviousFolder(Archive)", @""); break;
				case 16: string = NSLocalizedString(@"Add/RemoveBookmark", @""); break;
				case 17: string = NSLocalizedString(@"SwitchSingle/Bind", @""); break;
				case 18: string = NSLocalizedString(@"ShowNumber", @""); break;
				case 19: string = NSLocalizedString(@"Skip", @""); break;
				case 20: string = NSLocalizedString(@"BackSkip", @""); break;
				case 21: string = NSLocalizedString(@"ViewOriginal(right)", @""); break;
				case 22: string = NSLocalizedString(@"ViewOriginal(left)", @""); break;
				case 23: string = NSLocalizedString(@"Slideshow", @""); break;
				case 24: string = NSLocalizedString(@"Show Thumbnail", @""); break;
				case 25: string = NSLocalizedString(@"ChangeReadMode", @""); break;
				case 26: string = NSLocalizedString(@"ShowPageBar", @""); break;
				case 27: string = NSLocalizedString(@"ViewOriginal(L/R)**", @""); break;
				case 28: string = NSLocalizedString(@"Show in Finder(left)", @""); break;
				case 29: string = NSLocalizedString(@"Show in Finder(right)", @""); break;
				case 30: string = NSLocalizedString(@"Show in Finder(L/R)**", @""); break;
				case 31: string = NSLocalizedString(@"PageUp", @""); break;
				case 32: string = NSLocalizedString(@"PageDown", @""); break;
				case 33: string = NSLocalizedString(@"PageUp + PrevPage", @""); break;
				case 34: string = NSLocalizedString(@"PageDown + NextPage", @""); break;
				case 35: string = NSLocalizedString(@"ScrollToTop", @""); break;
				case 36: string = NSLocalizedString(@"ScrollToEnd", @""); break;
				case 37: string = NSLocalizedString(@"ScrollUp", @""); break;
				case 38: string = NSLocalizedString(@"ScrollDown", @""); break;
				case 39: string = NSLocalizedString(@"ScrollLeft", @""); break;
				case 40: string = NSLocalizedString(@"ScrollRight", @""); break;
				case 41: string = NSLocalizedString(@"DragScroll", @""); break;
				case 42: string = NSLocalizedString(@"PageUp/Down + Prev/NextPage**", @""); break;
				case 43: string = NSLocalizedString(@"ShowLoupe", @""); break;
				case 44: string = NSLocalizedString(@"NextSubFolder(Archive)", @""); break;
				case 45: string = NSLocalizedString(@"PreviousSubFolder(Archive)", @""); break;
				case 46: string = NSLocalizedString(@"Next/PrevSubFolder(Archive)**", @""); break;
				case 47: string = NSLocalizedString(@"LoupePower+", @""); break;
				case 48: string = NSLocalizedString(@"LoupePower-", @""); break;
				case 49: string = NSLocalizedString(@"Rotate Right", @""); break;
				case 50: string = NSLocalizedString(@"Rotate Left", @""); break;
				case 51: string = NSLocalizedString(@"ChangeViewMode", @""); break;
				case 52: string = NSLocalizedString(@"Move to Trash(right)", @""); break;
				case 53: string = NSLocalizedString(@"Move to Trash(left)", @""); break;
				case 54: string = NSLocalizedString(@"Move to Trash(L/R)**", @""); break;
				case 55: string = NSLocalizedString(@"Rotate(L/R)**", @""); break;
				case 56: string = NSLocalizedString(@"ChangeSortMode", @""); break;
				case 57: string = NSLocalizedString(@"Close", @""); break;
				case 58: string = NSLocalizedString(@"Shuffle", @""); break;
				case 59: string = NSLocalizedString(@"ContextualMenu", @""); break;
				case 60: string = NSLocalizedString(@"Open the last page", @""); break;
				case 61: string = NSLocalizedString(@"SwitchFullscreen", @""); break;
				case 62: string = NSLocalizedString(@"MinimizeWindow", @""); break;
				case 63: string = NSLocalizedString(@"EnlargeViewMode", @""); break;
				case 64: string = NSLocalizedString(@"ReduceViewMode", @""); break;
				default: string = NSLocalizedString(@"unknown", @""); break;
			}
			return string;
		} else if([[aTableColumn identifier] isEqualToString:@"button"]) {
			NSString *mouseName = [[currentMouseArray objectAtIndex:rowIndex] objectForKey:@"button"];
			if ([mouseName intValue]>=1000) {
				switch ([mouseName intValue]) {
					case 1000:
						mouseName = @"swipe right";
						break;
					case 2000:
						mouseName = @"swipe left";
						break;
					case 3000:
						mouseName = @"swipe up";
						break;
					case 4000:
						mouseName = @"swipe down";
						break;
					case 5000:
						mouseName = @"pinch in";
						break;
					case 6000:
						mouseName = @"pinch out";
						break;
					case 7000:
						mouseName = @"rotate right";
						break;
					case 8000:
						mouseName = @"rotate left";
						break;
					default:
						break;
				}
			} else {
				mouseName = [NSString stringWithFormat:@"button%@",mouseName];
			}
			
			int temp = [[[currentMouseArray objectAtIndex:rowIndex] objectForKey:@"modifier"] intValue];
			if (temp >= 500) {
				mouseName = [NSString stringWithFormat:@"%@ drag down",mouseName];
				temp -= 500;
			} else if (temp >= 400) {
				mouseName = [NSString stringWithFormat:@"%@ drag up",mouseName];
				temp -= 400;
			} else if (temp >= 300) {
				mouseName = [NSString stringWithFormat:@"%@ drag right",mouseName];
				temp -= 300;
			} else if (temp >= 200) {
				mouseName = [NSString stringWithFormat:@"%@ drag left",mouseName];
				temp -= 200;
			} else if (temp >= 100) {
				mouseName = [NSString stringWithFormat:@"%@ drag",mouseName];
				temp -= 100;
			}
			
			switch (temp) {
				case 0: mouseName = [NSString stringWithFormat:@"%@",mouseName];
					break;
				case 1: mouseName = [NSString stringWithFormat:@"shift+%@",mouseName];
					break;
				case 2: mouseName = [NSString stringWithFormat:@"option+%@",mouseName];
					break;
				case 4: mouseName = [NSString stringWithFormat:@"control+%@",mouseName];
					break;
				case 3: mouseName = [NSString stringWithFormat:@"shift+option+%@",mouseName];
					break;
				case 5: mouseName = [NSString stringWithFormat:@"shift+control+%@",mouseName];
					break;
				case 6: mouseName = [NSString stringWithFormat:@"option+control+%@",mouseName];
					break;
				case 7: mouseName = [NSString stringWithFormat:@"shift+option+control+%@",mouseName];
					break;	
				default:break;				
			}
			return mouseName;
		} else if([[aTableColumn identifier] isEqualToString:@"value"]) {
			return [[currentMouseArray objectAtIndex:rowIndex] objectForKey:@"value"];
		} else if([[aTableColumn identifier] isEqualToString:@"switchAction"]) {
			if ([[[currentMouseArray objectAtIndex:rowIndex] objectForKey:@"switchAction"] boolValue] == YES) {
				return @"*";
			}
			return nil;
		}
	}
	return nil;
}

- (void)tableView:(NSTableView *)aTableView 
   setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn 
			  row:(int)rowIndex
{
}


#pragma mark preferences
- (void)preferences
{	
	[accessorySettingView setPreferences];
	
	keyArray = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"KeyArray"]];
	keyArrayMode2 = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"KeyArrayMode2"]];
	keyArrayMode3 = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"KeyArrayMode3"]];
	mouseArray = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"MouseArray"]];
	mouseArrayMode2 = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"MouseArrayMode2"]];
	mouseArrayMode3 = [[NSMutableArray alloc] initWithArray:[defaults arrayForKey:@"MouseArrayMode3"]];
	switch ([keyModePopUpButton indexOfSelectedItem]) {
		case 0:
			currentKeyArray = keyArray;
			break;
		case 1:
			currentKeyArray = keyArrayMode2;
			break;
		case 2:
			currentKeyArray = keyArrayMode3;
			break;
		default:break;
	}
	switch ([mouseModePopUpButton indexOfSelectedItem]) {
		case 0:
			currentMouseArray = mouseArray;
			break;
		case 1:
			currentMouseArray = mouseArrayMode2;
			break;
		case 2:
			currentMouseArray = mouseArrayMode3;
			break;
		default:break;
		
	}
	[currentKeyArray sortUsingSelector:@selector(keyArrayCompare:)];
	[currentMouseArray sortUsingSelector:@selector(mouseArrayCompare:)];
	
	
	int bufferingMode = (int)[defaults integerForKey:@"BufferingMode"];
	BOOL fitOriginal = [defaults boolForKey:@"FitOriginal"];
	BOOL rememberBookSettings = [defaults boolForKey:@"RememberBookSettings"];
	NSDictionary *thumbnail = [defaults dictionaryForKey:@"Thumbnail"];
	float sliderValue = [defaults floatForKey:@"SlideshowDelay"];
	int loopCheck = (int)[defaults integerForKey:@"LoopCheck"];
	
	int maxEnlargement = (int)[defaults integerForKey:@"MaxEnlargement"];
	//int skipPage = [defaults integerForKey:@"SkipPage"];
	int singleSetting = (int)[defaults integerForKey:@"SingleSetting"];
	BOOL readSubFolder = [defaults boolForKey:@"ReadSubFolder"];
	float wheelSensitivity = [defaults floatForKey:@"WheelSensitivity"];
	BOOL openLastFolder = [defaults boolForKey:@"OpenLastFolder"];
	
	int prevPageAction = (int)[defaults integerForKey:@"PrevPageMode"];
	int canScrollAction = (int)[defaults integerForKey:@"CanScrollMode"];
	
	[prevPageActionPopUpButton selectItemAtIndex:prevPageAction];
	[canScrollActionPopUpButton selectItemAtIndex:canScrollAction];
	
	
	
	if ([defaults boolForKey:@"ShowNumber"]) {
		[showPageNumCheck setState:NSOnState];
	} else {
		[showPageNumCheck setState:NSOffState];
	}
	if ([defaults boolForKey:@"ShowPageBar"]) {
		[showPageBarCheck setState:NSOnState];
	} else {
		[showPageBarCheck setState:NSOffState];
	}
	
	if ([defaults boolForKey:@"PageNumAutoHide"]) {
		[pageNumAutoHideCheck setState:NSOnState];
	} else {
		[pageNumAutoHideCheck setState:NSOffState];
	}
	if ([defaults boolForKey:@"PageBarAutoHide"]) {
		[pageBarAutoHideCheck setState:NSOnState];
	} else {
		[pageBarAutoHideCheck setState:NSOffState];
	}
	if ([defaults boolForKey:@"PageBarShowThumbnail"]) {
		[pageBarShowThumbCheck setState:NSOnState];
	} else {
		[pageBarShowThumbCheck setState:NSOffState];
	}
	if ([defaults boolForKey:@"ChangeOpenWith"]) {
		[changeOpenWithCheck setState:NSOnState];
	} else {
		[changeOpenWithCheck setState:NSOffState];
	}
	if ([defaults boolForKey:@"ChangeCreator"]) {
		[changeCreatorCheck setState:NSOnState];
	} else {
		[changeCreatorCheck setState:NSOffState];
	}
	
	switch ([defaults integerForKey:@"SortMode"]) {
		case 0:
			[sortModePopUpButton selectItemAtIndex:0];
			break;
		case 1:
			[sortModePopUpButton selectItemAtIndex:3];
			break;
		case 2:
			[sortModePopUpButton selectItemAtIndex:1];
			break;
		case 3:
			[sortModePopUpButton selectItemAtIndex:2];
			break;
		default:
			[sortModePopUpButton selectItemAtIndex:0];
			break;
	}
	
	if ([defaults boolForKey:@"DontHideMenuBar"]) {
		[dontHideMenubarCheck setState:NSOnState];
	} else {
		[dontHideMenubarCheck setState:NSOffState];
	}
	if ([defaults boolForKey:@"ShowThumbnailWhenOpen"]) {
		[showThumbnailCheck setState:NSOnState];
	} else {
		[showThumbnailCheck setState:NSOffState];
	}
	
	/*history*/
	if ([defaults boolForKey:@"AlwaysRememberLastPage"]) {
		[alwaysRememberLastCheck setState:NSOnState];
	} else {
		[alwaysRememberLastCheck setState:NSOffState];
	}
	
	[goToLastPopUpButton selectItemAtIndex:[defaults integerForKey:@"GoToLastPage"]];
	
	if ([defaults integerForKey:@"OpenRecentLimit"]) {
		[numberOfOpenRecentTextField setStringValue:[NSString stringWithFormat:@"%i",(int)[defaults integerForKey:@"OpenRecentLimit"] ]];
	}
	
	/*pdf link*/
	[openLinkPopUpButton selectItemAtIndex:[defaults integerForKey:@"OpenLinkMode"]];	
	
	/*change current folder*/
	[changeCurrentFolderPopUpButton selectItemAtIndex:[defaults integerForKey:@"ChangeCurrentFolder"]];	
	
	
	/*pageBar*/
	NSColor *pageBarBG;
	if ([defaults objectForKey:@"PageBarBGColor"]) {
		pageBarBG = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"PageBarBGColor"]];
	} else {
		pageBarBG = [[NSColor blackColor] colorWithAlphaComponent:0.8];
	}
	[pageBarBGColor setCurrentColor:pageBarBG];
	[pageBarFontTextField setBackgroundColor:pageBarBG];
	NSColor *pageBarBorder;
	if ([defaults objectForKey:@"PageBarBorderColor"]) {
		pageBarBorder = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"PageBarBorderColor"]];
	} else {
		pageBarBorder = [NSColor whiteColor];
	}
	[pageBarBorderColor setCurrentColor:pageBarBorder];
	NSColor *pageBarReaded;
	if ([defaults objectForKey:@"PageBarReadedColor"]) {
		pageBarReaded = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"PageBarReadedColor"]];
	} else {
		pageBarReaded = [[NSColor whiteColor] colorWithAlphaComponent:0.5];
	}
	[pageBarReadedColor setCurrentColor:pageBarReaded];
	NSColor *pageBarFont;
	if ([defaults objectForKey:@"PageBarFontColor"]) {
		pageBarFont = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"PageBarFontColor"]];
	} else {
		pageBarFont = [NSColor whiteColor];
	}
	[pageBarFontColor setCurrentColor:pageBarFont];
	[pageBarFontTextField setTextColor:pageBarFont];
	if ([defaults objectForKey:@"PageBarTextFont"]) {
		[pageBarFontTextField setFont:[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"PageBarTextFont"]]];
	} else {
		[pageBarFontTextField setFont:[NSFont userFontOfSize:14]];
	}
	
	/*loupe*/
	int loupeSize = (int)[defaults integerForKey:@"LoupeSize"];
	[loupeSizeTextField setStringValue:[NSString stringWithFormat:@"%i", loupeSize]];
	float loupeRate = [defaults floatForKey:@"LoupeRate"];
	[loupeRateTextField setStringValue:[NSString stringWithFormat:@"%f", loupeRate]];
	/*view*/
	NSColor *viewBackGround;
	if ([defaults objectForKey:@"ViewBackGroundColor"]) {
		viewBackGround = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"ViewBackGroundColor"]];
	} else {
		viewBackGround = [NSColor blackColor];
	}
	[viewBackGroundColor setCurrentColor:viewBackGround];
	/*cache*/
	int imageCache = (int)[defaults integerForKey:@"ImageCache"];
	[imageCacheTextField setStringValue:[NSString stringWithFormat:@"%i", imageCache]];
	int screenCache = (int)[defaults integerForKey:@"ScreenCache"];
	[screenCacheTextField setStringValue:[NSString stringWithFormat:@"%i", screenCache]];
	int thumbnailCache = (int)[defaults integerForKey:@"ThumbnailCache"];
	[thumbnailCacheTextField setStringValue:[NSString stringWithFormat:@"%i", thumbnailCache]];
	
	
	/**/
    [inputTableView setDataSource:(id)self];
    [inputTableView setDelegate:(id)self];
	[inputTableView reloadData];
	
	[mouseTableView setDataSource:(id)self];
    [mouseTableView setDelegate:(id)self];
	[mouseTableView reloadData];
	/**/
	
	
	/*pagenumber*/
	if ([defaults objectForKey:@"TextFont"]) {
		[fontTextField setFont:[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"TextFont"]]];
	} else {
		[fontTextField setFont:[fontTextField font]];
	}

	
	NSColor *textColor;
	if ([defaults objectForKey:@"TextColor"]) {
		textColor = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"TextColor"]];
	} else {
		textColor = [NSColor whiteColor];
	}
	[pageColor setCurrentColor:textColor];
	[fontTextField setTextColor:textColor];
	NSColor *textBGColor;
	if ([defaults objectForKey:@"TextBGColor"]) {
		textBGColor = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"TextBGColor"]];
	} else {
		textBGColor = [[NSColor blackColor] colorWithAlphaComponent:0.8];
	}
	[pageBGColor setCurrentColor:textBGColor];
	[fontTextField setBackgroundColor:textBGColor];
	NSColor *textBorderColor;
	if ([defaults objectForKey:@"TextBorderColor"]) {
		textBorderColor = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"TextBorderColor"]];
	} else {
		textBorderColor = [NSColor whiteColor];
	}
	[pageBorderColor setCurrentColor:textBorderColor];
	
	
	
	[interpolationPopUpButton selectItemAtIndex:[defaults integerForKey:@"Interpolation"]];
	
	[bufferingModePopUpButton selectItemAtIndex:[defaults integerForKey:@"BufferingMode"]];
	if ([bufferingModePopUpButton indexOfSelectedItem]==1) {
		[screenCacheTextField setEnabled:NO];
	} else {
		[screenCacheTextField setEnabled:YES];
	}
	
	if (fitOriginal) {
		[fitOriginalCheck setState:NSOnState];
	} else {
		[fitOriginalCheck setState:NSOffState];
	}
	
	
	//[skipPageTextField setStringValue:[NSString stringWithFormat:@"%d", skipPage]];
	
	if (wheelSensitivity == 0.0) {
		[wheelSlider setFloatValue:0.0];
	} else {
		[wheelSlider setFloatValue:(2.1-wheelSensitivity)];
	}
	

	
	if (rememberBookSettings) {
		[rememberBookSettingsCheck setState:NSOnState];
	} else {
		[rememberBookSettingsCheck setState:NSOffState];
	}
	
	
	
	
	if (openLastFolder == YES) {
		[openLastFolderCheck setState:NSOnState];
	} else {
		[openLastFolderCheck setState:NSOffState];
	}
	
	

	[thumbnailTextFieldRow setStringValue:[NSString stringWithFormat:@"%i",[[thumbnail objectForKey:@"row"] intValue] ]];
	[thumbnailTextFieldCol setStringValue:[NSString stringWithFormat:@"%i", [[thumbnail objectForKey:@"column"] intValue]]];
	
	[singleSettingTextField setStringValue:[NSString stringWithFormat:@"%i", singleSetting]];
	
	
	
	
	if (readSubFolder == YES) {
		[readSubFolderCheck setState:NSOnState];
	} else {
		[readSubFolderCheck setState:NSOffState];
	}
	
	
	if (loopCheck == 0) {
		//loop
		[loopPopUpButton selectItemAtIndex:0];
	} else if (loopCheck == 1) {
		//folder first
		[loopPopUpButton selectItemAtIndex:1];
	} else if (loopCheck == 2) {
		//folder
		[loopPopUpButton selectItemAtIndex:2];
	} else if (loopCheck == 3) {
		//none
		[loopPopUpButton selectItemAtIndex:3];
	}
	
	
	switch ([defaults integerForKey:@"ReadMode"]) {
		case 0:
			[readRightButton setState:NSOffState];
			[readLeftButton setState:NSOnState];
			[readSingleCheckButton setState:NSOffState];
			break;
		case 1:
			[readRightButton setState:NSOnState];
			[readLeftButton setState:NSOffState];
			[readSingleCheckButton setState:NSOffState];
			break;
		case 2:
			[readRightButton setState:NSOffState];
			[readLeftButton setState:NSOnState];
			[readSingleCheckButton setState:NSOnState];
			break;
		case 3:
			[readRightButton setState:NSOnState];
			[readLeftButton setState:NSOffState];
			[readSingleCheckButton setState:NSOnState];
			break;
		default:break;
	}
	
	if (maxEnlargement == 0) {
		[enlargePopUpButton selectItemAtIndex:5];
	} else if (maxEnlargement == 1) {
		[enlargePopUpButton selectItemAtIndex:0];
	} else if (maxEnlargement == 2) {
		[enlargePopUpButton selectItemAtIndex:1];
	} else if (maxEnlargement == 3) {
		[enlargePopUpButton selectItemAtIndex:2];
	} else if (maxEnlargement == 4) {
		[enlargePopUpButton selectItemAtIndex:3];
	} else if (maxEnlargement == 5) {
		[enlargePopUpButton selectItemAtIndex:4];
	}
	
	[slideshowSlider setFloatValue:sliderValue];
	[slideshowTextField setStringValue:[NSString stringWithFormat:@"%.1f", sliderValue]];
	
	
	if ([window isVisible]) {
		[preferences setLevel:NSModalPanelWindowLevel];
	}
	int result;
	result = (int)[[NSApplication sharedApplication] runModalForWindow:preferences];
	[preferences orderOut:self];
	
	if(result == DIALOG_CANCEL) {
		[keyArray release];
		keyArray = nil;
		[keyArrayMode2 release];
		keyArrayMode2 = nil;
		[keyArrayMode3 release];
		keyArrayMode3 = nil;
		[mouseArray release];
		mouseArray = nil;
		[mouseArrayMode2 release];
		mouseArrayMode2 = nil;
		[mouseArrayMode3 release];
		mouseArrayMode3 = nil;
		currentKeyArray = nil;
		currentMouseArray = nil;
        return;
    } else if(result == DIALOG_OK) {
		if ([fitOriginalCheck state] == NSOnState) {
			fitOriginal = YES;
		} else {
			fitOriginal = NO;
		}

		[defaults setBool:fitOriginal forKey:@"FitOriginal"];
		
		bufferingMode = (int)[bufferingModePopUpButton indexOfSelectedItem];
		[defaults setInteger:bufferingMode forKey:@"BufferingMode"];
		
		[defaults setObject:keyArray forKey:@"KeyArray"];
		[defaults setObject:keyArrayMode2 forKey:@"KeyArrayMode2"];
		[defaults setObject:keyArrayMode3 forKey:@"KeyArrayMode3"];
		[defaults setObject:mouseArray forKey:@"MouseArray"];
		[defaults setObject:mouseArrayMode2 forKey:@"MouseArrayMode2"];
		[defaults setObject:mouseArrayMode3 forKey:@"MouseArrayMode3"];
		
		
		
		/*
		[accessorySettingView pageBarPosition];
		[accessorySettingView pageBarMargin];
		[accessorySettingView pageBarSize];
		[accessorySettingView pageStringPosition];
		[accessorySettingView pageMargin];
		*/
		
		if ([rememberBookSettingsCheck state] == NSOnState) {
			rememberBookSettings = YES;
		} else {
			rememberBookSettings = NO;
		}
		
		
		[defaults setBool:rememberBookSettings forKey:@"RememberBookSettings"];
		
		
		if ([openLastFolderCheck state] == NSOnState) {
			openLastFolder = YES;
		} else {
			openLastFolder = NO;
		}
		[defaults setBool:openLastFolder forKey:@"OpenLastFolder"];
		
		if ([readSubFolderCheck state] == NSOnState) {
			readSubFolder = YES;
		} else {
			readSubFolder = NO;
		}
		[defaults setBool:readSubFolder forKey:@"ReadSubFolder"];
		
		int loopIndex = (int)[loopPopUpButton indexOfSelectedItem];
		if (loopIndex == 0){
			loopCheck = 0;
		} else if (loopIndex == 1){
			loopCheck = 1;
		} else if (loopIndex == 2){
			loopCheck = 2;
		} else if (loopIndex == 3){
			loopCheck = 3;
		}
		[defaults setInteger:loopCheck forKey:@"LoopCheck"];
		
		
		
		int readMode;
		if ([readLeftButton state] == NSOnState) {
			if ([readSingleCheckButton state] == NSOnState) {
				readMode = 2;
			} else {
				readMode = 0;
			}
		} else /*if ([readRightButton state] == NSOnState)*/ {
			if ([readSingleCheckButton state] == NSOnState) {
				readMode = 3;
			} else {
				readMode = 1;
			}
		}
		[defaults setInteger:readMode forKey:@"ReadMode"];

		
		
		
		singleSetting = [[singleSettingTextField stringValue] intValue];
		[defaults setInteger:singleSetting forKey:@"SingleSetting"];
		
		
		int interpolationIndex = (int)[interpolationPopUpButton indexOfSelectedItem];
		[defaults setInteger:interpolationIndex forKey:@"Interpolation"];
		
		int enlargementIndex = (int)[enlargePopUpButton indexOfSelectedItem];
		if (enlargementIndex == 0){
			maxEnlargement = 1;
		} else if (enlargementIndex == 1){
			maxEnlargement = 2;
		} else if (enlargementIndex == 2){
			maxEnlargement = 3;
		} else if (enlargementIndex == 3){
			maxEnlargement = 4;
		} else if (enlargementIndex == 4){
			maxEnlargement = 5;
		} else if (enlargementIndex == 5){
			maxEnlargement = 0;
		}
		[defaults setInteger:maxEnlargement forKey:@"MaxEnlargement"];
		
		if ([wheelSlider floatValue] == 0.0) {
			wheelSensitivity = 0.0;
		} else {
			wheelSensitivity = (2.1-[wheelSlider floatValue]);
		}
		
		[defaults setFloat:wheelSensitivity forKey:@"WheelSensitivity"];
		
		
		

		
		//skipPage = [[skipPageTextField stringValue] intValue];
		//[defaults setInteger:skipPage forKey:@"SkipPage"];
		
		NSDictionary *thumbnail;
		int col = [[thumbnailTextFieldCol stringValue] intValue];
		int row = [[thumbnailTextFieldRow stringValue] intValue];
		thumbnail = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:row],@"row",
			[NSNumber numberWithInt:col],@"column",nil];
		[defaults setObject:thumbnail forKey:@"Thumbnail"];
		
		sliderValue = [[slideshowTextField stringValue] floatValue];
		[defaults setFloat:sliderValue forKey:@"SlideshowDelay"];
		
		
		prevPageAction = (int)[prevPageActionPopUpButton indexOfSelectedItem];
		canScrollAction = (int)[canScrollActionPopUpButton indexOfSelectedItem];
		[defaults setInteger:prevPageAction forKey:@"PrevPageMode"];
		[defaults setInteger:canScrollAction forKey:@"CanScrollMode"];
		
		
		/*pageNum*/
		[defaults setInteger:[accessorySettingView pageNumPosition] forKey:@"PageNumPosition"];
		[defaults setObject:[accessorySettingView pageMargin] forKey:@"Margin_Page"];
		[defaults setObject:[NSArchiver archivedDataWithRootObject:[fontTextField font]] forKey:@"TextFont"];
		[defaults setObject:[NSArchiver archivedDataWithRootObject:[pageColor currentColor]] forKey:@"TextColor"];
		[defaults setObject:[NSArchiver archivedDataWithRootObject:[pageBGColor currentColor]] forKey:@"TextBGColor"];
		[defaults setObject:[NSArchiver archivedDataWithRootObject:[pageBorderColor currentColor]] forKey:@"TextBorderColor"];
		if ([showPageNumCheck state]==NSOnState) {
			[defaults setBool:YES forKey:@"ShowNumber"];
		} else {
			[defaults setBool:NO forKey:@"ShowNumber"];
		}	
		/*pageBar*/
		//NSDictionary *pageBarDic;
		[defaults setInteger:[accessorySettingView pageBarPosition] forKey:@"PageBarPosition"];
		[defaults setObject:[accessorySettingView pageBarMargin] forKey:@"Margin_PageBar"];
		[defaults setObject:[accessorySettingView pageBarSize] forKey:@"PageBarSize"];
		[defaults setObject:[NSArchiver archivedDataWithRootObject:[pageBarBGColor currentColor]] forKey:@"PageBarBGColor"];
		[defaults setObject:[NSArchiver archivedDataWithRootObject:[pageBarBorderColor currentColor]] forKey:@"PageBarBorderColor"];
		[defaults setObject:[NSArchiver archivedDataWithRootObject:[pageBarReadedColor currentColor]] forKey:@"PageBarReadedColor"];
		[defaults setObject:[NSArchiver archivedDataWithRootObject:[pageBarFontColor currentColor]] forKey:@"PageBarFontColor"];
		[defaults setObject:[NSArchiver archivedDataWithRootObject:[pageBarFontTextField font]] forKey:@"PageBarTextFont"];		
		if ([showPageBarCheck state]==NSOnState) {
			[defaults setBool:YES forKey:@"ShowPageBar"];
		} else {
			[defaults setBool:NO forKey:@"ShowPageBar"];
		}	
		
		
		
		/*loupe*/
		int loupeSize = [[loupeSizeTextField stringValue] intValue];
		[defaults setInteger:loupeSize forKey:@"LoupeSize"];
		float loupeRate = [[loupeRateTextField stringValue] floatValue];
		[defaults setFloat:loupeRate forKey:@"LoupeRate"];
		/*cache*/
		int imageCache = [[imageCacheTextField stringValue] intValue];
		[defaults setInteger:imageCache forKey:@"ImageCache"];
		int screenCache = [[screenCacheTextField stringValue] intValue];
		[defaults setInteger:screenCache forKey:@"ScreenCache"];
		int thumbnailCache = [[thumbnailCacheTextField stringValue] intValue];
		[defaults setInteger:thumbnailCache forKey:@"ThumbnailCache"];
		/*view*/
		[defaults setObject:[NSArchiver archivedDataWithRootObject:[viewBackGroundColor currentColor]] forKey:@"ViewBackGroundColor"];
		
		

		
		if ([pageNumAutoHideCheck state]==NSOnState) {
			[defaults setBool:YES forKey:@"PageNumAutoHide"];
		} else {
			[defaults setBool:NO forKey:@"PageNumAutoHide"];
		}			
		if ([pageBarAutoHideCheck state]==NSOnState) {
			[defaults setBool:YES forKey:@"PageBarAutoHide"];
		} else {
			[defaults setBool:NO forKey:@"PageBarAutoHide"];
		}	
		if ([pageBarShowThumbCheck state]==NSOnState) {
			[defaults setBool:YES forKey:@"PageBarShowThumbnail"];
		} else {
			[defaults setBool:NO forKey:@"PageBarShowThumbnail"];
		}		
		if ([changeOpenWithCheck state]==NSOnState) {
			[defaults setBool:YES forKey:@"ChangeOpenWith"];
		} else {
			[defaults setBool:NO forKey:@"ChangeOpenWith"];
		}
		if ([changeCreatorCheck state]==NSOnState) {
			[defaults setBool:YES forKey:@"ChangeCreator"];
		} else {
			[defaults setBool:NO forKey:@"ChangeCreator"];
		}
		
		switch ([sortModePopUpButton indexOfSelectedItem]) {
			case 0:
				[defaults setInteger:0 forKey:@"SortMode"];
				break;
			case 1:
				[defaults setInteger:2 forKey:@"SortMode"];
				break;
			case 2:
				[defaults setInteger:3 forKey:@"SortMode"];
				break;
			case 3:
				[defaults setInteger:1 forKey:@"SortMode"];
				break;
			break;
		default:
			break;
		}
		
		if ([dontHideMenubarCheck state]==NSOnState) {
			[defaults setBool:YES forKey:@"DontHideMenuBar"];
		} else {
			[defaults setBool:NO forKey:@"DontHideMenuBar"];
		}
		if ([showThumbnailCheck state]==NSOnState) {
			[defaults setBool:YES forKey:@"ShowThumbnailWhenOpen"];
		} else {
			[defaults setBool:NO forKey:@"ShowThumbnailWhenOpen"];
		}
		
		if ([alwaysRememberLastCheck state]==NSOnState) {
			[defaults setBool:YES forKey:@"AlwaysRememberLastPage"];
		} else {
			[defaults setBool:NO forKey:@"AlwaysRememberLastPage"];
		}
		[defaults setInteger:[[numberOfOpenRecentTextField stringValue] intValue] forKey:@"OpenRecentLimit"];
		
		
		[defaults setInteger:[goToLastPopUpButton indexOfSelectedItem] forKey:@"GoToLastPage"];
		
		[defaults setInteger:[openLinkPopUpButton indexOfSelectedItem] forKey:@"OpenLinkMode"];
		
		[defaults setInteger:[changeCurrentFolderPopUpButton indexOfSelectedItem] forKey:@"ChangeCurrentFolder"];
		
		[defaults synchronize];
		
		
		
		[keyArray release];
		keyArray = nil;
		[keyArrayMode2 release];
		keyArrayMode2 = nil;
		[keyArrayMode3 release];
		keyArrayMode3 = nil;
		[mouseArray release];
		mouseArray = nil;
		[mouseArrayMode2 release];
		mouseArrayMode2 = nil;
		[mouseArrayMode3 release];
		mouseArrayMode3 = nil;
		currentKeyArray = nil;
		currentMouseArray = nil;
		
		
		if ([window isVisible]) {
			[[NSApp keyWindow] makeKeyAndOrderFront:self];
		}
		[controller setPreferences];
		return;
    } else if(result == NSRunAbortedResponse) {
		[keyArray release];
		keyArray = nil;
		[keyArrayMode2 release];
		keyArrayMode2 = nil;
		[keyArrayMode3 release];
		keyArrayMode3 = nil;
		[mouseArray release];
		mouseArray = nil;
		[mouseArrayMode2 release];
		mouseArrayMode2 = nil;
		[mouseArrayMode3 release];
		mouseArrayMode3 = nil;
		currentKeyArray = nil;
		currentMouseArray = nil;
		[[NSApp keyWindow] makeKeyAndOrderFront:self];
		return;
    }
}

- (IBAction)sheetOk:(id)sender
{
	[[NSApplication sharedApplication] stopModalWithCode:DIALOG_OK];
}

- (IBAction)sheetCancel:(id)sender
{
	[[NSApplication sharedApplication] stopModalWithCode:DIALOG_CANCEL];
}

- (IBAction)setValueToSlider:(id)sender
{
    [slideshowSlider setFloatValue:[[slideshowTextField stringValue] intValue]];
}

- (IBAction)sliderMoved:(id)sender
{
    [slideshowTextField setStringValue:[NSString stringWithFormat:@"%.1f", [slideshowSlider floatValue]]];
}

- (IBAction)changeBufferingMode:(id)sender
{
	if ([bufferingModePopUpButton indexOfSelectedItem]==1) {
		[screenCacheTextField setEnabled:NO];
	} else {
		[screenCacheTextField setEnabled:YES];
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	if ([inputTabView indexOfTabViewItem:[inputTabView selectedTabViewItem]] == 0) {
		if ([keyModePopUpButton indexOfSelectedItem] == 0) {
			if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollToTop", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollToEnd", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"PageUp", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"PageDown", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"PageUp + PrevPage", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"PageDown + NextPage", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollUp", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollDown", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollLeft", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollRight", @"")] == YES) {
				return NO;
			}
		} else if ([keyModePopUpButton indexOfSelectedItem] == 1) {
			if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollLeft", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollRight", @"")] == YES) {
				return NO;
			}
		}
		return YES;
	} else {
		if ([mouseModePopUpButton indexOfSelectedItem] == 0) {
			if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollToTop", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollToEnd", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"PageUp", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"PageDown", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"PageUp + PrevPage", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"PageDown + NextPage", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollUp", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollDown", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollLeft", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollRight", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"PageUp/Down + Prev/NextPage", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"DragScroll", @"")] == YES) {
				return NO;
			}
		} else if ([mouseModePopUpButton indexOfSelectedItem] == 1) {
			if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollLeft", @"")] == YES) {
				return NO;
			} else if ([[anItem title] isEqualToString:NSLocalizedString(@"ScrollRight", @"")] == YES) {
				return NO;
			}
		}
		if ([mouseModePopUpButton indexOfSelectedItem] != 0) {
			if ([mousePanelClickPopUpButton indexOfSelectedItem] != 1) {
				if ([[anItem title] isEqualToString:NSLocalizedString(@"DragScroll", @"")] == YES) {
					return NO;
				}
			}
		}
		return YES;
	}
}

- (IBAction)selectedKeyMode:(id)sender
{
	switch ([sender indexOfSelectedItem]) {
		case 0:
			currentKeyArray = keyArray;
			break;
		case 1:
			currentKeyArray = keyArrayMode2;
			break;
		case 2:
			currentKeyArray = keyArrayMode3;
			break;
		default:break;
	}
	
	[currentKeyArray sortUsingSelector:@selector(keyArrayCompare:)];
	[inputTableView reloadData];
}

- (IBAction)selectedMouseMode:(id)sender
{
	
	switch ([sender indexOfSelectedItem]) {
		case 0:
			currentMouseArray = mouseArray;
			break;
		case 1:
			currentMouseArray = mouseArrayMode2;
			break;
		case 2:
			currentMouseArray = mouseArrayMode3;
			break;
		default:break;
	}
	[currentMouseArray sortUsingSelector:@selector(mouseArrayCompare:)];
	[mouseTableView reloadData];
}


- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSRect oldFrame = [preferences frame];
	NSRect newFrame = [preferences frame];
	/*
	//need + 67 = margin
	if ([[tabViewItem label] isEqualToString:NSLocalizedString(@"Input",@"")] == YES) {
		//555
		float y = oldFrame.size.height-(555+margin)+oldFrame.origin.y;
		newFrame = NSMakeRect(oldFrame.origin.x,y, 633, (555+margin));
	} else if ([[tabViewItem label] isEqualToString:NSLocalizedString(@"Advanced",@"")] == YES) {
		float y = oldFrame.size.height-(267+margin)+oldFrame.origin.y;
		newFrame = NSMakeRect(oldFrame.origin.x,y, 484, (267+margin));
	} else if ([[tabViewItem label] isEqualToString:NSLocalizedString(@"Appearance",@"")] == YES) {
		//555
		float y = oldFrame.size.height-(555+margin)+oldFrame.origin.y;
		newFrame = NSMakeRect(oldFrame.origin.x,y, 484, (555+margin));
	} else if ([[tabViewItem label] isEqualToString:NSLocalizedString(@"General",@"")] == YES) {
		//534
		float y = oldFrame.size.height-(534+margin)+oldFrame.origin.y;
		newFrame = NSMakeRect(oldFrame.origin.x,y, 484, (534+margin));
	} else {
		float y = oldFrame.size.height-oldFrame.size.height+oldFrame.origin.y;
		newFrame = NSMakeRect(oldFrame.origin.x,y, 484, oldFrame.size.height);
	}*/
	
	if ([[tabViewItem label] isEqualToString:NSLocalizedString(@"Input",@"")] == YES) {
		newFrame.size.width = 633; 
	} else {
		newFrame.size.width = 484; 
	}
	if (NSEqualRects(newFrame,oldFrame)) {
		return;
	}
	[[[tabView selectedTabViewItem] view] setHidden:YES];
	[preferences setFrame:newFrame
			  display:YES
				  animate:YES ];
	[[[tabView selectedTabViewItem] view] setHidden:NO];	 
}

- (IBAction)dummyAction:(id)sender
{
	if (sender == mousePanelButtonPopUpButton) {
		if ([mousePanelButtonPopUpButton selectedTag]>=1000) {
			[mousePanelClickPopUpButton setEnabled:NO];
		} else {
			[mousePanelClickPopUpButton setEnabled:YES];
		}
	}
	[[mousePanelActionPopUpButton menu] update];
	[[mousePanelButtonPopUpButton menu] update];
	[[mousePanelClickPopUpButton menu] update];
}

- (IBAction)disposeSettings:(id)sender
{
    NSBeginAlertSheet(NSLocalizedString(@"Disposing of settings",@""),
					  NSLocalizedString(@"OK",@""), 
					  NSLocalizedString(@"Cancel",@""), 
					  nil, 
					  preferences, 
					  self, 
					  @selector(sureDisposeSettingAlertSheetDidEnd:returnCode:contextInfo:), 
					  nil, 
					  nil, 
					  NSLocalizedString(@"Are you sure you want to delete the setting which file is not found?",@""));
}
- (void)sureDisposeSettingAlertSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    [sheet orderOut:self];
	
	if(returnCode == NSAlertDefaultReturn) {
		[[NSApplication sharedApplication] beginSheet:disposeSettingPanel 
									   modalForWindow:preferences 
										modalDelegate:self 
									   didEndSelector:@selector(disposeSettingSheetDidEnd:returnCode:contextInfo:) 
										  contextInfo:nil];
		
		NSDictionary *currentBookSettingDic;
		if ([defaults dictionaryForKey:@"BookSettings"]) {
			currentBookSettingDic = [defaults dictionaryForKey:@"BookSettings"];
		} else {
			currentBookSettingDic = [NSDictionary dictionary];
		}
		NSEnumerator *currnetBookSettingEnu = [currentBookSettingDic keyEnumerator];
		NSMutableDictionary *newtBookSettingDic = [NSMutableDictionary dictionary];
		
		
		NSArray *currentLastPageArray;
		if ([defaults arrayForKey:@"LastPages"]) {
			currentLastPageArray = [defaults arrayForKey:@"LastPages"];
		} else {
			currentLastPageArray = [NSArray array];
		}
		NSEnumerator *currentLastPageEnu = [currentLastPageArray objectEnumerator];
		NSMutableArray *newtLastPageArray = [NSMutableArray array];
		
		[disposeSettingProgress setMaxValue: (double)([currentBookSettingDic count]+[currentLastPageArray count]+1)];
		[disposeSettingProgress setDoubleValue: (double)0];
		[disposeSettingProgress displayIfNeeded];
		[self performSelectorOnMainThread:@selector(disposeSettingMethod:) withObject:[NSArray arrayWithObjects:currentBookSettingDic,currnetBookSettingEnu,newtBookSettingDic,currentLastPageArray,currentLastPageEnu,newtLastPageArray,[NSNumber numberWithInt:0],nil] waitUntilDone:NO];
    }
}

- (void)disposeSettingMethod:(NSArray *)array
{
	NSString *temp;
	
	NSDictionary *currentBookSettingDic = [array objectAtIndex:0];
	NSEnumerator *currnetBookSettingEnu = [array objectAtIndex:1];
	NSMutableDictionary *newtBookSettingDic = [array objectAtIndex:2];
	NSArray *currentLastPageArray = [array objectAtIndex:3];
	NSEnumerator *currentLastPageEnu = [array objectAtIndex:4];
	NSMutableArray *newtLastPageArray = [array objectAtIndex:5];
	int i = [[array objectAtIndex:6] intValue];
	
	if (i<[currentBookSettingDic count]) {
		id tempKey;
		
		if (tempKey = [currnetBookSettingEnu nextObject]) {
			temp = [controller pathFromAliasData:[[currentBookSettingDic objectForKey:tempKey] objectForKey:@"alias"]];
			if ([[NSFileManager defaultManager] fileExistsAtPath:temp]) {
				[newtBookSettingDic setObject:[currentBookSettingDic objectForKey:tempKey] forKey:tempKey];
			}
		}
	} else {
		id object;
		if (object = [currentLastPageEnu nextObject]) {
			temp = [controller pathFromAliasData:[object objectForKey:@"alias"]];
			if ([[NSFileManager defaultManager] fileExistsAtPath:temp]) {
				[newtLastPageArray addObject:object];
			}
		}
		
	}
	
	i++;
	[disposeSettingProgress setDoubleValue: (double)i];
	[disposeSettingProgress displayIfNeeded];
	if ([disposeSettingPanel isVisible]) {
		if (i<([currentBookSettingDic count]+[currentLastPageArray count])) {
			[self performSelectorOnMainThread:@selector(disposeSettingMethod:) withObject:[NSArray arrayWithObjects:currentBookSettingDic,currnetBookSettingEnu,newtBookSettingDic,currentLastPageArray,currentLastPageEnu,newtLastPageArray,[NSNumber numberWithInt:i],nil] waitUntilDone:NO];
		} else {
			[defaults setObject:newtBookSettingDic forKey:@"BookSettings"];
			[defaults setObject:newtLastPageArray forKey:@"LastPages"];
			[defaults synchronize];
			[[NSApplication sharedApplication] endSheet:disposeSettingPanel returnCode:DIALOG_OK];
		}
	}
}

- (IBAction)disposeSettingsCancel:(id)sender
{
	[[NSApplication sharedApplication] endSheet:disposeSettingPanel returnCode:DIALOG_CANCEL];
}

- (void)disposeSettingSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
	[disposeSettingPanel orderOut:self];
	
	NSString *message;
	if (returnCode==DIALOG_CANCEL) {
		message = NSLocalizedString(@"Disposing of settings was canceled",@"");
	} else {
		message = NSLocalizedString(@"Disposing of settings was completed",@"");
	}
	
    NSBeginAlertSheet(NSLocalizedString(@"Disposing of settings",@""),
					  NSLocalizedString(@"OK",@""), 
					  nil, 
					  nil, 
					  preferences, 
					  self, 
					  @selector(completeDisposeSettingAlertSheetDidEnd:returnCode:contextInfo:), 
					  nil, 
					  nil, 
                      @"%@", message);
}
- (void)completeDisposeSettingAlertSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    [sheet orderOut:self];
}


#pragma mark fontConfig
- (IBAction)showFontPanel:(id)sender
{
    NSFontPanel* fontPanel;
    fontPanel = [[NSFontManager sharedFontManager] fontPanel:YES];
	[[NSFontManager sharedFontManager] setSelectedFont:[fontTextField font] isMultiple:NO];
	[fontPanel setLevel:NSMainMenuWindowLevel];
	[fontPanel setDelegate:(id)self];
	[[NSFontManager sharedFontManager] setAction:@selector(changeFont:)];
    [fontPanel makeKeyAndOrderFront:self];
}
- (void)changeFont:(id)fontManager
{
    NSFont *oldFont = [fontTextField font];
    NSFont *newFont = [fontManager convertFont:oldFont];
	[fontTextField setFont:newFont];
}
- (IBAction)changeFontColor:(id)sender
{
	[fontTextField setTextColor:[sender currentColor]];
}
- (IBAction)changeFontBGColor:(id)sender
{
	[fontTextField setBackgroundColor:[sender currentColor]];
}


- (IBAction)showPageBarFontPanel:(id)sender
{
    NSFontPanel* fontPanel;
    fontPanel = [[NSFontManager sharedFontManager] fontPanel:YES];
	[[NSFontManager sharedFontManager] setSelectedFont:[pageBarFontTextField font] isMultiple:NO];
	[fontPanel setLevel:NSMainMenuWindowLevel];
	[fontPanel setDelegate:(id)self];
	[[NSFontManager sharedFontManager] setAction:@selector(changePageBarFont:)];
    [fontPanel makeKeyAndOrderFront:self];
}
- (void)changePageBarFont:(id)fontManager
{
    NSFont *oldFont = [pageBarFontTextField font];
    NSFont *newFont = [fontManager convertFont:oldFont];
	[pageBarFontTextField setFont:newFont];
}
- (IBAction)changePageBarFontColor:(id)sender
{
	[pageBarFontTextField setTextColor:[sender currentColor]];
}
- (IBAction)changePageBarBGColor:(id)sender
{
	[pageBarFontTextField setBackgroundColor:[sender currentColor]];
}

- (NSUInteger) validModesForFontPanel : (NSFontPanel *) fontPanel
{
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1040
	if([NSObject respondsToSelector:@selector(finalize)]){
		return (NSFontPanelAllModesMask - NSFontPanelAllEffectsModeMask);
	}
#endif
	
	return NSFontPanelStandardModesMask;
}
#pragma mark mouseConfig
- (IBAction)mouseConfig:(id)sender
{
	editMode = NO;
	NSArray *menuArray = [[mousePanelActionPopUpButton menu] itemArray];
	NSArray *subMenuArray;
	int i,ii;
	for (i=0;i<[menuArray count];i++) {
		if ([[menuArray objectAtIndex:i] hasSubmenu]) {
			subMenuArray = [[[menuArray objectAtIndex:i] submenu] itemArray];
			for (ii=0;ii<[subMenuArray count];ii++) {
				[[subMenuArray objectAtIndex:ii] setTarget:self];
				[[subMenuArray objectAtIndex:ii] setAction:@selector(mousePanelActionPopUpButtonAction:)];
			}
		} else {
			[[menuArray objectAtIndex:i] setTarget:self];
			[[menuArray objectAtIndex:i] setAction:@selector(mousePanelActionPopUpButtonAction:)];
		}
	}
	
	[mousePanelActionPopUpButton setTitle:@"Action"];
	[mousePanelClickPopUpButton selectItemAtIndex:0];
	[mousePanelButtonPopUpButton selectItemAtIndex:0];
	[mousePanelSwitchActionCheck setEnabled:NO];
	[mouseValueTextField setEnabled:NO];
	lastInput = nil;
	[[NSApplication sharedApplication] beginSheet:mouseConfigPanel 
								   modalForWindow:preferences 
									modalDelegate:self 
								   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
									  contextInfo:nil];
}


- (IBAction)mouseConfigDelete:(id)sender
{
	if ([mouseTableView selectedRow] >= 0) {
		[currentMouseArray removeObjectAtIndex:[mouseTableView selectedRow]];
		[currentMouseArray sortUsingSelector:@selector(mouseArrayCompare:)];
		[mouseTableView reloadData];
	} else {
		NSBeep();
	}
}

- (IBAction)mousePanelOk:(id)sender
{
	if (!lastInput) {
		NSBeep();
		return;
	}
	if (editMode) {
		[currentMouseArray removeObjectAtIndex:editedInputIndex];
		editMode = NO;
	}
	
	NSMutableDictionary *mouse = lastInput;
	int action = [[lastInput objectForKey:@"action"] intValue];
	if (action < 0) {
		NSBeep();
		return;
	}
	switch (action) {
		case 5: case 19: case 20: case 37: case 38: case 39: case 40:
			[mouse setObject:[NSNumber numberWithInt:[[mouseValueTextField stringValue] intValue]] forKey:@"value"];
			break;
		case 47: case 48:
			[mouse setObject:[NSNumber numberWithFloat:[[mouseValueTextField stringValue] floatValue]] forKey:@"value"];
			break;
		default:
			break;
			
	}
	
	[mouse setObject:[NSNumber numberWithInt:(int)[mousePanelButtonPopUpButton selectedTag]] forKey:@"button"];
	int cMod = 0;
	if ([mousePanelShiftCheck state] == NSOnState) {
		cMod += 1;
	}
	if ([mousePanelOptionCheck state] == NSOnState) {
		cMod += 2;
	}
	if ([mousePanelControlCheck state] == NSOnState) {
		cMod += 4;
	}
	if ([mousePanelClickPopUpButton isEnabled]) {
		switch ([mousePanelClickPopUpButton indexOfSelectedItem]) {
			case 1:
				cMod += 100;
				break;
			case 2:
				cMod += 200;
				break;
			case 3:
				cMod += 300;
				break;
			case 4:
				cMod += 400;
				break;
			case 5:
				cMod += 500;
				break;
			case 6:
				cMod += 600;
				break;
			case 7:
				cMod += 700;
				break;
			case 8:
				cMod += 800;
				break;
			case 9:
				cMod += 900;
				break;
			case 10:
				cMod += 1000;
				break;
			default:break;
		}
	}
	[mouse setObject:[NSNumber numberWithInt:cMod] forKey:@"modifier"];
	
	if ([mousePanelSwitchActionCheck isEnabled] && [mousePanelSwitchActionCheck state] == NSOnState) {
		[mouse setObject:[NSNumber numberWithBool:YES] forKey:@"switchAction"];
	} else {
		[mouse removeObjectForKey:@"switchAction"];
	}
	
	[currentMouseArray addObject:mouse];
	[currentMouseArray sortUsingSelector:@selector(mouseArrayCompare:)];
	[mouseTableView reloadData];
    [mouseTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[currentMouseArray indexOfObject:mouse]] byExtendingSelection:NO];
	[mouseTableView scrollRowToVisible:[currentMouseArray indexOfObject:mouse]];
	[[NSApplication sharedApplication] endSheet:mouseConfigPanel returnCode:DIALOG_OK];
	[lastInput release];
	lastInput = nil;
}

- (IBAction)mousePanelCancel:(id)sender
{
	if (lastInput) {
		[lastInput release];
		lastInput = nil;
	}
	[[NSApplication sharedApplication] endSheet:mouseConfigPanel returnCode:DIALOG_CANCEL];
}

- (IBAction)mousePanelActionPopUpButtonAction:(id)sender
{
	NSNumberFormatter *fo = [mouseValueTextField formatter];
	switch ([sender tag]) {
		case 5: case 19: case 20:
			[fo setFormat:@"0;0;(0)"];
			[mouseValueTextField setEnabled:YES];
			[mouseValueTextField setStringValue:[NSString stringWithFormat:@"%i", 10]];
			break;
		case 37: case 38: case 39: case 40:
			[fo setFormat:@"0;0;(0)"];
			[mouseValueTextField setEnabled:YES];
			[mouseValueTextField setStringValue:[NSString stringWithFormat:@"%i", 20]];
			break;
		case 47: case 48:
			[fo setFormat:@"0.00;0.00;(0.00)"];
			//[fo setFormat:@"$#,###.00;0.00;($#,##0.00)"];
			[mouseValueTextField setEnabled:YES];
			[mouseValueTextField setStringValue:[NSString stringWithFormat:@"%f", 1.0]];
			break;
		default:
			[fo setFormat:@"0;0;(0)"];
			[mouseValueTextField setEnabled:NO];
			break;
	}
	switch ([sender tag]) {
		case 6: case 7:
		case 8: case 9:
		case 10: case 11:
		case 12: case 13:
		case 14: case 15:
		case 19: case 20:
		case 33: case 34:
		case 44: case 45:
			[mousePanelSwitchActionCheck setEnabled:YES];
			break;
		default:
			[mousePanelSwitchActionCheck setEnabled:NO];
			break;
	}
	
	[mousePanelActionPopUpButton setTitle:[sender title]];
	
	if (lastInput) {
		[lastInput setObject:[NSNumber numberWithInt:(int)[sender tag]] forKey:@"action"];
	} else {
		lastInput = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
			[NSNumber numberWithInt:(int)[sender tag]],@"action",
			nil];
	}
}



- (IBAction)mouseReset:(id)sender
{
	int mode = (int)[mouseModePopUpButton indexOfSelectedItem];
	NSString *title,*message;
	switch (mode) {
		case 0:
			message = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to reset the %@ mode mouse setting?",@""),
				NSLocalizedString(@"Fit to Screen",@"")];
			title = [NSString stringWithFormat:NSLocalizedString(@"Reset mouse setting",@"")];
			break;
		case 1:
			message = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to reset the %@ mode mouse setting?",@""),
				NSLocalizedString(@"Fit to Screen Width",@"")];
			title = [NSString stringWithFormat:NSLocalizedString(@"Reset mouse setting",@"")];
			break;
		case 2:
			message = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to reset the %@ mode mouse setting?",@""),
				NSLocalizedString(@"No Scale",@"")];
			title = [NSString stringWithFormat:NSLocalizedString(@"Reset mouse setting",@"")];
			break;
		default:
			NSBeep();
			return;
	}
	
	
	NSBeginAlertSheet(title,
					  NSLocalizedString(@"OK",@""), 
					  NSLocalizedString(@"Cancel",@""), 
					  nil,
					  preferences,
					  self,
					  @selector(runAlertSheetDidEnd:returnCode:contextInfo:), 
					  nil, 
					  @"mouse", 
                      @"%@", message);
}

#pragma mark keyConfig

- (BOOL)inKeyEdit
{
	if ([keyConfigPanel isKeyWindow] && [[keyPanelTextView backgroundColor] isEqualTo:[NSColor lightGrayColor]]) {
		return YES;
	}
	return NO;
}
- (void)setKeyCharacters:(NSString*)characters
{
    unichar character = [characters characterAtIndex: 0];
	NSString *keyName;
	switch(character) {
		case kRemoteButtonPlus:
			keyName = @"AppleRemote Volume up";			
			break;
		case kRemoteButtonMinus:
			keyName = @"AppleRemote Volume down";
			break;			
		case kRemoteButtonMenu:
			keyName = @"AppleRemote Menu";
			break;			
		case kRemoteButtonPlay:
			keyName = @"AppleRemote Play";
			break;			
		case kRemoteButtonRight:	
			keyName = @"AppleRemote Right";
			break;			
		case kRemoteButtonLeft:
			keyName = @"AppleRemote Left";
			break;			
		case kRemoteButtonRight_Hold:
			//keyName = @"AppleRemote Right holding";	
			keyName = @"AppleRemote Right";
			break;	
		case kRemoteButtonLeft_Hold:
			//keyName = @"AppleRemote Left holding";	
			keyName = @"AppleRemote Left";	
			break;			
		case kRemoteButtonPlus_Hold:
			//keyName = @"AppleRemote Volume up holding";	
			keyName = @"AppleRemote Volume up";	
			break;				
		case kRemoteButtonMinus_Hold:			
			//keyName = @"AppleRemote Volume down holding";
			keyName = @"AppleRemote Volume down";	
			break;				
		case kRemoteButtonPlay_Hold:
			//keyName = @"AppleRemote Play (sleep mode)";
			keyName = @"AppleRemote Play";
			break;			
		case kRemoteButtonMenu_Hold:
			//keyName = @"AppleRemote Menu (long)";
			keyName = @"AppleRemote Menu";
			break;
		case kRemoteControl_Switched:
			keyName = @"AppleRemote Remote Control Switched";
			break;
		default:
			keyName = [NSString stringWithFormat:@"AppleRemote button%@",characters];
			break;
	}
	
	unsigned int cMod = 100;
	
	if (lastInput) {
		[lastInput setObject:keyName forKey:@"keyname"];
		[lastInput setObject:characters forKey:@"key"];
		[lastInput setObject:[NSNumber numberWithInt:cMod] forKey:@"modifier"];
	} else {
		lastInput = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
			[NSNumber numberWithInt:-1],@"action",
			keyName,@"keyname",
			characters,@"key",
			[NSNumber numberWithInt:cMod],@"modifier",
			nil];
	}
	[keyPanelTextView setString:keyName];
	
	[keyPanelPopUpButton setEnabled:YES];
}

- (IBAction)keyConfig:(id)sender
{		
	editMode = NO;
	NSArray *menuArray = [[keyPanelPopUpButton menu] itemArray];
	NSArray *subMenuArray;
	int i,ii;
	for (i=0;i<[menuArray count];i++) {
		if ([[menuArray objectAtIndex:i] hasSubmenu]) {
			subMenuArray = [[[menuArray objectAtIndex:i] submenu] itemArray];
			for (ii=0;ii<[subMenuArray count];ii++) {
				[[subMenuArray objectAtIndex:ii] setTarget:self];
				[[subMenuArray objectAtIndex:ii] setAction:@selector(keyPanelPopUpButtonAction:)];
			}
		} else {
			[[menuArray objectAtIndex:i] setTarget:self];
			[[menuArray objectAtIndex:i] setAction:@selector(keyPanelPopUpButtonAction:)];
		}
	}
	
	[keyPanelPopUpButton setTitle:@"Action"];
	[keyValueTextField setEnabled:NO];
	[keyPanelPopUpButton setEnabled:NO];
	[keyPanelSwitchActionCheck setEnabled:NO];
	lastInput = nil;
	[keyPanelTextView setString:@"Push any key..."];
	[[NSApplication sharedApplication] beginSheet:keyConfigPanel 
								   modalForWindow:preferences 
									modalDelegate:self 
								   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
									  contextInfo:nil];
}




- (void)keyConfigAction:(id)sender
{
	NSString *keyName;
	NSString *characters = [sender charactersIgnoringModifiers];
    unichar character = [characters characterAtIndex: 0];
	if (character == NSLeftArrowFunctionKey) {
		keyName = @"left arrow";
	} else if (character == NSRightArrowFunctionKey) {
		keyName = @"right arrow";
	} else if (character == NSUpArrowFunctionKey) {
		keyName = @"up arrow";
	} else if (character == NSDownArrowFunctionKey) {
		keyName = @"down arrow";
	} else if (character == NSPageUpFunctionKey) {
		keyName = @"page up";
	} else if (character == NSPageDownFunctionKey) {
		keyName = @"page down";
	} else if (character == NSHomeFunctionKey) {
		keyName = @"home";
	} else if (character == NSEndFunctionKey) {
		keyName = @"end";
	} else if (character == NSTabCharacter || character == NSBackTabCharacter) {
		keyName = @"tab";
	} else if (character == NSDeleteFunctionKey) {
		keyName = @"Fwd Delete";
	} else if (character == NSDeleteCharacter) {
		keyName = @"delete";
	} else if (character == NSHomeFunctionKey) {
		keyName = @"home";
	} else if (character == NSClearLineFunctionKey) {
		keyName = @"clear";
	} else if (character == NSHelpFunctionKey) {
		keyName = @"help";
	} else if (character == NSEnterCharacter) {
		keyName = @"enter";
	} else if (character == 0x20){
		keyName = @"space";
	} else if (character == NSCarriageReturnCharacter){
		keyName = @"return";
	} else if (character == NSF1FunctionKey) {
		keyName = @"F1";
	} else if (character == NSF2FunctionKey) {
		keyName = @"F2";
	} else if (character == NSF3FunctionKey) {
		keyName = @"F3";
	} else if (character == NSF4FunctionKey) {
		keyName = @"F4";
	} else if (character == NSF5FunctionKey) {
		keyName = @"F5";
	} else if (character == NSF6FunctionKey) {
		keyName = @"F6";
	} else if (character == NSF7FunctionKey) {
		keyName = @"F7";
	} else if (character == NSF8FunctionKey) {
		keyName = @"F8";
	} else if (character == NSF9FunctionKey) {
		keyName = @"F9";
	} else if (character == NSF10FunctionKey) {
		keyName = @"F10";
	} else if (character == NSF11FunctionKey) {
		keyName = @"F11";
	} else if (character == NSF12FunctionKey) {
		keyName = @"F12";
	} else if (character == NSF13FunctionKey) {
		keyName = @"F13";
	} else if (character == NSF14FunctionKey) {
		keyName = @"F14";
	} else if (character == NSF15FunctionKey) {
		keyName = @"F15";
	} else if (character == NSF16FunctionKey) {
		keyName = @"F16";
	} else if (character == 0x1B) {
		[self keyPanelCancel:self];
		return;
	} else {
		keyName = characters;
	}
	
	
	NSMutableString *tempKeyName = [NSMutableString string]; 
	unsigned int cMod = 0;
	BOOL shift = ([sender modifierFlags] & NSShiftKeyMask) ? YES : NO;
	BOOL option = ([sender modifierFlags] & NSAlternateKeyMask) ? YES : NO;
	BOOL control = ([sender modifierFlags] & NSControlKeyMask) ? YES : NO;
	BOOL numeric = ([sender modifierFlags] & NSNumericPadKeyMask) ? YES : NO;
	if (shift) {
		cMod += 1;
		[tempKeyName appendString:@"shift+"];
	}
	if (option) {
		cMod += 2;
		[tempKeyName appendString:@"option+"];
	}
	if (control) {
		cMod += 4;
		[tempKeyName appendString:@"control+"];
	}
	if (numeric) {
		if (character == NSLeftArrowFunctionKey||character == NSRightArrowFunctionKey||character == NSUpArrowFunctionKey||character == NSDownArrowFunctionKey) {
		} else {
			cMod += 8;
			[tempKeyName appendString:@"num "];
		}
	}
	keyName = [NSString stringWithFormat:@"%@%@",tempKeyName,keyName];
	
	if (lastInput) {
		[lastInput setObject:keyName forKey:@"keyname"];
		[lastInput setObject:characters forKey:@"key"];
		[lastInput setObject:[NSNumber numberWithInt:cMod] forKey:@"modifier"];
	} else {
		lastInput = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
			[NSNumber numberWithInt:-1],@"action",
			keyName,@"keyname",
			characters,@"key",
			[NSNumber numberWithInt:cMod],@"modifier",
			nil];
	}
	[keyPanelTextView setString:keyName];
	
	
	[keyPanelPopUpButton setEnabled:YES];
}

- (IBAction)keyPanelOk:(id)sender
{
	if (!lastInput) {
		NSBeep();
		return;
	}
	if (editMode) {
		[currentKeyArray removeObjectAtIndex:editedInputIndex];
		editMode = NO;
	}
	int action = [[lastInput objectForKey:@"action"] intValue];
	if (action < 0) {
		NSBeep();
		return;
	}
	switch (action) {
		case 13: case 14: case 30: case 31: case 32: case 33: case 39:
			[lastInput setObject:[NSNumber numberWithInt:[[keyValueTextField stringValue] intValue]] forKey:@"value"];
			break;
		case 37: case 38:
			[lastInput setObject:[NSNumber numberWithFloat:[[keyValueTextField stringValue] floatValue]] forKey:@"value"];
			break;
		default:
			break;
			
	}
	if ([keyPanelSwitchActionCheck isEnabled] && [keyPanelSwitchActionCheck state] == NSOnState) {
		[lastInput setObject:[NSNumber numberWithBool:YES] forKey:@"switchAction"];
	} else {
		[lastInput removeObjectForKey:@"switchAction"];
	}
	
	[currentKeyArray addObject:lastInput];
	[currentKeyArray sortUsingSelector:@selector(keyArrayCompare:)];
	[inputTableView reloadData];
    [inputTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[currentKeyArray indexOfObject:lastInput]] byExtendingSelection:NO];
	[inputTableView scrollRowToVisible:[currentKeyArray indexOfObject:lastInput]];
	[[NSApplication sharedApplication] endSheet:keyConfigPanel returnCode:DIALOG_OK];
	[lastInput release];
	lastInput = nil;
}

- (IBAction)keyPanelCancel:(id)sender
{
	if (lastInput) {
		[lastInput release];
		lastInput = nil;
	}
	[[NSApplication sharedApplication] endSheet:keyConfigPanel returnCode:DIALOG_CANCEL];
}

- (IBAction)keyConfigDelete:(id)sender
{
	if ([inputTableView selectedRow] >= 0) {
		[currentKeyArray removeObjectAtIndex:[inputTableView selectedRow]];
		[currentKeyArray sortUsingSelector:@selector(keyArrayCompare:)];
		[inputTableView reloadData];
	} else {
		NSBeep();
	}
}

- (IBAction)keyPanelPopUpButtonAction:(id)sender
{
	NSNumberFormatter *fo = [keyValueTextField formatter];
	switch ([sender tag]) {
		case 13: case 14: case 39:
			[fo setFormat:@"0;0;(0)"];
			[keyValueTextField setEnabled:YES];
			[keyValueTextField setStringValue:[NSString stringWithFormat:@"%i", 10]];
			break;
		case 30: case 31: case 32: case 33:
			[fo setFormat:@"0;0;(0)"];
			[keyValueTextField setEnabled:YES];
			[keyValueTextField setStringValue:[NSString stringWithFormat:@"%i", 20]];
			break;
		case 37: case 38:
			[fo setFormat:@"0.00;0.00;(0.00)"];
			[keyValueTextField setEnabled:YES];
			[keyValueTextField setStringValue:[NSString stringWithFormat:@"%f", 1.0]];
			break;
		default:
			[fo setFormat:@"0;0;(0)"];
			[keyValueTextField setEnabled:NO];
			break;
	}
	switch ([sender tag]) {
		case 0: case 1: case 2:
		case 3: case 4: case 5:
		case 6: case 7: case 8:
		case 9: case 13: case 14:
		case 26: case 27:
		case 35: case 36:
			[keyPanelSwitchActionCheck setEnabled:YES];
			break;
		default:
			[keyPanelSwitchActionCheck setEnabled:NO];
			break;
	}
	[keyPanelPopUpButton setTitle:[sender title]];
	
	if (lastInput) {
		[lastInput setObject:[NSNumber numberWithInt:(int)[sender tag]] forKey:@"action"];
	}
}

- (IBAction)keyReset:(id)sender
{
	/* Reset 000
	Are you sure you want to reset the Junk Mail database?*/
	/* 000のリセット
	000をリセットしてもよろしいですか?*/
	
	int mode = (int)[keyModePopUpButton indexOfSelectedItem];
	NSString *title,*message;
	switch (mode) {
		case 0:
			message = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to reset the %@ mode key setting?",@""),
				NSLocalizedString(@"Fit to Screen",@"")];
			title = [NSString stringWithFormat:NSLocalizedString(@"Reset key setting",@"")];
			break;
		case 1:
			message = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to reset the %@ mode key setting?",@""),
				NSLocalizedString(@"Fit to Screen Width",@"")];
			title = [NSString stringWithFormat:NSLocalizedString(@"Reset key setting",@"")];
			break;
		case 2:
			message = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to reset the %@ mode key setting?",@""),
				NSLocalizedString(@"No Scale",@"")];
			title = [NSString stringWithFormat:NSLocalizedString(@"Reset key setting",@"")];
			break;
		default:
			NSBeep();
			return;
	}
	NSBeginAlertSheet(title,
					  NSLocalizedString(@"OK",@""), 
					  NSLocalizedString(@"Cancel",@""), 
					  nil,
					  preferences,
					  self,
					  @selector(runAlertSheetDidEnd:returnCode:contextInfo:), 
					  nil, 
					  @"key", 
                      @"%@", message);	
}
#pragma mark key&mouseEdit
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if (aTableView == inputTableView) {
		editMode = YES;
		editedInputIndex = rowIndex;
		
		lastInput = [[NSMutableDictionary dictionaryWithDictionary:[currentKeyArray objectAtIndex:rowIndex]] retain];
		
		int tag = [[lastInput objectForKey:@"action"] intValue];
		
		NSArray *menuArray = [[keyPanelPopUpButton menu] itemArray];
		NSArray *subMenuArray;
		int i,ii;
		for (i=0;i<[menuArray count];i++) {
			if ([[menuArray objectAtIndex:i] hasSubmenu]) {
				subMenuArray = [[[menuArray objectAtIndex:i] submenu] itemArray];
				for (ii=0;ii<[subMenuArray count];ii++) {
					[[subMenuArray objectAtIndex:ii] setTarget:self];
					[[subMenuArray objectAtIndex:ii] setAction:@selector(keyPanelPopUpButtonAction:)];
					if ([[subMenuArray objectAtIndex:ii] tag] == tag) {
						if (![[[subMenuArray objectAtIndex:ii] title] isEqualToString:@""]) {
							[[[menuArray objectAtIndex:i] submenu] performActionForItemAtIndex:ii];
							if ([lastInput objectForKey:@"value"]) [keyValueTextField setStringValue:[[lastInput objectForKey:@"value"] stringValue]];
						}
					}
				}
			} else {
				[[menuArray objectAtIndex:i] setTarget:self];
				[[menuArray objectAtIndex:i] setAction:@selector(keyPanelPopUpButtonAction:)];
				/*
				 //今のところサブメニュー以外に項目ないから…
				 if ([[menuArray objectAtIndex:i] tag] == tag) {
					 NSLog(@"2 kita %i %@",tag,[[menuArray objectAtIndex:i] title]);
				 }*/
			}
		}
		if ([[lastInput objectForKey:@"switchAction"] boolValue] == YES) {
			[keyPanelSwitchActionCheck setState:NSOnState];
		} else {
			[keyPanelSwitchActionCheck setState:NSOffState];
		}
		
		[keyPanelPopUpButton setEnabled:YES];
		[keyPanelTextView setString:[lastInput objectForKey:@"keyname"]];
		[[NSApplication sharedApplication] beginSheet:keyConfigPanel 
									   modalForWindow:preferences 
										modalDelegate:self 
									   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
										  contextInfo:nil];
	} else if (aTableView == mouseTableView) {
		editMode = YES;
		editedInputIndex = rowIndex;
		
		lastInput = [[NSMutableDictionary dictionaryWithDictionary:[currentMouseArray objectAtIndex:rowIndex]] retain];
		int tag = [[lastInput objectForKey:@"action"] intValue];
		
		NSArray *menuArray = [[mousePanelActionPopUpButton menu] itemArray];
		NSArray *subMenuArray;
		int i,ii;
		for (i=0;i<[menuArray count];i++) {
			if ([[menuArray objectAtIndex:i] hasSubmenu]) {
				subMenuArray = [[[menuArray objectAtIndex:i] submenu] itemArray];
				for (ii=0;ii<[subMenuArray count];ii++) {
					[[subMenuArray objectAtIndex:ii] setTarget:self];
					[[subMenuArray objectAtIndex:ii] setAction:@selector(mousePanelActionPopUpButtonAction:)];
					if ([[subMenuArray objectAtIndex:ii] tag] == tag) {
						if (![[[subMenuArray objectAtIndex:ii] title] isEqualToString:@""]) {
							[[[menuArray objectAtIndex:i] submenu] performActionForItemAtIndex:ii];
							if ([lastInput objectForKey:@"value"]) [mouseValueTextField setStringValue:[[lastInput objectForKey:@"value"] stringValue]];
						}
					}
				}
			} else {
				[[menuArray objectAtIndex:i] setTarget:self];
				[[menuArray objectAtIndex:i] setAction:@selector(mousePanelActionPopUpButtonAction:)];
			}
		}
		[mousePanelShiftCheck setState:NSOffState];
		[mousePanelOptionCheck setState:NSOffState];
		[mousePanelControlCheck setState:NSOffState];
		int cMod = [[lastInput objectForKey:@"modifier"] intValue];
		if (cMod>=1000) {
			[mousePanelClickPopUpButton selectItemAtIndex:10];
			cMod -= 1000;
		} else if (cMod>=900) {
			[mousePanelClickPopUpButton selectItemAtIndex:9];
			cMod -= 900;
		} else if (cMod>=800) {
			[mousePanelClickPopUpButton selectItemAtIndex:8];
			cMod -= 800;
		} else if (cMod>=700) {
			[mousePanelClickPopUpButton selectItemAtIndex:7];
			cMod -= 700;
		} else if (cMod>=600) {
			[mousePanelClickPopUpButton selectItemAtIndex:6];
			cMod -= 600;
		} else if (cMod>=500) {
			[mousePanelClickPopUpButton selectItemAtIndex:5];
			cMod -= 500;
		} else if (cMod>=400) {
			[mousePanelClickPopUpButton selectItemAtIndex:4];
			cMod -= 400;
		} else if (cMod>=300) {
			[mousePanelClickPopUpButton selectItemAtIndex:3];
			cMod -= 300;
		} else if (cMod>=200) {
			[mousePanelClickPopUpButton selectItemAtIndex:2];
			cMod -= 200;
		} else if (cMod>=100) {
			[mousePanelClickPopUpButton selectItemAtIndex:1];
			cMod -= 100;
		} else {
			[mousePanelClickPopUpButton selectItemAtIndex:0];
		}
		switch (cMod) {
			case 0:break;
			case 1:[mousePanelShiftCheck setState:NSOnState];break;
			case 2:[mousePanelOptionCheck setState:NSOnState];break;
			case 3:[mousePanelShiftCheck setState:NSOnState];[mousePanelOptionCheck setState:NSOnState];break;
			case 4:[mousePanelControlCheck setState:NSOnState];break;
			case 5:[mousePanelControlCheck setState:NSOnState];[mousePanelShiftCheck setState:NSOnState];break;
			case 6:[mousePanelControlCheck setState:NSOnState];[mousePanelOptionCheck setState:NSOnState];break;
			case 7:[mousePanelControlCheck setState:NSOnState];[mousePanelShiftCheck setState:NSOnState];[mousePanelOptionCheck setState:NSOnState];break;
			default:break;
		}
		[mousePanelButtonPopUpButton selectItemWithTag:[[lastInput objectForKey:@"button"] intValue]];
		if ([mousePanelButtonPopUpButton selectedTag]>=1000) {
			[mousePanelClickPopUpButton setEnabled:NO];
		} else {
			[mousePanelClickPopUpButton setEnabled:YES];
		}
		if ([[lastInput objectForKey:@"switchAction"] boolValue] == YES) {
			[mousePanelSwitchActionCheck setState:NSOnState];
		} else {
			[mousePanelSwitchActionCheck setState:NSOffState];
		}
		[[NSApplication sharedApplication] beginSheet:mouseConfigPanel 
									   modalForWindow:preferences 
										modalDelegate:self 
									   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
										  contextInfo:nil];
		
	}
    return NO;
}

#pragma mark key&mouseConfig
- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
	if ([keyConfigPanel isVisible]) {
		[keyConfigPanel orderOut:self];
	} else if ([mouseConfigPanel isVisible]) {
		[mouseConfigPanel orderOut:self];
	}
	
	if(returnCode == DIALOG_OK) {
    }
}

- (void)runAlertSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
	[sheet orderOut:self];
	
	if(returnCode == NSAlertDefaultReturn) {
		if ([(NSString*)contextInfo isEqualToString:@"mouse"]) {
			int mode = (int)[mouseModePopUpButton indexOfSelectedItem];
			switch (mode) {
				case 0:
					[mouseArray removeAllObjects];
					[mouseArray addObjectsFromArray:[PreferenceController defaultMouseArray]];
					currentMouseArray = mouseArray;
					break;
				case 1:
					[mouseArrayMode2 removeAllObjects];
					[mouseArrayMode2 addObjectsFromArray:[PreferenceController defaultMouseArrayMode2]];
					currentMouseArray = mouseArrayMode2;
					break;
				case 2:
					[mouseArrayMode3 removeAllObjects];
					[mouseArrayMode3 addObjectsFromArray:[PreferenceController defaultMouseArrayMode3]];
					currentMouseArray = mouseArrayMode3;
					break;
				default:
					break;
			}
			[currentMouseArray sortUsingSelector:@selector(mouseArrayCompare:)];
			[mouseTableView reloadData];
		} else if ([(NSString*)contextInfo isEqualToString:@"key"]) {
			int mode = (int)[keyModePopUpButton indexOfSelectedItem];	
			switch (mode) {
				case 0:
					[keyArray removeAllObjects];
					[keyArray addObjectsFromArray:[PreferenceController defaultKeyArray]];
					currentKeyArray = keyArray;
					break;
				case 1:
					[keyArrayMode2 removeAllObjects];
					[keyArrayMode2 addObjectsFromArray:[PreferenceController defaultKeyArrayMode2]];
					currentKeyArray = keyArrayMode2;
					break;
				case 2:
					[keyArrayMode3 removeAllObjects];
					[keyArrayMode3 addObjectsFromArray:[PreferenceController defaultKeyArrayMode3]];
					currentKeyArray = keyArrayMode3;
					break;
				default:
					break;
			}
			[currentKeyArray sortUsingSelector:@selector(keyArrayCompare:)];
			[inputTableView reloadData];
		}
    }
}


#pragma mark setPageString&PageBarPosition
- (IBAction)setPosition:(id)sender
{
	[accessorySettingPanel setWorksWhenModal:YES];
	[accessorySettingPanel setBackgroundColor:[viewBackGroundColor currentColor]];
	[accessorySettingView display];
	[accessorySettingPanel setLevel:NSMainMenuWindowLevel];
	[accessorySettingPanel setDelegate:(id)self];
	
	
	[accessorySettingView setPageBarBGColor:[pageBarBGColor currentColor]];
	[accessorySettingView setPageBarBorderColor:[pageBarBorderColor currentColor]];
	[accessorySettingView setPageBarReadedColor:[pageBarReadedColor currentColor]];
	[accessorySettingView setTextFont:[fontTextField font]];
	[accessorySettingView setTextFontColor:[pageColor currentColor]];
	[accessorySettingView setTextBGColor:[pageBGColor currentColor]];
	[accessorySettingView setTextBorderColor:[pageBorderColor currentColor]];
	
	[accessorySettingView setPositionSettingMode:YES];
	[accessorySettingPanel makeKeyAndOrderFront:self];
	[accessorySettingView setPageString:@"#1-2/345 (67.jpg | 89.jpg)"];
	[accessorySettingView drawAccessory];
}

- (void)windowDidResignKey:(NSNotification *)aNotification
{
	//showFontPanelとsetPositionで使ってる
	[[aNotification object] orderOut:self];
}


@end
