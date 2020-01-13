/* PreferenceController */

#import <Cocoa/Cocoa.h>

@interface PreferenceController : NSObject
{	
	int editedInputIndex;
	BOOL editMode;
	
	NSMutableDictionary *lastInput;
	NSMutableArray *currentKeyArray;
	NSMutableArray *currentMouseArray;
	
	NSMutableArray *keyArray;
	NSMutableArray *keyArrayMode2;
	NSMutableArray *keyArrayMode3;
	NSMutableArray *mouseArray;
	NSMutableArray *mouseArrayMode2;
	NSMutableArray *mouseArrayMode3;
	
	NSUserDefaults *defaults;
	
	IBOutlet id sortModePopUpButton;
	
	
	IBOutlet id changeOpenWithCheck;
	IBOutlet id changeCreatorCheck;
	
	IBOutlet id dontHideMenubarCheck;
	IBOutlet id showThumbnailCheck;
	
	IBOutlet id imageCacheTextField;
	IBOutlet id screenCacheTextField;
	IBOutlet id thumbnailCacheTextField;
	
    IBOutlet id bufferingModePopUpButton;
    IBOutlet id canScrollActionPopUpButton;
    IBOutlet id controller;
    IBOutlet id enlargePopUpButton;
    IBOutlet id fitOriginalCheck;
    IBOutlet id inputTabView;
    IBOutlet id inputTableView;
    IBOutlet id interpolationPopUpButton;
    IBOutlet id keyConfigPanel;
    IBOutlet id keyModePopUpButton;
    IBOutlet id keyPanelPopUpButton;
	IBOutlet id keyPanelSwitchActionCheck;
    IBOutlet id keyValueTextField;
    IBOutlet id loopPopUpButton;
    IBOutlet id loupeSizeTextField;
    IBOutlet id loupeRateTextField;
    IBOutlet id mouseConfigPanel;
    IBOutlet id mouseModePopUpButton;
    IBOutlet id mousePanelActionPopUpButton;
    IBOutlet id mousePanelButtonPopUpButton;
    IBOutlet id mousePanelClickPopUpButton;
    IBOutlet id mousePanelControlCheck;
    IBOutlet id mousePanelOptionCheck;
    IBOutlet id mousePanelShiftCheck;
	IBOutlet id mousePanelSwitchActionCheck;
    IBOutlet id mouseTableView;
    IBOutlet id mouseValueTextField;
    IBOutlet id openLastFolderCheck;
    IBOutlet id pageBarBGColor;
    IBOutlet id pageBarBorderColor;
    IBOutlet id pageBarReadedColor;
	IBOutlet id pageBarShowThumbCheck;
	IBOutlet id pageBarAutoHideCheck;
    IBOutlet id pageColor;
    IBOutlet id pageBGColor;
    IBOutlet id pageBorderColor;
	IBOutlet id pageNumAutoHideCheck;
    IBOutlet id preferences;
    IBOutlet id prevPageActionPopUpButton;
    IBOutlet id readLeftButton;
    IBOutlet id readRightButton;
    IBOutlet id readSingleCheckButton;
    IBOutlet id readSubFolderCheck;
    IBOutlet id rememberBookSettingsCheck;
    IBOutlet id singleSettingTextField;
    IBOutlet id slideshowSlider;
    IBOutlet id slideshowTextField;
    IBOutlet id thumbnailTextFieldCol;
    IBOutlet id thumbnailTextFieldRow;
    IBOutlet id wheelSlider;
    IBOutlet id window;
    IBOutlet id viewBackGroundColor;
    IBOutlet id alwaysRememberLastCheck;
    IBOutlet id numberOfOpenRecentTextField;
	
    IBOutlet id fontTextField;
    IBOutlet id pageBarFontTextField;
    IBOutlet id pageBarFontColor;
	
    IBOutlet id showPageNumCheck;
    IBOutlet id showPageBarCheck;
	
    IBOutlet id accessorySettingPanel;
    IBOutlet id accessorySettingView;
	
	
    IBOutlet id keyPanelTextView;
	
    IBOutlet id goToLastPopUpButton;
	
    IBOutlet id openLinkPopUpButton;
	
    IBOutlet id disposeSettingPanel;
    IBOutlet id disposeSettingProgress;
	
    IBOutlet id changeCurrentFolderPopUpButton;
}
+ (NSArray*)defaultKeyArray;
+ (NSArray*)defaultKeyArrayMode2;
+ (NSArray*)defaultKeyArrayMode3;
+ (NSArray*)defaultMouseArray;
+ (NSArray*)defaultMouseArrayMode2;
+ (NSArray*)defaultMouseArrayMode3;

+ (void)setDefaultKeyArray;
+ (void)setDefaultKeyArrayMode2;
+ (void)setDefaultKeyArrayMode3;
+ (void)setDefaultMouseArray;
+ (void)setDefaultMouseArrayMode2;
+ (void)setDefaultMouseArrayMode3;


- (void)preferences;

- (IBAction)showFontPanel:(id)sender;


- (IBAction)showPageBarFontPanel:(id)sender;
- (IBAction)changePageBarFontColor:(id)sender;
- (IBAction)changePageBarBGColor:(id)sender;

- (IBAction)changeFontColor:(id)sender;
- (IBAction)changeFontBGColor:(id)sender;
- (IBAction)keyConfig:(id)sender;
- (IBAction)keyConfigAction:(id)sender;
- (IBAction)keyConfigDelete:(id)sender;
- (IBAction)keyPanelCancel:(id)sender;
- (IBAction)keyPanelOk:(id)sender;
- (IBAction)keyPanelPopUpButtonAction:(id)sender;
- (IBAction)mouseConfig:(id)sender;
- (IBAction)mouseConfigDelete:(id)sender;
- (IBAction)mousePanelActionPopUpButtonAction:(id)sender;
- (IBAction)mousePanelCancel:(id)sender;
- (IBAction)mousePanelOk:(id)sender;
- (IBAction)selectedKeyMode:(id)sender;
- (IBAction)selectedMouseMode:(id)sender;
- (IBAction)setValueToSlider:(id)sender;
- (IBAction)sheetCancel:(id)sender;
- (IBAction)sheetOk:(id)sender;
- (IBAction)sliderMoved:(id)sender;
- (IBAction)changeBufferingMode:(id)sender;


- (IBAction)keyReset:(id)sender;
- (IBAction)mouseReset:(id)sender;

- (IBAction)dummyAction:(id)sender;

- (IBAction)disposeSettings:(id)sender;
- (IBAction)disposeSettingsCancel:(id)sender;

- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo;


- (IBAction)setPosition:(id)sender;
- (BOOL)inKeyEdit;
- (void)setKeyCharacters:(NSString*)characters;
@end
