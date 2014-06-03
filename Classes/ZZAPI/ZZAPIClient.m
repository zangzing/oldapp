//
//  ZZAPIClient.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 3/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "Moment.h"
#import "albums.h"
#import "AFNetworking.h"
#import "ZZAPIClient.h"

#define ZZAPICLIENT_PRODUCTION_SERVER  @"https://staging.moment.com"

//Error domains for NSERROR
NSString * const ZZAPIASIHTTPErrorDomain = @"com.zangzing.iphone.ASIHTTPEerror";
NSString * const ZZAPIServerErrorDomain  = @"com.zangzing.iphone.ServerError";
NSString * const ZZAPIJSONErrorDomain    = @"com.zangzing.iphone.JSONError";

static ZZAPIClient *_sharedClient;

@implementation ZZAPIClient


// Initialize is called once and exactly once for every class upon loading
+(void) initialize
{
    NSAssert( self == [ZZAPIClient class], @"ZZAPIClient is not designed to be subclassed.");
    _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:ZZAPICLIENT_PRODUCTION_SERVER]];
    MLOG(@"ZZAPIClient INITIALIZED to %@",_sharedClient.baseURL ); 
}

+ (ZZAPIClient *)sharedClient
{
    return _sharedClient;
}


-(void) setBaseURL:(NSURL *)baseURL
{
    [super setBaseURL:baseURL];
    MLOG(@"ZZAPIClient BaseURL set to %@", self.baseURL); 
}


-(NSArray *) devServerArray
{
    return [NSArray arrayWithObjects: @"https://www.zangzing.com",
     @"https://photos-mauricio.zangzing.com",
     @"https://localhost",
     @"https://staging.moment.com",
     nil];
}


- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    //Requests are coming from an iphone/ipad
    [self setDefaultHeader:@"X-ZangZing-API" value:@"iphone"];
   
    //Sends and Accepts JSON
    [self setDefaultHeader:@"Accept"         value:@"application/json"];
    [self setDefaultHeader:@"Content-Type"   value:@"application/json"];    
    return self;
}



// Unmashal the contents of a request respons into an Array if possible 
// and handle response content type errors
-(NSMutableArray *) decodeArrayFromRequestJSON:(id)JSON error:(NSError **)error 
{
    
    if( JSON != NULL ){
        if( [JSON isKindOfClass:[NSMutableArray class]]){
            MLOG(@"Response ArrayDecoded with %i members", ((NSArray *) JSON).count);
            return (NSMutableArray *) JSON;
        }else{
            //the response is not an array; create custom error and return it
            NSString *msg = @"Request response JSON is not an array";
            NSArray *objArray = [NSArray arrayWithObjects: @"", msg, nil];
            NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
            NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];            
            *error = [[NSError alloc] initWithDomain:ZZAPIJSONErrorDomain code:ZZAPI_ERROR userInfo:eDict];                
        }
    }
    return NULL;
}


// Unmarshal the contents of a request response into an NSDict
// if possible and handle content type errors
-(NSDictionary *) decodeDictionaryFromRequestJSON:(id)JSON error:(NSError **)error 

{
    if( JSON != NULL ){
        if( [JSON isKindOfClass:[NSDictionary class]] || [JSON isKindOfClass:[NSMutableDictionary class]]){
            MLOG(@"Response DictionariyDecode SUCCESS %@", (NSDictionary *) JSON);
            return (NSDictionary *) JSON;
        }else{
            //the response is not an dictionary; create custom error and return it
            NSString *msg = @"Request response is not a dictionary";
            NSArray *objArray = [NSArray arrayWithObjects: @"", msg, nil];
            NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
            NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];            
            *error = [[NSError alloc] initWithDomain:ZZAPIJSONErrorDomain code:ZZAPI_ERROR userInfo:eDict];                
        }
    }
    return NULL;
}


