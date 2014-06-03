//
//  MainViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 8/29/11.
//  Copyright 2011 ZangZing. All rights reserved.
//

#import "AlbumsViewController.h"
#import <QuartzCore/CoreAnimation.h>
#import "Stack.h"
#import "util.h"
#import "zzglobal.h"
#import "photouploader.h"
#import "albums.h"
#import "SettingsViewController.h"
#import "MainViewController.h"
#import "ActivityViewController.h"
#import "CameraViewController.h"
#import "PeopleViewController.h"
#import "LoginViewController.h"

#define SELECTED_VIEW_CONTROLLER_TAG    98456345
#define TABBAR_HEIGHT                   49

MainViewController *gV = nil;


@implementation ZZUIViewController

-(void)switchToView
{
    
}


-(void)switchFromView
{
    
}

-(void)actionView:(NSString*)action
{
    
}

@end


@implementation MainViewController

@synthesize tabbar;

- (void) awakeFromNib
{        
    _bar1 = [NSArray arrayWithObjects:
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"actionIndex", @"imageset", @"imageType", @"albums-tab.png", @"image", @"albums-tab-selected.png", @"imageSelected", @"AlbumsViewController", @"viewController", @"Albums", @"text", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"actionIndex", @"imageset", @"imageType", @"activity-tab.png", @"image", @"activity-tab-selected.png", @"imageSelected", @"ActivityViewController", @"viewController", @"Activity", @"text", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"actionIndex", @"buttonset", @"imageType", @"camera-main-button.png", @"image", @"camera-main-button-selected.png", @"imageSelected", @"CameraViewController", @"viewController", @"", @"text", [NSNumber numberWithInt:4], @"ypos", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:3], @"actionIndex", @"imageset", @"imageType", @"people-tab.png", @"image", @"people-tab-selected.png", @"imageSelected", @"PeopleViewController", @"viewController", @"People", @"text", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:4], @"actionIndex", @"imageset", @"imageType", @"me-tab.png", @"image", @"me-tab-selected.png", @"imageSelected", @"SettingsViewController", @"viewController", @"Me", @"text", nil], nil];
    
    _bar2 = [NSArray arrayWithObjects:
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"actionIndex", @"imageset", @"imageType", @"share-tab.png", @"image", @"share-tab.png", @"imageSelected", @"share", @"action", @"Share", @"text", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"actionIndex", @"imageset", @"imageType", @"like-tab.png", @"image", @"like-tab.png", @"imageSelected", @"like", @"action", @"Like", @"text", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"actionIndex", @"buttonset", @"imageType", @"camera-main-button.png", @"image", @"camera-main-button-selected.png", @"imageSelected", @"CameraViewController", @"viewController", @"", @"text", [NSNumber numberWithInt:4], @"ypos", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:3], @"actionIndex", @"imageset", @"imageType", @"comment-tab.png", @"image", @"comment-tab.png", @"imageSelected", @"comment", @"action", @"Comment", @"text", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:4], @"actionIndex", @"imageset", @"imageType", @"more-tab.png", @"image", @"more-tab.png", @"imageSelected", @"more", @"action", @"More", @"text", nil], nil];
    
    _bar3 = [NSArray arrayWithObjects:
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"actionIndex", @"imageset", @"imageType", @"share-tab.png", @"image", @"share-tab.png", @"imageSelected", @"", @"share", @"Share", @"text", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"actionIndex", @"imageset", @"imageType", @"like-tab.png", @"image", @"like-tab.png", @"imageSelected", @"like", @"action", @"Like", @"text", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"actionIndex", @"buttonset", @"imageType", @"camera-main-button.png", @"image", @"camera-main-button-selected.png", @"imageSelected", @"CameraViewController", @"viewController", @"", @"text", [NSNumber numberWithInt:4], @"ypos", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:3], @"actionIndex", @"imageset", @"imageType", @"comment-tab.png", @"image", @"comment-tab.png", @"imageSelected", @"comment", @"action", @"Comment", @"text", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:4], @"actionIndex", @"imageset", @"imageType", @"more-tab.png", @"image", @"more-tab.png", @"imageSelected", @"more", @"action", @"More", @"text", nil], nil];
    
    _bar4 = [NSArray arrayWithObjects:
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"actionIndex", @"buttonset", @"imageType", @"camera-back.png", @"image", @"camera-back-selected.png", @"imageSelected", @"back", @"action", @"", @"text", [NSNumber numberWithInt:10], @"xpos", [NSNumber numberWithInt:11], @"ypos", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"actionIndex", @"none", @"imageType", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"actionIndex", @"buttonset", @"imageType", @"camera-button.png", @"image", @"camera-button-selected.png", @"imageSelected", @"takepict", @"action", @"", @"text", [NSNumber numberWithInt:109], @"xpos", [NSNumber numberWithInt:4], @"ypos", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"actionIndex", @"none", @"imageType", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"actionIndex", @"buttonset", @"imageType", @"camera-upload-2.png", @"image", @"camera-upload-selected-2.png", @"imageSelected", @"add", @"action", @"", @"text", [NSNumber numberWithInt:320-68-7], @"xpos", [NSNumber numberWithInt:11], @"ypos", nil], nil];
    
    _bar5 = [NSArray arrayWithObjects:
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"actionIndex", @"buttonset", @"imageType", @"camera-back.png", @"image", @"camera-back-selected.png", @"imageSelected", @"back", @"action", @"", @"text", [NSNumber numberWithInt:10], @"xpos", [NSNumber numberWithInt:11], @"ypos", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"actionIndex", @"none", @"imageType", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"actionIndex", @"none", @"imageType", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"actionIndex", @"none", @"imageType", nil],
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"actionIndex", @"buttonset", @"imageType", @"camera-upload-2.png", @"image", @"camera-upload-selected-2.png", @"imageSelected", @"add", @"action", @"", @"text", [NSNumber numberWithInt:320-68-7], @"xpos", [NSNumber numberWithInt:11], @"ypos", nil], nil];
    
    
    
    _barspec1 = [NSDictionary dictionaryWithObjectsAndKeys:@"tabbar-background.png", @"tabbarbackground", @"dark+solid", @"style", nil];
    _barspec2 = [NSDictionary dictionaryWithObjectsAndKeys:@"tabbar-background.png", @"tabbarbackground", @"dark+transparent", @"style", nil];
    _barspec3 = [NSDictionary dictionaryWithObjectsAndKeys:@"tabbar-background.png", @"tabbarbackground", @"dark+transparent", @"style", @"full+", @"size", @"YES", @"rotate", nil];
    _barspec4 = [NSDictionary dictionaryWithObjectsAndKeys:@"tabbar-background.png", @"tabbarbackground", @"dark+solid", @"style", nil];
    _barspec5 = [NSDictionary dictionaryWithObjectsAndKeys:@"tabbar-background.png", @"tabbarbackground", @"dark+solid", @"style", nil];
    
}


