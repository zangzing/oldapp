//
//  MAnalytics.m
//  Moment
//
//  Created by Mauricio Alvarez on 5/11/12.
//  Copyright (c) 2012 Moment All rights reserved.
//


#import "Moment.h"
#import "CJSONSerializer.h"
#import "AFNetworking.h"


#define MANALYTICS_REPORTING_INTERVAL_SECS 60
#define MANALYTICS_URL          @"https://zza.zangzing.com"
#define MANALYTICS_SOURCE       @"iphone/app"
#define MANALYTICS_LASTRUN_KEY  @"MAnalyticsLastRunKey"

@implementation MAnalytics


//Singleton access methor
+ (MAnalytics *)defaultAnalytics
{
    static MAnalytics *defaultMAnalytics;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        defaultMAnalytics = [[self alloc] init];
    });
    return defaultMAnalytics;
}


-(id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:MANALYTICS_URL] ];
    if( self ){
        MLOG(@"MAnalytics initialized to %@", [self baseURL]); 
        //set default headers
        [self setDefaultHeader:@"Accept"         value:@"application/json"];
        [self setDefaultHeader:@"Content-Type"   value:@"application/json"];  
        
        //init event queue 
        eventQueue = [[NSMutableArray alloc] init];  
    
        //start event notification timer
        [NSTimer scheduledTimerWithTimeInterval: MANALYTICS_REPORTING_INTERVAL_SECS target: self selector: @selector( pushTimerUp:) userInfo: nil repeats: YES];
        return self;
    }
    return NULL;
}

-(NSString*) cacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
	return [cachesDirectory stringByAppendingPathComponent:@"MAnalyticsCache"];  
}

-(void) trackEvent:(NSString*)event xdata:(NSDictionary*)xdata
{
	// track ZZA event: queue it
    // NOTE: gZZ must be initialized prior to calling
    
	//NSLog(@"ZZA event: %@", event);             // do not replace with MLOG
	
	NSMutableDictionary *evt = [[NSMutableDictionary alloc] init];
	
	NSString *e = [[NSString alloc] initWithString:@"iphone."];
	e = [e stringByAppendingString:event];
	[evt setObject:e forKey:@"e"];
	
	time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
	NSString *t = [NSString stringWithFormat:@"%d", unixTime];
	t = [t stringByAppendingString:@"000"];
	[evt setObject:t forKey:@"t"];
	
	if ([ZZSession currentSession]) {
		// user user ID
        ZZUserID userid = [ZZSession currentUser].user_id;
		[evt setObject:[NSString stringWithFormat:@"%llu", userid] forKey:@"u"];
		[evt setObject:[NSNumber numberWithInt:1] forKey:@"v"];
	} else {
		// use iphone identifier
		[evt setObject:[OpenUDID value] forKey:@"u"];
		[evt setObject:[NSNumber numberWithInt:4] forKey:@"v"];
	}
	
	if (xdata){
		[evt setObject:[[NSDictionary alloc] initWithDictionary:xdata copyItems:YES] forKey:@"x"];
	}
	
	@synchronized(eventQueue) {
		[eventQueue addObject:evt];
	}
}


-(void) trackException:(NSString*)event exception:(NSException*)exception
{
    NSLog(@"EXCEPTION: %@: %@ %@", event, exception.name, exception.reason);
    
    NSMutableDictionary *xdata = [[NSMutableDictionary alloc] init];
    [xdata setObject:exception.name forKey:@"name"];
    [xdata setObject:exception.reason forKey:@"reason"];
    
    event = [NSString stringWithFormat:@"exception.%@",event];
    [self trackEvent:event xdata:xdata];
}


-(void)pushStoredEvents
{
    if( self.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown || 
        self.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable ) {
        return;
    }
    
    DLOG(@"pushStoredEvents");
    
        NSString *path = [self cacheDirectory];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        for (NSString* file in files) {
            
            BOOL pushed;
            NSString *filepath;
            
            @try {
                pushed = NO;
                filepath = NULL;
                
                if ([[file pathExtension] isEqualToString:@"zza"]){
                    DLOG(@"pushing event file: %@", file);
                    
                    filepath = [NSString stringWithFormat:@"%@/%@", path, file];
                    NSData *data = [[NSData alloc]initWithContentsOfFile:filepath];
                    if (data) 
                        pushed = [self pushEventData:data];
                }        
            }
            @catch (NSException *exception) {
                DLOG(@"pushStoredEvents exception: %@", exception);
            }
            @finally {
                // delete event file
                if (pushed && filepath) 
                    [[NSFileManager defaultManager] removeItemAtPath:filepath error:NULL];
            }
            
        }
}