-(BOOL) loginWithParams:(NSDictionary *)params
                  success:(void (^)(ZZSession *session))success 
                  failure:(void(^)(NSError *error))failure
{
    [ZZSession logout];
    
    ZZAPIClient *zzAPIClient = [ZZAPIClient sharedClient];

    NSString *sessionMsg = ([params objectForKey:@"service"] ? @"Session with Facebook": @"Session with username/password");
    
    NSMutableURLRequest *request = [zzAPIClient requestWithMethod:ZZAPI_POST 
                                                             path:ZZAPI_LOGIN_URL 
                                                       parameters:params];
    
    // setup ZZA login event
    NSMutableDictionary *xdata = [[NSMutableDictionary alloc] init];
    NSString *username = [params objectForKey:@"username"];
    if( username ){
        [xdata setObject:username forKey:@"user"];
    }else{
        [xdata setObject:@"Facebook Login" forKey:@"user"];
    }
    
    AFJSONRequestOperation *operation; 
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                        
                                                                    MLOG(@"%@ SUCCESS", sessionMsg);
                                                                    NSError *error = nil;
                                                                    NSDictionary *authentication = [self decodeDictionaryFromRequestJSON:JSON error:&error];
                                                                    if( authentication ){
                                                                        NSString *server = [zzAPIClient.baseURL absoluteString];
                                                                        //add server to dictionary
                                                                        NSMutableDictionary *newHash = [[NSMutableDictionary alloc]initWithDictionary:authentication copyItems:YES];
                                                                        [newHash setObject:server forKey:@"server"];                
                                                                        ZZSession *newSession = [[ZZSession alloc] initWithDictionary:newHash];
                                                                        [[MAnalytics defaultAnalytics] trackEvent:@"login" xdata:xdata];
                                                                        success( newSession );
                                                                    }else{
                                                                       MLOG(@"%@ ERROR unable to decodeDictionaryFromRequest %@", sessionMsg, error);     
                                                                    }
                                                                } 
                                                                failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                    MLOG(@"%@ FAILED returned this JSON %@ and error %@", sessionMsg, JSON, error );
                                                                    [xdata setObject:[NSNumber numberWithInt:response.statusCode] forKey:@"err"];
                                                                    [[MAnalytics defaultAnalytics] trackEvent:@"login.failed" xdata:xdata];
                                                                    failure( error );
                                                                }
                 ];    
    MLOG(@"%@ Sending this request %@",sessionMsg, request);
    [operation start];    
    return YES;

}

//-(BOOL) loginWithUsername:(NSString*)username 
//                        pwd:(NSString*)password 
//                    success:(void (^)(ZZSession *session))success 
//                    failure:(void (^)(NSError *error))failure
//{
//    
//    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
//    [body setValue:username forKey:@"email"];
//    [body setValue:password forKey:@"password"];
//
//    return [self loginWithParams:body success:success failure:failure];
//}
//
//-(BOOL) loginWithFacebookWithSuccessBlock:(void (^)(ZZSession *session))success 
//                    failure:(void (^)(NSError *error))failure
//{
//    if( [FacebookSessionController sharedController].authorized == NO ){
//        //User did not authorize fb, return nil
//        return NO;
//    }
//    
//    //FB Session is authorized proceed to attempt login
//    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
//    [body setValue:ZZAPI_SERVICE_FACEBOOK forKey:@"service"];
//    [body setValue: [FacebookSessionController sharedController].credentials forKey:@"credentials"];
//    [body setValue:@"true" forKey:@"create"];
//
//    return [self loginWithParams:body success:success failure:failure];
//}


