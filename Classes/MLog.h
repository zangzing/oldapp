//
//  MLog.h
//  Moment
//
//  Created by Mauricio Alvarez on 5/10/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifndef MLog_h
#define MLog_h
// For Logging
#define MLOG(s,...) \
[MLog logFile:__FILE__ lineNumber:__LINE__ \
format:(s),##__VA_ARGS__]

#if defined DEBUG
#define DLOG(s,...) \
[MLog logFile:__FILE__ lineNumber:__LINE__ \
format:(s),##__VA_ARGS__]
#else
#define DLOG(...)
#endif

@interface MLog : NSObject
+(void)logFile:(char*)sourceFile lineNumber:(int)lineNumber format:(NSString*)format, ...;
+(void)setLogOn:(BOOL)logOn;
+(void)openLogFile;
+(void)closeLogFile;
+(void)deleteLogFile;
+(NSString*)logPath;
@end
#endif
