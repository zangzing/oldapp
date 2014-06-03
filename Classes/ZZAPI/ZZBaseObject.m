//
//  ZZAPI.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/18/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "Moment.h"
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"




@implementation ZZBaseObject
@synthesize lastCallError=_lastCallError;


// Objects are created from a dictionary when they come from
// the server or the cache. Whenever we build an object from
// a dict, we save it. in _serverHash
-(id)initWithNSDictionary:(NSDictionary *)serverHash
{
    self = [super init];
    if( self && serverHash ){
        if( serverHash ){
            _serverHash = serverHash;
            return self;
        }
    }
    return NULL;    
}


// Puts together a GET request ready to be sent to the server
-(ASIHTTPRequest *) createGETRequest:(NSString *) url
{
    if ( [ZZSession currentSession]) {
        MLOG(@"HTTP GET  to %@  as %@ ", url, [ZZSession currentSession].user_id);
    } else {
        MLOG(@"HTTP POST  to %@  NO-credentials", url);
    }

    ASIHTTPRequest *request = [self createHTTPRequest:url];    
    [request setRequestMethod:@"GET"];
    return request;    
}


// Puts together a POST request ready to be sent to the server
// Adds appropriate request headers and JSONifies the body
-(ASIHTTPRequest *) createPOSTRequest:(NSString *) url body:(NSMutableDictionary *) body {
 
    NSData *bodyJSON = [[CJSONSerializer serializer] serializeObject:body error:nil];
    
    if ( [ZZSession currentSession]) {
        MLOG(@"POST  to %@  as %@ with body %@", url, [ZZSession currentSession].user_id, body);
    } else {
        MLOG(@"POST  to %@  NO-CREDENTIALS with body %@", url, body);
    }

    ASIHTTPRequest *request = [self createHTTPRequest:url];
    
    [request setRequestMethod:@"POST"];
    [request appendPostData:bodyJSON];
    
    return request;    
}

// Puts together a GET request ready to be sent to the server
// adds appropriate format and security headers
-(ASIHTTPRequest *) createHTTPRequest:(NSString*) url {
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[[NSURL alloc] initWithString:url]];
    request.useCookiePersistence          = NO;
    request.useSessionPersistence         = NO;
    request.numberOfTimesToRetryOnTimeout = 2;
    request.timeOutSeconds                = 60;
    [request addRequestHeader:@"Accept"         value:@"application/json"];
    [request addRequestHeader:@"Content-Type"   value:@"application/json"];
    [request addRequestHeader:@"X-ZangZing-API" value:@"iphone"];
#ifdef DEBUG
    [request setValidatesSecureCertificate:NO];
#endif
    if ( [ZZSession currentSession]) {
        request.requestCookies = [NSMutableArray arrayWithObject:[ZZSession currentSession].auth_cookie ];
    }
    return request;
}

// Returns a properly formated service url
-(NSString *) createURL: (NSString *)urlBase ssl:(BOOL)ssl
{
    return [ZZBaseObject createURL:urlBase ssl:ssl production:[ZZSession currentSession].production];
}

+(NSString *) createURL: (NSString *)urlBase ssl:(BOOL)ssl production:(BOOL)production
{
    if( ssl ){
        return [NSString stringWithFormat:@"%@%@",[ZZAPIClient sharedClient].baseURL,urlBase];
    }else{
        NSString * urlRightProtocol = [[[ZZAPIClient sharedClient].baseURL absoluteString] stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"];
        return [NSString stringWithFormat:@"%@%@", urlRightProtocol,urlBase];
    }
        
    //return [NSString stringWithFormat:@"%@%@%@",( ssl? @"https://" : @"http://"), (  production  ? ZZAPI_PRODUCTION_SERVER: ZZAPI_STAGING_SERVER),urlBase];
}

// Reviews the request results and takes appropriate action
// it returns ZZAPI_SUCCESS and no error or ZZAPI_REQUEST_ERROR
-(int) decodeRequestStatus:(ASIHTTPRequest*)request message:(NSString *)message
{
    //clear error
    _lastCallError = nil;
    //Verify that there were no errors with the request itself
    NSError *error = [request error];
    if( error) { 
        // This error happened within the ASI library or the network, the request
        // did not reach the server or it never returned
        NSString *failureReason = [NSString stringWithFormat:@"ZZAPI HTTP RequestError error in %@: %@", message, [error localizedDescription]]; 
        MLOG( failureReason );        
        //create a custom NSError with the underlying error
        NSArray *objArray = [NSArray arrayWithObjects: message, failureReason, error, nil];
        NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, NSUnderlyingErrorKey, nil];
        NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];            
        _lastCallError = [[NSError alloc] initWithDomain:ZZAPIASIHTTPErrorDomain code:error.code userInfo:eDict];
        return ZZAPI_ERROR;
    }
    
    // Check for server errors
    int statusCode = [request responseStatusCode];
    if (statusCode == ZZAPI_SUCCESS)
        return ZZAPI_SUCCESS;
    
    //The status was not success, we have a 509 server error
    if (statusCode == ZZAPI_STATUS_ERROR) {      // 509 indicates zz_api api error
        NSObject *data = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:NULL ];
        if ([data isKindOfClass:[NSDictionary class]]) {
            // exception, code, message
            // return code
            NSDictionary *result = (NSDictionary*)data;
            NSObject* msg = [result objectForKey:@"message"];
            NSNumber *code = [result objectForKey:@"code"];            
            MLOG(@"ZZAPI Request Status Server Error in %@: (%d) %@", message, [code intValue], msg);            
            
            // Make and return ZZServerErrorDomain NSError
            // Make and return ZZAPIASIHTTPEErrorDomain domain error.            
            NSArray *objArray = [NSArray arrayWithObjects: message, msg, nil];
            NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
            NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];            
            _lastCallError = [[NSError alloc] initWithDomain:ZZAPIServerErrorDomain code:[code intValue] userInfo:eDict];                
            return ZZAPI_ERROR;
        }
    }
    
    // The call made it to the server succeeded but something went wrong at the server.
    // the server handles errors with statuscode 509 only. Anything else is unexpected
    // throw exception, statusCode is not 200 nor 509
    [NSException raise:@"Invalid return code from server" format:@"Expected 200 or 509 but received %i", statusCode];
    return statusCode;     
}

