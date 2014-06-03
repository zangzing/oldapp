//
//  zzglobal.h
//  zziphone
//
//  Created by Phil Beisel on 7/11/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "zztypes.h"
#import "ZZSession.h"
#import "ZZUser.h"
#import "FacebookSessionController.h"



/*  for testing to force use of the BugSense-iOS.framework version
@interface UIImageView (AFNetworking)

- (void)setImageWithURL:(NSURL *)url;

- (void)setImageWithURL:(NSURL *)url 
       placeholderImage:(UIImage *)placeholderImage;



@end
*/


#ifdef DEBUG
#define kNEWALBUM_FUNCTION          
#define kSHAREALBUM_FUNCTION
#endif

#define MLOG(s,...) \
    [MLog logFile:__FILE__ lineNumber:__LINE__ \
        format:(s),##__VA_ARGS__]

// Macros for easy color generation
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


#define kPRODUCTION_ZANGZING_USERID     249900073723

#define kTABBAR_MainBar                 1
#define kTABBAR_AlbumBar                2
#define kTABBAR_PictureBar              3
#define kTABBAR_CameraBar               4
#define kTABBAR_CameraReview            5

#define kThumbSize                      94
#define kThumbSize_Retina               (kThumbSize*2)


@class ASIHTTPRequest;

@interface ZZGlobal : NSObject <CLLocationManagerDelegate> {

    NSString *_version;
    NSInteger _systemversion;
    
	// authentication	
    //BOOL _newauthentication;    
    //BOOL _userproduction;              // YES = if user is authenticated to the production server; NO otherwise        
    //NSString *_userserver;             // server the user is authenticated to
    //NSNumber *_userid;                 // authenticated user ID
    //NSString *_usercredentials;        // user credentials (token)
    //NSString *_username;               // authenticated username
    //NSHTTPCookie *_authcookie;         // authentication cookie
    
    //ZZSession *_session;                 // ZZsession 
    //ZZUser *_currentUser;                // The currently logged in user retrieved from identity.
     
	NSString *_uid;
	NSString *_phonenum;
    NSString *_build;
	
	NSString *_myalbumsURL;
	BOOL _myalbumsValid;
	
	NSMutableDictionary* _objcache;
	NSString *_objcachepath;
    NSString *_imagecachepath;
    NSString *_uploadqueuepath;
	
	NSMutableArray *_zzaeventqueue;    // ZZA event queue
	NSString *_zzasource;			   // source e.g., iphone/app
	NSURL *_zzaurl;                    // URL to ZZA server
    
    NetworkStatus networkStatus;       // current network status
    
    NSMutableDictionary *_settings;    // settings
    
    BOOL _hires;                       // hires mode (retina or ipad 2x)
        
    BOOL p1;                           // power user feature #1
    
    CLLocationManager *_locationManager;
    unsigned long _locationUpdates;
    CLLocationCoordinate2D _currentLoc2D;
    CLLocationDistance _currentAltitude;
    NSDate* _currentLocTimestamp;
    BOOL _currentLocationValid;
    
    BOOL _haveStoredEvents;
    
    NSUInteger _lastmem;
    NSUInteger _highmem;
    NSUInteger _memoryWarnings;
    
    NSString *uploadSource;
    
    NSTimeInterval  _lastrun;
}

@property (nonatomic) BOOL p1;
@property (nonatomic) NetworkStatus networkStatus;
@property (nonatomic, strong) NSString *uploadSource;

-(void)start;

-(NSString*)version;

//-(NSString*) server: (BOOL)production;
-(NSString*) protocol: (BOOL)ssl;

-(NSString*) serviceURL;                 // service URL for authenticated user
-(NSHTTPCookie*) authCookie;             // authentication cookie for authenticated user

-(ZZUserID) defaultuserid;

// authentication
-(NSString*) UID;

// cache
-(NSObject*) getObj:(NSString*)key keytype:(NSString*)keytype;
-(NSObject*) getObj2:(NSString*)key keytype:(NSString*)keytype;
-(BOOL) cacheObj:(NSString*)key keytype:(NSString*)keytype obj:(NSObject*)obj;
-(BOOL) cacheObj2:(NSString*)key keytype:(NSString*)keytype obj:(NSObject*)obj;
-(void) deleteObj:(NSString*)key keytype:(NSString*)keytype;
-(void) deleteObj2:(NSString*)key keytype:(NSString*)keytype;

// image cache
-(UIImage*) getImage:(NSString*)key;
-(BOOL) cacheImage:(NSString*)key imageData:(NSData*)imageData;
-(BOOL) isCachedImage:(NSString*)key;

-(NSNumber*) uploadImageSize:(NSString*)key;
-(NSString*) uploadQueuePathForKey:(NSString*)key;
-(int) cacheUploadQueueImage:(NSString*)key imageData:(NSData*)imageData;
-(UIImage*) getUploadQueueImage:(NSString*)key;
-(void) deleteUploadQueueImage:(NSString*)key;

// zza
+(void) trackEvent:(NSString*)event xdata:(NSDictionary*)xdata;
+(void) trackException:(NSString*)event exception:(NSException*)exception;
-(void) pushEvents;
-(BOOL) pushEvents:(BOOL)onlyStore;
-(void) pushStoredEvents;
-(BOOL) pushEventData:(NSData*)eventData;
-(void) resumeEvents;

// user prefs
-(NSInteger)integerForSetting: (ZZUserID)userid setting:(NSString*)setting;
-(void) setIntegerForSetting: (ZZUserID)userid setting:(NSString*)setting value:(NSInteger)value;
-(NSNumber*)numberForSetting: (ZZUserID)userid setting:(NSString*)setting;
-(void) setNumberForSetting: (ZZUserID)userid setting:(NSString*)setting value:(NSNumber*)value;
-(NSString*)stringForSetting: (ZZUserID)userid setting:(NSString*)setting;
-(void) setStringForSetting: (ZZUserID)userid setting:(NSString*)setting value:(NSString*)value;
-(void) saveSettings;
-(void) initSettings;

// deserialize JSON
+(NSObject*) getObjfromJSON: (NSData*)data;

// environment
-(BOOL) isHiResScreen;
+(BOOL)isMultitaskingSupported;

// util
+(int) responseError:(ASIHTTPRequest*)request data:(NSObject*)data;
+(void) debug_print:(NSDictionary*)obj log:(NSString*)log;
+(NSString*)countLabel:(int)count;
+(NSString*)fullyQualifiedEmailAddress:(NSString*)email first:(NSString*)first last:(NSString*)last;
+(NSString*)formatName:(NSString*)first last:(NSString*)last;
+(BOOL)validateEmail:(NSString*)email;
+(NSString*)GetUUID;

// location
-(void)startLocationServices;
-(void)stopLocationServices;
-(BOOL)locationIsValid;
-(CLLocationDegrees)getLocationLongitude;
-(CLLocationDegrees)getLocationLatitude;
-(CLLocationDistance)getLocationAltitude;
-(NSDate*)getLocationTimestamp;

// misc
-(NSMutableArray*)zzaEventQueue;
-(BOOL)pushLogToS3:(int)logID;

-(void) report_memory;
+(void) report_memory_2;

-(NSInteger)getSystemVersion;
-(NSUInteger)getMem;
-(NSUInteger)getHighMem;
-(NSUInteger)getMemWarnings;
-(NSString*)getVersion;
-(void)reportMemoryWarning;

@end

extern ZZGlobal *gZZ;



@interface MLog : NSObject
{
}

+(void)logFile:(char*)sourceFile lineNumber:(int)lineNumber format:(NSString*)format, ...;
+(void)setLogOn:(BOOL)logOn;
+(void)openLogFile;
+(void)closeLogFile;
+(void)deleteLogFile;
+(NSString*)logPath;

@end
