//
//  ZZAlbum.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import  "zztypes.h"
#import "ZZJSONModel.h"

#ifndef ZZALBUMDEFS
#define ZZALBUMDEFS



//Album privacies
#define ZZAPI_ALBUM_PUBLIC       @"public"
#define ZZAPI_ALBUM_HIDDEN       @"hidden"
#define ZZAPI_ALBUM_PASSWORD     @"password"
typedef enum{
    kPublic,
    kHidden,
    kPassword
} ZZAPIAlbumPrivacy;


//Album options for who can download/upload/buy?
#define ZZAPI_ALBUM_EVERYONE     @"everyone"
#define ZZAPI_ALBUM_VIEWERS      @"viewers"
#define ZZAPI_ALBUM_CONTRIBUTORS @"contributors"
#define ZZAPI_ALBUM_OWNER        @"owner"
typedef enum{
    kEveryone,
    kViewers,
    kContributors,
    kOwner
} ZZAPIAlbumWhoOption;

#endif

@interface ZZAlbum: ZZJSONModel

//    V9.0    
//    :id => album_id,
//    :name => album_name,
//    :email => album.email,
//    :user_name => album_user_name,
//    :user_id => album_user_id,
//    :album_path => album_pretty_path(album_user_name, album_friendly_id),
//    :profile_album => is_profile_album,
//    :c_url =>  c_url,
//    :cover_id => cover_id,
//    :cover_base => cover_base,
//    :cover_sizes => cover_sizes,
//    :cover_date => cover_date.to_i,
//    :photos_count => album.photos_count,
//    :photos_ready_count => album.photos_ready_count,
//    :cache_version => album.cache_version_key,
//    :updated_at => album.updated_at.to_i,
//    :my_role => album.my_role, # valid values are viewer, contributor, admin
//    :privacy => album.privacy,
//    :all_can_contrib => album.everyone_can_contribute?,
//    :who_can_download => album.who_can_download, #Valid values are viewers, owner, everyone
//    :who_can_upload => album.who_can_upload,
//    :who_can_buy => album.who_can_buy,
//    :stream_to_facebook => album.stream_to_facebook,
//    :stream_to_twitter => album.stream_to_twitter,
//    :stream_to_email => album.stream_to_email,    


//properties
@property (nonatomic)         ZZAlbumID   album_id;
@property (nonatomic, strong) NSString    *name; 
@property (nonatomic, strong) NSString    *email;
@property (nonatomic, strong) NSString    *user_name; 
@property (nonatomic)         ZZUserID    user_id;
@property (nonatomic, strong) NSString    *album_path; 
@property (nonatomic )        BOOL        profile_album;
@property (nonatomic, strong) NSString    *c_url;
@property (nonatomic)         ZZPhotoID   cover_id;
@property (nonatomic, strong) NSString    *cover_base;
@property (nonatomic, strong) NSMutableDictionary    *cover_sizes;  //SPECIAL CASE MAPPING
@property (nonatomic, strong) NSDate      *cover_date;
@property (nonatomic, strong) NSNumber    *photos_count;
@property (nonatomic, strong) NSNumber    *photos_ready_count;
@property (nonatomic, strong) NSString    *cache_version;
@property (nonatomic, strong) NSDate      *updated_at;
@property (nonatomic, strong) NSString    *my_role;
@property (nonatomic)         ZZAPIAlbumPrivacy privacy;            //SPECIAL CASE MAPPING
@property (nonatomic)         BOOL        all_can_contrib;
@property (nonatomic)         ZZAPIAlbumWhoOption  who_can_download;  //SPECIAL CASE MAPPING
@property (nonatomic)         ZZAPIAlbumWhoOption  who_can_upload;    //SPECIAL CASE MAPPING
@property (nonatomic)         ZZAPIAlbumWhoOption  who_can_buy;       //SPECIAL CASE MAPPING
@property (nonatomic)         BOOL        stream_to_facebook;
@property (nonatomic)         BOOL        stream_to_email;
@property (nonatomic, strong) NSMutableArray *photos;


// create methods
+(ZZAlbum *) albumWithName:(NSString *)name 
                   privacy:(ZZAPIAlbumPrivacy)privacy 
         facebookStreaming:(BOOL)facebookStreaming
          twitterStreaming:(BOOL)twitterStreaming
            whoCanDownload:(ZZAPIAlbumWhoOption)whoCanDownload 
              whoCanUpload:(ZZAPIAlbumWhoOption)whoCanUpload 
                 whoCanBuy:(ZZAPIAlbumWhoOption) whoCanBuy 
                     error:(NSError **)anError;

//init methods

+ (NSString *) albumPrivacyToString:(ZZAPIAlbumPrivacy)privacy;
+ (ZZAPIAlbumPrivacy) stringToAlbumPrivacy:(NSString*)privacy;
+ (NSString*)  albumWhoOptionToString:(ZZAPIAlbumWhoOption)whoOption;
+ (NSString*)  albumWhoOptionToDisplayString:(ZZAPIAlbumWhoOption)whoOption;
+ (ZZAPIAlbumWhoOption) stringToAlbumWhoOption:(NSString*)albumWhoOptionStr;

@end
