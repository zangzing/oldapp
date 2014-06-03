//
//  albums.h
//  zziphone
//
//  Created by Phil Beisel on 8/10/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zztypes.h"
#import "ZZAPI.h"

@class ASIHTTPRequest;
@class ASINetworkQueue;
@class ZZUIImageView;
@class Album;


// -------------------------------------------------------------------------------------------------------------------------
// Albums
// main albums model object

@interface Albums : NSObject {
    
    NSMutableDictionary *_albumsets;           // AlbumSets objects; keyed by user id
    NSMutableDictionary *_albums;              // Album objects; keyed by album id  
    
    // image caching
    NSMutableDictionary *_albumimagecache;     // AlbumImageCache objects
    NSMutableDictionary *_albumimagecachelist; // current albums being cached
    BOOL _imageCachingInitialized;
    
    CFTimeInterval _lastrefresh;                // last albumset refresh
    
    // last album
    ZZUserID _lastalbumuserid;
    ZZAlbumID _lastalbumid;
    NSString* _lastalbumname;
}

-(void)getalbumsets: (ZZUserID)userid;
-(void)refreshalbumsets: (ZZUserID)userid;
-(unsigned long)albumsetsupdated: (ZZUserID)userid;
-(void)updateallalbumsets;
-(Album*) getcachedalbum: (ZZAlbumID)albumid userid:(ZZUserID)userid updated_at:(unsigned long)updated_at cache_version:(NSString*)cache_version; 
-(void)getalbumrefresh: (ZZAlbumID)albumid userid:(ZZUserID)userid;
-(void)getalbum: (ZZAlbumID)albumid userid:(ZZUserID)userid updated_at:(unsigned long)updated_at cache_version:(NSString*)cache_version forceRefresh:(BOOL)forceRefresh;        // make async request for album if not loaded
-(BOOL)albumloaded: (ZZAlbumID)albumid;
-(void)unloadalbum: (ZZAlbumID)albumid;
-(int)getphotocount: (ZZAlbumID)albumid;
-(NSDictionary*)getphoto: (int)photo albumid:(ZZAlbumID)albumid;
-(ZZUIImageView*)getgrid: (int)photo albumid:(ZZAlbumID)albumid;
-(ZZUIImageView*)getscreen: (int)photo albumid:(ZZAlbumID)albumid;
-(NSArray*)getScreenPhotos:(ZZAlbumID)albumid;
-(BOOL)albumsetloaded: (ZZUserID)userid type:(NSString*)type;
-(NSArray*)albumset: (ZZUserID)userid type:(NSString*)type;
-(void)setLastAlbum: (ZZUserID)userid albumid:(ZZAlbumID)albumid name:(NSString*)name;
-(ZZUserID)getLastAlbumUserID;
-(ZZAlbumID)getLastAlbumID;
-(NSString*)getLastAlbumName;
-(ZZSharePermission)sharePermission:(ZZUserID)userid albumid:(ZZAlbumID)albumid;
-(BOOL)canAdd:(ZZUserID)userid albumid:(ZZAlbumID)albumid;          // can add a photo
-(NSDictionary*)getAddable;
-(NSDictionary*)getAlbumData:(ZZUserID)userid albumid:(ZZAlbumID)albumid;


// album image caching
-(void)initImageCaching;
-(void)startImageCaching:(ZZAlbumID)albumid userid:(ZZUserID)userid updated_at:(unsigned long long)updated_at cache_version:(NSString*)cache_version;
-(void)startImageCaching:(id)object;
-(void)stopImageCaching:(ZZAlbumID)albumid userid:(ZZUserID)userid;
-(void)stopImageCaching:(id)object;
-(void)imageCachingProgress:(ZZAlbumID)albumid userid:(ZZUserID)userid left:(out int*)left total:(out int*)total;
-(BOOL)isImageCachingRunning:(ZZAlbumID)albumid userid:(ZZUserID)userid;
-(BOOL)isCaching:(ZZAlbumID)albumid userid:(ZZUserID)userid;

-(void)memoryWarning;

@end

extern Albums *gAlbums;


// -------------------------------------------------------------------------------------------------------------------------
// Album

@interface Album : NSObject {
    
