//
//  UIFactory.m
//  ZangZing
//
//  Created by Phil Beisel on 1/27/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>
#import "zztypes.h"
#import "zzglobal.h"
#import "albums.h"
#import "ZZLabel.h"
#import "UIImageView+WebCache.h"
#import "UIFactory.h"
#import "ZZCache.h"

@implementation UIFactory



+(void)setAlbumsCell:(NSDictionary*)albumdata cell:(UITableViewCell*)cell withDisclosure:(BOOL)withDisclosure
{
    // rect  x,y,width,height
    int x, y, height, width;
    
    NSString *albumname = [albumdata valueForKey:@"name"];
    NSString *albumcover = NULL;
    
    NSObject *a = [albumdata objectForKey:@"cover_base"];
    if (a && a != [NSNull null]) {
        NSDictionary *photosizes = [albumdata objectForKey:@"cover_sizes"];
        if (photosizes) {
            NSString *photokey;
            if ([gZZ isHiResScreen]) 
                photokey = [photosizes objectForKey:@"iphone_cover_ret"];
            else
                photokey = [photosizes objectForKey:@"iphone_cover"];
            albumcover = (NSString*)a;
            albumcover = [albumcover stringByReplacingOccurrencesOfString:@"#{size}" withString:photokey];
            
            //MLOG(@"using key: %@", photokey);
        }
    } 
    
    if (!albumcover)
        albumcover = [albumdata objectForKey:@"c_url"];
    
    //MLOG(@"album cover URL: %@", albumcover);
    
    //NSNumber *updated_at = [albumdata valueForKey:@"updated_at"];
    NSString *u = [albumdata valueForKey:@"user_id"];
    ZZUserID userid = [u longLongValue];
    NSString *by = [[ZZCache getCachedUser:userid]displayNameOrMe];
    NSNumber *photos_ready_count = [albumdata valueForKey:@"photos_ready_count"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    int frameleft = 0;
    int frametop = 0;
    //int framebottom = 5;
    
    // frame
    UIImage *frameimage = [UIImage imageNamed:@"albums-frame.png"];
    UIImageView *frameimageView = [[UIImageView alloc] initWithImage:frameimage];
    frameimageView.frame = CGRectMake(frameleft,frametop,frameimage.size.width,frameimage.size.height); 
    [cell.contentView addSubview:frameimageView];
    
    
    int x_border = 5;
    int y_border = 5;
    int thumb_height = 94;  //frameimage.size.height - (y_border*2) - framebottom;
    int thumb_width = 310;  //frameimage.size.width - (x_border*2);
    
    
    // thumbnail
    x = x_border;
    y = y_border;
    height = thumb_height;
    width = thumb_width;
    
    UIImageView *albumImage = NULL;
    
    albumImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder.png"]];
    albumImage.frame = CGRectMake(x,y,width,height); 
    albumImage.bounds = CGRectMake(0,0,width,height); 
    albumImage.clipsToBounds = YES;
    albumImage.contentMode = UIViewContentModeScaleAspectFill;
    if (albumcover && [albumcover isKindOfClass:[NSString class]])        // albumcurl can be NSNull
        [albumImage setImageWithURL_SD:[NSURL URLWithString:albumcover] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [frameimageView addSubview:albumImage];
    
    
    // overlay
    x = 0;
    y = thumb_height - 40;
    height = 40;
    width = thumb_width;
    
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(x,y,width,height)];
    [overlay setBackgroundColor:[UIColor colorWithRed: 0.0/255.0 green: 0.0/255.0 blue: 0.0/255.0 alpha: 0.6]];
    [albumImage addSubview:overlay]; 
    
    
    int countXoffset = 17;
    if (withDisclosure)
        countXoffset = 30;
    
    // album image count
    height = 19;
    width = 27;
    x = 320 - width - countXoffset;        
    y = 10;
    
    UIImageView *countImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"counts.png"]];
    countImage.frame = CGRectMake(x,y,width,height); 
    countImage.bounds = CGRectMake(0,0,width,height); 
    countImage.clipsToBounds = YES;
    
    [overlay addSubview:countImage];
    
    y = y + 2;
    x = x + 1;
    height = 15;
    width = 25;
    
    ZZUILabel *countLabel = [[ZZUILabel alloc] initWithFrame:CGRectMake(x,y,width,height)];
    countLabel.font = [UIFont boldSystemFontOfSize:12];
    countLabel.textColor = [UIColor whiteColor];
    [countLabel setBackgroundColor:[UIColor clearColor]];
    [countLabel setTextAlignment:UITextAlignmentCenter];
    countLabel.text = [ZZGlobal countLabel:[photos_ready_count intValue]];   
    countLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    countLabel.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    countLabel.layer.shadowRadius = 20.0;
    countLabel.layer.shadowOpacity = 0.5;
    [overlay addSubview:countLabel];
    
    if (withDisclosure) {
        // disclosure arrow
        height = 13;
        width = 9;
        x = 320 - width - 15;        // 5 pixels from right edge of photo
        y = y + 1;
        
        UIImageView *disclosureImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclose-white.png"]];
        disclosureImage.frame = CGRectMake(x,y,width,height); 
        disclosureImage.bounds = CGRectMake(0,0,width,height); 
        disclosureImage.clipsToBounds = YES;
        
        [overlay addSubview:disclosureImage];
    }
    
    
    // album name
    x = 5;
    y = 1;
    height = 25;
    width = 256;
    
    ZZUILabel *albumnameLabel = [[ZZUILabel alloc] initWithFrame:CGRectMake(x,y,width,height)];
    y+=height;
    albumnameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]; //[UIFont boldSystemFontOfSize:14];
    [albumnameLabel setTextColor:[UIColor whiteColor]];  
    [albumnameLabel setBackgroundColor:[UIColor clearColor]];
    [overlay addSubview:albumnameLabel];
    
    albumnameLabel.text = albumname;
    
    // album owner  e.g., by Phil Beisel
    x = 5;
    y = 16;
    height = 25;
    width = 256;
    
    ZZUILabel *byLabel = [[ZZUILabel alloc] initWithFrame:CGRectMake(x,y,width,height)];
    y+=height;
    byLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    byLabel.textColor = [UIColor whiteColor];
    [byLabel setBackgroundColor:[UIColor clearColor]];
    
    byLabel.text = [NSString stringWithFormat:@"by %@", by]; 
    [overlay addSubview:byLabel];
}