-(BOOL) getActivityForUser:(ZZUserID)userID
                   success:(void (^)(NSMutableArray *activity))success 
                   failure:(void(^)(NSError *error))failure
{
    
    ZZAPIClient *zzAPIClient = [ZZAPIClient sharedClient];
    
    
    NSMutableURLRequest *request = [zzAPIClient requestWithMethod:ZZAPI_GET 
                                                             path:[NSString stringWithFormat:ZZAPI_USER_ACTIVITY_URL,userID] 
                                                       parameters:nil];
    
    
    // setup ZZA login event    
    AFJSONRequestOperation *operation; 
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                        
                                                                    NSDictionary *headers = [response allHeaderFields];
                                                                    MLOG(@"Response headers are %@", headers);
                                                                    NSError *error = nil;
                                                                    NSMutableArray *activity = [self decodeArrayFromRequestJSON:JSON error:&error];
                                                                    if( activity ){                                                                        
                                                                        MLOG(@"%@ SUCCESS returned %i activities", NSStringFromSelector(_cmd), activity.count );
                                                                        NSMutableArray *zzActivityArray = [[NSMutableArray alloc] init];
                                                                        NSEnumerator *e = [activity objectEnumerator];
                                                                        NSDictionary *oneActivityHash;
                                                                        ZZActivity *oneZZActivity;
                                                                        while ( oneActivityHash = [e nextObject]) {
                                                                            oneZZActivity = [[ZZActivity alloc] initWithDictionary:oneActivityHash];
                                                                            [zzActivityArray addObject: oneZZActivity];
                                                                        }
                                                                                                                                   //Make each activity into an activity object                                                                        
                                                                        MLOG(@"%@  %i activities loaded into ZZActivities", NSStringFromSelector(_cmd), activity.count);                                                                        
                                                                        success( zzActivityArray );
                                                                    } else {
                                                                        success( [[NSMutableArray alloc] initWithCapacity:0] );
                                                                    }
                                                                } 
                                                                failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                    MLOG(@"%@ FAILED returned this JSON %@ and error %@",  NSStringFromSelector(_cmd), JSON, error );
                                                                    failure( error );
                                                                }
                 ];
    MLOG(@"%@ %@ starting %@ request to %@ without parameters", [NSString stringWithUTF8String:__FILE__], NSStringFromSelector(_cmd), [ request HTTPMethod ], [ request URL ]);
    [operation start];    
    return YES;
}

-(BOOL) getActivityForAlbums:(NSArray *)albumIDs
                      userId:(ZZUserID)userID
                        page:(NSInteger) page
                        size:(NSInteger) size
                   success:(void (^)(NSArray *activity))success 
                   failure:(void(^)(NSError *error))failure
{
    
    ZZAPIClient *zzAPIClient = [ZZAPIClient sharedClient];
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue:albumIDs forKey:@"albums"];
    [body setValue:[NSNumber numberWithInteger: page] forKey:@"page"];
    [body setValue:[NSNumber numberWithInteger: size] forKey:@"size"];

    
    NSMutableURLRequest *request = [zzAPIClient requestWithMethod:ZZAPI_POST 
                                                             path:[NSString stringWithFormat:ZZAPI_USER_ACTIVITY_URL,userID] 
                                                       parameters:body];
    
    // setup ZZA login event    
    AFJSONRequestOperation *operation; 
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                        
                                                                    NSError *error = nil;
                                                                    NSArray *activity = [self decodeArrayFromRequestJSON:JSON error:&error];
                                                                    if( activity ){                                                                        
                                                                        MLOG(@"%@ SUCCESS returned %i activities", NSStringFromSelector(_cmd), activity.count );
                                                                        NSMutableArray *zzActivityArray = [[NSMutableArray alloc] init];
                                                                        NSEnumerator *e = [activity objectEnumerator];
                                                                        NSDictionary *oneActivityHash;
                                                                        ZZActivity *oneZZActivity;
                                                                        while ( oneActivityHash = [e nextObject]) {
                                                                            oneZZActivity = [[ZZActivity alloc] initWithDictionary:oneActivityHash];
                                                                            [zzActivityArray addObject: oneZZActivity];
                                                                           }
                                                                        //Make each activity into an activity object                                                                        
                                                                        MLOG(@"%@  %i activities loaded into ZZActivities and returned", NSStringFromSelector(_cmd), activity.count );                                                                        
                                                                        success( zzActivityArray );
                                                                    }else{                                                                        
                                                                        failure( error );
                                                                    }
                                                                } 
                                                                failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                    MLOG(@"%@ FAILED returned this JSON %@ and error %@",  NSStringFromSelector(_cmd), JSON, error );
                                                                    failure( error );
                                                                }
                 ];
    MLOG(@"%@ %@ starting %@ request to %@ without parameters", [NSString stringWithUTF8String:__FILE__], NSStringFromSelector(_cmd), [ request HTTPMethod ], [ request URL ]);
    [operation start];    
    return YES;
}


