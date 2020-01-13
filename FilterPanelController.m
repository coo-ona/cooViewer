//
//  FilterPanelController.m
//  cooViewer
//
//  Created by coo on 2020/01/11.
//

#import "FilterPanelController.h"

@implementation FilterPanelController
-(void)awakeFromNib
{
    filterDic = [[NSMutableDictionary alloc] init];
    selectedFilterKeys = [[NSMutableArray alloc] init];
    selectedFilters = [[NSMutableDictionary alloc] init];
    selectedFilterUIViews = [[NSMutableDictionary alloc] init];
    [CIPlugIn loadAllPlugIns];
    
    NSArray *usingCategories =
        [NSArray arrayWithObjects:
                        [NSArray arrayWithObjects:kCICategoryColorAdjustment,kCICategoryStillImage, nil],
                        [NSArray arrayWithObjects:kCICategoryColorEffect,kCICategoryStillImage, nil],
                        [NSArray arrayWithObjects:kCICategorySharpen,kCICategoryStillImage, nil],
                        [NSArray arrayWithObjects:kCICategoryBlur,kCICategoryStillImage, nil],
                        nil
          ];
    
    NSEnumerator *catenu = [usingCategories objectEnumerator];
    NSArray *cate;
    [popupButton addItemWithTitle:@""];
    while (cate = [catenu nextObject]) {
        NSArray *filters = [CIFilter filterNamesInCategories:cate];
        NSEnumerator *enu = [filters objectEnumerator];
        NSString *filterName;
        while (filterName = [enu nextObject]) {
            [filterDic setObject:filterName forKey:[CIFilter localizedNameForFilterName:filterName]];
            [popupButton addItemWithTitle:[CIFilter localizedNameForFilterName:filterName]];
        }
    }
}
- (IBAction)openFilterPanel:(id)sender
{
    [filterPanel orderFront:self];
}
- (IBAction)filterSelected:(id)sender
{
    NSString *filterName = [filterDic objectForKey:[sender title]];
    if ([selectedFilterKeys containsObject:filterName]!=YES) {
        CIFilter *newFilter = [CIFilter filterWithName:filterName];
        if (newFilter) {
            [selectedFilterKeys addObject:filterName];
            [selectedFilters setObject:newFilter forKey:filterName];
            [self drawFilterUIViews];
        }
    }
    [sender setTitle:@""];
}
- (void)drawFilterUIViews
{
    int contenntsHeight = 0;
    NSRect docBounds = [[scrollView documentView] bounds];
    NSEnumerator *enu = [selectedFilterKeys objectEnumerator];
    NSString *filterKey;
    while (filterKey = [enu nextObject]) {
        NSView *baseView = [selectedFilterUIViews objectForKey:filterKey];
        if (baseView == nil) {
            CIFilter *newFilter = [selectedFilters objectForKey:filterKey];
            NSString *filterName = [newFilter name];
            NSString *localizedFilterName = [CIFilter localizedNameForFilterName:filterName];
            
            NSButton *closeBtn = [[[NSButton alloc] init] autorelease];
            [closeBtn setImage:[NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate]];
            [closeBtn setBezelStyle:NSInlineBezelStyle];
            [closeBtn setBordered:NO];
            //[closeBtn setControlSize:NSControlSizeMini];
            [closeBtn setFrameSize:NSMakeSize(15,16)];
            [closeBtn setTarget:self];
            [closeBtn setAction:@selector(deleteFilter:)];
            [closeBtn setIdentifier:filterName];
            
            int labelHeight = 20;
            NSTextField *label = [NSTextField labelWithString:localizedFilterName];
            [label setDrawsBackground:NO];
            [label setBordered:NO];
            [label setEditable:NO];
            [label setSelectable:NO];
            
            [newFilter setDefaults];
            NSDictionary *options =
                [NSMutableDictionary dictionaryWithObject:IKUISizeMini forKey:IKUISizeFlavor];
            IKFilterUIView *filterContentView =
                [newFilter viewForUIConfiguration:options
                                     excludedKeys:[NSArray arrayWithObjects:kCIInputImageKey, kCIInputTargetImageKey, nil]];
            
            NSEnumerator *attrkeys = [[newFilter inputKeys] objectEnumerator];
            NSString *attrkey;
            while (attrkey = [attrkeys nextObject]) {
                [newFilter
                 addObserver:self
                 forKeyPath:attrkey
                 options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial
                 context:nil];
            }
            
            NSRect contentBounds = [filterContentView bounds];
            int contentHeight = contentBounds.size.height;
            if ([contentsView bounds].size.height<(contenntsHeight+labelHeight+contentHeight)) {
                [contentsView setFrameSize:NSMakeSize([contentsView bounds].size.width,(contenntsHeight+labelHeight+contentHeight))];
            }
            
            baseView = [[[NSView alloc] init] autorelease];
            [baseView addSubview:label];
            [label setFrameOrigin:NSMakePoint(0, contentHeight)];
            [baseView addSubview:closeBtn];
            [closeBtn setFrameOrigin:NSMakePoint([label frame].size.width, contentHeight-1)];
            NSBox *boxView = [[[NSBox alloc] init] autorelease];
            [boxView setTitle:@""];
            [boxView addSubview:filterContentView];
            [boxView sizeToFit];
            [baseView addSubview:boxView];
            [baseView setFrameOrigin:NSMakePoint(0, 0)];
            
            [contentsView addSubview:baseView];
            [baseView setFrame:NSMakeRect(0,([contentsView bounds].size.height-(contenntsHeight+labelHeight+contentHeight)),[contentsView bounds].size.width,labelHeight+contentHeight)];
            [baseView setAutoresizingMask:NSViewMinYMargin];
            contenntsHeight += (labelHeight+contentHeight);
            [selectedFilterUIViews setObject:baseView forKey:filterKey];
        } else {
            NSSize baseViewSize = [baseView bounds].size;
            [baseView setFrame:NSMakeRect(0,([contentsView bounds].size.height-(contenntsHeight+baseViewSize.height)),[contentsView bounds].size.width,baseViewSize.height)];
            contenntsHeight += baseViewSize.height;
        }
    }
}
- (BOOL)validateMenuItem:(NSMenuItem *)anItem
{
    return YES;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterUIValueDidChange" object:[selectedFilters allValues]];
}
- (void)deleteFilter:(id)sender
{
    [selectedFilters removeObjectForKey:[sender identifier]];
    [[selectedFilterUIViews objectForKey:[sender identifier]] removeFromSuperview];
    [selectedFilterUIViews removeObjectForKey:[sender identifier]];
    [selectedFilterKeys removeObject:[sender identifier]];
    [self drawFilterUIViews];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FilterUIValueDidChange" object:[selectedFilters allValues]];
}

@end
