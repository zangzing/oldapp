//
//

#import "Moment.h"

#ifndef ZZCACHEDEFS
#define ZZCACHEDEFS

#define ZZACTIVITY_CACHEFILE @"Activity.archive"
#define kActivityStaleSeconds 30

#define ZZUSER_CACHEFILE @"User.%llu.archive"
#define kUserStaleSeconds 30

#define ZZALBUMINFO_CACHEFILE @"AlbumInfo.%llu.archive"
#define kAlbumInfoStaleSeconds 30

#define ZZALBUMARRAY_CACHEFILE @"AlbumArray.archive"
#define kAlbumArrayStaleSeconds 30

#define ZZALBUMPHOTOS_CACHEFILE @"AlbumPhotos.%llu.%s.archive"
#define kAlbumPhotosStaleSeconds 30

#endif





@implementation ZZCache

#pragma mark -
#pragma mark Singleton Methods

static NSMutableDictionary *memoryCache;
static NSMutableArray *recentlyAccessedKeys;
static int kCacheMemoryLimit;

static NSMutableDictionary *pendingUserRequests;
static NSMutableDictionary *pendingAlbumPhotosRequests;

+(void) initialize
{
    // Find the cache directory and if it does not exist, create it.
    NSString *cacheDirectory = [ZZCache cacheDirectory];
    if(![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory]){
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:nil];            
    }
    
    // Find out the version of the existing cache if any and compare it to the current app version
    // If they dont match then delete the cache and start from scratch. The user has installed  a new
    // version of the app and the existing data is not compatible
    double lastSavedCacheVersion = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CACHE_VERSION"];
    double currentAppVersion = [[ZZCache appVersion] doubleValue];
    
    if( lastSavedCacheVersion == 0.0f || lastSavedCacheVersion < currentAppVersion){
        [ZZCache clearCache];      
        // save current app version as cache version
        [[NSUserDefaults standardUserDefaults] setDouble:currentAppVersion forKey:@"CACHE_VERSION"];					
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    memoryCache = [[NSMutableDictionary alloc] init];
    recentlyAccessedKeys = [[NSMutableArray alloc] init];
    pendingUserRequests = [[NSMutableDictionary alloc] init];
    
    // we can set this based on the running device and expected cache size
    kCacheMemoryLimit = 10;
    
    // Listen to app backgrounding events to save cache to disk
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self 
                   selector:@selector(saveMemoryCacheToDisk:) 
                       name:UIApplicationDidReceiveMemoryWarningNotification 
                     object:nil];
    
    [notiCenter addObserver:self 
                   selector:@selector(saveMemoryCacheToDisk:) 
                       name:UIApplicationDidEnterBackgroundNotification 
                     object:nil];
    
    [notiCenter addObserver:self 
                   selector:@selector(saveMemoryCacheToDisk:) 
                       name:UIApplicationWillTerminateNotification 
                     object:nil];  
    [notiCenter addObserver:self 
                   selector:@selector(clearCache) 
                       name:@"Logout" 
                     object:nil];  
}

+(void) dealloc
{   
    //Clear the memory cache and keys and unsubscribe from backgroun notifications
    memoryCache = nil;
    recentlyAccessedKeys = nil;
    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    
    [notiCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [notiCenter removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
    [notiCenter removeObserver:self name:@"Logout" object:nil];  

    
}

// Called when we get a backgrounding notification
// save the cache to disk and clear memory
+(void) saveMemoryCacheToDisk:(NSNotification *)notification
{
  for(NSString *filename in [memoryCache allKeys])
  {
    NSString *archivePath = [[ZZCache cacheDirectory] stringByAppendingPathComponent:filename];  
    NSData *cacheData = [memoryCache objectForKey:filename];
    [cacheData writeToFile:archivePath atomically:YES];
  }
  
  [memoryCache removeAllObjects];  
}

// Used to erase the cache when we have a new version of the app
+(void) clearCache
{
  NSArray *cachedItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[ZZCache cacheDirectory] 
                                                      error:nil];
  
  for(NSString *path in cachedItems)
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
  
  [memoryCache removeAllObjects];
  MLOG(@"CacheCleared");
}

//Retrieves the app version from the bundle
+(NSString*) appVersion
{
	CFStringRef versStr = (CFStringRef)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey);
	NSString *version = [NSString stringWithUTF8String:CFStringGetCStringPtr(versStr,kCFStringEncodingMacRoman)];
	return version;
}

