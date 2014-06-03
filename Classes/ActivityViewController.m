//
//  ActivityViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 8/29/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "albums.h"
#import "ActivityViewController.h"
#import "ZZActivityTableViewCell.h"
#import "ZZActivityViewHeader.h"
#import "ZZCache.h"
#import "ZZAPIClient.h"


@implementation ActivityViewController

@synthesize _activityTable;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    MLOG(@"ActivityViewController: viewDidLoad");

    if( ![ZZSession currentSession] ){
        [self presentLoginDialog];
    }
        
    //Create date formatter
    _mdf = [[NSDateFormatter alloc] init];
    [_mdf setDateFormat:@"yyyy-MM-dd"];
    _dateFormatter = [[NSDateFormatter alloc] init]; 
    _activityTable.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (void)viewDidUnload
{
    MLOG(@"ActivityViewController: viewDidUnload");

    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    // Get activities
    NSMutableArray *cachedActivity = [ZZCache getCachedActivity];
    
    // Check for existence and staleness
    if( cachedActivity ){ 
        _activityArray = cachedActivity;
        if( [ZZCache isActivityStale] ){
            MLOG( @"Activity is stale, reloading");
            [[ZZAPIClient sharedClient] 
             getActivityForUser: [ZZSession currentUser].user_id
             success:^(NSMutableArray *activity){         
                 _activityArray = activity;
                 [_activityTable reloadData];
             } 
             failure:^(NSError *error){
                 [[[UIAlertView alloc] initWithTitle:@"Activity" 
                                             message: NSLocalizedString( @"There was an error when loading your activity please try again.", @"Error message when user did not authorize access to FB account")
                                            delegate:self 
                                   cancelButtonTitle:@"OK" 
                                   otherButtonTitles:nil] show];
             }
             
             ];
        }else{
            MLOG( @"Activity is NOT stale, keeping");
        }
    }else{    
        [[ZZAPIClient sharedClient] 
         getActivityForUser: [ZZSession currentUser].user_id
         success:^(NSMutableArray *activity){         
             _activityArray = activity;
             [_activityTable reloadData];
         } 
         failure:^(NSError *error){
             [[[UIAlertView alloc] initWithTitle:@"Activity" 
                                         message: NSLocalizedString( @"There was an error when loading your activity please try again.", @"Error message when user did not authorize access to FB account")
                                        delegate:self 
                               cancelButtonTitle:@"OK" 
                               otherButtonTitles:nil] show];
         }];
    }
    [super  viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [ZZCache cacheActivity:_activityArray];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)switchToView
{
    MLOG(@"ActivityViewController: switch view");
}

#pragma mark - Table Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _activityArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 56;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
 
    // fixed font style. use custom view (UILabel) if you want something different
    ZZActivity *activity = [_activityArray objectAtIndex: section];
    ZZUser *activityUser = [ZZCache getCachedUser: activity.by_user_id];
    NSString *username; 
    if( activityUser ){
        username =  [activityUser displayFirstName];
                    
        if( username == NULL ){
            MLOG(@"Retrieving userName for userID:%llu",activity.by_user_id);
            username = @"Waiting";
        }else{
            //MLOG(@"Retrieved userName for userID:%@ was %s",activity.by_user_id, userName );
        }
        
    }else{
        username = @"Unavailable";
        MLOG(@"activity.by_user_id was NULL");        
    }
    
    NSString *actionString;
    if( [activity.kind isEqualToString:@"Upload"] ){
        //Upload
        actionString = [NSString stringWithFormat:@"%@ uploaded this photo", username];
    }else{
        //Comment
        actionString = [NSString stringWithFormat:@"%@ Commented on this photo", username];
    }
 
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ZZActivityViewHeader" owner:self options:nil];
    ZZActivityViewHeader *header;
    id firstObject = [topLevelObjects objectAtIndex:0];
    if ( [ firstObject isKindOfClass:[ZZActivityViewHeader class]] ){
        header = firstObject;     
    }else{
        header = [topLevelObjects objectAtIndex:1];
    }

    
    
    //TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    TTTAttributedLabel *label = header.label;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor darkGrayColor];
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    //label.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    
    [label setText:actionString afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldBlueRange = [[mutableAttributedString string] rangeOfString:username options:NSCaseInsensitiveSearch];
        
        // make text blue
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[RGB(70,111,170) CGColor] range:boldBlueRange]; //

        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
//        UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:14];
//        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
//        if (font) {
//            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldBlueRange];
//        }
        return mutableAttributedString;
    }];
    
    //Set image
    
    UIImageView *userimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_profile.png"]];
    [userimage setImageWithURL_SD:[NSURL URLWithString:activityUser.profile_photo_url]];
     
    
    userimage.frame = CGRectMake(5,5,26,26); 
    userimage.bounds = CGRectMake(0,0,26,26); 
    userimage.clipsToBounds = YES;
    userimage.contentMode = UIViewContentModeScaleAspectFill;
    userimage.layer.cornerRadius = 3.0;
    userimage.layer.masksToBounds = YES;

    [header.image addSubview:userimage];

    if(section > 0 ){
        UIImageView *separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, header.frame.size.width, 1.0f)];
        separatorLine.image = [[UIImage imageNamed:@"gray_dot.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
        separatorLine.tag = 4;
        [header addSubview:separatorLine];
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    ZZActivity *activity = [_activityArray objectAtIndex: indexPath.section];

    switch (row) 
    {
        case 0:
        {
            ZZActivityTableViewCell *cell = (ZZActivityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ZZActivityTableViewCell"];
            if ( cell == nil ){
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ZZActivityTableViewCell" owner:self options:nil];
                id firstObject = [topLevelObjects objectAtIndex:0];
                if ( [ firstObject isKindOfClass:[UITableViewCell class]] ){
                    cell = firstObject;     
                }else{
                    cell = [topLevelObjects objectAtIndex:1];
                }
                cell.photoView.contentMode = UIViewContentModeScaleAspectFill; 
                cell.photoView.clipsToBounds = YES;
                cell.photoView.layer.borderColor = [[UIColor whiteColor] CGColor];
                cell.photoView.layer.borderWidth = 5.0;
            }            
           
            [cell.photoView setImageWithURL_SD:activity.photo.screen_url 
                              placeholderImage:[UIImage imageNamed:@"grid-placeholder.png"]];         
            //cell.timeLabel.text = [self formattedDateRelativeToNow:activity.createdAt];
            //cell.likesLabel.text = [NSString stringWithFormat:@"%@ Likes", activity.like_count];            
            return cell;
            break;
        }
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"likeCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"likeCell"];
            }
            
            
            UIImage *normalButton = [[UIImage imageNamed:@"activity-btn.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:0.0];
            UIImage *hlButton = [[UIImage imageNamed:@"activity-btn-hl.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:0.0];
            
            UIButton* likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            likeButton.frame = CGRectMake(10, 0.0, 80, 27);            
            [likeButton setTitleColor:RGB(102,102,102) forState:UIControlStateNormal];
            likeButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            NSString *likeText;
            if( activity.like_count <= 0){
                    likeText = @"Like";
            }else if( [activity.like_count intValue] == 1){
                    likeText = @"1 Like";
            }else if( [activity.like_count intValue] > 1){
                    likeText = [NSString stringWithFormat:@"%@ Likes", activity.like_count];
            }
            [likeButton setTitle:likeText forState:UIControlStateNormal];                        
            [likeButton setBackgroundImage:normalButton forState:UIControlStateNormal];
            [likeButton setBackgroundImage:hlButton forState:UIControlStateHighlighted];
            [likeButton setBackgroundImage:hlButton forState:UIControlStateSelected];
            likeButton.adjustsImageWhenHighlighted = NO;
            likeButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [likeButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            UIImage *likeIconImage = [UIImage imageNamed:@"activity-like-icon.png"];
            likeButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0,  10);
            [likeButton setImage:likeIconImage forState:UIControlStateNormal];
            [cell addSubview:likeButton];

            UIButton* commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            commentButton.frame = CGRectMake(100, 0.0, 100, 27);            
            [commentButton setTitleColor:RGB(102,102,102) forState:UIControlStateNormal];
            commentButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];            
            [commentButton setTitle:@"Comment" forState:UIControlStateNormal];                       
            [commentButton setBackgroundImage:normalButton forState:UIControlStateNormal];
            [commentButton setBackgroundImage:hlButton forState:UIControlStateHighlighted];
            [commentButton setBackgroundImage:hlButton forState:UIControlStateSelected];
            commentButton.adjustsImageWhenHighlighted = NO;
            commentButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [commentButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            UIImage *commentIconImage = [UIImage imageNamed:@"activity-comment-icon.png"];
            commentButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0,  10);
            [commentButton setImage:commentIconImage forState:UIControlStateNormal];
            [cell addSubview:commentButton];

            UIButton* shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
            shareButton.frame = CGRectMake(210, 0.0, 80, 27);            
            [shareButton setTitleColor:RGB(102,102,102) forState:UIControlStateNormal];
            shareButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];            
            [shareButton setTitle:@"Share" forState:UIControlStateNormal];                       
            [shareButton setBackgroundImage:normalButton forState:UIControlStateNormal];
            [shareButton setBackgroundImage:hlButton forState:UIControlStateHighlighted];
            [shareButton setBackgroundImage:hlButton forState:UIControlStateSelected];
            shareButton.adjustsImageWhenHighlighted = NO;
            shareButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
            [shareButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            UIImage *shareIconImage = [UIImage imageNamed:@"activity-share-icon.png"];
            shareButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0,  10);
            [shareButton setImage:shareIconImage forState:UIControlStateNormal];
            [cell addSubview:shareButton];

            return cell;
            break;
        }
            /* your additional cases go here */
    }
   
    return NULL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) 
    {
        case 0: // Photo
            return 310;
        case 1: //Likes
            return 50;
    }
    return 50;
}



-(NSString *) formattedDateRelativeToNow:(NSDate *)date
{
   
    NSDate *midnight = [_mdf dateFromString:[_mdf stringFromDate:date]];
    NSInteger dayDiff = (int)[midnight timeIntervalSinceNow] / (60*60*24);
    
    if(dayDiff == 0){
        NSDate *todayDate = [NSDate date];
        double ti = [date timeIntervalSinceDate:todayDate];
        ti = ti * -1;
        if(ti < 1) {
            return @"never";
        } else      if (ti < 60) {
            return @"less than a minute ago";
        } else if (ti < 3600) {
            int diff = round(ti / 60);
            return [NSString stringWithFormat:@"%d minutes ago", diff];
        } else if (ti < 86400) {
            int diff = round(ti / 60 / 60);
            return[NSString stringWithFormat:@"%d hours ago", diff];
        } else if (ti < 2629743) {
            int diff = round(ti / 60 / 60 / 24);
            return[NSString stringWithFormat:@"%d days ago", diff];
        } else {
            return @"never";
        }   
        //[dateFormatter setDateFormat:@"'Today, 'h':'mm aaa"];
    }else if(dayDiff == -1)
        return @"Yesterday"; //[dateFormatter setDateFormat:@"'Yesterday, 'h':'mm aaa"];
    else if(dayDiff == -2)
        return @"Two days ago"; //[dateFormatter setDateFormat:@"MMMM d', Two days ago'"];
    else if(dayDiff > -7 && dayDiff <= -2)
        return @"This week";// [dateFormatter setDateFormat:@"MMMM d', This week'"];
    else if(dayDiff > -14 && dayDiff <= -7)
        return @"Last week"; //[dateFormatter setDateFormat:@"MMMM d'; Last week'"];
    else if(dayDiff > -30 && dayDiff <= -14)
        return @"A few weeks ago"; //[dateFormatter setDateFormat:@"MMMM d'; Last week'"];
    else if(dayDiff >= -60 && dayDiff <= -30)
        return @"A month ago"; //[dateFormatter setDateFormat:@"MMMM d'; Last month'"];
    else if(dayDiff >= -90 && dayDiff <= -60)
        return @"Two months ago";//[dateFormatter setDateFormat:@"MMMM d'; Within last three months'"];
    else if(dayDiff >= -180 && dayDiff <= -90)
        return @"Six months ago";//[dateFormatter setDateFormat:@"MMMM d'; Within last six months'"];
    else if(dayDiff >= -365 && dayDiff <= -180)
        return @"More than six months ago";// [dateFormatter setDateFormat:@"MMMM d, YYYY'; Within this year'"];
    else if(dayDiff < -365)
        return @"A long time ago";//[dateFormatter setDateFormat:@"MMMM d, YYYY'; A long time ago'"];
    
    return [_dateFormatter stringFromDate:date];
} 


//
//-(NSString *)dateDiff:(NSString *)origDate {
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
//    [df setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
//    NSDate *convertedDate = [df dateFromString:origDate];
//    [df release];
//    NSDate *todayDate = [NSDate date];
//    double ti = [convertedDate timeIntervalSinceDate:todayDate];
//    ti = ti * -1;
//    if(ti < 1) {
//        return @"never";
//    } else      if (ti < 60) {
//        return @"less than a minute ago";
//    } else if (ti < 3600) {
//        int diff = round(ti / 60);
//        return [NSString stringWithFormat:@"%d minutes ago", diff];
//    } else if (ti < 86400) {
//        int diff = round(ti / 60 / 60);
//        return[NSString stringWithFormat:@"%d hours ago", diff];
//    } else if (ti < 2629743) {
//        int diff = round(ti / 60 / 60 / 24);
//        return[NSString stringWithFormat:@"%d days ago", diff];
//    } else {
//        return @"never";
//    }   
//}
@end