+(void)setUserProfileCell:(ZZUser *)user cell:(UITableViewCell*)cell showSharePermission:(BOOL)showSharePermission;
{
    if (user.auto_by_contact ) {
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 10, 250, 20)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
        nameLabel.text = user.email;
        [cell.contentView addSubview:nameLabel];
    } else {
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 3, 250, 20)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
        nameLabel.text = user.name;
        [cell.contentView addSubview:nameLabel];
        
        UILabel *usernameLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 22, 200, 20)];
        [usernameLabel setBackgroundColor:[UIColor clearColor]];
        usernameLabel.textColor = [UIColor grayColor];
        usernameLabel.font = [UIFont systemFontOfSize:14.0];
        usernameLabel.text = user.username;
        [cell.contentView addSubview:usernameLabel];
    }
    
    UIImageView *userimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_profile.png"]];
    NSString *profilePhotoURL = user.profile_photo_url;
    if (profilePhotoURL && ![profilePhotoURL isKindOfClass:[NSNull class]]) {
        [userimage setImageWithURL_SD:[NSURL URLWithString: profilePhotoURL]];
    }
    userimage.frame = CGRectMake(6,6,30,30); 
    userimage.clipsToBounds = YES;
    userimage.contentMode = UIViewContentModeScaleAspectFill;
    [cell.contentView addSubview:userimage];
    
    if (showSharePermission) {
        
        if (user.sharePermission == kShareAsViewer) {
            cell.detailTextLabel.text = @"View";
        } else if (user.sharePermission == kShareAsContributor) {
            cell.detailTextLabel.text = @"Add";
        } else
            cell.detailTextLabel.text = @"Admin";
    }
        
}

+ (UIButton *)screenWideGreenButton:(NSString *)text frame:(CGRect)frame
{
    UIImage* greenImage = [[UIImage imageNamed:@"green-wide-btn.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0];
    UIImage *greenImageHL = [[UIImage imageNamed:@"green-wide-btn-hl.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0];
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newButton setBackgroundImage:greenImage forState:UIControlStateNormal];
    [newButton setBackgroundImage:greenImageHL forState:UIControlStateHighlighted];
    newButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    newButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    newButton.frame = frame;
    
    
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
    titlelabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.0];
    titlelabel.font = [UIFont boldSystemFontOfSize:16];
    titlelabel.textColor = [UIColor whiteColor];
    titlelabel.shadowColor = RGBA(0,0,0,0.3);
    titlelabel.shadowOffset = CGSizeMake(0, -1);
    titlelabel.textAlignment = UITextAlignmentCenter;
    titlelabel.text = text;
    [newButton addSubview:titlelabel];

    return newButton;
}

+ (UIButton *)screenWideRedButton:(NSString *)text frame:(CGRect)frame
{
    UIImage* greenImage = [[UIImage imageNamed:@"red-wide-btn.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0];
    UIImage *greenImageHL = [[UIImage imageNamed:@"red-wide-btn-hl.png"] stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0];
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newButton setBackgroundImage:greenImage forState:UIControlStateNormal];
    [newButton setBackgroundImage:greenImageHL forState:UIControlStateHighlighted];
    newButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    newButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    newButton.frame = frame;
    
    
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
    titlelabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.0];
    titlelabel.font = [UIFont boldSystemFontOfSize:16];
    titlelabel.textColor = [UIColor whiteColor];
    titlelabel.shadowColor = RGBA(0,0,0,0.3);
    titlelabel.shadowOffset = CGSizeMake(0, -1);
    titlelabel.textAlignment = UITextAlignmentCenter;
    titlelabel.text = text;
    [newButton addSubview:titlelabel];
    
    return newButton;
}

+ (UIButton *)facebookConnectButton:(CGRect)frame
{
    UIImage *facebookButtonImage = [UIImage imageNamed:@"facebook-connect.png"] ;
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newButton setBackgroundImage:facebookButtonImage forState:UIControlStateNormal];
    newButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    newButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    newButton.frame = frame;
    return newButton;
}

@end
