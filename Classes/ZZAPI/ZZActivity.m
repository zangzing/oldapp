//
//  ZZActivity.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/5/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZActivity.h"

#import "ZZCAche.h"


@implementation ZZActivity

@synthesize created_at;
@synthesize kind;
@synthesize by_user_id;
@synthesize photo_id;
@synthesize like_count;
@synthesize photo;

-(id) initWithDictionary:(NSDictionary*) serverJson
{
    self = [super initWithDictionary:serverJson];
    if( self ){
        photo = [[ZZPhoto alloc] initWithDictionary:serverJson];
        [ZZCache getAndCacheUserWithId:by_user_id];
    }
    return self;
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if([key isEqualToString:@"id"]){
        photo_id = [value unsignedLongLongValue];        
    }else [super setValue:value forUndefinedKey:key];
}


- (id) initWithCoder:(NSCoder *)decoder
{	
    self = [super init ];
    if( self ){
        created_at       = [decoder decodeObjectForKey:@"created_at"];
        kind             = [decoder decodeObjectForKey:@"kind"];
        by_user_id       = [[decoder decodeObjectForKey:@"by_user_id"] unsignedLongLongValue];
        photo_id         = [[decoder decodeObjectForKey:@"server"] unsignedLongLongValue];
        photo            = [decoder decodeObjectForKey:@"photo"];
        like_count       = [decoder decodeObjectForKey:@"like_count"];
        [ZZCache getAndCacheUserWithId:by_user_id];  
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:created_at forKey:@"created_at"];
    [encoder encodeObject:kind forKey:@"kind"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:by_user_id] forKey:@"by_user_id"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong:photo_id]  forKey:@"photo_id"];
    [encoder encodeObject:photo forKey:@"photo"];
    [encoder encodeObject:like_count forKey:@"like_count"];
}

@end