- (ZZUIViewController*)viewControllerFactory:(NSString*)name
{
    if (!name)
        return NULL;
    
    MLOG(@"viewControllerFactory: %@", name);
 
    if ([name isEqualToString:@"AlbumsViewController"]) {
        
        AlbumsViewController *vc = [[AlbumsViewController alloc] initWithNibName:@"AlbumsView" bundle:[NSBundle mainBundle]];
        
        UINib *nib = [UINib nibWithNibName:@"NavController" bundle:nil]; 
        UINavigationController *navigationController = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        [navigationController setViewControllers:[NSArray arrayWithObject:vc]];
        
        navigationController.delegate = self;
        return (ZZUIViewController *) navigationController;
    }
    
    if ([name isEqualToString:@"ActivityViewController"]) 
        return [[ActivityViewController alloc] initWithNibName:@"ActivityView" bundle:[NSBundle mainBundle]];
    
    if ([name isEqualToString:@"CameraViewController"]) {
                
        CameraViewController *vc = [[CameraViewController alloc] initWithNibName:@"CameraView" bundle:[NSBundle mainBundle]];
        
        UINib *nib = [UINib nibWithNibName:@"NavController" bundle:nil]; 
        UINavigationController *navigationController = [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        [navigationController setViewControllers:[NSArray arrayWithObject:vc]];
        
        navigationController.delegate = self;
    
        navigationController.navigationBarHidden = YES;
        
        return (ZZUIViewController *)navigationController;
    }
    
    if ([name isEqualToString:@"PeopleViewController"]) 
        return [[PeopleViewController alloc] initWithNibName:@"PeopleView" bundle:[NSBundle mainBundle]];
    
    if ([name isEqualToString:@"SettingsViewController"]) 
        return [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:[NSBundle mainBundle]];
    
    return NULL;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    MLOG(@"MainViewController: didReceiveMemoryWarning");
    
    // pass it on
    if (_setviewcontroller) {
        [_setviewcontroller didReceiveMemoryWarning];
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _activebar = 0;
    _settab = -1;
    _setviewcontroller = NULL;
    _actionviewcontroller = NULL;
    
    _isfullscreen = NO;
    _wasfullscreen = NO;
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    NSInteger tab = 0;
    if([ZZSession currentSession]){
        tab = [gZZ integerForSetting:[ZZSession currentUser].user_id setting:@"tabbar_main_tab"];
        if (tab == -1) {
            tab = 0;
        }
    }
    _timerInterval = 1.0;
    _timer= [NSTimer scheduledTimerWithTimeInterval: _timerInterval target: self selector: @selector(handleTimer:) userInfo: nil repeats: YES];

    [self switchToView:kTABBAR_MainBar selectedTab:tab viewController:NULL];
}


-(void)applicationDidEnterBackground
{
    // suspend timer
    [_timer invalidate]; 
    _timer = nil;
}


-(void)applicationWillEnterForeground
{
    // resume timer
    _timer= [NSTimer scheduledTimerWithTimeInterval: _timerInterval target: self selector: @selector(handleTimer:) userInfo: nil repeats: YES];
}


- (void) handleTimer:(NSTimer*)timer 
{    
    int readyCount = [gPhotoUploader readyToUploadCount];       // left to upload
    
    if (readyCount > 0) {
        // show upload status
        
        if (![gPhotoUploader suspended]) {
            
            if (_timerInterval > 0.1) {
                // reset for faster interval
                [_timer invalidate];    
                _timerInterval = 0.1;
                _timer= [NSTimer scheduledTimerWithTimeInterval: _timerInterval target: self selector: @selector(handleTimer:) userInfo: nil repeats: YES];
            }
            
            int totalCount = [gPhotoUploader totalReadyUpload];  

            if (!_uploadingStatus) {
                
                // initialize views
                
                _uploadingStatus = [[UIView alloc]initWithFrame:CGRectMake(0,-20,320,20)];
                [_uploadingStatus setBackgroundColor:[UIColor blackColor]];
                [self.view addSubview:_uploadingStatus];             
                
                //CGSize textSize = [text sizeWithFont:backButton.titleLabel.font];
                
                // height is 9
                int width = 130;
                _uploadingProgress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
                _uploadingProgress.frame = CGRectMake(width+5,5,320-(width+10),10);
                [_uploadingProgress setBackgroundColor:[UIColor clearColor]];
                _uploadingProgress.progress = 0;
                [_uploadingStatus addSubview:_uploadingProgress]; 
                
                _uploadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(3,0,width,18)];
                [_uploadingLabel setBackgroundColor:[UIColor clearColor]];
                [_uploadingLabel setTextColor:[UIColor colorWithRed: 191.0/255.0 green: 191.0/255.0 blue: 191.0/255.0 alpha: 1.0]];
                _uploadingLabel.font = [UIFont boldSystemFontOfSize:13];
                _uploadingLabel.textAlignment = UITextAlignmentCenter;
                [_uploadingStatus addSubview:_uploadingLabel];
                
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            }
            
            float bytesToUpload = [gPhotoUploader bytesToUpload];
            float bytesUploaded = [gPhotoUploader bytesUploaded];

            // x parts n of n / y parts MB left
            _uploadingPhase++;
            if (_uploadingPhase >= 60)
                _uploadingPhase = 0;
            
            // update status
            _uploadingLabel.text = [NSString stringWithFormat:@"Uploading %d of %d",(totalCount-readyCount)+1,totalCount];

            if (gZZ.p1 && _uploadingPhase >= 40) {
                // alternate with MB left
                
                _uploadingLabel.text = [NSString stringWithFormat:@"%.2f MB left", (bytesToUpload-bytesUploaded) / 1024 / 1024];
            }
            
            [_uploadingLabel setNeedsDisplay];            

            float p = bytesUploaded/bytesToUpload;            
            _uploadingProgress.progress = p;
        }
        
    } else {
        // dismiss if showing
        if (_uploadingStatus) {
            
            [_uploadingProgress removeFromSuperview];
            _uploadingProgress = nil;
            [_uploadingLabel removeFromSuperview];
            _uploadingLabel = nil;
            
            [_uploadingStatus removeFromSuperview];
            _uploadingStatus = nil;
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
        
        // slow timer
        if (_timerInterval < 1.0) {
            // reset for faster interval
            [_timer invalidate];    
            _timerInterval = 1.0;
            _timer= [NSTimer scheduledTimerWithTimeInterval: _timerInterval target: self selector: @selector(handleTimer:) userInfo: nil repeats: YES];
        }
    }
}


-(void)switchToView:(NSUInteger)bar selectedTab:(NSInteger)selectedTab viewController:(ZZUIViewController*)viewController
{
       
    _setviewcontroller = nil;
    _setviewcontroller = viewController;
    _actionviewcontroller = viewController;
    
    [self switchTabbar:bar selectedTab:selectedTab];
    
    if (!viewController) {
        NSDictionary* data = [_tabbarItems objectAtIndex:selectedTab];
        _setviewcontroller = [self viewControllerFactory:[data objectForKey:@"viewController"]];
    }
    
    _wasfullscreen = _isfullscreen;
    [self setToViewController];
}


-(void)switchTabbar:(NSUInteger)bar selectedTab:(NSInteger)selectedTab actionViewController:(ZZUIViewController*)actionViewController
{
    [self switchTabbar:bar selectedTab:selectedTab];
    _actionviewcontroller = actionViewController;
}


-(void)switchTabbar:(NSUInteger)bar selectedTab:(NSInteger)selectedTab
{
    _activebar = bar;
    _settab = selectedTab;
    
    switch (bar) {
        case 1:
            _tabbarItems = _bar1;
            _tabbarSpec = _barspec1;
            
            [gZZ setIntegerForSetting:[ZZSession currentUser].user_id setting:@"tabbar_main_tab" value:selectedTab];
            break;
            
        case 2:
            _tabbarItems = _bar2;
            _tabbarSpec = _barspec2;
            break;
            
        case 3:
            _tabbarItems = _bar3;
            _tabbarSpec = _barspec3;
            break;
            
        case 4:
            _tabbarItems = _bar4;
            _tabbarSpec = _barspec4;
            break;
            
        case 5:
            _tabbarItems = _bar5;
            _tabbarSpec = _barspec5;
            break;
            
        default:
            return;
            break;
    }
    
    if (tabbar) {
        [tabbar removeFromSuperview];
    }
        
    // Create a ZZTabBar passing in the number of items, the size of each item and setting ourself as the delegate
    self.tabbar = [[ZZTabBar alloc] initWithItemCount:_tabbarItems.count itemSize:CGSizeMake(self.view.frame.size.width/_tabbarItems.count, TABBAR_HEIGHT) tag:0 delegate:self];
    
    // Place the tab bar at the bottom of our view
    tabbar.frame = CGRectMake(0,self.view.frame.size.height-TABBAR_HEIGHT,self.view.frame.size.width, TABBAR_HEIGHT);
    
    [self.view addSubview:tabbar];
    
    if (selectedTab >= 0) 
        [tabbar selectItemAtIndex:selectedTab];
}


-(void)setTabbarText:(NSString*)text
{
    [tabbar setText:text];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated
{
}



- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    MLOG(@"MainViewController: willShowViewController");
    
    if ([viewController respondsToSelector:@selector(willAppearIn:)])
        [viewController performSelector:@selector(willAppearIn:) withObject:navigationController];
}


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    MLOG(@"MainViewController: didShowViewController");
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    
    
    NSString *rotate = [_tabbarSpec objectForKey:@"rotate"];
    if (rotate  && [rotate isEqualToString:@"YES"])
        return YES;
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
	NSString *rotate = [_tabbarSpec objectForKey:@"rotate"];
    if (rotate  && [rotate isEqualToString:@"YES"]) {
        
        [tabbar willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        [_setviewcontroller willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
	
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	NSString *rotate = [_tabbarSpec objectForKey:@"rotate"];
    if (rotate  && [rotate isEqualToString:@"YES"])
        [_setviewcontroller willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSString *rotate = [_tabbarSpec objectForKey:@"rotate"];
    if (rotate  && [rotate isEqualToString:@"YES"])
        [_setviewcontroller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


#pragma mark -
#pragma mark ZZTabBarDelegate

- (NSString*) style 
{
    return [_tabbarSpec objectForKey:@"style"];
}

- (int) xposFor:(ZZTabBar*)tabBar atIndex:(NSUInteger)itemIndex
{
    NSDictionary* data = [_tabbarItems objectAtIndex:itemIndex];
    NSNumber *x = [data objectForKey:@"xpos"];
    if (x) 
        return [x intValue];
    
    return -1;
}


- (int) yposFor:(ZZTabBar*)tabBar atIndex:(NSUInteger)itemIndex
{
    NSDictionary* data = [_tabbarItems objectAtIndex:itemIndex];
    NSNumber *y = [data objectForKey:@"ypos"];
    if (y) 
        return[y intValue];
    
    return -1;
}


- (NSString*) textFor:(ZZTabBar*)tabBar atIndex:(NSUInteger)itemIndex
{
    NSDictionary* data = [_tabbarItems objectAtIndex:itemIndex];
    return [NSString stringWithString:[data objectForKey:@"text"]];
}


- (ZZTabBarItemImageType) imageType:(ZZTabBar *)tabBar atIndex:(NSUInteger)itemIndex
{
    NSDictionary* data = [_tabbarItems objectAtIndex:itemIndex];
    NSString* imageType = [data objectForKey:@"imageType"];
    
    if ([imageType isEqualToString:@"imageset"])
        return imageSet;
    else if ([imageType isEqualToString:@"camera"])
        return imageCamera;
    if ([imageType isEqualToString:@"none"])
        return imageNone;
    if ([imageType isEqualToString:@"buttonset"])
        return buttonSet;
    else
        return imageMask;
}

- (UIImage*) imageFor:(ZZTabBar*)tabBar atIndex:(NSUInteger)itemIndex selected:(BOOL)selected
{
    // return the image for this tab bar item
    
    NSDictionary* data = [_tabbarItems objectAtIndex:itemIndex];    
    NSString *imageName = NULL;
    if (selected)
        imageName = [data objectForKey:@"imageSelected"];
    if (!imageName)
        imageName = [data objectForKey:@"image"];
    
    
    return [UIImage imageNamed:[[NSString alloc]initWithString:imageName]];
}

- (UIImage*) backgroundImage
{
    /*
    NSString *style = [_tabbarSpec objectForKey:@"style"];
    
    // The tab bar's width is the same as our width
    CGFloat width = self.view.frame.size.width;
    // Get the image that will form the top of the background
    UIImage* topImage = [UIImage imageNamed:[_tabbarSpec objectForKey:@"gradient-top"]];
    
    // Create a new image context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, topImage.size.height*2), NO, 0.0);
    
    // Create a stretchable image for the top of the background and draw it
    UIImage* stretchedTopImage = [topImage stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [stretchedTopImage drawInRect:CGRectMake(0, 0, width, topImage.size.height)];
    
    // Draw a solid black color for the bottom of the background 
    if ([style isEqualToString:@"dark+solid"]) 
        [[UIColor colorWithRed:44.0/255.0 green:44.0/255.0 blue:44.0/255.0 alpha:1.0] set];
    else
        [[UIColor colorWithRed:44.0/255.0 green:44.0/255.0 blue:44.0/255.0 alpha:1.0] set];
    //[[UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0] set];
    
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, topImage.size.height, width, topImage.size.height));
    
    // Generate a new image
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
    */
    
    return [UIImage imageNamed:[_tabbarSpec objectForKey:@"tabbarbackground"]];
}

// This is the blue background shown for selected tab bar items
- (UIImage*) selectedItemBackgroundImage
{
    return [UIImage imageNamed:@"TabBarItemSelectedBackground.png"];
}

// This is the glow image shown at the bottom of a tab bar to indicate there are new items
- (UIImage*) glowImage
{
    UIImage* tabBarGlow = [UIImage imageNamed:@"TabBarGlow.png"];
    
    // Create a new image using the TabBarGlow image but offset 4 pixels down
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tabBarGlow.size.width, tabBarGlow.size.height-4.0), NO, 0.0);
    
    // Draw the image
    [tabBarGlow drawAtPoint:CGPointZero];
    
    // Generate a new image
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

// This is the embossed-like image shown around a selected tab bar item
- (UIImage*) selectedItemImage
{
    CGSize tabBarItemSize = CGSizeMake(self.view.frame.size.width/_tabbarItems.count, TABBAR_HEIGHT);
    UIGraphicsBeginImageContextWithOptions(tabBarItemSize, NO, 0.0);
    
    // Create a stretchable image using the TabBarSelection image but offset 4 pixels down
    //[[[UIImage imageNamed:@"TabBarSelection.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:0] drawInRect:CGRectMake(0, 4.0, tabBarItemSize.width, tabBarItemSize.height-4.0)]; 
    
    [[[UIImage imageNamed:@"TabBarSelection.png"] stretchableImageWithLeftCapWidth:4.0 topCapHeight:0] drawInRect:CGRectMake(0, 0, tabBarItemSize.width, tabBarItemSize.height)]; 
    
    // Generate a new image
    UIImage* selectedItemImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return selectedItemImage;
}

- (UIImage*) tabBarArrowImage
{
    return [UIImage imageNamed:@"TabBarNipple.png"];
}


- (void) setToViewController
{
    /*  iPhone dimensions (magic numbers):
     width  = 320
     height = 480 (460 without status bar)
     */
    
    // Remove the current view controller's view
    UIView* currentView = [self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];
    if (currentView)
        [currentView removeFromSuperview];
    currentView = nil;
    
    NSString *style = [_tabbarSpec objectForKey:@"style"];
    NSString *size = [_tabbarSpec objectForKey:@"size"];
    
    BOOL fullscreen = NO;
    if (size  && [size isEqualToString:@"full+"])
        fullscreen = YES;
    
    int x1 = 0;
    int y_adjust_current = 0;
    int y, y_main;    
    int height, height_main;
    
    // Set the view controller's frame to account for the tab bar
    if ([style isEqualToString:@"dark+solid"]) { 
        
        y_main = 20;
        y = 0;
        
        height_main = 460;
        height = 460;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
        self.view.frame = CGRectMake(0,y_main,320,height_main);
        self.wantsFullScreenLayout = NO;
        _setviewcontroller.view.frame = CGRectMake(x1,y,320,height);
        
        //[ZZUtil setOrientation:UIDeviceOrientationPortrait];
        
        _isfullscreen = NO;
        
        if (_wasfullscreen)
            y_adjust_current = -20;
    }
    else {
        if (fullscreen) {
            
            y_main = 0;
            y = 0;
            
            height_main = 480;
            height = 480;
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
            self.view.frame = CGRectMake(0,y_main,320,height_main);
            self.wantsFullScreenLayout = YES;
            _setviewcontroller.view.frame = CGRectMake(x1,y,320,height); 
            
            _isfullscreen = YES;
            
            if (_wasfullscreen == NO) {
                y_adjust_current = 20;
            }
            
        } else {
            
            y_main = 20;
            y = 0;
            
            height_main = 460;
            height = 460;
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
            self.view.frame = CGRectMake(0,y_main,320,height_main);
            self.wantsFullScreenLayout = NO;
            _setviewcontroller.view.frame = CGRectMake(x1,y,320,height);
            
            //[ZZUtil setOrientation:UIDeviceOrientationPortrait];
            
            _isfullscreen = NO; 
            
            if (_wasfullscreen)
                y_adjust_current = -20;
        }
    }
    
    /*
     MLOG(@"MainViewController view.frame: x:%f y:%f width:%f height:%f", self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height);
     MLOG(@"MainViewController view.center: x:%f y:%f", self.view.center.x, self.view.center.y);
     MLOG(@"setToViewController view.frame: x:%f y:%f width:%f height:%f", _setviewcontroller.view.frame.origin.x,_setviewcontroller.view.frame.origin.y,_setviewcontroller.view.frame.size.width, _setviewcontroller.view.frame.size.height);
     MLOG(@"setToViewController view.center: x:%f y:%f", _setviewcontroller.view.center.x, _setviewcontroller.view.center.y);
     
     MLOG(@"MainViewController view.bounds: x:%f y:%f width:%f height:%f", self.view.bounds.origin.x,self.view.frame.origin.y,self.view.bounds.size.width, self.view.bounds.size.height);
     MLOG(@"setToViewController view.bounds: x:%f y:%f width:%f height:%f", _setviewcontroller.view.bounds.origin.x,_setviewcontroller.view.bounds.origin.y,_setviewcontroller.view.bounds.size.width, _setviewcontroller.view.bounds.size.height); 
     */
    
    // Set the tag so we can find it later
    _setviewcontroller.view.tag = SELECTED_VIEW_CONTROLLER_TAG;
    
    // Add the new view controller's view
    [self.view insertSubview:_setviewcontroller.view belowSubview:tabbar];
    
    [_setviewcontroller viewWillAppear:YES];
    
    [self hideTabbar:NO];
    tabbar.frame = CGRectMake(0,self.view.frame.size.height-TABBAR_HEIGHT,self.view.frame.size.width, TABBAR_HEIGHT);
    
    // In 1 second glow the selected tab
    //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(addGlowTimerFireMethod:) userInfo:[NSNumber numberWithInteger:itemIndex] repeats:NO];
    
    // refresh model for logged in user
    if ([ZZSession currentSession])
        [gAlbums refreshalbumsets:[ZZSession currentUser].user_id];
    
    if ([_setviewcontroller respondsToSelector:@selector(switchToView)]) 
		[_setviewcontroller switchToView];
}


- (void) handleTouch:(NSUInteger)itemIndex
{
    // find correct tabbar item
    NSEnumerator *e = [_tabbarItems objectEnumerator];
    NSDictionary* data;
    while (data = [e nextObject]) {
        NSInteger index = [(NSNumber*)[data objectForKey:@"actionIndex"] intValue];
        if (index == itemIndex)
            break;
    }
    
    NSString* vcname = [data objectForKey:@"viewController"];
    if ([vcname isEqualToString:@"CameraViewController"]) {
        [ZZUtil setOrientation:UIDeviceOrientationPortrait];
    }
    ZZUIViewController* viewController = [self viewControllerFactory:vcname];
    
    if (viewController) {
        // switch to view controller
        
        ZZUIViewController *currentvc = _setviewcontroller;
        
        // if the current view controller is a navcontroller, call switchFromView on each pushed view controller and pop
        // otherwise just call switchFromView on the existing view controller
        if ([currentvc isKindOfClass:[UINavigationController class]]) {
            NSArray *navvcs = ((UINavigationController*)currentvc).viewControllers;
            
            for (int n = navvcs.count-1; n >= 0; n--) {
                
                UIViewController *v = [navvcs objectAtIndex:n];
                if ([v respondsToSelector:@selector(switchFromView)])  {
                    [v performSelector:@selector(switchFromView) withObject:nil];
                }
                
                if (n > 0)
                    [currentvc.navigationController popViewControllerAnimated:NO];
            }
        } else {
            if ([currentvc respondsToSelector:@selector(switchFromView)])  {
                [currentvc performSelector:@selector(switchFromView) withObject:nil]; 
            }
        }
        
        _setviewcontroller = nil;

        // set to new viewcontroller
        _setviewcontroller = viewController;
        [self setToViewController];
    } else {
        // call action on _setviewcontroller
        NSString* action = [data objectForKey:@"action"];
        
        if (action) {
            if (_actionviewcontroller) {                
                if ([_actionviewcontroller respondsToSelector:@selector(actionView:)]) {
                    MLOG(@"calling action view controller with action: %@", action);
                    [_actionviewcontroller performSelector:@selector(actionView:) withObject:action afterDelay:.01];
                }
            } else {
                UIViewController *vc = _setviewcontroller;
                if (vc && [vc isKindOfClass:[UINavigationController class]])
                    vc = [((UINavigationController*)vc).viewControllers objectAtIndex:0];
                
                if (vc)
                    if ([vc respondsToSelector:@selector(actionView:)])  {
                        //[(ZZUIViewController*)vc actionView:action];  
                        MLOG(@"calling set view controller with action: %@", action);
                        [vc performSelector:@selector(actionView:) withObject:action afterDelay:.01];
                    }
            }
        }
    }
}


- (void) touchUpInsideItemAtIndex:(NSUInteger)itemIndex
{
    MLOG(@"touchUpInsideItemAtIndex");
    [self handleTouch:itemIndex];
}


- (void) touchDownAtItemAtIndex:(NSUInteger)itemIndex
{   
    MLOG(@"touchDownAtItemAtIndex");
    [self handleTouch:itemIndex];
}

- (void)addGlowTimerFireMethod:(NSTimer*)theTimer
{
    // Remove the glow from all tab bar items
    for (NSUInteger i = 0 ; i < _tabbarItems.count ; i++)
    {
        [tabbar removeGlowAtIndex:i];
    }
    
    // Then add it to this tab bar item
    [tabbar glowItemAtIndex:[[theTimer userInfo] integerValue]];
}

-(void)hideTabbar:(BOOL)hidden
{
    [tabbar setHidden:hidden];
}


-(BOOL)isFullScreen
{
    return _isfullscreen;
}

@end
