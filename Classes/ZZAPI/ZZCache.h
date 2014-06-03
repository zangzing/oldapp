

#import <Foundation/Foundation.h>
#import "ZZAPI.h"
#import "ZZUser.h"

@interface ZZCache : NSObject 

+(NSString*) cacheDirectory;
+(void) clearCache;
+(NSString*) appVersion;

+(void) cacheActivity:(NSMutableArray*) activity;
+(NSMutableArray*) getCachedActivity;
+(BOOL) isActivityStale;

+(void) cacheUser:(ZZUser *) user;
+(ZZUser *)getCachedUser:(ZZUserID)user_id;
+(BOOL) isUserStale:(ZZUser *)user;
+(void) getAndCacheUserWithId:(ZZUserID)user_id;

+(void) cacheAlbumInfo:(ZZAlbumInfo *) albumInfo;
+(ZZAlbumInfo *)getCachedAlbumInfoForUser:(ZZUser *)user;
+(BOOL) isAlbumInfoStale:(ZZAlbumInfo *)albumInfo;

@end
