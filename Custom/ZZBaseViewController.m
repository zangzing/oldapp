//
//  ZZBaseViewController.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/27/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZBaseViewController.h"
#import "ZZUINavigationBar.h"

@implementation ZZBaseViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
   
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)useDefaultNavigationBarStyle
{
    ZZUINavigationBar* navbar = (ZZUINavigationBar*)self.navigationController.navigationBar;
    [navbar setBackgroundWith:[UIImage imageNamed:@"nav-background.png"]];
}


- (void)setTitle:(NSString *)title
{
    [super setTitle:title];    
    if( _titlelabel == nil ){
        _titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,170,30)];
        _titlelabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.0];
        _titlelabel.font = [UIFont boldSystemFontOfSize:20.0f];
        _titlelabel.textColor = [UIColor blackColor];
        _titlelabel.shadowColor = [UIColor whiteColor];
        _titlelabel.shadowOffset = CGSizeMake(0, 1);
        _titlelabel.textAlignment = UITextAlignmentCenter;
        UIView *titleview = [[UIView alloc]initWithFrame:CGRectMake(0,0,170,30)];
        [titleview addSubview:_titlelabel];        
        self.navigationItem.titleView = titleview;
    }
    _titlelabel.text = title;
}

// use a custom back button wth the previous
// view controller as its text and a defaul pop view action
- (void)useCustomBackButton
{
    [self useCustomBackButton:nil target:nil action:nil];
}

// use a custom back button wth the previous
// view controller as its text and a defaul pop view action
- (void)useCustomBackButton:(NSString *)text
{
    [self useCustomBackButton:text target:nil action:nil];
}

// Use a custom Arrow-Back-Button with specific title and target action
- (void)useCustomBackButton:(NSString *)text target:(id)target action:(SEL)action
{
    // Get our custom nav bar
    ZZUINavigationBar* zzNavBar = (ZZUINavigationBar*)self.navigationController.navigationBar;
    
    // User custom nav bar to create custom back button
    // using previous controller name as text default
    UIButton* backButton = [zzNavBar backButtonWith:[UIImage imageNamed:@"back-gray-landscape.png"] highlight:[UIImage imageNamed:@"back-gray-landscape-highlighted.png"] leftCapWidth:18.0];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
   
    if( text ){
        [zzNavBar setText:text onBackButton:backButton];
    }
    if( target && action ){
        [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside]; 
    }else{
        [backButton addTarget:self action:@selector( defaultBackAction:) forControlEvents:UIControlEventTouchUpInside];         
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];    
}

// Use a custom Square-Cancel-Button with specific target action
- (void)useGrayCancelRightButton:(id)target action:(SEL)action
{
   [self useGraySquareButton:RIGHT_SIDE
                        text:NSLocalizedString(@"Cancel", @"Cancel Label for NavBar right hand gray cancel button")
                       target:target 
                       action:action];
}
// Use a custom Square-Cancel-Button with specific target action
- (void)useGrayEditRightButton:(id)target action:(SEL)action
{
    [self useGraySquareButton:RIGHT_SIDE
                         text:NSLocalizedString(@"Edit", @"Edit Label for NavBar right hand gray cancel button")
                        target:target 
                        action:action];
}
// Use a custom Square-Cancel-Button with specific target action
- (void)useGrayDoneRightButton:(id)target action:(SEL)action
{
    [self useGraySquareButton:RIGHT_SIDE
                         text:NSLocalizedString(@"Done", @"Done Label for NavBar right hand gray cancel button")
                        target:target
                        action:action];
}

// Use a custom Square-Cancel-Button with specific title and target action
- (void)useGraySquareButton:(int)side text:(NSString *)text target:(id)target action:(SEL)action
{
    // Get our custom nav bar
    ZZUINavigationBar* zzNavBar = (ZZUINavigationBar*)self.navigationController.navigationBar;    
    // User custom nav bar to create custom back button
    UIButton* button = [zzNavBar graySquareButtonWith:text];
    
    if( target && action ){
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside]; 
    }
    if( side == LEFT_SIDE ){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];    
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];            
    }
}


//Use a custom Right Button with specific text and action
// Add Green Done Button
- (void) useGreenRightButton:(NSString *)text target:(id)target action:(SEL)action
{
    ZZUINavigationBar* zzNavBar = (ZZUINavigationBar*)self.navigationController.navigationBar;    
    // User custom nav bar to create custom GREEN button
    // using previous controller name as text default
    UIButton* rightButton = [zzNavBar greenSquareButtonWith:text ];
    [rightButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}


-(void)clearRightButton
{
    self.navigationItem.rightBarButtonItem = NULL;
}

- (IBAction) defaultBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];    
}

-(void) showUnderConstructionAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Construction Zone", @"Under Construction Alert Title") 
                                                    message:NSLocalizedString(@"This feature is currently under construction.", @"Under construction Alert Text") 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

// sets the image as a background texture
// READ THIS:
// do not use images larger than 1024 x 1024 or OpenGL ES will barf
// excerpt from UIImage info in UIKit docs for apple:
// You should avoid creating UIImage objects that are greater than 1024 x 1024 in size. 
// Besides the large amount 
// of memory such an image would consume, you may run into problems when using the image as a texture in OpenGL 
// ES or when drawing the image to a view or layer. This size restriction does not apply if you are performing 
// code-based manipulations, such as resizing an image larger than 1024 x 1024 pixels by drawing it to a bitmap
// backed graphics context. In fact, you may need to resize an image in this manner (or break it into several 
// smaller images) in order to draw it to one of your views.

-(void) setBackgroundImage:(UIImage *)image;
{
     if( image ){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.alpha = 0.5f;       
        self.view.backgroundColor = [UIColor blackColor];
        [self.view addSubview:imageView];
        [self.view sendSubviewToBack:imageView];
    }
}
@end