// Unmarshal the contents of a successful request and handle JSON parsing errors
-(NSObject *) decodeRequestResponse: (ASIHTTPRequest*)request message:(NSString *)message
{
    //clear error
    _lastCallError = nil;

    NSError *JSONError = nil;
    NSObject *response = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:&JSONError];
    if( response == NULL ){
        //there was an error parsing the json
        // Make and return ZZAPIASIHTTPEErrorDomain domain error.  
        NSArray *objArray = [NSArray arrayWithObjects: message, @"Unable to parse JSON response", JSONError , nil];
        NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, NSUnderlyingErrorKey, nil];
        NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];            
        _lastCallError = [[NSError alloc] initWithDomain:ZZAPIASIHTTPErrorDomain code:JSONError.code userInfo:eDict];
        return NULL;
    }
    return response;
}

// Unmashal the contents of a request respons into an Array if possible 
// and handle response content type errors
-(NSArray *) decodeRequestResponseAsArray: (ASIHTTPRequest*)request message:(NSString *)message
{
    _lastCallError = nil;
    
    NSObject *response = [self decodeRequestResponse:request message:message];
    if( response != NULL ){
        if( [response isKindOfClass:[NSArray class]] || [response isKindOfClass:[NSMutableArray class]]){
            return (NSArray *) response;
        }else{
            //the response is not an array; create custom error and return it
            NSString *msg = @"Request response is not an array";
            NSArray *objArray = [NSArray arrayWithObjects: message, msg, nil];
            NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
            NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];            
            _lastCallError = [[NSError alloc] initWithDomain:ZZAPIJSONErrorDomain code:ZZAPI_ERROR userInfo:eDict];                
        }
    }
    return NULL;
}

// Unmarshal the contents of a request response into an NSDict
// if possible and handle content type errors
-(NSDictionary *) decodeRequestResponseAsDictionary: (ASIHTTPRequest*)request message:(NSString *)message
{
    _lastCallError = nil;
    NSObject *response = [self decodeRequestResponse:request message:message];
    if( response != NULL ){
        if( [response isKindOfClass:[NSDictionary class]] || [response isKindOfClass:[NSMutableDictionary class]]){
            return (NSDictionary *) response;
        }else{
            //the response is not an dictionary; create custom error and return it
            NSString *msg = @"Request response is not a dictionary";
            NSArray *objArray = [NSArray arrayWithObjects: message, msg, nil];
            NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, NSLocalizedFailureReasonErrorKey, nil];
            NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];            
            _lastCallError = [[NSError alloc] initWithDomain:ZZAPIJSONErrorDomain code:ZZAPI_ERROR userInfo:eDict];                
        }
    }
    return NULL;
}

// For caching and compatiblity we  need to be able to convert this object 
// into an NSDictionary
-(NSDictionary *) toNSDictionary
{
    return _serverHash;
}


+(NSString*)sharePermissionToString:(ZZSharePermission)permission
{
    switch(permission) {
        case kShareAsViewer:
            return ZZAPI_ALBUM_PERMISSION_VIEWER;
        case kShareAsContributor:
            return ZZAPI_ALBUM_PERMISSION_CONTRIB;
        case kShareAsAdmin:
            return ZZAPI_ALBUM_PERMISSION_ADMIN;
        default:
            [NSException raise:NSGenericException format:@"Unexpected ZZSharePermission."];
    }    
}


+(ZZSharePermission)sharePermissionFromString:(NSString*)permission
{
    permission = [permission lowercaseString];
    if ([permission isEqualToString:[ZZAPI_ALBUM_PERMISSION_VIEWER lowercaseString]])
        return kShareAsViewer;
    if ([permission isEqualToString:[ZZAPI_ALBUM_PERMISSION_CONTRIB lowercaseString]])
        return kShareAsContributor;
    if ([permission isEqualToString:[ZZAPI_ALBUM_PERMISSION_ADMIN lowercaseString]])
        return kShareAsAdmin;

    [NSException raise:NSGenericException format:@"Unexpected permission: %@.", permission];
    return NO;
}

- (NSDateFormatter *)dateFormatter
{
    static dispatch_once_t pred;
    static NSDateFormatter *sharedDateFormatter = nil;
    
    dispatch_once(&pred, ^{
        sharedDateFormatter = [[NSDateFormatter alloc]init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
           [sharedDateFormatter setDateFormat:@"yyyy-MM-dd  HH:mm:ss"]; //2012-01-14 00:16:43
        [sharedDateFormatter setLocale:locale];
    });
    
    return sharedDateFormatter;
}


@end