-(BOOL) getUserWithId:(ZZUserID)user_id
               success:(void (^)(ZZUser *user))success 
               failure:(void(^)(NSError *error))failure
{
    ZZAPIClient *zzAPIClient = [ZZAPIClient sharedClient];
    MLOG(@"%@: request with UserID: %llu", NSStringFromSelector(_cmd), user_id);
    
    NSMutableURLRequest *request = [zzAPIClient requestWithMethod:ZZAPI_GET 
                                                             path: [NSString stringWithFormat:ZZAPI_USER_INFO_URL,user_id]
                                                       parameters:nil];
    
    AFJSONRequestOperation *operation; 
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                        
                                                                    NSError *error = nil;
                                                                    NSDictionary *userHash = [self decodeDictionaryFromRequestJSON:JSON error:&error];
                                                                    if( userHash ){                                                                        
                                                                        MLOG(@"%@ SUCCESS returned user %@", NSStringFromSelector(_cmd), userHash );
                                                                        ZZUser *aUser = [[ZZUser alloc] initWithDictionary:userHash];
                                                                        success( aUser );
                                                                    }else{
                                                                        MLOG(@"Unable to parseDictionary in %@", NSStringFromSelector(_cmd));
                                                                        failure( error );
                                                                    }
                                                                } 
                                                                failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                    MLOG(@"%@ FAILED returned this JSON %@ and error %@",  NSStringFromSelector(_cmd), JSON, error );
                                                                    failure( error );
                                                                }
                 ];
    MLOG(@"%@ %@ starting %@ request to %@ without parameters", [NSString stringWithUTF8String:__FILE__], NSStringFromSelector(_cmd), [ request HTTPMethod ], [ request URL ]);
    [operation start];    
    return YES;
}

#pragma mark -
#pragma mark Identities
/*
 * This method retrieves the facebook and twitter identities for the logged in user,
 * if different identities are required, the method with the desiredIdentities
 * array argument should be used.
 */

-(BOOL) identitiesWithStandardServicesAndSuccesBlock:(void (^)(ZZIdentities *identities))success 
failure:(void(^)(NSError *error))failure
{
    return [self identitiesForServices:[[NSArray alloc] initWithObjects: [NSNumber numberWithInteger:ZZIdentityServiceFacebook], [NSNumber numberWithInteger:ZZIdentityServiceTwitter], nil ] 
                               success:success
            failure:failure];    
}

/*
 # Checks for existence and validity of the credentials for multiple services.
 #
 # This is called as (POST):
 #
 # /zz_api/identities/validate
 #
 # Operates in the context of the current logged in user
 #
 # Input array of services:
 #
 # {
 #   :services => [service1, service2, ...]  - array of service names to check
 # },
 #
 # Returns the array of validation info.
 #
 # {
 #   :service1 => {
 #     :credentials_valid => true if the credentials validated properly, false otherwise
 #       We only currently check valid credentials for facebook & twitter, for others we always return true
 #     :has_credentials => true if the credentials have actually been set, use credentials_valid to see if
 #       they are also valid.
 #   },
 #   ...
 # }
 */

