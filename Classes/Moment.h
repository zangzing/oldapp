//
//  Moment.h
//  Moment
//
//  Created by Mauricio Alvarez on 5/10/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "MLog.h"
#import "MAnalytics.h"
#import "OpenUDID.h"
#import "ZZAPI.h"

#import "FacebookSessionController.h"


#ifndef Moment_h
#define Moment_h
// For easy color generation
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

// For Retina Display detection
#define RETINA_DISPLAY ([[UIScreen mainScreen] scale] > 1.0f)


//Thumbnail size
#define kThumbSize                      94
#define kThumbSize_Retina               (kThumbSize*2)


#endif



@interface Moment : NSObject
+(NSString *)name;
+(NSString *)build;
+(NSString *)version;
@end