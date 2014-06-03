//
//  WhoOptionsViewController.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/23/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "WhoOptionsViewController.h"
#import "photouploader.h"


@implementation WhoOptionsViewController

@synthesize optionsTable;
@synthesize delegate;

//
//User must specify which style and who is the delegate for this options view
//
- (id) initWithStyle: (WhoOptionsViewStyle) style optionsDelegate:(id<WhoOptionsViewDelegate>) optionsDelegate
{
    self = [super initWithNibName: @"WhoOptions" bundle:NULL];
    if (self) {
        viewStyle = style;
        delegate  = optionsDelegate;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//
// Setup the view according to the style selected
//
- (void)viewDidLoad 
{   
    [super viewDidLoad]; 
    [self useDefaultNavigationBarStyle];
    [self useCustomBackButton:NSLocalizedString(@"Back", @"Back Button atop Who Options View Controller")];
    [self setBackgroundImage:[gPhotoUploader lastPhotoScreenSize]];
    optionsTable.backgroundColor = [UIColor clearColor];
    
    switch( viewStyle ){
        case WhoOptionsViewBuyStyle:
            self.title = NSLocalizedString(@"Buy", @"Who options VC title for who can buy photos");
            //self.list = [[NSArray alloc] initWithObjects: @"Everyone",  @"Viewers",  @"Owner", nil];
            list[0] = kEveryone;
            list[1] = kViewers;
            list[2] = kOwner;
            cellCount=3;
            self.whoCan = [delegate whoCanBuy];
            break;
        case WhoOptionsViewUploadStyle:
            self.title = NSLocalizedString(@"Add Photos", @"Who options VC title for who can add photos");
            //self.list = [[NSArray alloc] initWithObjects: @"Everyone", @"Contributors", nil]; 
            list[0] = kEveryone;
            list[1] = kContributors;
            cellCount = 2;
            self.whoCan = [delegate whoCanUpload];
            break;
        default:
        case WhoOptionsViewDownloadStyle:
            self.title = NSLocalizedString(@"Download", @"Who options VC title for who can download photos");
            //self.list = [[NSArray alloc] initWithObjects: @"Everyone", @"Viewers",  @"Owner", nil];
            list[0] = kEveryone;
            list[1] = kViewers;
            list[2] = kOwner;
            cellCount =3;
            self.whoCan = [delegate whoCanDownload];
            break;
    }
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ 
    return cellCount; 
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CheckMarkCellIdentifier = @"CheckMarkCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CheckMarkCellIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CheckMarkCellIdentifier];
    }    
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [ZZAlbum albumWhoOptionToDisplayString:list[row]];
    cell.accessoryType = (row == whoCan ) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell; 
} 

//
// Whenever a user clicks on a cell, change the option notify the delegate
// and pop the view
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    int newRow = [indexPath row];
    int oldRow = whoCan;
    if (newRow != oldRow){
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath: indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:whoCan inSection: 0]];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        whoCan = newRow;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    [delegate didChangeWhoOption:viewStyle whoOption: self.whoCan];
    [self.navigationController popViewControllerAnimated:YES];   
}

// 
// setup the UI based on the whoOption
//
- (void) setWhoCan:(ZZAPIAlbumWhoOption) input
{

    NSInteger newRowIndex = -1;

    for( int i=0; i < cellCount; i++){
        if( input == list[i]){
            newRowIndex = i; 
            break;
        }
    }
    
    //Check if newRowIndex was set
    if( newRowIndex == -1 ){
        [NSException raise:NSGenericException format:@"Unexpected ZZAPIAlbumWhoCanOption while setting WhoCan."];
    }
    
    UITableViewCell *newCell = [optionsTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:newRowIndex  inSection:0]];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    if( newRowIndex != whoCan ){
        UITableViewCell *oldCell = [optionsTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:whoCan inSection: 0]];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        whoCan = newRowIndex;   
    }
}

- (ZZAPIAlbumWhoOption) whoCan
{    
    return list[whoCan];    
}
@end