-(BOOL) identitiesForServices:(NSArray *)services 
                      success:(void (^)(ZZIdentities *identities))success 
                      failure:(void(^)(NSError *error))failure
{
    int serviceCount = [services count];
    NSMutableArray *desiredServiceStrings = [[NSMutableArray alloc] initWithCapacity:serviceCount ];
    
    for( int i = 0; i < serviceCount; i++ ){
        NSString *serviceString = [ZZIdentities identityServiceToString:[(NSNumber *) [services objectAtIndex:i] intValue]];
        [desiredServiceStrings insertObject:serviceString  atIndex:i];
    }
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue:desiredServiceStrings forKey:@"services"];
    
    ZZAPIClient *zzAPIClient = [ZZAPIClient sharedClient];
    MLOG(@"%@: request for identities for these services: %@", NSStringFromSelector(_cmd), desiredServiceStrings);
    
    NSMutableURLRequest *request = [zzAPIClient requestWithMethod:ZZAPI_POST 
                                                             path: ZZAPI_VALIDATE_IDENTITIES_URL
                                                       parameters:body];
    AFJSONRequestOperation *operation; 
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                        
                                                                    NSError *error = nil;
                                                                    NSDictionary *identityHash = [self decodeDictionaryFromRequestJSON:JSON error:&error];
                                                                    if( identityHash ){                                                                        
                                                                        MLOG(@"%@ SUCCESS returned identities %@", NSStringFromSelector(_cmd), identityHash );
                                                                        ZZIdentities *identities = [[ZZIdentities alloc] initWithDictionary:identityHash];
                                                                        success( identities );
                                                                    }else{
                                                                        MLOG(@"Unable to parseDictionary in %@", NSStringFromSelector(_cmd));
                                                                        failure( error );
                                                                    }
                                                                } 
                                                                failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                    MLOG(@"%@ FAILED returned this JSON %@ and error %@",  NSStringFromSelector(_cmd), JSON, error );
                                                                    failure( error );
                                                                }
                 ];
    MLOG(@"%@ %@ starting %@ request to %@ without parameters", [NSString stringWithUTF8String:__FILE__], NSStringFromSelector(_cmd), [ request HTTPMethod ], [ request URL ]);
    [operation start];    
    return YES;
}


/*
 # Sets the credentials for a given identity.
 #
 # This is called as (POST - https):
 #
 # /zz_api/identities/update
 #
 # Operates in the context of the current logged in user
 #
 # Input:
 #
 # {
 #   :service => the service you are setting the identity for (facebook,twitter,etc) - must be lower case,
 #   :credentials => the api token for the identity.  This can be nil if you want to clear the token.  In
 #     this case we will clear the token and return false for credentials_valid.
 # }
 #
 # We validate and then set the identity.  If token cannot be verified we do not
 # set the token and return false for credentials_valid.
 #
 # Returns the validation info.
 #
 # {
 #   :credentials_valid => true if the credentials validated properly, false otherwise
 #     We only currently check valid credentials for facebook & twitter, for others we always return true
 # }
 */
-(BOOL)updateIdentities:(ZZIdentityService)service 
            credentials:(NSString *)credentials
                success:(void (^)(NSDictionary *identiyHash))success 
                failure:(void(^)(NSError *error))failure
{
    
    NSString *serviceString = [ZZIdentities identityServiceToString:service];
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue: serviceString forKey:@"service"];
    [body setValue:credentials forKey:@"credentials"];
    
    ZZAPIClient *zzAPIClient = [ZZAPIClient sharedClient];
    MLOG(@" Updating %s's credentials for %@", [ZZSession currentUser].username,  service);
    
    NSMutableURLRequest *request = [zzAPIClient requestWithMethod:ZZAPI_POST 
                                                             path:ZZAPI_UPDATE_IDENTITY_CREDENTIALS
                                                       parameters:body];
    AFJSONRequestOperation *operation; 
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                        
                                                                    NSError *error = nil;
                                                                    NSDictionary *identityHash = [self decodeDictionaryFromRequestJSON:JSON error:&error];
                                                                    if( identityHash ){                                                                        
                                                                        MLOG(@"SUCCESS returned identities %@", identityHash );
                                                                        success( identityHash );
                                                                    }else{
                                                                        MLOG(@"Unable to parseDictionary %@",error);
                                                                        failure( error );
                                                                    }
                                                                } 
                                                                failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                    MLOG(@"%@ FAILED returned this JSON %@ and error %@",  NSStringFromSelector(_cmd), JSON, error );
                                                                    failure( error );
                                                                }
                 ];
    MLOG(@"starting %@ request to %@ without parameters",[ request HTTPMethod ], [ request URL ]);
    [operation start];    
    return YES;
}

#pragma mark - Album

