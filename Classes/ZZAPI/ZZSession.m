//
//  ZZSession.m
//  ZangZing
//
//  Created by Mauricio Alvarez, no make that Phil Beisel, on 1/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "Moment.h"
#import "ZZAPIClient.h"
#import "ZZSession.h"
#import "ZZAPIClient.h"
#import "ZZCache.h"


static ZZSession *currentSession = nil;


@implementation ZZSession

@synthesize user_id;
@synthesize user_credentials;
@synthesize username;
@synthesize server;
@synthesize role;
@synthesize available_roles;
@synthesize zzv_id;
@synthesize user;


@synthesize production;
@synthesize auth_cookie;
@synthesize saved;



//This method is called once and only once upon class loading
+(void) initialize
{
    currentSession = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingSession = [defaults objectForKey:ZZ_DEFAULTS_SESSION_KEY];
    if (dataRepresentingSession) {
        currentSession = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSession];
    }
}

+ (ZZSession *)currentSession
{
    return currentSession;
}

+ (ZZUser *)currentUser
{
    if( currentSession ){
        return currentSession.user;
    }else {
        return nil;
    }
}


+(BOOL) loginWithUsername:(NSString*)username 
                      pwd:(NSString*)password 
                  success:(void (^)(void))success 
                  failure:(void (^)(NSError *error))failure
{
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue:username forKey:@"email"];
    [body setValue:password forKey:@"password"];
    
    return [[ZZAPIClient sharedClient] loginWithParams:body 
                                               success:^(ZZSession *session){
                                                   success();
                                               }
                                               failure:failure];
}

+(BOOL) loginWithFacebookWithSuccessBlock:(void (^)(void))success 
                                  failure:(void (^)(NSError *error))failure
{
    if( [FacebookSessionController sharedController].authorized == NO ){
        //User did not authorize fb, return nil
        return NO;
    }
    
    //FB Session is authorized proceed to attempt login
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue:ZZAPI_SERVICE_FACEBOOK forKey:@"service"];
    [body setValue: [FacebookSessionController sharedController].credentials forKey:@"credentials"];
    [body setValue:@"true" forKey:@"create"];
    
    return [[ZZAPIClient sharedClient] loginWithParams:body 
                                               success:^(ZZSession *session){
                                                   success();
                                               }
                                               failure:failure];
}
//
// Init the session from a dict whenever the session is coming 
// from disk or cache
//
- (id)initWithDictionary:(NSMutableDictionary *)serverJson;
{
    self = [super initWithDictionary:serverJson];
    
    if( self ){
        //user.identities;
        // Validate the data set by KVC
        if (!((user_credentials && user_credentials.length > 0) && (username && username.length > 0))){
            // session cannot be valid without credentialss and username
            //NSString *msg = @"ZZSession cannot be started without credentials and username";
            //NSArray *objArray = [NSArray arrayWithObjects: msg, msg, nil];
            //NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
            //NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];            
            //_lastCallError = [[NSError alloc] initWithDomain:ZZAPIJSONErrorDomain code:ZZAPI_ERROR userInfo:eDict];   
            return NULL;
        }
        
        // Set the data not set by KVC
        production = YES;
        auth_cookie = [self _makeCookie:user_credentials];
        [ZZAPIClient sharedClient].baseURL = [NSURL URLWithString:server];

        //save it if it had not been saved before
        if(!saved){
           [self save ];
            MLOG(@"Saving new Session to NSDefaults");
        }
        
        //Cache the user that just logged in
        [ZZCache cacheUser:user];
        MLOG(@"New Session: user_credentials: %@",user_credentials);
        MLOG(@"New Session: user_id: %llu",       user_id);
        MLOG(@"New Session: username: %@",        username);
        MLOG(@"New Session: user server: %@",     server);
        currentSession = self;
    }
    return self;
}

-(void) setValue:(id)value forKey:(NSString *)key
{
    if([key isEqualToString:@"user"]){
        user = [[ZZUser alloc] initWithDictionary:value];
    } else {
        [super setValue:value forKey:key];
    }
}

- (id) initWithCoder:(NSCoder *)decoder
{	
    self = [super init ];
    if( self ){
        user_id          = [decoder decodeObjectForKey:@"user_id"];
        user_credentials = [decoder decodeObjectForKey:@"user_credentials"];
        username         = [decoder decodeObjectForKey:@"username"];
        server           = [decoder decodeObjectForKey:@"server"];
        role             = [decoder decodeObjectForKey:@"role"];
        user             = [decoder decodeObjectForKey:@"user"];
        saved            = YES;
        production       = YES;
        auth_cookie      = [self _makeCookie:user_credentials];    
        [ZZAPIClient sharedClient].baseURL = [NSURL URLWithString:self.server];
        MLOG(@"Saved Session: user_credentials: %@",user_credentials);
        MLOG(@"Saved Session: user_id: %llu",       user_id);
        MLOG(@"Saved Session: username: %@",        username);
        MLOG(@"Saved Session: user server: %@",     server);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:user_id forKey:@"user_id"];
    [encoder encodeObject:user_credentials forKey:@"user_credentials"];
    [encoder encodeObject:username forKey:@"username"];
    [encoder encodeObject:server  forKey:@"server"];
    [encoder encodeObject:role forKey:@"role"];
    [encoder encodeObject:user forKey:@"user"];
    [encoder encodeObject:[NSNumber numberWithBool:YES] forKey:@"saved"];
}



-(BOOL)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:self]
                 forKey:ZZ_DEFAULTS_SESSION_KEY];
    [defaults synchronize];
    saved = YES;
    return saved;
}


//
// Returns the cookie that a request needs to send to
// the server to be recognized as the logged in user
//
-(NSHTTPCookie *)_makeCookie:(NSString *)userCredentials
{
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:userCredentials forKey:NSHTTPCookieValue];
    [properties setValue:@"user_credentials" forKey:NSHTTPCookieName];
    [properties setValue:server forKey:NSHTTPCookieDomain];
    [properties setValue:@"" forKey:NSHTTPCookiePath];
    return [[NSHTTPCookie alloc] initWithProperties:properties];
}

+(void) logout
{
    //Delete all of the apps cookies
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in [cookieStorage cookies]) {
        if([[each name] isEqualToString:@"user_credentials"] || [[each name] isEqualToString:@"_zangzing_session"] ){
            MLOG(@"Logout Deleting cookie %@", each);
            [cookieStorage deleteCookie:each];
        }
    }

    //Remove login information from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:ZZ_DEFAULTS_SESSION_KEY];
    [defaults synchronize];
    
    
    //Delete session
    if( currentSession ){
        [currentSession logout];
         currentSession = nil;
        //trigger logout reloads
        [[FacebookSessionController sharedController] clearCredentials];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Logout" object:self];
    }
}



-(void) logout
{
    
    //Send logout event
    NSMutableDictionary *xdata = [[NSMutableDictionary alloc] init];
    [xdata setObject: user.username forKey:@"user"];
    [[MAnalytics defaultAnalytics] trackEvent:@"logout" xdata:xdata];
    saved = false;
}




@end
