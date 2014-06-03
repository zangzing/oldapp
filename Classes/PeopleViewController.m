//
//  PeopleViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 8/30/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>
#import "UIImageView+WebCache.h"
#import "zzglobal.h"
#import "albums.h"
#import "MainViewController.h"
#import "PeopleViewController.h"
#import "ZZCache.h"

@implementation PeopleViewController

@synthesize peopletable;
@synthesize peopleselect;
@synthesize peopleselectholder;
@synthesize imageView;

#define kRowHeight  66

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    MLOG(@"PeopleViewController: didReceiveMemoryWarning");

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad	
{
    [super viewDidLoad];
    
    /*
    [peopletable setSeparatorColor:[UIColor colorWithRed: 223.0/255.0 green: 223.0/255.0 blue: 223.0/255.0 alpha: 1.0]];
    peopletable.rowHeight = kRowHeight;
    
    // segment control
    NSDictionary *peopleselectdef = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"Following", @"Followed By", nil], @"titles", [NSValue valueWithCGSize:CGSizeMake(154,30)], @"size", @"segment_gray.png", @"button-image", @"segment_gray_selected.png", @"button-highlight-image", @"segment_gray_divider.png", @"divider-image", [NSNumber numberWithFloat:11.0], @"cap-width", [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0], @"button-color", [UIColor colorWithRed:100.0 green:100.0 blue:100.0 alpha:1.0], @"button-highlight-color", nil];
    
    peopleselect = [[ZZSegmentedControl alloc] initWithSegmentCount:2 selectedSegment:0 segmentdef:peopleselectdef tag:0 delegate:self];
    peopleselect.frame = CGRectMake(5, 50, peopleselect.frame.size.width, peopleselect.frame.size.height);    // adjust location
    [self.view addSubview:peopleselect];
        
    // peopletable top border
    UIView *overlayView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [overlayView2 setBackgroundColor:[UIColor colorWithRed: 172.0/255.0 green: 172.0/255.0 blue: 172.0/255.0 alpha: 1.0]];
    [peopletable addSubview:overlayView2]; 
    
    // fill peopleselectholder gradient
    UIColor *gcolor1 = [UIColor colorWithRed: 244.0/255.0 green: 244.0/255.0 blue: 244.0/255.0 alpha: 1.0];
    UIColor *gcolor2 = [UIColor colorWithRed: 219.0/255.0 green: 219.0/255.0 blue: 219.0/255.0 alpha: 1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = peopleselectholder.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[gcolor1 CGColor], (id)[gcolor2 CGColor], nil];
    [peopleselectholder.layer insertSublayer:gradient atIndex:0];
    
    */
    
    // *** OFF
    peopleselect.hidden = YES;
    peopleselectholder.hidden = YES;
    peopletable.hidden = YES;
    
    [self switchToView];
}

-(IBAction) handleSwipe:(UISwipeGestureRecognizer *)recognizer 
{
    
    MLOG(@"%s", __FUNCTION__);
    switch (recognizer.direction)
    {
        case (UISwipeGestureRecognizerDirectionRight):
            MLOG(@"%s Right Swipe", __FUNCTION__);
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationDelay:0.0];
            [UIView setAnimationBeginsFromCurrentState:YES];
            //[UIView setAnimationDidStopSelector:@selector(animCompleteHandler:finished:context:)];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft  forView:self.view cache:YES];
            [UIView commitAnimations];
            
            break;               
            
        case (UISwipeGestureRecognizerDirectionLeft): 
            MLOG(@"%s Left Swipe", __FUNCTION__);
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationDelay:0.0];
            [UIView setAnimationBeginsFromCurrentState:YES];
            //[UIView setAnimationDidStopSelector:@selector(animCompleteHandler:finished:context:)];
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
            [UIView commitAnimations];
            break;
            
        default:
            break;
    }     
}     

- (void)switchToView
{
    MLOG(@"PeopleViewController: switchToView");
    
    // *** [peopletable reloadData];
}


- (void)switchFromView
{
    MLOG(@"PeopleViewController: switchFromView");
    
}


- (void)viewDidUnload
{
    MLOG(@"PeopleViewController: viewDidUnload");

    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // ***
    return 0;
    // *** temporary
    
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
//    int pos = [indexPath indexAtPosition: 1];
//    
//    NSDictionary *userinfoset = [gUserInfo getUserInfoSet];
//    NSArray *keys = [userinfoset allKeys];
//    NSNumber *nuserid = [keys objectAtIndex:pos];
//    
//    [gZZ setNumberForSetting:[ZZSession currentUser].user_id setting:@"albums_user" value:nuserid];
//    [gZZ setStringForSetting:[ZZSession currentUser].user_id setting:@"albums_type" value:@"my"];
//    
//    [gV switchToView:kTABBAR_MainBar selectedTab:0 viewController:NULL];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // rect  x,y,width,height
//    int x;
//    int y;
//    int height;
//    int width;
//    
//    
//    int pos = [indexPath indexAtPosition: 1];
    NSString *CellIdentifier = [ NSString stringWithFormat: @"s%d:%d", [ indexPath indexAtPosition: 0 ], [ indexPath indexAtPosition:1 ]];
//    MLOG(@"PeopleViewController:  cellForRowAtIndexPath: %@", CellIdentifier);
//    
//    //UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    
//     
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    
////    NSDictionary *userinfoset = [gUserInfo getUserInfoSet];
////    NSArray *keys = [userinfoset allKeys];
////    NSNumber *nuserid = [keys objectAtIndex:pos];
////    
//#define nName 1		// name
//    
//    x = kRowHeight + 5;
//    y = 11;
//    height = 25;
//    width = 200;
//    
//    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x,y,width,height)];
//    y+=height;
//    nameLabel.tag = nName;
//    nameLabel.font = [UIFont boldSystemFontOfSize:14];
//    [nameLabel setTextColor:[UIColor colorWithRed: 58.0/255.0 green: 58.0/255.0 blue: 58.0/255.0 alpha: 1.0]];
//    [nameLabel setBackgroundColor:[UIColor clearColor]];
//    [cell.contentView addSubview:nameLabel];
//    
//    nameLabel.text = [ZZCache getCachedUser:[nuserid unsignedLongLongValue]].user_display_name;
//    
//    
//    // user profile pict
//    x = 5;
//    y = 5;
//    height = 58;
//    width = 58;
//    
//    UIImageView *peopleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder.png"]];
//    peopleImage.frame = CGRectMake(x,y,width,height); 
//    peopleImage.bounds = CGRectMake(0,0,width,height); 
//    peopleImage.clipsToBounds = YES;
//    peopleImage.contentMode = UIViewContentModeScaleAspectFill;
//    NSString *profileURL = [ZZCache getCachedUser:[nuserid unsignedLongLongValue]].profile_photo_url;
//    if (profileURL && [profileURL isKindOfClass:[NSString class]])        // albumcurl can be NSNull
//        [peopleImage setImageWithURL_SD:[NSURL URLWithString:profileURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
//    [cell.contentView addSubview:peopleImage];
//    
    return cell;
}


@end