//Retrieves the cache directory
+(NSString*) cacheDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *cachesDirectory = [paths objectAtIndex:0];
	return [cachesDirectory stringByAppendingPathComponent:@"ZZCache"];  
}

#pragma mark -
#pragma mark Custom Methods

// Add your custom methods here

+(void) cacheData:(NSData*) data toFile:(NSString*) fileName
{
  [memoryCache setObject:data forKey:fileName];
  if([recentlyAccessedKeys containsObject:fileName])
  {
    [recentlyAccessedKeys removeObject:fileName];
  }

  [recentlyAccessedKeys insertObject:fileName atIndex:0];
  
  if([recentlyAccessedKeys count] > kCacheMemoryLimit)
  {
    NSString *leastRecentlyUsedDataFilename = [recentlyAccessedKeys lastObject];
    NSData *leastRecentlyUsedCacheData = [memoryCache objectForKey:leastRecentlyUsedDataFilename];
    NSString *archivePath = [[ZZCache cacheDirectory] stringByAppendingPathComponent:fileName];  
    [leastRecentlyUsedCacheData writeToFile:archivePath atomically:YES];
    
    [recentlyAccessedKeys removeLastObject];
    [memoryCache removeObjectForKey:leastRecentlyUsedDataFilename];
  }
}

+(NSData*) dataForFile:(NSString*) fileName
{
  NSData *data = [memoryCache objectForKey:fileName];  
  if(data) return data; // data is present in memory cache
    
	NSString *archivePath = [[ZZCache cacheDirectory] stringByAppendingPathComponent:fileName];
  data = [NSData dataWithContentsOfFile:archivePath];
  
  if(data)
    [self cacheData:data toFile:fileName]; // put the recently accessed data to memory cache
  
  return data;
}

+(void) cacheActivity:(NSMutableArray*) activity
{
    [self cacheData:[NSKeyedArchiver archivedDataWithRootObject:activity]
             toFile:ZZACTIVITY_CACHEFILE];  
}

#pragma mark -
#pragma mark  Activity

+(NSMutableArray*) getCachedActivity
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[self dataForFile:ZZACTIVITY_CACHEFILE]];
}

+(BOOL) isActivityStale
{
    // if it is in memory cache, it is not stale
    if([recentlyAccessedKeys containsObject:ZZACTIVITY_CACHEFILE])
        return NO;
    
    // if it was saved more than lM
	NSString *archivePath = [[ZZCache cacheDirectory] stringByAppendingPathComponent:ZZACTIVITY_CACHEFILE];  
    NSTimeInterval stalenessLevel = [[[[NSFileManager defaultManager] attributesOfItemAtPath:archivePath error:nil] fileModificationDate] timeIntervalSinceNow];
    
    return stalenessLevel > kActivityStaleSeconds;
}
#pragma mark -
#pragma mark Users
+(NSString *)cacheFileNameForUser:(ZZUserID)user_id
{
    return [NSString stringWithFormat:ZZUSER_CACHEFILE, user_id];
}


+(void) getAndCacheUserWithId:(ZZUserID)user_id
{
    
    ZZUser *cachedUser = [ZZCache getCachedUser:user_id];
    
    //If the user is not in the cache and if the user is not stale and
    // if we do not have a request pending for the user. Then go get it.
    if( !cachedUser || [ZZCache isUserStale:cachedUser ] ){
        NSNumber *userIdNumber = [NSNumber numberWithUnsignedLongLong:user_id];
        if (![pendingUserRequests objectForKey:userIdNumber]) {
            [pendingUserRequests setObject:userIdNumber forKey:userIdNumber];
            
            [[ZZAPIClient sharedClient] getUserWithId:user_id 
                                              success:^(ZZUser *user){   
                                                  [ZZCache cacheUser: user]; 
                                                  [pendingUserRequests removeObjectForKey:userIdNumber];
                                              } 
                                              failure:^(NSError *error){ 
                                                  MLOG(@"Error getting user with id=%llu : %@",user_id, error);
                                                  [pendingUserRequests removeObjectForKey:userIdNumber];
                                              }];
        }
    }
}

