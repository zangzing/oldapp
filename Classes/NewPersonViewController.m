//
//  NewPersonViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 2/3/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "zzglobal.h"
#import "UIFactory.h"
#import "UIImageView+WebCache.h"
#import "NewPersonViewController.h"

@implementation NewPersonViewController

@synthesize delegate=_delegate;
@synthesize nameLabel=_nameLabel;
@synthesize emailLabel=_emailLabel;
@synthesize profileImage=_profileImage;
@synthesize emailSelect=_emailSelect;
@synthesize allowTypeSelection=_allowTypeSelection;
@synthesize mode=_mode;

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
    self.title = @"Person";
    [self useCustomBackButton:@"Back" target:self action:@selector(backButtonAction:)];
    
    UIColor *bcolor = [UIColor colorWithRed: 221.0/255.0 green: 221.0/255.0 blue: 221.0/255.0 alpha: 1.0];
    [self.view setBackgroundColor:bcolor];
    [_emailSelect setBackgroundColor:bcolor];
    
    if (_mode == kPersonNewMode) {
        UIButton *addPersonButton = [UIFactory screenWideGreenButton: NSLocalizedString(@"Add Person", @"Add Person Button Text") frame:CGRectMake(9, 363, 302, 46)];
        [self.view addSubview:addPersonButton];
        [addPersonButton addTarget:self action:@selector(addPersonAction:) forControlEvents:UIControlEventTouchUpInside]; 
    }
        
    BOOL contact = (_user == nil);
    
    int persontype_offset = 0;
    
    MLOG(@"contact: %d", contact);
    
    if (contact) {
        
        // as contact
        
        _nameLabel.text = [ZZGlobal formatName:_first last:_last];
        _emailLabel.text = @"";
        
        _profileImage.image = [UIImage imageNamed:@"default_profile.png"];
        
        persontype_offset = (_emails.count * 44) + 20;
    
        _emailSelect.frame = CGRectMake(_emailSelect.frame.origin.x, _emailSelect.frame.origin.y, _emailSelect.frame.size.width, (_emails.count * 44) + 12);
        _emailSelected = [_emails objectAtIndex:0];
        
        _sharetype = kShareAsContributor;
        
        if (_emails && _emails.count > 0) {
            
            _profileImage.hidden = YES;
            _nameLabel.hidden = YES;
            _emailLabel.hidden = YES;
            
            // move _emailSelect / _persontype
            CGRect frame;
            
            frame = _emailSelect.frame;
            frame.origin.y = 5;
            _emailSelect.frame = frame;
            
            persontype_offset -= 98;            // an example of a
        }

    } else {
        
        // as user
        
        NSString *name = [_user name];
        if (name) {
            _nameLabel.text = [_user name];
            if (_user.automatic)
                _emailLabel.text = [_user email];
            else
                _emailLabel.text = [_user username];
        } else {
            // no usable name; just display email
            _nameLabel.text = [_user email];
            _emailLabel.text = @"";
        }

        _sharetype = _user.sharePermission;

        _emailSelect.hidden = YES;
        
        _profileImage.image = [UIImage imageNamed:@"default_profile.png"];
        
        NSString *profilePhotoURL = _user.profile_photo_url;
        if (profilePhotoURL && ![profilePhotoURL isKindOfClass:[NSNull class]]) {
            [_profileImage setImageWithURL_SD:[NSURL URLWithString: profilePhotoURL]];
        }
        _profileImage.clipsToBounds = YES;
        _profileImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    if (_allowTypeSelection) {
        int selectedSegment;
        if (_sharetype == kShareAsContributor) 
            selectedSegment = 0;
        else if (_sharetype == kShareAsViewer)
            selectedSegment = 1;
        
        NSDictionary *persontypedef = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"Add Photos", @"View Photos", nil], @"titles", [NSValue valueWithCGSize:CGSizeMake(90,30)], @"size", @"segment.png", @"button-image", @"segment-selected.png", @"button-highlight-image", @"segment-separator.png", @"divider-image", [NSNumber numberWithFloat:11.0], @"cap-width", [UIColor blackColor], @"button-color", [UIColor blackColor], @"button-highlight-color", nil];
        
        _persontype = [[ZZSegmentedControl alloc] initWithSegmentCount:2 selectedSegment:selectedSegment segmentdef:persontypedef tag:0 delegate:self];
        _persontype.frame = CGRectMake(70, 105, _persontype.frame.size.width, _persontype.frame.size.height);    // adjust location
        
        _persontype.frame = CGRectOffset(_persontype.frame, 0, persontype_offset);
        
        [self.view addSubview:_persontype];
    }
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


-(void)setUser:(ZZUser*)user first:(NSString*)first last:(NSString*)last
{
    _user = [[ZZUser alloc]initWithUser:user];
    if (first)
        _first = [NSString stringWithString:first];
    else
        _first = _user.first_name;
    
    if (last)
        _last = [NSString stringWithString:last];
    else
        _last = _user.last_name;
}


-(void)setContact:(NSArray*)emails first:(NSString*)first last:(NSString*)last
{
    _emails = [[NSArray alloc]initWithArray:emails];
    if (first)
        _first = [NSString stringWithString:first];
    if (last)
        _last = [NSString stringWithString:last];
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    _emailSelected = [_emails objectAtIndex:indexPath.row];
    [_emailSelect reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *email = [_emails objectAtIndex:indexPath.row];
    
    UITableViewCell *cell;
        
    cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone; 
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(43, 0, 320, 44)];
    textLabel.text = email;
    textLabel.font = [UIFont boldSystemFontOfSize:17.0];
    textLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:textLabel];
    
    BOOL selected = [email isEqualToString:_emailSelected];
    
    UIImage *addimage = [UIImage imageNamed:@"check-unchecked.png"];
    if (selected)
        addimage = [UIImage imageNamed:@"check-checked-green.png"];
    
    UIImageView *addimageView = [[UIImageView alloc] initWithImage:addimage];
    addimageView.frame = CGRectMake(6,7,addimage.size.width,addimage.size.height); 
    [cell.contentView addSubview:addimageView];
    
    return cell;

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_emails && _emails.count > 0)
        return _emails.count;
    
    return 0;
}


-(void)backButtonAction:(id)sender
{
    MLOG(@"backButtonAction");
    
    if (_mode == kPersonNewMode) {
        [_delegate newPersonCancel];
    } else {
        _user.sharePermission = _sharetype;
        [_delegate newPersonChanged:_user];
    }
}


-(void)addPersonAction:(id)sender
{
    MLOG(@"addPersonAction");
    
    if (!_user) {
        // have contact, turn into user
        
        NSString *fqemail = [ZZGlobal fullyQualifiedEmailAddress:_emailSelected first:_first last:_last];
        NSArray *emails = [[NSArray alloc]initWithObjects:fqemail, nil];
        
        NSError *error;
        NSArray *users = [ZZUser findOrCreateUsers:nil userNames:nil emails:emails error:&error];
        if (users && users.count > 0) {
            _user = [users objectAtIndex:0];
        }
    }
    
    _user.sharePermission = _sharetype;
    
    [_delegate newPersonAdded:_user];
}


- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    if (segmentIndex == 0) 
        _sharetype = kShareAsContributor;
    else
        _sharetype = kShareAsViewer;
}






@end
