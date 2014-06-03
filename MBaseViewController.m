//
//  MBaseViewController.m
//  Moment
//
//  Created by Mauricio Alvarez on 5/22/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "MBaseViewController.h"
#import "LoginViewController.h"

@interface MBaseViewController ()

@end

@implementation MBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) presentLoginDialog
{
    
    LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
    if (vc) {
        //vc.parent = self;
        vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:vc animated:YES];
    }

}

@end