+(void) cacheUser:(ZZUser *) user
{
    [self cacheData:[NSKeyedArchiver archivedDataWithRootObject:user]
             toFile:[ZZCache cacheFileNameForUser:user.user_id]];  
}

+(ZZUser *)getCachedUser:(ZZUserID)user_id
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[self dataForFile:[ZZCache cacheFileNameForUser:user_id]]];
}

+(BOOL) isUserStale:(ZZUser *)user
{
    // if it is in memory cache, it is not stale
    NSString * userCacheFile = [ZZCache cacheFileNameForUser:user.user_id];
    if([recentlyAccessedKeys containsObject:userCacheFile])
        return NO;
    
    // if it was saved more than lM
	NSString *archivePath = [[ZZCache cacheDirectory] stringByAppendingPathComponent:userCacheFile];  
    NSTimeInterval stalenessLevel = [[[[NSFileManager defaultManager] attributesOfItemAtPath:archivePath error:nil] fileModificationDate] timeIntervalSinceNow];
    
    return stalenessLevel > kUserStaleSeconds;
}

#pragma mark -
#pragma mark AlbumInfo
+(NSString *)cacheFileNameForAlbumInfo:(ZZUserID)user_id
{
    return [NSString stringWithFormat:ZZUSER_CACHEFILE, user_id];
}
+(void) cacheAlbumInfo:(ZZAlbumInfo *) albumInfo
{
    [self cacheData:[NSKeyedArchiver archivedDataWithRootObject:albumInfo]
             toFile:[ZZCache cacheFileNameForUser:albumInfo.user_id]];  
}
+(ZZAlbumInfo *)getCachedAlbumInfoForUser:(ZZUser *)user
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[self dataForFile:[ZZCache cacheFileNameForUser:user.user_id]]];
}

+(BOOL) isAlbumInfoStale:(ZZAlbumInfo *)albumInfo
{
    // if it is in memory cache, it is not stale
    NSString * albumInfoCacheFile = [ZZCache cacheFileNameForAlbumInfo:albumInfo.user_id];
    if([recentlyAccessedKeys containsObject:albumInfoCacheFile])
        return NO;
    
    // if it was saved more than lM
	NSString *archivePath = [[ZZCache cacheDirectory] stringByAppendingPathComponent:albumInfoCacheFile];  
    NSTimeInterval stalenessLevel = [[[[NSFileManager defaultManager] attributesOfItemAtPath:archivePath error:nil] fileModificationDate] timeIntervalSinceNow];
    
    return stalenessLevel > kAlbumInfoStaleSeconds;
}
#pragma mark -
#pragma mark AlbumSet
//+(NSMutableArray*) getCachedAlbumArray
//{
//    return [NSKeyedUnarchiver unarchiveObjectWithData:[self dataForFile:ZZACTIVITY_CACHEFILE]];
//}
//
//+(BOOL) isActivityStale
//{
//    // if it is in memory cache, it is not stale
//    if([recentlyAccessedKeys containsObject:ZZACTIVITY_CACHEFILE])
//        return NO;
//    
//    // if it was saved more than lM
//	NSString *archivePath = [[ZZCache cacheDirectory] stringByAppendingPathComponent:ZZACTIVITY_CACHEFILE];  
//    NSTimeInterval stalenessLevel = [[[[NSFileManager defaultManager] attributesOfItemAtPath:archivePath error:nil] fileModificationDate] timeIntervalSinceNow];
//    
//    return stalenessLevel > kActivityStaleSeconds;
//}
#pragma mark -
#pragma mark Photos

