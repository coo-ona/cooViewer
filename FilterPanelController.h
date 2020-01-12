//
//  FilterPanelController.h
//  cooViewer
//
//  Created by coo on 2020/01/11.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>

@interface FilterPanelController : NSObject
{
    IBOutlet id filterPanel;
    IBOutlet id scrollView;
    IBOutlet id popupButton;
    IBOutlet id contentsView;
    
    IBOutlet id controller;
    
    NSMutableDictionary *filterDic;
    NSMutableArray *selectedFilterKeys;
    NSMutableDictionary *selectedFilters;
    NSMutableDictionary *selectedFilterUIViews;
}
- (BOOL)validateMenuItem:(NSMenuItem *)anItem;
- (IBAction)openFilterPanel:(id)sender;
@end
