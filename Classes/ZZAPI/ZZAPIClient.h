//
//  ZZAPIClient.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 3/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZAPI.h"
#import "AFHTTPClient.h"

#ifndef ZZAPICLIENTDEFS
#define ZZAPICLIENTDEFS
#define ZZAPI_POST @"POST"
#define ZZAPI_GET  @"GET"

#endif


//Error domains for NSERROR
extern NSString * const ZZAPIASIHTTPErrorDomain;
extern NSString * const ZZAPIServerErrorDomain;
extern NSString * const ZZAPIJSONErrorDomain;


@interface ZZAPIClient : AFHTTPClient{
    
}


+(ZZAPIClient *)sharedClient; 

-(NSArray *) devServerArray;

//LOGIN
-(BOOL) loginWithParams:(NSDictionary *)params
                success:(void (^)(ZZSession *session))success 
                failure:(void(^)(NSError *error))failure;



//ACTIVITIES
-(BOOL) getActivityForUser:(ZZUserID)userID
                   success:(void (^)(NSMutableArray *activity))success 
                   failure:(void(^)(NSError *error))failure;

-(BOOL) getActivityForAlbums:(NSArray *)albumIDs
                      userId:(ZZUserID)userID
                        page:(NSInteger) page
                        size:(NSInteger) size
                     success:(void (^)(NSArray *activity))success 
                     failure:(void(^)(NSError *error))failure;

//USER
-(BOOL) getUserWithId:(ZZUserID)user_id
              success:(void (^)(ZZUser *user))success 
              failure:(void(^)(NSError *error))failure;




//IDENTITIES
-(BOOL) identitiesWithStandardServicesAndSuccesBlock:(void (^)(ZZIdentities *identities))success 
                                             failure:(void(^)(NSError *error))failure;
-(BOOL) identitiesForServices:(NSArray *)services 
                      success:(void (^)(ZZIdentities *identities))success 
                      failure:(void(^)(NSError *error))failure;
-(BOOL)updateIdentities:(ZZIdentityService)service 
            credentials:(NSString *)credentials
                success:(void (^)(NSDictionary *identiyHash))success 
                failure:(void(^)(NSError *error))failure;


//ALBUMS
-(BOOL) albumWithName:(NSString *)name 
              privacy:(ZZAPIAlbumPrivacy)privacy 
    facebookStreaming:(BOOL)facebookStreaming
     twitterStreaming:(BOOL)twitterStreaming
       whoCanDownload:(ZZAPIAlbumWhoOption)whoCanDownload 
         whoCanUpload:(ZZAPIAlbumWhoOption)whoCanUpload 
            whoCanBuy:(ZZAPIAlbumWhoOption) whoCanBuy 
              success:(void (^)(ZZAlbum *album))success 
              failure:(void(^)(NSError *error))failure;

-(BOOL) getAlbumPhotosForAlbum:(ZZAlbum *)album 
                       success:(void (^)(NSMutableArray *albumPhotos))success 
                       failure:(void(^)(NSError *error))failure;

//ALBUMINFO
-(BOOL) getAlbumInfoForUser:(ZZUser *)user
                    success:(void (^)(ZZAlbumInfo *albumInfo))success 
                    failure:(void(^)(NSError *error))failure;
//ALBUMSET
-(BOOL) getAlbumSetForAlbumInfo:(ZZAlbumInfo *)albumInfo
                        success:(void (^)(ZZAlbumSet *albumSet))success 
                        failure:(void(^)(NSError *error))failure;

@end
