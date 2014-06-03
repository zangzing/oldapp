//
//  AlbumSettingsViewController.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/23/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "AlbumSettingsViewController.h"
#import "WhoOptionsViewController.h"
#import "photouploader.h"

@implementation AlbumSettingsViewController

@synthesize settings;
@synthesize delegate=_delegate;
@synthesize whoCanUpload;
@synthesize whoCanDownload;
@synthesize whoCanBuy;

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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];       
    self.navigationController.navigationBarHidden = NO;
    [self useDefaultNavigationBarStyle];
    self.title  = NSLocalizedString( @"Album Settings", @"Album Settings Screen Title (who can do what)");
    [self useCustomBackButton:NSLocalizedString(@"Back", @"Back Button atop Album Settings View Controller")];
    [self setBackgroundImage: [gPhotoUploader lastPhotoScreenSize]];    

    //Customize table
    settings.backgroundColor = [UIColor clearColor];

    
    // Get current values from delegate
    self.whoCanUpload     = _delegate.whoCanUpload;
    self.whoCanDownload   = _delegate.whoCanDownload;
    self.whoCanBuy        = _delegate.whoCanBuy;            
} 

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *AlbumSettingsCellIdentifier = @"AlbumSettingsCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: AlbumSettingsCellIdentifier];

    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:AlbumSettingsCellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;  
    }    

    int pos = [indexPath indexAtPosition: 1];   
    switch (pos) {
        case 0:
            cell.textLabel.text = NSLocalizedString( @"Add Photos", @"Album Settings Who Can Add Photos Option");
            cell.detailTextLabel.text =  [ZZAlbum albumWhoOptionToDisplayString: self.whoCanUpload];
            return cell;
        case 1:
            cell.textLabel.text = NSLocalizedString( @"Download" , @"Album Settings Who Can Download Originals Option");
            cell.detailTextLabel.text =  [ZZAlbum albumWhoOptionToDisplayString: self.whoCanDownload];
            return cell;
        case 2:
            cell.textLabel.text = NSLocalizedString( @"Buy" , @"Album Settings Who Can Buy Option");
            cell.detailTextLabel.text =  [ZZAlbum albumWhoOptionToDisplayString: self.whoCanBuy];
            return cell;
        default:
            return NULL;
    }
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{   
    if( optionsController == nil){ 
          }
    
    int pos = [indexPath row ];   
    switch (pos) {
        case 0:
            optionsController = [[WhoOptionsViewController alloc] initWithStyle:WhoOptionsViewUploadStyle optionsDelegate:self];
            break;
        case 1:
            optionsController = [[WhoOptionsViewController alloc] initWithStyle:WhoOptionsViewDownloadStyle optionsDelegate:self];
            break;
        case 2:
            optionsController = [[WhoOptionsViewController alloc] initWithStyle:WhoOptionsViewBuyStyle optionsDelegate:self];
            break;
        default:
            return;
    }
    [self.navigationController pushViewController:optionsController animated:YES]; 
}

- (void)didChangeWhoOption:(WhoOptionsViewStyle)style whoOption:(ZZAPIAlbumWhoOption)option
{
    switch( style ){        
        case WhoOptionsViewUploadStyle:
            self.whoCanUpload = option;            
            break;
        case WhoOptionsViewDownloadStyle:
            self.whoCanDownload = option;            
            break;
        case WhoOptionsViewBuyStyle:
            self.whoCanBuy = option;
            break;            
        default:
            [NSException raise:NSGenericException format:@"Unexpected style."];
    }
    if( _delegate ){
        [_delegate didChangeWhoOption:style whoOption:option];
    }
}

-(void) setWhoCanDownload: (ZZAPIAlbumWhoOption) input
{
    if( settings ){
        [settings cellForRowAtIndexPath: [NSIndexPath indexPathForRow:1 inSection:0]].detailTextLabel.text =  [ZZAlbum albumWhoOptionToDisplayString:input];
    }
}
-(void) setWhoCanUpload: (ZZAPIAlbumWhoOption) input
{
    if(settings){
        [settings cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]].detailTextLabel.text =  [ZZAlbum albumWhoOptionToDisplayString:input]; 
    }
}
-(void) setWhoCanBuy: (ZZAPIAlbumWhoOption) input
{
    if( settings ){
        [settings cellForRowAtIndexPath: [NSIndexPath indexPathForRow:2 inSection:0]].detailTextLabel.text =  [ZZAlbum albumWhoOptionToDisplayString:input];
    }
}
- (ZZAPIAlbumWhoOption) whoCanDownload
{
    return [_delegate whoCanDownload];
}
- (ZZAPIAlbumWhoOption) whoCanUpload
{

        return [_delegate whoCanUpload];
}
- (ZZAPIAlbumWhoOption) whoCanBuy
{
    return [_delegate whoCanBuy];
}
- (IBAction) back:(id)sender
{
 [self.navigationController popViewControllerAnimated:YES];       
}
@end
