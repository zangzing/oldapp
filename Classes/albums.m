//
//  albums.m
//  zziphone
//
//  Created by Phil Beisel on 8/10/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import "malloc/malloc.h"
#import "zzglobal.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Resize.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Alpha.h"
#import "ZZUIImageView.h"
#import "zzglobal.h"
#import "albums.h"
#import "BrowsePhoto.h"
#import "ZZCache.h"


// -------------------------------------------------------------------------------------------------------------------------
// Albums

Albums *gAlbums = nil;

@implementation Albums

- (id)init
{
    self = [super init];
    if (self) {
        _albums = [[NSMutableDictionary alloc] init];
        _albumsets = [[NSMutableDictionary alloc] init];
        
        _lastalbumuserid = 0;
        _lastalbumid = 0;
        
        // defer initImageCaching
        _imageCachingInitialized = NO;
        [NSTimer scheduledTimerWithTimeInterval: 5 target: self selector: @selector(initializeImageCachingTimer:) userInfo: nil repeats: NO];
    }
    
    return self;
}

- (void)initializeImageCachingTimer: (NSTimer*)timer 
{
    if (!_imageCachingInitialized)
        [self performSelectorInBackground:@selector(initImageCaching) withObject:nil];
} 


-(void)getalbumsets: (ZZUserID)userid
{
    AlbumSets *albumsets = [_albumsets objectForKey:[NSNumber numberWithUnsignedLongLong:userid]];
    if (!albumsets) {
        // initialize albumsets
        albumsets = [[AlbumSets alloc] init:userid];
        [_albumsets setObject:albumsets forKey:[NSNumber numberWithUnsignedLongLong:userid]];        
    }
    
    [albumsets get];
}


-(void)refreshalbumsets: (ZZUserID)userid
{
    float deltaTimeInSeconds = CFAbsoluteTimeGetCurrent() - _lastrefresh;
    if (deltaTimeInSeconds > 10.0) {
        
        _lastrefresh = CFAbsoluteTimeGetCurrent();
        [self getalbumsets:userid];
    }
}


-(unsigned long)albumsetsupdated: (ZZUserID)userid
{
    AlbumSets *albumsets = [_albumsets objectForKey:[NSNumber numberWithUnsignedLongLong:userid]];
    if (albumsets) 
        return [albumsets updated];
    return 0;
}


-(void)updateallalbumsets
{
    // refresh all tracked albumsets and the albums within
    
    for (NSNumber *userid in _albumsets) {
        AlbumSets *albumsets = [_albumsets objectForKey:userid];
        [albumsets get];
    }
}


-(Album*) getcachedalbum: (ZZAlbumID)albumid userid:(ZZUserID)userid updated_at:(unsigned long)updated_at cache_version:(NSString*)cache_version
{
    // get cached album
    Album *album = [[Album alloc] init:albumid userid:userid updated_at:updated_at cache_version:cache_version];
    [album getphotosascached];
    return album;
}


