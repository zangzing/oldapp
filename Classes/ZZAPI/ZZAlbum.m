//
//  ZZAlbum.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/30/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//


#import "Moment.h"
//#import "PhotoBrowser.h"

NSString * const kAlbumPrivacyTypeArray[]={
    ZZAPI_ALBUM_PUBLIC,
    ZZAPI_ALBUM_HIDDEN,
    ZZAPI_ALBUM_PASSWORD,
};

NSString * const kAlbumWhoOptionTypeArray[]={
    ZZAPI_ALBUM_EVERYONE,
    ZZAPI_ALBUM_VIEWERS,
    ZZAPI_ALBUM_CONTRIBUTORS,
    ZZAPI_ALBUM_OWNER 
};

@implementation ZZAlbum

@synthesize album_id;
@synthesize name; 
@synthesize email;
@synthesize user_name; 
@synthesize user_id;
@synthesize album_path; 
@synthesize profile_album;
@synthesize c_url;
@synthesize cover_id;
@synthesize cover_base;
@synthesize cover_sizes;        //SPECIAL CASE MAPPING
@synthesize cover_date;
@synthesize photos_count;
@synthesize photos_ready_count;
@synthesize cache_version;
@synthesize updated_at;
@synthesize my_role;
@synthesize privacy;            //SPECIAL CASE MAPPING
@synthesize all_can_contrib;
@synthesize who_can_download;     //SPECIAL CASE MAPPING
@synthesize who_can_upload;       //SPECIAL CASE MAPPING
@synthesize who_can_buy;          //SPECIAL CASE MAPPING
@synthesize stream_to_facebook;
@synthesize stream_to_email;
@synthesize photos;


