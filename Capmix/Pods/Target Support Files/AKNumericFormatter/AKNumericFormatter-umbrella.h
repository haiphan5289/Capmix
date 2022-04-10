#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AKNumericFormatter.h"
#import "NSString+AKNumericFormatter.h"
#import "UITextField+AKNumericFormatter.h"

FOUNDATION_EXPORT double AKNumericFormatterVersionNumber;
FOUNDATION_EXPORT const unsigned char AKNumericFormatterVersionString[];