-(BOOL) albumWithName:(NSString *)name 
                   privacy:(ZZAPIAlbumPrivacy)privacy 
         facebookStreaming:(BOOL)facebookStreaming
          twitterStreaming:(BOOL)twitterStreaming
            whoCanDownload:(ZZAPIAlbumWhoOption)whoCanDownload 
              whoCanUpload:(ZZAPIAlbumWhoOption)whoCanUpload 
                 whoCanBuy:(ZZAPIAlbumWhoOption) whoCanBuy 
              success:(void (^)(ZZAlbum *album))success 
              failure:(void(^)(NSError *error))failure
{   
    // create the request body 
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    [body setValue: name                                             forKey: @"name"];
    [body setValue: [NSNumber numberWithBool: facebookStreaming]     forKey: @"stream_to_facebook"];   
    [body setValue: [NSNumber numberWithBool: twitterStreaming]      forKey: @"stream_to_twitter"];   
    [body setValue: [ZZAlbum albumPrivacyToString: privacy]          forKey: @"privacy"];
    [body setValue: [ZZAlbum albumWhoOptionToString: whoCanDownload] forKey: @"who_can_download"];
    [body setValue: [ZZAlbum albumWhoOptionToString: whoCanUpload]   forKey: @"who_can_upload"];
    [body setValue: [ZZAlbum albumWhoOptionToString: whoCanBuy]      forKey: @"who_can_buy"];
  
    ZZAPIClient *zzAPIClient = [ZZAPIClient sharedClient];
    MLOG(@" Creating new album %s", name);
    
    NSMutableURLRequest *request = [zzAPIClient requestWithMethod:ZZAPI_POST 
                                                             path:ZZAPI_ALBUM_CREATE_URL
                                                       parameters:body];
    AFJSONRequestOperation *operation; 
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                        
                                                                    NSError *error = nil;
                                                                    NSDictionary *albumHash = [self decodeDictionaryFromRequestJSON:JSON error:&error];
                                                                    if( albumHash ){                                                                        
                                                                        MLOG(@"SUCCESS returned album %@", albumHash );
                                                                        ZZAlbum *newAlbum = [[ZZAlbum alloc] initWithDictionary:albumHash];
                                                                        success( newAlbum );
                                                                    }else{
                                                                        MLOG(@"Unable to parseDictionary %@",error);
                                                                        failure( error );
                                                                    }
                                                                } 
                                                                failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                    MLOG(@"%@ FAILED returned this JSON %@ and error %@",  NSStringFromSelector(_cmd), JSON, error );
                                                                    failure( error );
                                                                }
                 ];
    MLOG(@"starting %@ request to %@ without parameters",[ request HTTPMethod ], [ request URL ]);
    [operation start];    
    return YES;
    
//    //Creation failed, pass the error back out
//    *anError = emptyAlbum.lastCallError;
//    if( [*anError code] == 409 ){ //duplicate name
//        NSString *desc = @"Check the Name";
//        NSString *reason =  @"You already have an album with that name. Please use a different name.";
//        NSArray *objArray = [NSArray arrayWithObjects: desc, reason, *anError, nil];
//        NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,NSUnderlyingErrorKey, nil];
//        NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];            
//        *anError = [[NSError alloc] initWithDomain:ZZAPIJSONErrorDomain code:ZZAPI_ERROR userInfo:eDict];  
//    }
//    return NULL;
}


