//
//  SelectGroupViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 1/29/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zzglobal.h"
#import "ZZUINavigationBar.h"
#import "GroupAddViewController.h"
#import "SelectGroupViewController.h"

@implementation SelectGroupViewController

@synthesize selectgroup=_selectgroup;
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
    self.title = @"Select Group";
    [self useCustomBackButton:@"Back" target:self action:@selector(backButtonAction:)];  
    
    _groups = [[ZZSession currentUser] getGroups];
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


-(void)setExcludeGroups:(NSArray*)excludeGroups
{
    _excludeGroups = excludeGroups;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _useGroups = [[NSMutableArray alloc]initWithCapacity:_groups.count];
        
    int gindex = 0;
    for (ZZGroup *g in _groups) {
        
        BOOL exclude = NO;
        
        if (_excludeGroups) {
            for (ZZGroup *gx in _excludeGroups) {
                if (g.id == gx.id) {
                    exclude = YES;
                    break;
                }
            }
        }
        
        if (!exclude)
            [_useGroups addObject:[NSNumber numberWithInt:gindex]];
        
        gindex++;
    }
    
    if (_useGroups.count == 0)
        return 1;
    
    return _useGroups.count;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    if (_useGroups.count == 0) 
        return;
    
    NSNumber *gi = [_useGroups objectAtIndex:indexPath.row];
    ZZGroup *group = [_groups objectAtIndex:[gi intValue]];
    
    if (!_allowTypeSelection) {
        [_delegate selectGroupDone:group];
    } else {
        GroupAddViewController *groupAddVC = [[GroupAddViewController alloc] initWithNibName:@"GroupAdd" bundle:[NSBundle mainBundle]];
        group.sharePermission = kShareAsContributor;
        groupAddVC.group = group;
        groupAddVC.allowTypeSelection = _allowTypeSelection;
        groupAddVC.delegate = self;
        [self.navigationController pushViewController:groupAddVC animated:YES];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    if (_useGroups.count == 0) {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *noGroupsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 320, 40)];
        
        if (_groups.count == 0)
            noGroupsLabel.text = @"There are no groups to select.";
        else
            noGroupsLabel.text = @"You have already selected all of your groups.";
        
        noGroupsLabel.font = [UIFont italicSystemFontOfSize:12];
        noGroupsLabel.textAlignment = UITextAlignmentCenter;
        
        [cell.contentView addSubview:noGroupsLabel];
        
        return cell;
    }

    NSNumber *gi = [_useGroups objectAtIndex:indexPath.row];
    ZZGroup *group = [_groups objectAtIndex:[gi intValue]];
    
    if (_allowTypeSelection) 
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    cell.selectionStyle = UITableViewCellSelectionStyleBlue; 
    cell.textLabel.text = group.name;    

    return cell;
}


-(void)backButtonAction:(id)sender
{
    MLOG(@"backButtonAction");
    
    [_delegate selectGroupCancel];
}


-(void)groupAddDone:(ZZGroup*)group
{
    [self.navigationController popViewControllerAnimated:NO];

    [_delegate selectGroupDone:group];
}

-(void)groupAddCancel
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [_selectgroup reloadData];
}




@end