    ZZAlbumID _id;                     // album id
    ZZUserID _userid;                  // belongs to
    unsigned long _updated_at;         // last time updated
    BOOL _photosloaded;                // photos loaded (_photos contains JSON)
    NSString *_cache_version;          // cache version key
    NSString *_photosurl;              // photos JSON url e.g., http://staging.photos.zangzing.com/zz_api/albums/7/photos
    NSArray *_photos;                  // photos data
    NSMutableArray *_photoSet;         // indices of valid photos
    ASIHTTPRequest *_request;          // data request
}

-(id)init:(ZZAlbumID)albumid userid:(ZZUserID)userid updated_at:(unsigned long)updated_at cache_version:(NSString*)cache_version;
-(BOOL)photosloaded;
-(int)getphotocount;
-(void)getphotosascached;
-(void)getphotos;
-(NSDictionary*)getphoto: (int)photo;
-(ZZUIImageView*)getgrid: (int)photo;
-(ZZUIImageView*)getscreen: (int)photo;
-(NSArray*)getScreenPhotos;
-(unsigned long)updated_at;
-(NSString*)cache_version;
-(void)uncache;
-(void)unload;


@end


// -------------------------------------------------------------------------------------------------------------------------
// AlbumImageCache

@interface AlbumImageCache : NSObject {
    
    ZZAlbumID _id;                     // album id
    ZZUserID _userid;                  // belongs to
    ASINetworkQueue *_queue;
    BOOL _suspended;
    BOOL _running;
    BOOL _done;
    Album *_album;
    
    NSUInteger  _thumbtotal;
    NSUInteger  _thumbrequests;
    NSUInteger  _thumbgets;
    NSUInteger  _screentotal;
    NSUInteger  _screenrequests;
    NSUInteger  _screengets;
}

- (id)init:(ZZAlbumID)albumid userid:(ZZUserID)userid album:(Album*)album;
- (void)setAlbumIfNotSet:(Album*)album;
- (void)start;
- (void)stop;
- (void)suspend:(BOOL)suspend;
- (BOOL)running;
- (int)left;
- (void)progress:(out int*)current total:(out int*)total;

@end



// -------------------------------------------------------------------------------------------------------------------------
// AlbumSets
// 1 per user
// holder of 1..n AlbumSet's and the album set info

@interface AlbumSets : NSObject {

    ZZUserID _userid;                  // belongs to
    NSMutableDictionary *_albumsets;   // AlbumSet objects keyed type e.g., 'my', 'like', etc.

    NSString *_albuminfourl;           // photos JSON url e.g., http://www.zangzing.com/zz_api/users/249900073726/albums
    NSDictionary *_albumsetsinfo;      // album sets info
    ASIHTTPRequest *_srequest;         // data request for album set info info e.g., http://www.zangzing.com/zz_api/users/249900073726/albums
}

-(id)init:(ZZUserID)userid;
-(void)get;
-(void)getalbumsets;
-(void)getalbumset:(ZZUserID)userid type:(NSString*)type url:(NSString*)url currentversion:(unsigned long)currentversion;
-(BOOL)albumsetloaded: (NSString*)type;
-(unsigned long)updated;
-(NSArray*)albumset:(NSString*)type;
-(NSDictionary*)getalbumsetdata:(ZZAlbumID)albumid;
-(ZZSharePermission)sharePermission:(ZZUserID)userid albumid:(ZZAlbumID)albumid;
-(BOOL)canAdd:(ZZUserID)userid albumid:(ZZAlbumID)albumid;          // can add a photo
-(NSDictionary*)getAddable;

@end


// -------------------------------------------------------------------------------------------------------------------------
// AlbumSet

@interface AlbumSet : NSObject {
    
    ZZUserID _userid;                  // belongs to
    NSString *_type;                   // e.g., 'my', 'like', 'invited', etc.
    NSString *_url;                    // album set JSON url
    unsigned long _version;            // current version
    NSArray *_albumset;                // album set data
    unsigned long _updated;            // data updated
    
    ASIHTTPRequest *_request;          // data request
}

-(id)init:(ZZUserID)userid type:(NSString*)type url:(NSString*)url currentversion:(unsigned long)currentversion;
-(BOOL)update:(unsigned long)currentversion;
-(NSArray*)getalbumset;
-(void)set:(NSArray*)albumset sort:(BOOL)sort;
-(unsigned long)updated;
-(void)setVersion: (unsigned long long)version;
-(NSDictionary*)getdata:(ZZAlbumID)albumid;

@end





