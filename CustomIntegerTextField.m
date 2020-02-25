//
//  CustomIntegerTextField.m
//  cooViewer
//
//  Created by gnz on 2020/02/24.
//

#import "CustomIntegerTextField.h"

@implementation CustomIntegerTextField

- (void)setUp
{
    self.maxValue = NSIntegerMax;
    self.minValue = NSIntegerMin;
    [self setDelegate:self];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)textDidChange:(NSNotification *)notification
{
    NSInteger i = [self integerValue];
    i = MAX(self.minValue, MIN(self.maxValue, i));
    [self setStringValue:[NSString stringWithFormat:@"%ld", i]];
}

- (void)scrollWheel:(NSEvent *)event
{
    CGFloat dy = [event deltaY];
    if (dy == 0) {
        return;
    }
    dy = dy < 0 ? -1 : 1;
    if ([event isDirectionInvertedFromDevice]) {
        dy *= -1;
    }
    NSInteger i = [self integerValue];
    i += dy;
    i = MAX(self.minValue, MIN(self.maxValue, i));
    [self setStringValue:[NSString stringWithFormat:@"%ld", i]];
}
@end
