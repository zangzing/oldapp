//
//  GroupAddViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 2/13/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zzglobal.h"
#import "UIFactory.h"
#import "GroupEditViewController.h"
#import "GroupAddViewController.h"

@implementation GroupAddViewController

@synthesize groupedit=_groupedit;
@synthesize group=_group;
@synthesize delegate=_delegate;
@synthesize allowTypeSelection=_allowTypeSelection;

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
    
    // nav bar
    [self useDefaultNavigationBarStyle];
    self.title = _group.name;
    [self useCustomBackButton:@"Back" target:self action:@selector(backButtonAction:)];   
    
    
    int selectedSegment;
    if (_group.sharePermission == kShareAsContributor) 
        selectedSegment = 0;
    else if (_group.sharePermission == kShareAsViewer)
        selectedSegment = 1;
    
    if (_allowTypeSelection) {
        NSDictionary *grouptypedef = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"Add Photos", @"View Photos", nil], @"titles", [NSValue valueWithCGSize:CGSizeMake(90,30)], @"size", @"segment.png", @"button-image", @"segment-selected.png", @"button-highlight-image", @"segment-separator.png", @"divider-image", [NSNumber numberWithFloat:11.0], @"cap-width", [UIColor blackColor], @"button-color", [UIColor blackColor], @"button-highlight-color", nil];
        
        _grouptype = [[ZZSegmentedControl alloc] initWithSegmentCount:2 selectedSegment:selectedSegment segmentdef:grouptypedef tag:0 delegate:self];
        _grouptype.frame = CGRectMake(70, 95, _grouptype.frame.size.width, _grouptype.frame.size.height);    // adjust location
        
        [self.view addSubview:_grouptype];
    }
    
    _addgroup = [UIFactory screenWideGreenButton: NSLocalizedString(@"Add Group", @"Add Group Button Text") frame:CGRectMake(9, 363, 302, 46)];
	[self.view addSubview:_addgroup];
    [_addgroup addTarget:self action:@selector(addGroupAction:) forControlEvents:UIControlEventTouchUpInside];    

    UIColor *bcolor = [UIColor colorWithRed: 221.0/255.0 green: 221.0/255.0 blue: 221.0/255.0 alpha: 1.0];
    [self.view setBackgroundColor:bcolor];
    [_groupedit setBackgroundColor:bcolor];
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
    return 1;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GroupEditViewController *groupeditvc = [[GroupEditViewController alloc] initWithNibName:@"GroupEdit" bundle:[NSBundle mainBundle]];
    groupeditvc.delegate = self;
    [groupeditvc setGroup:_group];
    [groupeditvc setGroupEditMode:kGroupEditMode];
    [groupeditvc setAllowGroupDelete:NO];
    [self.navigationController pushViewController:groupeditvc animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;  
    cell.textLabel.text = _group.name;
    
    return cell;
}


-(void)backButtonAction:(id)sender
{
    MLOG(@"backButtonAction");
    
    [_delegate groupAddCancel];
}


- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    if (segmentIndex == 0) 
        _group.sharePermission = kShareAsContributor;
    else
        _group.sharePermission = kShareAsViewer;
}


-(void)addGroupAction:(id)sender
{
    MLOG(@"addGroupAction");
    
    [_delegate groupAddDone:_group];
}


-(void)groupEditComplete:(ZZGroup*)group changed:(BOOL)changed;
{
    [self.navigationController popViewControllerAnimated:YES];          
    
    if (changed) {
        _group = group;
        self.title = _group.name;
        [_groupedit reloadData];
    }
}


-(void)groupEditDeleteGroup:(ZZGroupID)groupid
{
}

-(void)groupEditNew:(ZZGroup*)group
{
    
}



@end