-(void) setValue:(id)value forKey:(NSString *)key
{
    if([key isEqualToString:@"privacy"]){
        privacy = [ZZAlbum stringToAlbumPrivacy: value];
    } else if([key isEqualToString:@"who_can_download"]){
        who_can_download = [ZZAlbum stringToAlbumWhoOption:value];
    } else if([key isEqualToString:@"who_can_upload"]){
        who_can_upload = [ZZAlbum stringToAlbumWhoOption:value];
    } else if([key isEqualToString:@"who_can_buy"]){
        who_can_buy = [ZZAlbum stringToAlbumWhoOption:value];
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if([key isEqualToString:@"id"]){
        album_id = [value unsignedLongLongValue];        
    }else{
        [super setValue:value forUndefinedKey:key];
    }
}


- (id) initWithCoder:(NSCoder *)decoder
{	
    self = [super init ];
    if( self ){
        album_id            = [[decoder decodeObjectForKey:@"album_id"] unsignedLongLongValue];
        name                = [decoder decodeObjectForKey:@"name"]; 
        email               = [decoder decodeObjectForKey:@"email"];
        user_name           = [decoder decodeObjectForKey:@"user_name"];
        user_id             = [[decoder decodeObjectForKey:@"user_id"] unsignedLongLongValue];
        album_path          = [decoder decodeObjectForKey:@"album_path"];
        profile_album       = [[decoder decodeObjectForKey:@"profile_album"] boolValue];
        c_url               = [decoder decodeObjectForKey:@"c_url"];
        cover_id            = [[decoder decodeObjectForKey:@"cover_id"] unsignedLongLongValue];
        cover_base          = [decoder decodeObjectForKey:@"cover_base"];
        cover_sizes         = [decoder decodeObjectForKey:@"cover_sizes"];   //SPECIAL CASE MAPPING MAYBE (Its a Dict)
        cover_date          = [decoder decodeObjectForKey:@"cover_date"];
        photos_count        = [decoder decodeObjectForKey:@"photos_count"];
        photos_ready_count  = [decoder decodeObjectForKey:@"photos_ready_count"];
        cache_version       = [decoder decodeObjectForKey:@"cache_version"];
        updated_at          = [decoder decodeObjectForKey:@"updated_at"];
        my_role             = [decoder decodeObjectForKey:@"my_role"];
        privacy             = (ZZAPIAlbumPrivacy) [[decoder decodeObjectForKey:@"privacy"] intValue];//SPECIAL CASE MAPPING
        all_can_contrib     = [[decoder decodeObjectForKey:@"all_can_contrib"] boolValue];
        who_can_download    = (ZZAPIAlbumPrivacy) [[decoder decodeObjectForKey:@"who_can_download"] intValue];//SPECIAL CASE MAPPING
        who_can_upload      = (ZZAPIAlbumPrivacy) [[decoder decodeObjectForKey:@"who_can_upload"] intValue];//SPECIAL CASE MAPPING
        who_can_buy         = (ZZAPIAlbumPrivacy) [[decoder decodeObjectForKey:@"who_can_buy"] intValue];//SPECIAL CASE MAPPING
        stream_to_facebook  = [[decoder decodeObjectForKey:@"stream_to_facebook"] boolValue];
        stream_to_email     = [[decoder decodeObjectForKey:@"stream_to_facebook"] boolValue];
        [ZZCache getAndCacheUserWithId:user_id];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject: [NSNumber numberWithUnsignedLongLong:album_id] forKey:@"album_id"];
    [encoder encodeObject: name forKey:@"name"]; 
    [encoder encodeObject: email forKey:@"email"];
    [encoder encodeObject: user_name forKey:@"user_name"];
    [encoder encodeObject: [NSNumber numberWithUnsignedLongLong:user_id] forKey:@"user_id"];
    [encoder encodeObject: album_path forKey:@"album_path"];
    [encoder encodeObject: [NSNumber numberWithBool:profile_album] forKey:@"profile_album"];
    [encoder encodeObject: c_url forKey:@"c_url"];
    [encoder encodeObject: [NSNumber numberWithUnsignedLongLong:cover_id] forKey:@"cover_id"];
    [encoder encodeObject: cover_base forKey:@"cover_base"];
    [encoder encodeObject: cover_sizes forKey:@"cover_sizes"];        //SPECIAL CASE MAPPING MAYBE (Its a Dict)
    [encoder encodeObject: cover_date forKey:@"cover_date"];
    [encoder encodeObject: photos_count forKey:@"photos_count"];
    [encoder encodeObject: photos_ready_count forKey:@"photos_ready_count"];
    [encoder encodeObject: cache_version forKey:@"cache_version"];
    [encoder encodeObject: updated_at forKey:@"updated_at"];
    [encoder encodeObject: my_role forKey:@"my_role"];
    [encoder encodeObject: [NSNumber numberWithInt:privacy] forKey:@"privacy"];            //SPECIAL CASE MAPPING
    [encoder encodeObject: [NSNumber numberWithBool:all_can_contrib] forKey:@"all_can_contrib"];
    [encoder encodeObject: [NSNumber numberWithInt:who_can_download] forKey:@"who_can_download"];//SPCIAL CASE MAPPING
    [encoder encodeObject: [NSNumber numberWithInt:who_can_upload] forKey:@"who_can_upload"];//SPECIAL CASE MAPPING
    [encoder encodeObject: [NSNumber numberWithInt:who_can_buy] forKey:@"who_can_buy"];//SPECIAL CASE MAPPING
    [encoder encodeObject: [NSNumber numberWithBool:stream_to_facebook] forKey:@"stream_to_facebook"];
    [encoder encodeObject: [NSNumber numberWithBool:stream_to_email] forKey:@"stream_to_facebook"];
    [encoder encodeObject: photos forKey:@"photos"];
}



// create a new album
//
// The zz_api create album method.  Creates a new album
// tied to the current user.
//
// This is called as (POST):
//
// /zz_api/users/albums/create
//
// Where :user_id is derived from your current account session.
//
// the expected parameters are (items marked with * are the defaults):
//
// {
//  :name => the album name
//  :privacy => the album privacy can be (public*, hidden, password)
//  :who_can_download => who is allowed to download (everyone*,viewers,contributors,owner)
//  :who_can_upload => who is allowed to upload (everyone,viewers,contributors*,owner)
//  :who_can_buy => who is allowed to buy (everyone*,viewers,contributors,owner)
// }
//
+(ZZAlbum *) albumWithName:(NSString *)name 
                   privacy:(ZZAPIAlbumPrivacy)privacy 
         facebookStreaming:(BOOL)facebookStreaming
         twitterStreaming:(BOOL)twitterStreaming
         whoCanDownload:(ZZAPIAlbumWhoOption)whoCanDownload 
              whoCanUpload:(ZZAPIAlbumWhoOption)whoCanUpload 
                 whoCanBuy:(ZZAPIAlbumWhoOption) whoCanBuy 
                     error:(NSError **)anError
{   
//    ZZAlbum *emptyAlbum = [ZZAlbum alloc]; //only used to access instance methods
//    
//    // create the request body 
//    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
//    [body setValue: name                                             forKey: @"name"];
//    [body setValue: [NSNumber numberWithBool: facebookStreaming]     forKey: @"stream_to_facebook"];   
//    [body setValue: [NSNumber numberWithBool: twitterStreaming]      forKey: @"stream_to_twitter"];   
//    [body setValue: [ZZAlbum albumPrivacyToString: privacy]          forKey: @"privacy"];
//    [body setValue: [ZZAlbum albumWhoOptionToString: whoCanDownload] forKey: @"who_can_download"];
//    [body setValue: [ZZAlbum albumWhoOptionToString: whoCanUpload]   forKey: @"who_can_upload"];
//    [body setValue: [ZZAlbum albumWhoOptionToString: whoCanBuy]      forKey: @"who_can_buy"];
//    
//    //create and send the request synchronously
//    ASIHTTPRequest *request = [emptyAlbum createPOSTRequest:[emptyAlbum createURL:ZZAPI_ALBUM_CREATE_URL ssl:NO] body:body];    
//    [request startSynchronous];
//    
//    int result = [emptyAlbum decodeRequestStatus:request message:@" ZZAlbum initWithName"];
//    if (result == ZZAPI_SUCCESS ){
//        NSDictionary * serverHash = [emptyAlbum decodeRequestResponseAsDictionary:request message:@" ZZAlbum initWithName"];
//        if( serverHash ){
//            return [[ZZAlbum alloc] initWithNSDictionary:serverHash];    
//        }
//    }
//    
//    //Creation failed, pass the error back out
//    *anError = emptyAlbum.lastCallError;
//    if( [*anError code] == 409 ){ //duplicate name
//        NSString *desc = @"Check the Name";
//        NSString *reason =  @"You already have an album with that name. Please use a different name.";
//        NSArray *objArray = [NSArray arrayWithObjects: desc, reason, *anError, nil];
//        NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,NSLocalizedFailureReasonErrorKey,NSUnderlyingErrorKey, nil];
//        NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];            
//        *anError = [[NSError alloc] initWithDomain:ZZAPIJSONErrorDomain code:ZZAPI_ERROR userInfo:eDict];  
//    }
    return NULL;
}


// Utility method to convert an album
// whoOption into a string designed for UI consumption
+ (NSString*) albumWhoOptionToDisplayString:(ZZAPIAlbumWhoOption)whoOption
{
    switch(whoOption) {
        case kEveryone:
            return @"Everyone";
        case kViewers:
            return @"Group";
        case kContributors:
            return @"Group";
        case kOwner:
            return @"No one";
        default:
            [NSException raise:NSGenericException format:@"Unexpected ZZAPIAlbumWhoOption."];
    }    
}

// Utility method to conver an album whooption
// into a string value to be sent to the server
// The server expected values are strings not ints
+ (NSString*) albumWhoOptionToString:(ZZAPIAlbumWhoOption)whoOption
{
    switch(whoOption) {
        case kEveryone:
            return ZZAPI_ALBUM_EVERYONE;
        case kViewers:
            return ZZAPI_ALBUM_VIEWERS;
        case kContributors:
            return ZZAPI_ALBUM_CONTRIBUTORS;
        case kOwner:
            return ZZAPI_ALBUM_OWNER;
        default:
            [NSException raise:NSGenericException format:@"Unexpected ZZAPIAlbumWhoOption."];
    }    
}

// Utility method to conver a who server string into an who  enum
+ (ZZAPIAlbumWhoOption) stringToAlbumWhoOption:(NSString*)albumWhoOptionStr
{
    for(int i=0; i < sizeof(kAlbumWhoOptionTypeArray)-1; i++)
    {
        if([(NSString*)kAlbumWhoOptionTypeArray[i] isEqual:albumWhoOptionStr])
        {
            return (ZZAPIAlbumWhoOption) i;
        }
    }
    [NSException raise:NSGenericException format:@"Unexpected String %@, unable to convert into ZZAPIAlbumWhoOption.", albumWhoOptionStr];
    return -1;
}


// Utility method to conver an album privacy enum
// into a string to be sent to the server
// the server expects privacy options to be sent as strings
+ (NSString*) albumPrivacyToString:(ZZAPIAlbumPrivacy)privacy
{
    return kAlbumPrivacyTypeArray[privacy];
}

// Utility method to conver a server string into an album privacy enum
+ (ZZAPIAlbumPrivacy) stringToAlbumPrivacy:(NSString*)privacyStr
{
    for(int i=0; i < sizeof(kAlbumPrivacyTypeArray)-1; i++)
    {
        if([(NSString*)kAlbumPrivacyTypeArray[i] isEqual:privacyStr])
        {
            return (ZZAPIAlbumPrivacy) i;
        }
    }
    [NSException raise:NSGenericException format:@"Unexpected String %@, unable to convert into ZZAPIAlbumPrivacy.", privacyStr];
    return -1;
}

//# Add members to the share
//#
//# This is called as (POST):
//#
//# /zz_api/albums/:album_id/add_sharing_members
//#
//# You must have an album admin role as determined by the current logged in users rights.
//#
//# Returns the sharing members as in sharing members.
//#
//# Input:
//#
//# {
//#   :emails => [...] an array of emails to add
//#   :group_ids => [...] optional array of group ids to add (must belong to this user or be wrapped users)
//#   :message => the message to send (set to nil if you don't want a message)
//#   :permission => the role for this set of users contributor/viewer
//# }
//#
//# Output will differ based on if you are passing in group_ids or not.  If you set
//# the group_id attribute even if it is an empty array we use the groups info model
//# to return the results.
//#
//# If groups_id is missing, we assume backwards compatability
//# mode and return results the form:
//# [
//# {
//#      :id => group_id,
//#      :name => name,
//#      :permission => permission,
//#      :profile_photo_url => profile_photo
//#  }
//#  ...
//#  ]
//#
//# if group_ids is set indicating new api style we return the form as in zz_api_sharing_members api call
//# as:
//# [
//#   {
//#     groups api info attributes for each group as in zz_api_info method of groups controller
//#     :permission => 'contributor' or 'viewer'    # this attribute is added in to each group
//#   }
//# ...
//# ]
//#
//#
//# On Error:
//# If we have a list validation error with either the emails or group_ids we collect the items that were
//# in error into a list for each type and raise an exception. The exception will be returned to the client
//# as json in the standard error format.  The code will be INVALID_LIST_ARGS (1001) and the
//# result part of the error will contain:
//#
//# {
//#   :emails => [
//#     {
//#       :index => the index in the corresponding input list location,
//#       :token => the invalid email,
//#       :error => an error string
//#     }
//#     ...
//#   ],
//#   :group_ids => [
//#     {
//#       :index => the index in the corresponding input list location,
//#       :token => the missing group_id,
//#       :error => an error string, may be blank
//#     }
//#     ...
//#   ]
//# }
//#


-(BOOL)photosLoaded
{
    return (photos == nil);
}


- (ZZPhoto *)getPhotoByIndex:(int)index
{    
    if(!photos)
        return NULL;
    
    if (index < 1 || index > [photos_count intValue] )
        return NULL;
    
    return (ZZPhoto *)[photos objectAtIndex:index];
}


//- (ZZUIImageView*)getGridUIImageByIndex: (int)index
//{
//    if( !photos )
//        return NULL;
//    
//    ZZPhoto *photo = [self getPhotoByIndex:index ];
//    if( photo ){
//        return [photo toGridZUIImageView];
//    }
//    return NULL;
//}
//
//
//- (ZZUIImageView*)getScreenUIImageByIndex:(int)index
//{
//    ZZPhoto *photo = [self getPhotoByIndex:index ];
//    if (photo) {        
//        return [photo toZZUIImageView];
//    }
//    
//    return NULL;
//}


-(NSArray*)getScreenUIImages
{
    if( !photos )
        return NULL;
    NSMutableArray* uiImages = [[NSMutableArray alloc] init];
    
    ZZPhoto *photo;
    for(photo in photos){
        if (photo) {
            if( photo.is_ready ) {
                NSLog(@"getScreenPhotos url: %@", photo.screen_url);
                //[uiImages addObject:[BrowsePhoto photoWithURL:[NSURL URLWithString:photo.screen_url]]];
            } else {
                // for other states e.g., 'assigned', photo has been created (somewhere) but not uploaded/processed
                // test to see if the photo is ours (agent_id matches our UID)
                // if yes, grab the source_guid (aka the photo key) and see if there is a upload image available to substitute
                
//                NSString *agent_id = photo.agent_id;
//                NSString *source_guid = photo.source_guid;
//                
//                if (agent_id && [agent_id isKindOfClass:[NSString class]]) {                    // not NSNull
//                    if ([agent_id isEqualToString:[OpenUDID value]]) {
//                        // this photo is ours, if photo is in the upload queue, grab local file
//                        if (source_guid && [source_guid isKindOfClass:[NSString class]]) {      // not NSNull
//                            
//                            NSString *fpath = [gZZ uploadQueuePathForKey:source_guid];
//                            NSLog(@"getScreenPhotos file: %@", fpath);
//                            [uiImages addObject:[BrowsePhoto photoWithFilePath:fpath]];
//                        }
//                    }
//                }
            }
        }
    }
    
    return uiImages;
}

@end