-(BOOL) getAlbumPhotosForAlbum:(ZZAlbum *)album 
                       success:(void (^)(NSMutableArray *albumPhotos))success 
                       failure:(void(^)(NSError *error))failure
{
    NSString *albumPhotosPath = [NSString stringWithFormat:ZZAPI_ALBUMPHOTOS_URL, album.album_id ];    
    if( album.cache_version && album.cache_version.length > 0 ){
        albumPhotosPath = [NSString stringWithFormat:@"%s?ver=%s", albumPhotosPath, album.cache_version ];     
    }
        
        
    ZZAPIClient *zzAPIClient = [ZZAPIClient sharedClient];
    NSMutableURLRequest *request = [zzAPIClient requestWithMethod:ZZAPI_GET 
                                                             path: albumPhotosPath
                                                       parameters:nil];
        
    AFJSONRequestOperation *operation; 
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                                                                                           
                                                                    NSError *error = nil;
                                                                    NSMutableArray *photos = [self decodeArrayFromRequestJSON:JSON error:&error];
                                                                    if( photos ){                                                                        
                                                                        MLOG(@"SUCCESS returned %i photos for album %llu", photos.count, album.album_id );
                                                                        NSMutableArray *zzAlbumPhotosArray = [[NSMutableArray alloc] init];
                                                                        NSEnumerator *e = [photos objectEnumerator];
                                                                        NSDictionary *onePhotoHash;
                                                                        ZZPhoto *oneZZPhoto;
                                                                        while ( onePhotoHash = [e nextObject]) {
                                                                            oneZZPhoto = [[ZZPhoto alloc] initWithDictionary:onePhotoHash];
                                                                            [zzAlbumPhotosArray addObject: oneZZPhoto];
                                                                        }
                                                                        MLOG(@"%i photos loaded", zzAlbumPhotosArray.count);                                                                        
                                                                        success( zzAlbumPhotosArray );
                                                                    } 
                                                                } 
                                                                failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                    MLOG(@"%@ FAILED returned this JSON %@ and error %@",  NSStringFromSelector(_cmd), JSON, error );
                                                                    failure( error );
                                                                }
                 ];
    MLOG(@"%@ starting %@ request to %@ without parameters", NSStringFromSelector(_cmd), [ request HTTPMethod ], [ request URL ]);
    [operation start];    
    return YES;
}
#pragma mark albumInfo
-(BOOL) getAlbumInfoForUser:(ZZUser *)user
                   success:(void (^)(ZZAlbumInfo *albumInfo))success 
                   failure:(void(^)(NSError *error))failure
{
    ZZAPIClient *zzAPIClient = [ZZAPIClient sharedClient];
    NSMutableURLRequest *request = [zzAPIClient requestWithMethod: ZZAPI_GET
                                                             path: [NSString stringWithFormat:ZZAPI_USER_ALBUMINFO,user.user_id]
                                                       parameters:nil];
    
    AFJSONRequestOperation *operation; 
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                                                                                           
                                                                    NSError *error = nil;
                                                                    NSDictionary *albumInfoHash = [self decodeDictionaryFromRequestJSON:JSON error:&error];
                                                                    if( albumInfoHash ){                                                                        
                                                                        MLOG(@"SUCCESS for user %llu, got albumInfoHash %@", user.user_id, albumInfoHash );
                                                                            ZZAlbumInfo *albumInfo  = [[ZZAlbumInfo alloc] initWithDictionary: albumInfoHash];
                                                                        MLOG(@"AlbumInfoHash Loades");                                                                        
                                                                        success( albumInfo );
                                                                    } 
                                                                } 
                                                                failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                    MLOG(@"%@ FAILED returned this JSON %@ and error %@",  NSStringFromSelector(_cmd), JSON, error );
                                                                    failure( error );
                                                                }
                 ];
    MLOG(@"%@ starting %@ request to %@ without parameters", NSStringFromSelector(_cmd), [ request HTTPMethod ], [ request URL ]);
    [operation start];    
    return YES;
}
#pragma mark -

#pragma mark albumSets

-(BOOL) getInvitedAlbumsAndBuildAlbumSetForAlbumInfo:(ZZAlbumInfo *)albumInfo
                                            myAlbums:(NSArray *) myAlbumsArray
                                             success:(void (^)(ZZAlbumSet *albumSet))success 
                                             failure:(void(^)(NSError *error))failure
{
 
    ZZAPIClient *zzAPIClient = [ZZAPIClient sharedClient];
    NSMutableURLRequest *secondReq = [zzAPIClient requestWithMethod: ZZAPI_GET
                                                               path: albumInfo.invited_albums_path
                                                         parameters:nil];
    AFJSONRequestOperation *secondOp; 
    secondOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:secondReq 
                                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                                                                                           
                                                                   NSError *error = nil;
                                                                   NSMutableArray *invitedAlbumsArray = [self decodeArrayFromRequestJSON:JSON error:&error];
                                                                   if( invitedAlbumsArray ){
                                                                       MLOG(@"SUCCESS second request for invitedAlbums building albumset");
                                                                       NSArray *albumArray=[myAlbumsArray arrayByAddingObjectsFromArray:invitedAlbumsArray];
                                                                       
                                                                       
                                                                   }
                                                                   
                                                                   
                                                               } 
                                                               failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                   MLOG(@"%@ FAILED second request for invitedAlbums returned this JSON %@ and error %@",  NSStringFromSelector(_cmd), JSON, error );
                                                                   failure( error );
                                                               }
                ];
    MLOG(@"starting %@ secondRequest for invitedAlbums %@ without parameters", [ secondReq HTTPMethod ], [ secondReq URL ]);
    [secondOp start]; 
}


