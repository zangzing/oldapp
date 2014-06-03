//
//  ZZPhoto.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/20/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "Moment.h"


@implementation ZZPhoto


@synthesize photo_id;
@synthesize agent_id;
@synthesize caption;
@synthesize state;
@synthesize rotate_to;
@synthesize source_guid;
@synthesize upload_batch_id;
@synthesize user_id;
@synthesize aspect_ratio;
@synthesize stamp_url;
@synthesize thumb_url;
@synthesize screen_url;
@synthesize full_screen_url;
@synthesize photo_base;
@synthesize photo_sizes;
@synthesize width;
@synthesize height;
@synthesize rotated_width;
@synthesize rotated_height;
@synthesize capture_date;
@synthesize created_at;


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if([key isEqualToString:@"id"]){
        photo_id = value;        
    }else [super setValue:value forUndefinedKey:key];
}


- (id) initWithCoder:(NSCoder *)decoder
{	
    self = [super init ];
    if( self ){
        photo_id        = [decoder decodeObjectForKey:@"photo_id"];
        agent_id        = [decoder decodeObjectForKey:@"agent_id"];
        caption         = [decoder decodeObjectForKey:@"caption"];
        state           = [decoder decodeObjectForKey:@"state"];
        rotate_to       = [decoder decodeObjectForKey:@"rotate_to"];
        source_guid     = [decoder decodeObjectForKey:@"source_guid"];
        upload_batch_id = [decoder decodeObjectForKey:@"upload_batch_id"];
        user_id         = (ZZUserID) [[decoder decodeObjectForKey:@"user_id"] unsignedLongLongValue];
        aspect_ratio    = [decoder decodeObjectForKey:@"aspect_ratio"];;
        stamp_url       = [decoder decodeObjectForKey:@"stamp_url"];;
        thumb_url       = [decoder decodeObjectForKey:@"thumb_url"];;
        screen_url      = [decoder decodeObjectForKey:@"screen_url"];
        full_screen_url = [decoder decodeObjectForKey:@"full_screen_url"];
        photo_base      = [decoder decodeObjectForKey:@"photo_base"];
        photo_sizes     = [decoder decodeObjectForKey:@"photo_sizes"];
        width           = [decoder decodeObjectForKey:@"width"];
        height          = [decoder decodeObjectForKey:@"height"];
        rotated_width   = [decoder decodeObjectForKey:@"rotated_width"];
        rotated_height  = [decoder decodeObjectForKey:@"rotated_height"];
        capture_date    = [decoder decodeObjectForKey:@"capture_date"];
        created_at      = [decoder decodeObjectForKey:@"created_at"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:photo_id forKey:@"photo_id"];
    [encoder encodeObject:agent_id forKey:@"agent_id"];
    [encoder encodeObject:caption forKey:@"caption"];
    [encoder encodeObject:state forKey:@"state"];
    [encoder encodeObject:rotate_to forKey:@"rotate_to"];
    [encoder encodeObject:source_guid forKey:@"source_guid"];
    [encoder encodeObject:upload_batch_id forKey:@"upload_batch_id"];
    [encoder encodeObject:[NSNumber numberWithUnsignedLongLong: user_id] forKey:@"user_id"];
    [encoder encodeObject:aspect_ratio forKey:@"aspect_ratio"];;
    [encoder encodeObject:stamp_url forKey:@"stamp_url"];;
    [encoder encodeObject:thumb_url forKey:@"thumb_url"];;
    [encoder encodeObject:screen_url forKey:@"screen_url"];
    [encoder encodeObject:full_screen_url forKey:@"full_screen_url"];
    [encoder encodeObject:photo_base forKey:@"photo_base"];
    [encoder encodeObject:photo_sizes forKey:@"photo_sizes"];
    [encoder encodeObject:width forKey:@"width"];
    [encoder encodeObject:height forKey:@"height"];
    [encoder encodeObject:rotated_width forKey:@"rotated_width"];
    [encoder encodeObject:rotated_height forKey:@"rotated_height"];
    [encoder encodeObject:capture_date forKey:@"capture_date"];
    [encoder encodeObject:created_at forKey:@"created_at"];

}

#pragma mark - Photo methods below
- (ZZUIImageView*)toZZUIImageView
{
    ZZUIImageView *photov = NULL;
    
    if(self.is_ready) {
        if(screen_url) {
            photov = [[ZZUIImageView alloc] init];
            photov.type = Screen;
            photov.userInteractionEnabled = YES;
            photov.photoid = [photo_id unsignedLongLongValue];
            
            [photov setImageWithURL_SD:[NSURL URLWithString:screen_url] placeholderImage:[UIImage imageNamed:@"grid-placeholder.png"]];
        } 
    }
    return photov;
}

-(BOOL)is_ready
{
    return [state isEqualToString:@"ready"];
}

- (ZZUIImageView*)toGridZUIImageView
{
    ZZUIImageView *photoView = NULL;
    if (self.is_ready) {
        NSString *imageUrl = photo_base;
        if( imageUrl && [imageUrl isKindOfClass:[NSString class]]) {
            if (photo_sizes) {
                NSString *photokey;
                if (RETINA_DISPLAY) 
                    photokey = [photo_sizes objectForKey:@"iphone_grid_ret"];
                else
                    photokey = [photo_sizes objectForKey:@"iphone_grid"];
                imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"#{size}" withString:photokey];
            }
        } else if(!imageUrl || [imageUrl isKindOfClass:[NSNull class]]){
            imageUrl = thumb_url;
        }

        if (imageUrl && [imageUrl isKindOfClass:[NSString class]]) {
            photoView = [[ZZUIImageView alloc] initWithImage:[UIImage imageNamed:@"grid-placeholder.png"]];
            photoView.type = Thumb;
            photoView.userInteractionEnabled = YES;            
            photoView.photoid = [photo_id unsignedLongLongValue];            
            if (imageUrl && [imageUrl isKindOfClass:[NSString class]]){        // protect against thumburl == nil or == NSNull
                [photoView setImageWithURL_SD:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"grid-placeholder.png"]];                        
            }
            MLOG(@"toGridZUIImageView: %llu photo_base", photo_id);
            return photoView;
        } 
    } else {
        // for other states e.g., 'assigned', photo has been created (somewhere) but not uploaded/processed
        // test to see if the photo is ours (agent_id matches our UID)
        // if yes, grab the source_guid (aka the photo key) and see if there is a upload image available to substitute
        if (agent_id && [agent_id isKindOfClass:[NSString class]]) {                    // not NSNull
            if ([agent_id isEqualToString:[OpenUDID value]]) {
                // this photo is ours, if photo is in the upload queue, grab local thumbnail
//                if (source_guid && [source_guid isKindOfClass:[NSString class]]) {      // not NSNull
//                    
//                    NSString *thumbkey = [NSString stringWithFormat:@"%@_t", source_guid];
//                    UIImage *uimage = [gZZ getUploadQueueImage:thumbkey];
//                    if (uimage) {
//                        // make thumbnail
//                        int thumbsize = kThumbSize;
//                        if( RETINA_DISPLAY ) {
//                            thumbsize = kThumbSize_Retina;
//                        }
//                        uimage = [uimage thumbnailImage:thumbsize transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationMedium];
//                        
//                        photoView = [[ZZUIImageView alloc] initWithImage:uimage];
//                        photoView.type = Thumb;
//                        photoView.userInteractionEnabled = YES;                        
//                        photoView.photoid = [photo_id unsignedLongLongValue];                        
//                        MLOG(@"toGridZUIImageView: %llu local", photo_id);
//                        return photoView;
//                    }
//                }
            }
        }
    }
    // default
    MLOG(@"toGridZUIImageView: %llu default", photo_id);    
    photoView = [[ZZUIImageView alloc] initWithImage:[UIImage imageNamed:@"inprocess.png"]];
    photoView.type = Thumb;
    photoView.userInteractionEnabled = NO;    
    photoView.photoid = [photo_id unsignedLongLongValue];
    return photoView;
}

@end
