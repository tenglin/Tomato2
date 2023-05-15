//
//  MyGlobal.h
//  Tomato
//
//  Created by Teng Lin on 13-1-9.
//  Copyright (c) 2013年 Teng Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEBUG_TOMATO 0
#define DEBUG_TUTORIAL 1
#define DEBUG_MAKE_DEFAULT_PNG 0

// begin debug
#define kCLAW_REMOVE_ALL_NSLOG 1

typedef enum {
    ClawLogLevelNothing,
    ClawLogLevelError,
    ClawLogLevelInfo,
    ClawLogLevelVerbose
}ClawLogLevel;

extern ClawLogLevel kClawDebugLogLevel; // defaults to ClawLogLevelError

extern BOOL kAnimationHistoryGraphBarLayer;

#define ClawError(fmt, ...) do { if(kClawDebugLogLevel >= ClawLogLevelError) NSLog((@"CError: %s/%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }while(0)
#define ClawInfo(fmt, ...) do { if(kClawDebugLogLevel >= ClawLogLevelInfo) NSLog((@"CInfo: %s/%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }while(0)
#define ClawVerbose(fmt, ...) do { if(kClawDebugLogLevel >= ClawLogLevelVerbose) NSLog((@"CVerbose: %s/%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }while(0)

#if kCLAW_REMOVE_ALL_NSLOG
#define NSLog(...) {}
#else
#define NSLog(...) NSLog(__VA_ARGS__)
#endif
// end debug

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )

#define MAX_LOC_NOTIFICATION 9
#define WARNING_BEFORE_END_SECONDS 30

#define END_ANIMATION_SECONDS 1

//FOUNDATION_EXPORT NSString *const MyFirstConstant;
//FOUNDATION_EXPORT NSString *const MySecondConstant;
FOUNDATION_EXPORT NSString *const TOMATO_NOTIFICATION_KEY;
FOUNDATION_EXPORT NSString *const TOMATO_NOTIFICATION_OBJECT;



#define MY_MACRO_EXAMPLE( img ) \
{\
UIImage *titleImage = [UIImage imageNamed:img]; \
UIImageView *titleImageView = [[UIImageView alloc] initWithImage:titleImage]; \
self.navigationItem.titleView = titleImageView; \
[titleImageView release];\
}
//Use it like this: MY_MACRO( @"myLogo.png" )


#define kClawErrorCoreData -11111
#define kClawErrorOther -11112

@interface MyGlobal : NSObject

+ (void)showClawErrorAlert:(NSInteger)reason;

@end