-(BOOL) getAlbumSetForAlbumInfo:(ZZAlbumInfo *)albumInfo
                        success:(void (^)(ZZAlbumSet *albumSet))success 
                        failure:(void(^)(NSError *error))failure
{
    ZZAPIClient *zzAPIClient = [ZZAPIClient sharedClient];
    __block NSMutableArray *myAlbumsArray;
    NSMutableURLRequest *myAlbumsReq = [zzAPIClient requestWithMethod: ZZAPI_GET
                                                              path: albumInfo.my_albums_path
                                                           parameters:nil];
    AFJSONRequestOperation *myAlbumsOp; 
    myAlbumsOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:myAlbumsReq 
                                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                                                                                           
                                                                  NSError *error = nil;
                                                                  myAlbumsArray = [self decodeArrayFromRequestJSON:JSON error:&error];
                                                                  if( myAlbumsArray ){
                                                                      MLOG(@"SUCCESS myAlbums request");
                                                                  }else{
                                                                      MLOG(@"DecodeArray From Request myAlbums failed with error %@", error);
                                                                  }
                                                              }                                                                                                                                 
                                                              failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                  MLOG(@"FAILED request for myAlbums returned this JSON %@ and error %@",JSON, error );
                                                                  failure( error );
                                                              }
    ];

    __block NSMutableArray *invitedAlbumsArray;
    NSMutableURLRequest *invitedAlbumsReq = [zzAPIClient requestWithMethod: ZZAPI_GET
                                                                      path: albumInfo.invited_albums_path
                                                                parameters:nil];
    AFJSONRequestOperation *invitedAlbumsOp; 
    invitedAlbumsOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:invitedAlbumsReq 
                                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                                                                                           
                                                                     NSError *error = nil;
                                                                     invitedAlbumsArray = [self decodeArrayFromRequestJSON:JSON error:&error];
                                                                     if( invitedAlbumsArray ){
                                                                         MLOG(@"SUCCESS invitedAlbums request");
                                                                     }else{
                                                                         MLOG(@"DecodeArray From Request invitedAlbums failed with error %@", error);
                                                                     }
                                                                 }                                                                                                                                 
                                                                 failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
                                                                     MLOG(@"FAILED request for invitedAlbums returned this JSON %@ and error %@",JSON, error );
                                                                     failure( error );
                                                                 }
                  ];
    
    
    MLOG(@"Batching myAlbums:%@ and invitedAlbums:%@ requests", myAlbumsReq.URL, invitedAlbumsReq.URL);
    [zzAPIClient enqueueBatchOfHTTPRequestOperations:[[NSArray alloc] initWithObjects: myAlbumsOp, invitedAlbumsOp, nil] 
                                       progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
                                           MLOG(@"Building AlbumSet %d of %d requests completed", numberOfCompletedOperations, totalNumberOfOperations);
                                       } completionBlock:^(NSArray *operations) {
                                           MLOG(@"AlbumSet with %d myAlbums and %d invitedAlbums requests complete", myAlbumsArray.count, invitedAlbumsArray.count);
                                           BOOL allSuccessful = YES;
                                           for( id op in operations){
                                               if( ![(AFJSONRequestOperation *)op hasAcceptableStatusCode] ){
                                                   allSuccessful = NO;
                                               }
                                           }
     if( allSuccessful ){
         NSMutableArray *allAlbumsArray = [[ myAlbumsArray  arrayByAddingObjectsFromArray:invitedAlbumsArray ] mutableCopy];
         NSString *allAlbumsVerstion = [albumInfo.my_albums stringByAppendingString:albumInfo.invited_albums];
         ZZAlbumSet *resultSet = [[ZZAlbumSet alloc] initWithUserID:albumInfo.user_id version:allAlbumsVerstion album_array:allAlbumsArray];
         success( resultSet );
     }
                                       }];
    return YES;
}
#pragma mark -

@end
