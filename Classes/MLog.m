//
//  MLog.m
//  Moment
//
//  Created by Mauricio Alvarez on 5/10/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "Moment.h"


static BOOL __MLogOn = NO;
static BOOL __MLogToZZA = NO;

static FILE *__log = NULL;

#ifdef DEBUG
static BOOL __MLogToFile = NO;      // set to NO for DEBUG
#else
static BOOL __MLogToFile = YES;     // set to YES for production
#endif



@implementation MLog

+(void)initialize
{
    __MLogOn=YES;
   
    [MLog openLogFile];
}


+(void)closeLogFile
{
    if (__log) {
        fclose(__log);
        __log = NULL;
    }
}


+(void)openLogFile
{
    if (__MLogToFile) {
        __log = freopen([[MLog logPath] cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    }
}


+(void)deleteLogFile
{
    BOOL reopen = NO;
    
    if (__log) {
        reopen = YES;
        [MLog closeLogFile];
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:[MLog logPath] error:NULL];
    
    if (reopen)
        [MLog openLogFile];
}


+(void)logFile:(char*)sourceFile lineNumber:(int)lineNumber format:(NSString*)format, ...;
{
	va_list ap;
	NSString *print,*file;
	if(__MLogOn==NO)
		return;
	va_start(ap,format);
	file=[[NSString alloc] initWithBytes:sourceFile length:strlen(sourceFile) encoding:NSUTF8StringEncoding];
	print=[[NSString alloc] initWithFormat:format arguments:ap];
	va_end(ap);
    
	NSLog(@"%s:%d %@",[[file lastPathComponent] UTF8String],lineNumber,print);
    
    if (__MLogToZZA) {
        NSMutableDictionary *log = [[NSMutableDictionary alloc]initWithCapacity:3];
        [log setObject:[NSString stringWithFormat:@"%s:%d %@",[[file lastPathComponent] UTF8String],lineNumber,print] forKey:@"log"];
        [[MAnalytics defaultAnalytics] trackEvent:@"log" xdata:log];
    }
    
	return;
}

+(void)setLogOn:(BOOL)logOn
{
	__MLogOn=logOn;
}

+(NSString*)logPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"console.log"];
}

+(void)logToZZA:(BOOL)zzalog
{
	__MLogToZZA=zzalog;
}
@end