+(NSString *)cacheFileNameForAlbumPhotos:(ZZAlbum *)album
{
    return [NSString stringWithFormat:ZZALBUMPHOTOS_CACHEFILE, album.album_id, album.cache_version];
}


+(void) getAndCacheAlbumPhotos:(ZZAlbum *)album
{
    
    NSMutableArray *cachedAlbumPhotos = [ZZCache getCachedAlbumPhotos:album];
    
    //If the user is not in the cache and if the user is not stale and
    // if we do not have a request pending for the user. Then go get it.
    if( !cachedAlbumPhotos || [ZZCache isAlbumPhotosStale:album] ){
        NSNumber *albumIdNumber = [NSNumber numberWithUnsignedLongLong:album.album_id];
        if (![pendingAlbumPhotosRequests objectForKey:albumIdNumber]) {
            [pendingAlbumPhotosRequests setObject:albumIdNumber forKey:albumIdNumber];
            
            [[ZZAPIClient sharedClient] getAlbumPhotosForAlbum:album 
                                                success:^(NSMutableArray *albumPhotos){   
                                                    album.photos = albumPhotos;
                                                    [ZZCache cacheAlbumPhotos:album]; 
                                                    [pendingAlbumPhotosRequests removeObjectForKey:albumIdNumber];
                                              } 
                                              failure:^(NSError *error){ 
                                                MLOG(@"Error getting AlbumPhotos for Album with id=%llu : %@",album.album_id, error);
                                                [pendingAlbumPhotosRequests removeObjectForKey:albumIdNumber];
                                              }];
        }
    } else {
        album.photos = cachedAlbumPhotos;
    }
    
}

+(void) cacheAlbumPhotos:(ZZAlbum *)album
{
    [self cacheData:[NSKeyedArchiver archivedDataWithRootObject:album.photos]
             toFile:[ZZCache cacheFileNameForAlbumPhotos:album]];  
}

+(NSMutableArray *)getCachedAlbumPhotos:(ZZAlbum *)album
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:[self dataForFile:[ZZCache cacheFileNameForAlbumPhotos:album]]];
}

+(BOOL) isAlbumPhotosStale:(ZZAlbum *)album
{
    // if it is in memory cache, it is not stale
    NSString * albumPhotosCacheFile = [ZZCache cacheFileNameForAlbumPhotos:album];
    if([recentlyAccessedKeys containsObject:albumPhotosCacheFile])
        return NO;
    
    // if it was saved more than lM
	NSString *archivePath = [[ZZCache cacheDirectory] stringByAppendingPathComponent:albumPhotosCacheFile];  
    NSTimeInterval stalenessLevel = [[[[NSFileManager defaultManager] attributesOfItemAtPath:archivePath error:nil] fileModificationDate] timeIntervalSinceNow];
    
    return stalenessLevel > kAlbumPhotosStaleSeconds;
}
#pragma mark -



//+(void) cacheMenuItems:(NSMutableArray*) menuItems
//{
//  [self cacheData:[NSKeyedArchiver archivedDataWithRootObject:menuItems]
//           toFile:@"MenuItems.archive"];  
//}
//
//+(NSMutableArray*) getCachedMenuItems
//{
//  return [NSKeyedUnarchiver unarchiveObjectWithData:[self dataForFile:@"MenuItems.archive"]];
//}
//
//+(BOOL) isMenuItemsStale
//{
//  // if it is in memory cache, it is not stale
//  if([recentlyAccessedKeys containsObject:@"MenuItems.archive"])
//    return NO;
//  
//	NSString *archivePath = [[ZZCache cacheDirectory] stringByAppendingPathComponent:@"MenuItems.archive"];  
//  
//  NSTimeInterval stalenessLevel = [[[[NSFileManager defaultManager] attributesOfItemAtPath:archivePath error:nil] fileModificationDate] timeIntervalSinceNow];
//  
//  return stalenessLevel > kMenuStaleSeconds;
//}
@end