-(void)getalbumrefresh: (ZZAlbumID)albumid userid:(ZZUserID)userid
{
    Album *album = [_albums objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
    if (album) {
        [self getalbum:albumid userid:userid updated_at:album.updated_at cache_version:album.cache_version forceRefresh:YES];
    } else {
        AlbumSets *albumsets = [_albumsets objectForKey:[NSNumber numberWithUnsignedLongLong:userid]];
        if (albumsets) {
            NSDictionary *data = [albumsets getalbumsetdata:albumid];
            if (data) {
                NSNumber *updated_at = [data objectForKey:@"updated_at"];
                NSString *cache_version = [data objectForKey:@"cache_version"];
                
                [self getalbum:albumid userid:userid updated_at:[updated_at unsignedLongValue] cache_version:cache_version forceRefresh:YES];
            }
        }
    }
}

-(void)getalbum: (ZZAlbumID)albumid userid:(ZZUserID)userid updated_at:(unsigned long)updated_at cache_version:(NSString*)cache_version forceRefresh:(BOOL)forceRefresh
{
    // get album object with network update (if out of date)
    
    MLOG(@"albums held: %d", _albums.count);
    
    Album *album = [_albums objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
    
    if (album) {
        // check to see if updated_at is newer than cached version, if yes remove Album and forced it to be recreated and filled with data
        if (updated_at > album.updated_at || forceRefresh) {
            
            [album uncache];
            [_albums removeObjectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
            album = nil;
        }
    }
    
    if (!album) {
        // initialize album
        album = [[Album alloc] init:albumid userid:userid updated_at:updated_at cache_version:cache_version];
        [_albums setObject:album forKey:[NSNumber numberWithUnsignedLongLong:albumid]];
    }
    
    // async load photos JSON 
    if (![album photosloaded]) {
        [album getphotos];
    }
}


-(BOOL)albumloaded: (ZZAlbumID)albumid
{
    Album *album = [_albums objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
    if (album) {
        return [album photosloaded];
    }
    
    return NO;
}


-(void)unloadalbum: (ZZAlbumID)albumid
{
    Album *album = [_albums objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
    if (album) {
        [album unload];
    }
}


-(int)getphotocount: (ZZAlbumID)albumid
{
    Album *album = [_albums objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
    if (album) {
        return [album getphotocount];
    }
    
    return -1;  
}


-(NSDictionary*)getphoto: (int)photo albumid:(ZZAlbumID)albumid 
{
    Album *album = [_albums objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];  
    if (album)
        return [album getphoto:photo];
    return NULL;
}


-(ZZUIImageView*)getgrid: (int)photo albumid:(ZZAlbumID)albumid
{
    Album *album = [_albums objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];  
    if (album)
        return [album getgrid:photo];
    return NULL;
}


-(ZZUIImageView*)getscreen: (int)photo albumid:(ZZAlbumID)albumid
{
    Album *album = [_albums objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];  
    if (album)
        return [album getscreen:photo];
    return NULL;
}


-(NSArray*)getScreenPhotos:(ZZAlbumID)albumid
{
    Album *album = [_albums objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];  
    if (album)
        return [album getScreenPhotos];
    return NULL;
}


-(BOOL)albumsetloaded: (ZZUserID)userid type:(NSString*)type
{
    AlbumSets *albumsets = [_albumsets objectForKey:[NSNumber numberWithUnsignedLongLong:userid]];
    if (albumsets)
        return [albumsets albumsetloaded:type];
    return NO;
}


-(NSArray*)albumset: (ZZUserID)userid type:(NSString*)type
{
    AlbumSets *albumsets = [_albumsets objectForKey:[NSNumber numberWithUnsignedLongLong:userid]];
    if (albumsets)
        return [albumsets albumset:type];
    return NULL;    
}


-(ZZUserID)getLastAlbumUserID
{
    return _lastalbumuserid;
}


-(ZZAlbumID)getLastAlbumID
{
    return _lastalbumid;
}


-(NSString*)getLastAlbumName
{
    return _lastalbumname;
}


-(void)setLastAlbum: (ZZUserID)userid albumid:(ZZAlbumID)albumid name:(NSString*)name
{
    _lastalbumuserid = userid;
    _lastalbumid = albumid;
    
    _lastalbumname = nil;
    _lastalbumname = [[NSString alloc]initWithString:name];
}


-(ZZSharePermission)sharePermission:(ZZUserID)userid albumid:(ZZAlbumID)albumid
{
    AlbumSets *albumsets = [_albumsets objectForKey:[NSNumber numberWithUnsignedLongLong:userid]];
    if (albumsets)
        return [albumsets sharePermission:userid albumid:albumid];
    return kShareAsViewer;
}


-(BOOL)canAdd:(ZZUserID)userid albumid:(ZZAlbumID)albumid
{
    // can add photos?
    
    AlbumSets *albumsets = [_albumsets objectForKey:[NSNumber numberWithUnsignedLongLong:userid]];
    if (albumsets)
        return [albumsets canAdd:userid albumid:albumid];
    return NO;
}


-(NSDictionary*)getAddable
{
    AlbumSets *albumsets = [_albumsets objectForKey:[NSNumber numberWithUnsignedLongLong:[ZZSession currentUser].user_id]];
    if (albumsets) {
        return [albumsets getAddable];
    }
    
    return NULL;
}


-(NSDictionary*)getAlbumData:(ZZUserID)userid albumid:(ZZAlbumID)albumid
{
    AlbumSets *albumsets = [_albumsets objectForKey:[NSNumber numberWithUnsignedLongLong:userid]];
    if (albumsets) {
        return [albumsets getalbumsetdata:albumid];
    }
    
    return NULL;
}


// album image caching

-(void)initImageCaching
{
    // build album cache list
    // operates on a background thread
    
    // TODO:
    // *** must get updated Album's first... this requires getting the AlbumSets and then finding current updated_at
    
    @autoreleasepool {
        
        MLOG(@"initImageCaching");
    
        _imageCachingInitialized = YES;
    
        _albumimagecache = [[NSMutableDictionary alloc] init];
        
        @synchronized(_albumimagecache) {
            NSDictionary *aic = (NSDictionary*)[gZZ getObj:@"AlbumImageCache" keytype:NULL];
            if (aic)
                _albumimagecachelist = [[NSMutableDictionary alloc] initWithDictionary:aic];
            else
                _albumimagecachelist = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in _albumimagecachelist) {
                NSDictionary *a = [_albumimagecachelist objectForKey:key];
                
                NSNumber *userid = [a objectForKey:@"userid"];
                NSNumber *albumid = [a objectForKey:@"albumid"];
                NSNumber *updated_at = [a objectForKey:@"updated_at"];
                NSString *cache_version = [a objectForKey:@"cache_version"];
                
                MLOG(@"initImageCaching: album: %llu", [albumid unsignedLongLongValue]);
                
                AlbumImageCache *cache = [[AlbumImageCache alloc]init:[albumid unsignedLongLongValue] userid:[userid unsignedLongLongValue] album:NULL];
                [_albumimagecache setObject:cache forKey:albumid];  
                
                [self startImageCaching:[albumid unsignedLongLongValue] userid:[userid unsignedLongLongValue] updated_at:[updated_at unsignedLongLongValue] cache_version:cache_version];
            }
        }
        
    } 
}


-(void)saveImageCaching
{
    [gZZ cacheObj:@"AlbumImageCache" keytype:NULL obj:_albumimagecachelist];
}


-(void)startImageCaching:(ZZAlbumID)albumid userid:(ZZUserID)userid updated_at:(unsigned long long)updated_at cache_version:(NSString*)cache_version  
{
    @try {
        Album *album = [_albums objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
        if (!album) {
            // if album not in albums list, load from cache
            album = [self getcachedalbum:albumid userid:userid updated_at:updated_at cache_version:cache_version];
        }    
        
        if (album) {
            @synchronized(_albumimagecache) {
                AlbumImageCache *cache = [_albumimagecache objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
                
                if (!cache) {
                    cache = [[AlbumImageCache alloc]init:albumid userid:userid album:album];
                    [_albumimagecache setObject:cache forKey:[NSNumber numberWithUnsignedLongLong:albumid]];
                    
                    // NOTE: to load a cached album, need three pieces of info: albumid, userid, and updated_at
                    NSMutableDictionary *a = [[NSMutableDictionary alloc]initWithCapacity:2];
                    [a setObject:[NSNumber numberWithUnsignedLongLong:albumid] forKey:@"albumid"];
                    [a setObject:[NSNumber numberWithUnsignedLongLong:userid] forKey:@"userid"];
                    [a setObject:[NSNumber numberWithUnsignedLongLong:updated_at] forKey:@"updated_at"];
                    [a setObject:cache_version forKey:@"cache_version"];
                    [_albumimagecachelist setObject:a forKey:[[NSNumber numberWithUnsignedLongLong:albumid] stringValue]];
                    
                    [self saveImageCaching];
                }
                
                [cache setAlbumIfNotSet:album];
                [cache start];
            }
        }
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"startImageCaching.1" exception:exception];
    }
}


-(void)startImageCaching:(id)object
{
    @autoreleasepool {
        
        NSDictionary *args = (NSDictionary*)object;
        
        NSNumber* n;
        
        @try {
            n = (NSNumber*)[args objectForKey:@"albumid"];
            ZZAlbumID albumid = [n unsignedLongLongValue];
            n = (NSNumber*)[args objectForKey:@"userid"];
            ZZUserID userid = [n unsignedLongLongValue];
            n = (NSNumber*)[args objectForKey:@"updated_at"];
            unsigned long long updated_at = [n unsignedLongLongValue];
            NSString *cache_version = [args objectForKey:@"cache_version"];
            
            [self startImageCaching:albumid userid:userid updated_at:updated_at cache_version:cache_version];
        }
        @catch (NSException *exception) {
            [ZZGlobal trackException:@"startImageCaching.2" exception:exception];
        }
        
    }
}


-(void)stopImageCaching:(ZZAlbumID)albumid userid:(ZZUserID)userid
{
    @autoreleasepool {
        
        @synchronized(_albumimagecache) {
            AlbumImageCache *cache = [_albumimagecache objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
            if (cache) {
                [cache stop];
                
                [_albumimagecache removeObjectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
                
                [_albumimagecachelist removeObjectForKey:[[NSNumber numberWithUnsignedLongLong:albumid] stringValue]];
                [self saveImageCaching];
            }
        }
        
    }
}


-(void)stopImageCaching:(id)object
{
    NSDictionary *args = (NSDictionary*)object;
    
    NSNumber* n;
    
    @try {
        n = (NSNumber*)[args objectForKey:@"albumid"];
        ZZAlbumID albumid = [n unsignedLongLongValue];
        n = (NSNumber*)[args objectForKey:@"userid"];
        ZZUserID userid = [n unsignedLongLongValue];
        
        [self stopImageCaching:albumid userid:userid];
    }
    @catch (NSException *exception) {
        [ZZGlobal trackException:@"stopImageCaching" exception:exception];
    }
}


-(void)imageCachingProgress:(ZZAlbumID)albumid userid:(ZZUserID)userid left:(out int*)left total:(out int*)total
{
    @synchronized(_albumimagecache) {
        AlbumImageCache *cache = [_albumimagecache objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
        if (cache) {
            [cache progress:left total:total];
        } else {
            *left = -1;
            *total = -1;
        }
    }
}


-(BOOL)isCaching:(ZZAlbumID)albumid userid:(ZZUserID)userid
{
    @synchronized(_albumimagecache) {
        AlbumImageCache *cache = [_albumimagecache objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
        return (cache != NULL);
    }
}


-(BOOL)isImageCachingRunning:(ZZAlbumID)albumid userid:(ZZUserID)userid
{
    @synchronized(_albumimagecache) {
        AlbumImageCache *cache = [_albumimagecache objectForKey:[NSNumber numberWithUnsignedLongLong:albumid]];
        if (cache)
            return [cache running];
        return NO;
    }
}


-(void)memoryWarning
{
    //[_albumsets removeAllObjects];
    //[_albums removeAllObjects];
}

@end


// -------------------------------------------------------------------------------------------------------------------------
// Album

@implementation Album

- (id)init: (ZZAlbumID)albumid userid:(ZZUserID)userid updated_at:(unsigned long)updated_at cache_version:(NSString*)cache_version;
{
    self = [super init];
    if (self) {
        _id = albumid;
        _userid = userid;
        _updated_at = updated_at;
        _cache_version = [[NSString alloc]initWithString:cache_version];
        _photosloaded = NO;
        _photoSet = NULL;
        
        _photosurl = [[NSString alloc]initWithFormat:@"%@/zz_api/albums/%llu/photos?ver=%@", [gZZ serviceURL], _id, _cache_version];
    }
    
    return self;
}


- (NSString*)key
{
    //return [NSString stringWithFormat:@"%@--%llu", _photosurl, _updated_at];
    return _photosurl;
}


- (BOOL)photosloaded
{
    return _photosloaded;
}


- (void)getphotosascached
{
    _photos = (NSArray*)[gZZ getObj: [self key] keytype:@"ALBUMS"];
    if (_photos) {
        MLOG(@"Album photos loaded from cache: %@", [self key]);
        _photosloaded = YES;        
    }    
}


- (void)getphotos
{    
    [self getphotosascached];
    if (_photos)
        return;
    
    // request photos JSON async
    MLOG(@"Album photos request: %@", _photosurl);
    _request = [ASIHTTPRequest requestWithURL:[[NSURL alloc] initWithString:_photosurl]];
    [_request setNumberOfTimesToRetryOnTimeout:2];
    [_request setTimeOutSeconds:60];
    [_request addRequestHeader:@"Accept" value:@"application/json"];
    [_request addRequestHeader:@"X-ZangZing-API" value:@"iphone"];
#ifdef DEBUG            
    [_request setValidatesSecureCertificate:NO];
#endif
    if ([ZZSession currentSession]) {
        [_request setUseCookiePersistence:NO];
        [_request setRequestCookies:[NSMutableArray arrayWithObject:[gZZ authCookie]]];
    }
    [_request setDelegate:self];
    [_request startAsynchronous];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    NSObject *data = [ZZGlobal getObjfromJSON: responseData];
    int result = [ZZGlobal responseError:request data:data];
    if (result == 0) {
        _photos = (NSArray*)data;
        _photoSet = NULL;
        
        [gZZ cacheObj:[self key] keytype:@"ALBUMS" obj:_photos];
        _photosloaded = YES; 
        
        MLOG(@"Album photos request complete, photos: %d", _photos.count);
    }
    
    _request = nil;
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    MLOG(@"Album Request Error: %@", error);
    
    _photos = NULL;
    _photoSet = NULL;
    _photosloaded = NO;
    
    _request = nil;
}


- (NSDictionary*)getphoto: (int)photo
{
    /*
     e.g.,
     
     {
     "source_guid":"simpleuploader:8bacdcd3-1538-4594-b86c-1698c0da7b1f",
     "rotate_to":0,
     "screen_url":"http://4.zz.s3.amazonaws.com/i/a1d49de5-c9ef-451b-ab4b-c11684395f89-m?1306448663",
     "stamp_url":"http://4.zz.s3.amazonaws.com/i/a1d49de5-c9ef-451b-ab4b-c11684395f89-s?1306448663",
     "full_screen_url":"http://4.zz.s3.amazonaws.com/i/a1d49de5-c9ef-451b-ab4b-c11684395f89-l?1306448663",
     "state":"ready",
     "caption":"light.jpg",
     "thumb_url":"http://4.zz.s3.amazonaws.com/i/a1d49de5-c9ef-451b-ab4b-c11684395f89-t?1306448663",
     "aspect_ratio":1.19530710835059,
     "user_id":249900073726,
     "id":169911658231,
     "upload_batch_id":209900078230
     }
     
     */
    
    if (!_photos)
        return NULL;
    
    if (photo < 1 || photo > [self getphotocount])
        return NULL;
    
    NSNumber *pindex = [_photoSet objectAtIndex:(photo-1)];
    return (NSDictionary*)[_photos objectAtIndex:[pindex intValue]];
}


- (int)getphotocount 
{
    if (_photos) {
        
        if (_photoSet != NULL)
            return _photoSet.count;
        else {
            _photoSet = [[NSMutableArray alloc]init];
            
            // build an array of indices of valid photos
            for (int p = 0; p < _photos.count; p++) {
                NSDictionary *photoobj = [_photos objectAtIndex:p];
                if (photoobj) {
                    NSString *state = [photoobj objectForKey:@"state"];
                    if ([state isEqualToString:@"ready"]) {
                        [_photoSet addObject:[NSNumber numberWithInt:p]];
                    }
                    else {
                        NSString *agent_id = [photoobj objectForKey:@"agent_id"];
                        if (agent_id && [agent_id isKindOfClass:[NSString class]]) {                    // not NSNull
                            if ([agent_id isEqualToString:[gZZ UID]]) {
                                [_photoSet addObject:[NSNumber numberWithInt:p]];
                            }
                        }
                    }
                }
            }
            
            return _photoSet.count;
        }
    }
    else
        return -1;
}


- (ZZUIImageView*)getgrid: (int)photo
{
    if (!_photos)
        return NULL;
    
    if (photo < 1 || photo > [self getphotocount])
        return NULL;
    
    ZZUIImageView *photov = NULL;
    
    NSDictionary *photoobj = [self getphoto:photo];
    if (photoobj) {
        
        NSString *state = [photoobj objectForKey:@"state"];
        if ([state isEqualToString:@"ready"]) {
            NSString *gridurl = [photoobj objectForKey:@"photo_base"];
            if (gridurl && [gridurl isKindOfClass:[NSString class]]) {
                NSDictionary *photosizes = [photoobj objectForKey:@"photo_sizes"];
                if (photosizes) {
                    NSString *photokey;
                    if ([gZZ isHiResScreen]) 
                        photokey = [photosizes objectForKey:@"iphone_grid_ret"];
                    else
                        photokey = [photosizes objectForKey:@"iphone_grid"];
                    gridurl = [gridurl stringByReplacingOccurrencesOfString:@"#{size}" withString:photokey];
                }
            } 
            
            if (!gridurl || [gridurl isKindOfClass:[NSNull class]])
                gridurl = [photoobj objectForKey:@"thumb_url"];
            
            if (gridurl && [gridurl isKindOfClass:[NSString class]]) {
                photov = [[ZZUIImageView alloc] initWithImage:[UIImage imageNamed:@"grid-placeholder.png"]];
                photov.type = Thumb;
                photov.userInteractionEnabled = YES;
                
                NSNumber *photoid = [photoobj objectForKey:@"id"];
                photov.photoid = [photoid unsignedLongLongValue];
                photov.photoIndex = photo;
                
                if (gridurl && [gridurl isKindOfClass:[NSString class]])        // protect against thumburl == nil or == NSNull
                    [photov setImageWithURL_SD:[NSURL URLWithString:gridurl] placeholderImage:[UIImage imageNamed:@"grid-placeholder.png"]];
                
                //MLOG(@"getgrid: %d ready", photo);
                
                return photov;
            } 
        } else {
            // for other states e.g., 'assigned', photo has been created (somewhere) but not uploaded/processed
            // test to see if the photo is ours (agent_id matches our UID)
            // if yes, grab the source_guid (aka the photo key) and see if there is a upload image available to substitute
            
            NSString *agent_id = [photoobj objectForKey:@"agent_id"];
            NSString *source_guid = [photoobj objectForKey:@"source_guid"];
            
            if (agent_id && [agent_id isKindOfClass:[NSString class]]) {                    // not NSNull
                if ([agent_id isEqualToString:[gZZ UID]]) {
                    // this photo is ours, if photo is in the upload queue, grab local thumbnail
                    if (source_guid && [source_guid isKindOfClass:[NSString class]]) {      // not NSNull
                        
                        NSString *thumbkey = [NSString stringWithFormat:@"%@_t", source_guid];
                        UIImage *uimage = [gZZ getUploadQueueImage:thumbkey];
                        if (uimage) {
                            // make thumbnail
                            int thumbsize = kThumbSize;
                            if ([gZZ isHiResScreen]) {
                                thumbsize = kThumbSize_Retina;
                            }
                            uimage = [uimage thumbnailImage:thumbsize transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationMedium];
                         
                            photov = [[ZZUIImageView alloc] initWithImage:uimage];
                            photov.type = Thumb;
                            photov.userInteractionEnabled = YES;
                            
                            NSNumber *photoid = [photoobj objectForKey:@"id"];
                            photov.photoid = [photoid unsignedLongLongValue];
                            photov.photoIndex = photo;

                            MLOG(@"getgrid: %d local", photo);
                            return photov;
                        }
                    }
                }
            }
        }
    }

    // default
    MLOG(@"getgrid: %d default", photo);
    
    photov = [[ZZUIImageView alloc] initWithImage:[UIImage imageNamed:@"inprocess.png"]];
    photov.type = Thumb;
    photov.userInteractionEnabled = NO;
    
    NSNumber *photoid = [photoobj objectForKey:@"id"];
    photov.photoid = [photoid unsignedLongLongValue];
    photov.photoIndex = photo;
    
    return photov;
}


- (ZZUIImageView*)getscreen: (int)photo
{
    if (!_photos)
        return NULL;
    
    if (photo < 1 || photo > [self getphotocount])
        return NULL;
    
    ZZUIImageView *photov = NULL;
    
    NSDictionary *photoobj = [self getphoto:photo];
    if (photoobj) {
        NSString *screenurl = [photoobj objectForKey:@"screen_url"];
        if (screenurl) {
            photov = [[ZZUIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder.png"]];
            photov.type = Screen;
            photov.userInteractionEnabled = YES;
            
            NSNumber *photoid = [photoobj objectForKey:@"id"];
            photov.photoid = [photoid unsignedLongLongValue];
            
            if (screenurl && [screenurl isKindOfClass:[NSString class]])        // protect against screenurl == nil or == NSNull
                [photov setImageWithURL_SD:[NSURL URLWithString:screenurl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            return photov;
        }
    }
    
    
    return NULL;
}


-(NSArray*)getScreenPhotos
{
    NSMutableArray* photos = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= _photos.count; i++) {
        NSDictionary *photoobj = [self getphoto:i];
        if (photoobj) {
            
            NSString *state = [photoobj objectForKey:@"state"];
            
            if ([state isEqualToString:@"ready"]) {
            
                NSString *screenurl = [photoobj objectForKey:@"screen_url"];
                NSLog(@"getScreenPhotos %d, url: %@", i, screenurl);
                [photos addObject:[BrowsePhoto photoWithURL:[NSURL URLWithString:screenurl]]];
            } else {
                // for other states e.g., 'assigned', photo has been created (somewhere) but not uploaded/processed
                // test to see if the photo is ours (agent_id matches our UID)
                // if yes, grab the source_guid (aka the photo key) and see if there is a upload image available to substitute
                
                NSString *agent_id = [photoobj objectForKey:@"agent_id"];
                NSString *source_guid = [photoobj objectForKey:@"source_guid"];
                
                if (agent_id && [agent_id isKindOfClass:[NSString class]]) {                    // not NSNull
                    if ([agent_id isEqualToString:[gZZ UID]]) {
                        // this photo is ours, if photo is in the upload queue, grab local file
                        if (source_guid && [source_guid isKindOfClass:[NSString class]]) {      // not NSNull
                            
                            NSString *fpath = [gZZ uploadQueuePathForKey:source_guid];
                            NSLog(@"getScreenPhotos %d, file: %@", i, fpath);
                            [photos addObject:[BrowsePhoto photoWithFilePath:fpath]];
                        }
                    }
                }
            }
        }
    }
    
    return photos;
}


-(unsigned long)updated_at
{
    return _updated_at;
}


-(NSString*)cache_version;
{
    return _cache_version;
}


-(void)uncache {
    [gZZ deleteObj:[self key] keytype:@"ALBUMS"];
}


-(void)unload {
    _photos = nil;
    _photoSet = nil;
    _photosloaded = NO;
}



@end


// -------------------------------------------------------------------------------------------------------------------------
// AlbumImageCache

@implementation AlbumImageCache

- (id)init:(ZZAlbumID)albumid userid:(ZZUserID)userid album:(Album *)album
{
    self = [super init];
    if (self) {
        _id = albumid;
        _userid = userid;
        _album = album;
        
        _running = NO;
        _done = NO;
        _suspended = NO;
        
        _queue = [[ASINetworkQueue alloc] init];        
    }
    
    return self;
}


- (void)setAlbumIfNotSet:(Album*)album
{
    if (!_album)
        _album = album;
}


- (void)start 
{
    MLOG(@"AlbumImageCache: album %llu: start",_id);
    
    if (_running)
        return;
    
    int photocount = [_album getphotocount];
    
    _thumbtotal = photocount;
    _screentotal = photocount;
    
    // build list of image request for thumbs and screen size
    for (int p = 1; p <= photocount; p++) {
        NSDictionary *photoinfo = [_album getphoto:p];
        if (photoinfo) {
             
            NSString *state = [photoinfo objectForKey:@"state"];
            if ([state isEqualToString:@"ready"]) {
                NSString *gridurl = [photoinfo objectForKey:@"photo_base"];
                if (gridurl && [gridurl isKindOfClass:[NSString class]]) {
                    NSDictionary *photosizes = [photoinfo objectForKey:@"photo_sizes"];
                    if (photosizes) {
                        NSString *photokey;
                        if ([gZZ isHiResScreen]) 
                            photokey = [photosizes objectForKey:@"iphone_grid_ret"];
                        else
                            photokey = [photosizes objectForKey:@"iphone_grid"];
                        gridurl = [gridurl stringByReplacingOccurrencesOfString:@"#{size}" withString:photokey];
                    }
                } 
                
                if (!gridurl || [gridurl isKindOfClass:[NSNull class]])
                    gridurl = [photoinfo objectForKey:@"thumb_url"];
                
                // if not in local disk cache, request it
                if (![gZZ isCachedImage:gridurl]) {
                    
                    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[[NSURL alloc] initWithString:gridurl]];
                    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: @"thumb", @"type", nil];
                    [request setNumberOfTimesToRetryOnTimeout:2];
                    [request setTimeOutSeconds:60];
                    [request setDelegate:self];
                    [request setDidFinishSelector:@selector(requestFinished:)];
                    [request setDidFailSelector:@selector(requestFailed:)];
#ifdef DEBUG            
                    [request setValidatesSecureCertificate:NO];
#endif
                    [_queue addOperation:request];
                    _thumbrequests++;
                }
                
                // if not in local disk cache, request it
                if (![gZZ isCachedImage:[photoinfo objectForKey:@"screen_url"]]) {
                    
                    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[[NSURL alloc] initWithString:[photoinfo objectForKey:@"screen_url"]]];
                    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: @"screen", @"type", nil];
                    [request setNumberOfTimesToRetryOnTimeout:2];
                    [request setTimeOutSeconds:60];
                    [request setDelegate:self];
                    [request setDidFinishSelector:@selector(requestFinished:)];
                    [request setDidFailSelector:@selector(requestFailed:)];
#ifdef DEBUG            
                    [request setValidatesSecureCertificate:NO];
#endif
                    [_queue addOperation:request];     
                    _screenrequests++;
                }
            }
        }
    }
    
    MLOG(@"AlbumImageCache: album %llu: thumb count: %u; thumbs requested: %u", _id, _thumbtotal, _thumbrequests);
    MLOG(@"AlbumImageCache: album %llu: screen count: %u; screen requested: %u", _id, _screentotal, _screenrequests);
    
    if (_thumbrequests == 0 && _screenrequests == 0) {
        _done = YES;
    } else {
        _running = YES;
        _done = NO;
        
        [_queue setMaxConcurrentOperationCount:1];
        [_queue go];   
    }
}


- (void)stop
{
    MLOG(@"AlbumImageCache: album %llu: stopping",_id);
    
    [_queue reset];
    _running = NO;
    
    _thumbtotal = 0;
    _thumbrequests = 0;
    _thumbgets = 0;
    _screentotal = 0;
    _screenrequests = 0;
    _screengets = 0;
    
    MLOG(@"AlbumImageCache: album %llu: stopped",_id);
}


-(BOOL)running
{
    return _running;
}


-(int)left
{
    return _screentotal - (_screenrequests - _screengets);      // what's left
}


- (void)progress:(out int*)left total:(out int*)total
{
    if (!_running) {
        *left = -1;
        *total = -1;
    } else {
        *left = [self left]; 
        *total = _screentotal;
    }
}


- (void)suspend:(BOOL)suspend
{
    [_queue setSuspended:suspend];
    
    if (suspend) {
        _suspended = YES;
    } else {
        _suspended = NO;
    }
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (!_running)
        return;
    
    NSString *type = [request.userInfo valueForKey:@"type"];
    if ([type isEqualToString:@"thumb"]) {
        _thumbgets++;
        MLOG(@"AlbumImageCache: album %llu: requestFinished, thumb: %d of %d", _id, _thumbgets, _thumbrequests);
    } else {
        _screengets++;
        MLOG(@"AlbumImageCache: album %llu: requestFinished, screen: %d of %d", _id, _screengets, _screenrequests);
    }
    
    NSData *responseData = [request responseData];    
    NSString* url = [request.url absoluteString];
    [gZZ cacheImage:url imageData:responseData];
    
    if ([self left]==0)
        _done = YES;
    
    request = nil;
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSError *error = [request error];
    //MLOG(@"AlbumImageCache album %llu: request error: %@", _id, error);
    
    if (!_running)
        return;
    
    // counting as success (TODO *** should retry)
    NSString *type = [request.userInfo valueForKey:@"type"];
    if ([type isEqualToString:@"thumb"]) {
        _thumbgets++;
        //MLOG(@"AlbumImageCache: requestFailed, thumb: %d of %d", _thumbgets, _thumbrequests);
    } else {
        _screengets++;
        //MLOG(@"AlbumImageCache: requestFailed, screen: %d of %d", _screengets, _screenrequests);
    }
    
    request = nil;
}


@end



// -------------------------------------------------------------------------------------------------------------------------
// AlbumSets

@implementation AlbumSets

- (id)init:(ZZUserID)userid
{
    self = [super init];
    if (self) {
        _userid = userid;
        _albuminfourl = [NSString stringWithFormat:@"%@/zz_api/users/%llu/albums", [gZZ serviceURL], _userid];
        _albumsetsinfo = NULL;
        _albumsets = [[NSMutableDictionary alloc] init];
        
        // load cached album set info 
        _albumsetsinfo = (NSDictionary*)[gZZ getObj:_albuminfourl keytype:@"ALBUMSETS"];
    }
    
    return self;
}


-(unsigned long)updated
{
    unsigned long latestupdated = 0;
    
    for (NSString *type in _albumsets) {
        AlbumSet *albumset = [_albumsets objectForKey:type];
        if (albumset.updated > latestupdated )
            latestupdated = albumset.updated;
    }
    
    return latestupdated;
}


-(void)get
{
    // fetch album set info and then 'my', 'like', 'invited' album sets if out of date
    
    /* e.g.,
     {
     "liked_users_albums_path":"/service/users/249900073726/liked_users_public_albums?ver=1313169146",
     "my_albums_path":"/service/users/249900073726/my_albums?ver=1313169146",
     "public":false,
     "liked_albums":1313105815,
     "liked_albums_path":"/service/users/249900073726/liked_albums?ver=1313105815",
     "my_albums":1313169146,
     "session_user_liked_albums_path":null,
     "session_user_liked_albums":null,
     "user_id":249900073726,
     "liked_users_albums":1313169146
     }
     */
    
    // *** also get back 'logged_in_user_id' which should match our logged in user (this would fail if say the user changed his pwd in the webapp, invalidating his authentication 
    
    if (gZZ.networkStatus == NotReachable) {
        
        // setup from cached data
        [self getalbumsets];
        return;
    }
    
    // request album setinfo JSON async
    MLOG(@"Album set info request: %@", _albuminfourl);
    
    _srequest = [ASIHTTPRequest requestWithURL:[[NSURL alloc] initWithString:_albuminfourl]];
    [_srequest setNumberOfTimesToRetryOnTimeout:2];
    [_srequest setTimeOutSeconds:60];
    [_srequest addRequestHeader:@"Accept" value:@"application/json"];
    [_srequest addRequestHeader:@"X-ZangZing-API" value:@"iphone"];
    if ([ZZSession currentSession]) {
        [_srequest setUseCookiePersistence:NO];
        [_srequest setRequestCookies:[NSMutableArray arrayWithObject:[gZZ authCookie]]];
    }
    [_srequest setDelegate:self];
#ifdef DEBUG            
    [_srequest setValidatesSecureCertificate:NO];
#endif

    [_srequest startAsynchronous];
}


-(void)getalbumset:(ZZUserID)userid type:(NSString*)type url:(NSString*)url currentversion:(unsigned long)currentversion
{
    AlbumSet *albumset = (AlbumSet*)[_albumsets objectForKey:type];
    if (!albumset) {
        // initialize albumset
        albumset = [[AlbumSet alloc] init:userid type:type url:url currentversion:currentversion];
        [_albumsets setObject:albumset forKey:type];        
    }
    
    // update AlbumSet if necessary
    BOOL update = [albumset update:currentversion];
    
    if (update) {
        // kill 'all' AlbumSet
        AlbumSet *albumset = (AlbumSet*)[_albumsets objectForKey:@"all"];
        if (albumset) {
            [_albumsets removeObjectForKey:@"all"];
        }
    }
    
    [albumset setVersion:currentversion];
}


-(void)getalbumsets
{
    // get albumset's for 'my', 'liked', 'invited'
    
    NSString *s;
    NSString *sv;
    
    // my
    s = [_albumsetsinfo objectForKey:@"my_albums"];
    sv = [s substringFromIndex:NSMaxRange([s rangeOfString:@"."])];    
    unsigned long myalbumsversion = strtoull([sv UTF8String], NULL, 0);
    NSString *myalbumsurl = [NSString stringWithFormat:@"%@%@", [gZZ serviceURL], [_albumsetsinfo objectForKey:@"my_albums_path"]];
    
    [self getalbumset:_userid type:@"my" url:myalbumsurl currentversion:myalbumsversion];
    
    // liked
    s = [_albumsetsinfo objectForKey:@"liked_albums"];
    sv = [s substringFromIndex:NSMaxRange([s rangeOfString:@"."])];    
    unsigned long likedalbumsversion = strtoull([sv UTF8String], NULL, 0);
    NSString *likedalbumsurl = [NSString stringWithFormat:@"%@%@", [gZZ serviceURL], [_albumsetsinfo objectForKey:@"liked_albums_path"]];
    
    [self getalbumset:_userid type:@"liked" url:likedalbumsurl currentversion:likedalbumsversion];
    
    MLOG(@"myalbumsversion: %lu; likedalbumsversion: %lu",myalbumsversion,likedalbumsversion);
    
    // invited
    s = [_albumsetsinfo objectForKey:@"invited_albums"];
    sv = [s substringFromIndex:NSMaxRange([s rangeOfString:@"."])];    
    unsigned long invitedalbumsversion = strtoull([sv UTF8String], NULL, 0);
    NSString *invitedalbumsurl = [NSString stringWithFormat:@"%@%@", [gZZ serviceURL], [_albumsetsinfo objectForKey:@"invited_albums_path"]];
    
    [self getalbumset:_userid type:@"invited" url:invitedalbumsurl currentversion:invitedalbumsversion];
    
    MLOG(@"myalbumsversion: %lu; likedalbumsversion: %lu; invitedalbumsversion %lu",myalbumsversion,likedalbumsversion, invitedalbumsversion);
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    
    NSObject *data = [ZZGlobal getObjfromJSON: responseData];
    int result = [ZZGlobal responseError:request data:data];
    if (result == 0) {
        _albumsetsinfo = (NSDictionary*)data;
        [gZZ cacheObj:_albuminfourl keytype:@"ALBUMSETS" obj:_albumsetsinfo];
        
        [self getalbumsets];
    }
    
    _srequest = nil;
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    MLOG(@"Album Set Info Request Error: %@", error);
    
    // setup from cached data
    [self getalbumsets];
    
    _srequest = nil;
}


-(BOOL)albumsetloaded: (NSString*)type
{
    AlbumSet *albumset = (AlbumSet*)[_albumsets objectForKey:type];
    if (albumset) {
        NSArray *a = [albumset getalbumset];
        if (a != NULL) {
            return YES;
        }
    }
    else {
        if ([type isEqualToString:@"all"]) {
            if ([self albumsetloaded:@"my"] && [self albumsetloaded:@"liked"] && [self albumsetloaded:@"invited"]) {
                // build 'all' AlbumSet
                
                NSString *allurl = [NSString stringWithFormat:@"all/%llu", _userid];       // url is used as the key; build proper unique key for this user
                albumset = [[AlbumSet alloc] init:_userid type:type url:allurl currentversion:0];
                
                
                NSMutableArray *all = [[NSMutableArray alloc]initWithArray:[self albumset:@"liked"] copyItems:YES];
                
                // now add 'invited' (filter duplicates)
                NSArray* invited = [self albumset:@"invited"];
                for (NSDictionary* invitedAlbum in invited) {
                    NSNumber *ia = [invitedAlbum objectForKey:@"id"];   
                    ZZAlbumID iaid = [ia unsignedLongLongValue];
                    
                    BOOL add = YES;
                    for (NSDictionary* allAlbum in all) {
                        NSNumber *a = [allAlbum objectForKey:@"id"];  
                        ZZAlbumID aid = [a unsignedLongLongValue];
                        if (aid == iaid) {
                            add = NO;
                            break;
                        }
                    }
                    
                    if (add)
                        [all addObject:invitedAlbum];
                }
                
                [all addObjectsFromArray:[self albumset:@"my"]];

                
                [albumset set:all sort:YES];
                
                [_albumsets setObject:albumset forKey:@"all"]; 
                return YES;
            }
        }
    }
    
    return NO;
}


-(NSArray*)albumset: (NSString*)type
{
    AlbumSet *albumset = (AlbumSet*)[_albumsets objectForKey:type];
    if (albumset) {
        return [albumset getalbumset];
    } 
    
    return NULL;
}


-(NSDictionary*)getalbumsetdata:(ZZAlbumID)albumid
{
    for (NSString *type in _albumsets) {
        AlbumSet *albumset = [_albumsets objectForKey:type];
        NSDictionary *data = [albumset getdata:albumid];
        if (data)
            return data;
    }
    
    return NULL;
}


-(ZZSharePermission)sharePermission:(ZZUserID)userid albumid:(ZZAlbumID)albumid
{
    NSDictionary *albumdata = [self getalbumsetdata:albumid];
    
    if (albumdata) {
        NSString *u = [albumdata objectForKey:@"user_id"];
        ZZUserID userid = [u longLongValue];
        if (userid == [ZZSession currentUser].user_id)
            return kShareAsAdmin;
        
        NSString *role = [albumdata objectForKey:@"my_role"];
        if (role && [role isKindOfClass:[NSString class]] && [role isEqualToString:ZZAPI_ALBUM_PERMISSION_CONTRIB])      
            return kShareAsContributor;
        
        NSNumber *all_can_contrib = [albumdata objectForKey:@"all_can_contrib"];
        if (all_can_contrib && [all_can_contrib isKindOfClass:[NSString class]]) {
            BOOL can = [all_can_contrib boolValue];
            if (can)
                return kShareAsContributor;
        }
    }
    
    return kShareAsViewer;
}


-(BOOL)canAdd:(ZZUserID)userid albumid:(ZZAlbumID)albumid
{
    ZZSharePermission perm = [self sharePermission:userid albumid:albumid];
    return (perm != kShareAsViewer);
}


-(NSDictionary*)getAddable
{
    NSArray* albumset = [self albumset:@"my"];
    if (albumset && albumset.count > 0) {
        return [albumset objectAtIndex:0];
    }
    
    return NULL;
}



@end


// -------------------------------------------------------------------------------------------------------------------------
// AlbumSet

@implementation AlbumSet

- (id)init:(ZZUserID)userid type:(NSString*)type url:(NSString*)url currentversion:(unsigned long)currentversion
{
    self = [super init];
    if (self) {
        _userid = userid;
        _type = [[NSString alloc] initWithString:type];
        _url = [[NSString alloc] initWithString:url];
        _version = 0;      // unknown
        
        _albumset = (NSArray*)[gZZ getObj:_url keytype:@"ALBUMSETS"];
        if (_albumset)
            _version = currentversion;      // unknown
    }
    
    return self;
}


NSInteger update_at_DESC_SORT_COMPARER(id a, id b, void *context)
{
    unsigned long v1 = [[a objectForKey:@"updated_at"] unsignedLongValue];
    unsigned long v2 = [[b objectForKey:@"updated_at"] unsignedLongValue];
    
    if (v1 > v2)
        return NSOrderedAscending;
    else if (v1 < v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}


-(void)set:(NSArray*)albumset sort:(BOOL)sort
{
    _albumset = [[NSArray alloc] initWithArray:albumset copyItems:YES];
    if (sort) {
        
        NSArray *sortedArray = [_albumset sortedArrayUsingFunction:update_at_DESC_SORT_COMPARER context:NULL];
        _albumset = [[NSArray alloc] initWithArray:sortedArray copyItems:YES];
    }
}


-(BOOL)update:(unsigned long)currentversion
{
    // return YES if update required
    
    MLOG(@"_version vs. current: %lu %lu",_version,currentversion);
    
    if (_version >= currentversion)
        return NO;
    
    // request album set JSON async
    
    /* e.g.,
     1..n of:
     {
     "id":29900090098,
     "c_url":"http:\/\/1.zz.s3.amazonaws.com\/i\/857342de-60df-43cc-9dfe-d26a15e4a5f1-t?1313897821",
     "photos_ready_count":64,
     "album_path":"\/surfkayak\/contemporaneous",
     "updated_at":1318719240,
     "cache_version":"v4.3901124",
     "photos_count":64,
     "user_id":"249900073747",
     "name":"contemporaneous",
     "user_name":"surfkayak",
     "my_role":"Viewer",
     "profile_album":false
     }
     */
    
    MLOG(@"Album set request: %@", _url);
    _request = [ASIHTTPRequest requestWithURL:[[NSURL alloc] initWithString:_url]];
    [_request setNumberOfTimesToRetryOnTimeout:2];
    [_request setTimeOutSeconds:60];
    [_request addRequestHeader:@"Accept" value:@"application/json"];
    [_request addRequestHeader:@"X-ZangZing-API" value:@"iphone"];
    if ([ZZSession currentSession]) {
        [_request setUseCookiePersistence:NO];
        [_request setRequestCookies:[NSMutableArray arrayWithObject:[gZZ authCookie]]];
    }
    [_request setDelegate:self];
#ifdef DEBUG
    [_request setValidatesSecureCertificate:NO];
#endif
    [_request startAsynchronous];
    
    return YES;
}


- (void)requestFinished:(ASIHTTPRequest*)request
{
    // *** leaking previous cached version; need to track and clean it up
    
    NSData *responseData = [request responseData];
    
    NSObject *data = [ZZGlobal getObjfromJSON: responseData];
    int result = [ZZGlobal responseError:request data:data];
    if (result == 0) {
        _albumset = (NSArray*)data;
        [gZZ cacheObj:_url keytype:@"ALBUMSETS" obj:_albumset];
        
        _updated = [[NSDate date] timeIntervalSince1970];
        
        /*
        // for 'invited' type, filter by 'my_role' as 'Contrib'
        if ([_type isEqualToString:@"invited"]) {
            
            NSMutableArray *newalbumset = [[NSMutableArray alloc] init];
            for (int i=0; i<_albumset.count; i++) {
                NSDictionary *album = [_albumset objectAtIndex:i];
                NSString *role = [album objectForKey:@"my_role"];
                if (role && [role isEqualToString:@"contributor"])
                    [newalbumset addObject:album];
            }
            
            _albumset = newalbumset;
        }
        */
        
        // request user info for all represented users
        for (int i=0; i<_albumset.count; i++) {
            NSDictionary *album = [_albumset objectAtIndex:i];
            NSString *u = [album objectForKey:@"user_id"];
            ZZUserID user_id = [u longLongValue];
            [ZZCache getAndCacheUserWithId: user_id];
        }
    }
    
    _request = nil;
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    MLOG(@"Album Set Request Error: %@", error);
    
    _request = nil;
}


-(NSArray*)getalbumset
{
    return _albumset;
}


-(unsigned long)updated
{
    return _updated;
}

-(void)setVersion: (unsigned long long)version
{
    _version = version;
}


-(NSDictionary*)getdata:(ZZAlbumID)albumid
{
    for (NSDictionary *data in _albumset) {
        NSNumber *a = [data objectForKey:@"id"];        
        if ([a unsignedLongLongValue] == albumid)
            return data;
    }
    
    return NULL;
}

@end






