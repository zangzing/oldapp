//
//  ZZBaseObject.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/18/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

#ifndef ZZAPIDEFS
#define ZZAPIDEFS

//Servers
//#define ZZAPI_PRODUCTION_SERVER             @"www.zangzing.com"     
//#define ZZAPI_STAGING_SERVER                @"www.zangzing.com"

//USER URLs
#define ZZAPI_LOGIN_URL                     @"/zz_api/login_or_create" //"/zz_api/login"   
#define ZZAPI_USER_INFO_URL                 @"/zz_api/users/%llu/info"
#define ZZAPI_FIND_OR_CREATE_USERS          @"/zz_api/users/find_or_create"
#define ZZAPI_USER_ACTIVITY_URL             @"/zz_api/users/%llu/activity"


//IDENTITY URLS
#define ZZAPI_VALIDATE_IDENTITIES_URL       @"/zz_api/identities/validate"
#define ZZAPI_UPDATE_IDENTITY_CREDENTIALS   @"/zz_api/identities/update"

//ALBUM URLs
#define ZZAPI_ALBUM_CREATE_URL              @"/zz_api/users/albums/create"
#define ZZAPI_USER_ALBUMINFO                @"/zz_api/users/%llu/albums"


//GROUP URLs
#define ZZAPI_GROUP_CREATE_URL              @"/zz_api/groups/create"
#define ZZAPI_GROUP_UPDATE_URL              @"/zz_api/groups/%llu/update"
#define ZZAPI_GROUP_DELETE_URL              @"/zz_api/groups/%llu/delete"
#define ZZAPI_GROUP_INFO_URL                @"/zz_api/groups/%llu"
#define ZZAPI_GROUP_GET_FOR_USER_URL        @"/zz_api/users/groups/all"
#define ZZAPI_GROUP_GET_USERS_URL           @"/zz_api/groups/%llu/members"
#define ZZAPI_GROUP_ADD_MEMBERS             @"/zz_api/groups/%llu/add_members"
#define ZZAPI_GROUP_REMOVE_MEMBERS_URL      @"/zz_api/groups/%llu/remove_members"

//ALBUM SHARINGS URLs
#define ZZAPI_ALBUM_SHARING_MEMBERS_URL     @"/zz_api/albums/%llu/sharing_members"
#define ZZAPI_ALBUM_SHARING_EDIT_URL        @"/zz_api/albums/%llu/sharing_edit"
#define ZZAPI_ALBUM_SHARING_ADD_MEMBERS     @"/zz_api/albums/%llu/add_sharing_members"
#define ZZAPI_ALBUM_SHARING_DELETE_MEMBER   @"/zz_api/albums/%llu/delete_sharing_member"
#define ZZAPI_SHARES_SEND                   @"/zz_api/shares/send"
#define ZZAPI_ALBUMPHOTOS_URL               @"/zz_api/albums/%llu/photos"


//MISC URLs
#define ZZAPI_SYSTEM_STATUS_URL             @"/zz_api/system/status"


#define ZZAPI_ALBUM_PERMISSION_VIEWER       @"viewer"
#define ZZAPI_ALBUM_PERMISSION_CONTRIB      @"contributor"
#define ZZAPI_ALBUM_PERMISSION_ADMIN        @"admin"
typedef enum{
    kShareAsViewer,
    kShareAsContributor,
    kShareAsAdmin
} ZZSharePermission;

//Error codes
#define ZZAPI_ERROR             -1
#define ZZAPI_STATUS_ERROR      509
#define ZZAPI_SUCCESS           200


#endif

@interface ZZBaseObject: NSObject {
     NSDictionary *_serverHash;
     NSError *_lastCallError;
}
@property (nonatomic, retain) NSError *lastCallError;



-(id)initWithNSDictionary:(NSDictionary *)serverHash;
-(NSDictionary *)toNSDictionary;

// methods for building server request
-(ASIHTTPRequest *) createPOSTRequest:(NSString *) url body:(NSMutableDictionary *) body;
-(ASIHTTPRequest *) createGETRequest:(NSString *) url;
-(ASIHTTPRequest *) createHTTPRequest:(NSString *) url;
-(NSString *) createURL:(NSString *)urlBase ssl:(BOOL)ssl;
+(NSString *) createURL: (NSString *)urlBase ssl:(BOOL)ssl production:(BOOL)production;

// methods for server request unmarshaling and error handling
-(int) decodeRequestStatus:(ASIHTTPRequest*)request message:(NSString *)message;
-(NSObject *) decodeRequestResponse: (ASIHTTPRequest*)request message:(NSString *)message;
-(NSArray *) decodeRequestResponseAsArray: (ASIHTTPRequest*)request message:(NSString *)message;
-(NSDictionary *) decodeRequestResponseAsDictionary: (ASIHTTPRequest*)request message:(NSString *)message;

+(NSString*)sharePermissionToString:(ZZSharePermission)permission;
+(ZZSharePermission)sharePermissionFromString:(NSString*)permission;

- (NSDateFormatter *)dateFormatter;

@end
