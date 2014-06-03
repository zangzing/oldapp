//
//  ZZAlbumInfo.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZAlbumInfo.h"

@implementation ZZAlbumInfo

@synthesize user_id;
@synthesize logged_in_user_id;
@synthesize my_albums;
@synthesize my_albums_path;
@synthesize liked_albums;
@synthesize liked_albums_path;
@synthesize liked_users_albums;
@synthesize liked_users_albums_path;
@synthesize session_user_liked_albums;
@synthesize session_user_liked_albums_path;
@synthesize invited_albums;
@synthesize invited_albums_path;
@synthesize session_user_invited_albums;
@synthesize session_user_invited_albums_path;


-(void) setValue:(id)value forKey:(NSString *)key
{
    if([key isEqualToString:@"user_id"]){
        user_id = [value unsignedLongLongValue];
    }else if([key isEqualToString:@"logged_in_user_id"]){
        logged_in_user_id = [value unsignedLongLongValue];
    } else {
        [super setValue:value forKey:key];
    }
}

#pragma mark - NSCoding protocol
- (id) initWithCoder:(NSCoder *)decoder
{	
    self = [super init ];
    if( self ){
        user_id             = [[decoder decodeObjectForKey:@"user_id"] unsignedLongLongValue];
        logged_in_user_id   = [[decoder decodeObjectForKey:@"logged_in_user_id"] unsignedLongLongValue];
        my_albums = [decoder decodeObjectForKey:@"my_albums"];
        my_albums_path= [decoder decodeObjectForKey:@"my_albums_path"];
        liked_albums = [decoder decodeObjectForKey:@"liked_albums"];
        liked_albums_path= [decoder decodeObjectForKey:@"liked_albums_path"];
        liked_users_albums= [decoder decodeObjectForKey:@"liked_users_albums"];
        liked_users_albums_path= [decoder decodeObjectForKey:@"liked_users_albums_path"];
        session_user_liked_albums= [decoder decodeObjectForKey:@"session_user_liked_albums"];
        session_user_liked_albums_path= [decoder decodeObjectForKey:@"session_user_liked_albums_path"];
        invited_albums= [decoder decodeObjectForKey:@"invited_albums"];
        invited_albums_path= [decoder decodeObjectForKey:@"invited_albums_path"];
        session_user_invited_albums= [decoder decodeObjectForKey:@"session_user_invited_albums"];
        session_user_invited_albums_path= [decoder decodeObjectForKey:@"session_user_invited_albums_path"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:user_id] forKey:@"user_id"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:logged_in_user_id] forKey:@"logged_in_user_id"];
    [encoder encodeObject:my_albums forKey:@"my_albums"];
    [encoder encodeObject:my_albums_path forKey:@"my_albums_path"];
    [encoder encodeObject:liked_albums forKey:@"liked_albums"];
    [encoder encodeObject:liked_albums_path forKey:@"liked_albums_path"];
    [encoder encodeObject:liked_users_albums forKey:@"liked_users_albums"];
    [encoder encodeObject:liked_users_albums_path forKey:@"liked_users_albums_path"];
    [encoder encodeObject:session_user_liked_albums forKey:@"session_user_liked_albums"];
    [encoder encodeObject:session_user_liked_albums_path forKey:@"session_user_liked_albums_path"];
    [encoder encodeObject:invited_albums forKey:@"invited_albums"];
    [encoder encodeObject:invited_albums_path forKey:@"invited_albums_path"];
    [encoder encodeObject:session_user_invited_albums forKey:@"session_user_invited_albums"];
    [encoder encodeObject:session_user_invited_albums_path forKey:@"session_user_invited_albums_path"];
} 
#pragma mark -

@end