-(BOOL)pushEventData:(NSData*)eventData
{

    NSMutableURLRequest *request = [self requestWithMethod:@"POST" 
                                                      path:@"/" 
                                                parameters:NULL];
    [request setHTTPBody:eventData];
    AFJSONRequestOperation *operation; 
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                        
                                                                    DLOG(@"MAnalytics Events Push SUCCESS:%@",JSON);
                                                                } 
                                                                failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                    DLOG(@"MAnalytics Events Push FAILURE %@ and error %@", JSON, error );
                                                                }
                 ];
    DLOG(@"MAnalytics Starting Event Push");
    [operation start];    
    return YES;
}

-(void)startEvents
{
    //Just for clarity, use startEvents the first time
    [self resumeEvents];
}

-(void)resumeEvents
{
    // signal that there might be store events allowing pushStoredEvents on next cycle
    haveStoredEvents = YES;
}

-(void)pushEvents
{
    [self pushEvents:NO];
}


-(BOOL) pushEvents:(BOOL)onlyStore;
{
    // push ZZA events to zza.zangzing.com
    // executed in background thread
    
    BOOL sent = NO;
    
    BOOL send = YES;
    BOOL store = NO;
    
    if( onlyStore ||
        self.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown || 
        self.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable )
    {
        send = NO;
        store = YES;
    }
    
    NSData *dataJSON = NULL;
    int evtcount = 0;
        @try {
            
            NSArray *events = NULL;
            
            @synchronized(eventQueue) {
                if (eventQueue.count == 0){
                    return NO;
                }
                events = [eventQueue copy];
                [eventQueue removeAllObjects];
            }	
            
            if (events == NULL){
                return NO;
            }
            
            evtcount = events.count;
            
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            [data setObject:MANALYTICS_SOURCE forKey:@"id"];
            [data setObject:events forKey:@"evts"];
            
            dataJSON = [[CJSONSerializer serializer] serializeObject:data error:nil];
            
            if (send) {
                NSLog(@"push ZZA: %d", evtcount);
                
                BOOL pushed = [self pushEventData:dataJSON];
                if (pushed) {
                    // events have been sent
                    sent = YES;
                } 
                else 
                {
                    // write to disk
                    store = YES;
                }
            }
        }
        @catch (NSException *exception) {
            store = YES;
        }
        
        if (store && dataJSON) {
            NSLog(@"store ZZA: %d", evtcount);
            
            NSString *evtfile = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
            evtfile = [evtfile stringByReplacingOccurrencesOfString:@"." withString:@""];
            evtfile = [evtfile stringByAppendingString:@".zza"];
            
            NSString *path = [self cacheDirectory];
            path = [path stringByAppendingPathComponent:evtfile];
            
            NSString* dataStr = [[NSString alloc] initWithData:dataJSON encoding:NSUTF8StringEncoding];
            [dataStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
      
    
    return sent;
}

-(void)processLastRun
{
    BOOL postRunEvent = NO;
    
    if (lastRun == 0) {
        //lastRun is not set, try to retrieve it from NSDefaults or set it to now
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *lastRunNumber = [defaults objectForKey:MANALYTICS_LASTRUN_KEY];
        if (lastRunNumber) {
            lastRun = [lastRunNumber doubleValue];
        }else{
            lastRun = [[NSDate date] timeIntervalSince1970];
            postRunEvent = YES;
        }
    } else {    
        // post a new run event every 24 hours
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        double diff = now - lastRun;
        if (diff > (60 * 60 * 24)) {
            lastRun = now;
            postRunEvent = YES;
        }
    }
    
    if (postRunEvent) {        
        //Save last run
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithDouble:lastRun] forKey:MANALYTICS_LASTRUN_KEY];
       
        

        NSString *event = [NSString stringWithFormat:@"%@.run",[Moment build]];
        NSMutableDictionary *xdata = [[NSMutableDictionary alloc] init];
        [xdata setObject:[OpenUDID value] forKey:@"uid"];
        [xdata setObject:[[UIDevice currentDevice] name] forKey:@"n"];
        [xdata setObject:[[UIDevice currentDevice] systemName] forKey:@"s"];
        [xdata setObject:[[UIDevice currentDevice] systemVersion] forKey:@"v"];
        [xdata setObject:[Moment version] forKey:@"z"];
        [self trackEvent:event xdata:xdata];
    }
}



- (void)pushTimerUp: (NSTimer*)timer 
{
    [self processLastRun];
    
    // push ZZA events
    
    if (haveStoredEvents) {
        haveStoredEvents = NO;
        [self performSelectorInBackground:@selector(pushStoredEvents) withObject:NULL];
    }else{
        // push queued ZZA events to server
        [self performSelectorInBackground:@selector(pushEvents) withObject:NULL];
    }
} 

@end
