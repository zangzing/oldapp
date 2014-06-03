//
//  ZZAlbumSet.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "Moment.h"

@implementation ZZAlbumSet

@synthesize user_id;
@synthesize version;
@synthesize album_array;
@synthesize last_updated;

-(id) initWithUserID:(ZZUserID)puser_id version:(NSString *)pversion album_array:(NSMutableArray *)palbum_array 
{
    self = [super init];
    if( self) {
        user_id         = puser_id;
        version         = pversion;
        album_array     = palbum_array;
        last_updated    = [NSDate date];
        return self;
    }
    return NULL;
}

#pragma mark - NSCoding protocol
- (id) initWithCoder:(NSCoder *)decoder
{	
    self = [super init ];
    if( self ){
        user_id             = [[decoder decodeObjectForKey:@"user_id"] unsignedLongLongValue];
        version             = [decoder decodeObjectForKey:@"version"];
        album_array         = [decoder decodeObjectForKey:@"album_array"];
        last_updated        = [decoder decodeObjectForKey:@"last_updated"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:user_id] forKey:@"user_id"];
    [encoder encodeObject:version forKey:@"version"];
    [encoder encodeObject:album_array forKey:@"album_array"];
    [encoder encodeObject:last_updated forKey:@"last_updated"];
} 
@end
