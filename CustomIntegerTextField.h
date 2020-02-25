//
//  CustomIntegerTextField.h
//  cooViewer
//
//  Created by gnz on 2020/02/24.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomIntegerTextField : NSTextField<NSTextFieldDelegate>

@property NSInteger maxValue;
@property NSInteger minValue;

@end

NS_ASSUME_NONNULL_END
