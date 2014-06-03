//
//  SystemViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 2/6/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "SystemViewController.h"

@implementation SystemViewController

@synthesize systemStats=_systemStats;
@synthesize navBar=_navBar;
@synthesize updateButton=_updateButton;

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
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed:)];
    
    [_updateButton addTarget:self action:@selector(update:) forControlEvents:UIControlEventTouchUpInside];

    
    _navBar.topItem.leftBarButtonItem = cancelItem;
    
    _formatter = [[NSNumberFormatter alloc] init];  
    [_formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    _systemZZAPI = [[ZZSystem alloc]init];
    _sysData = [_systemZZAPI systemStats];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval: 30 target: self selector: @selector(handleTimer:) userInfo: nil repeats: YES];   
    
    /*
    UILabel *xlabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 69, 300, 50)];
    [xlabel setBackgroundColor:[UIColor clearColor]];
    xlabel.textColor = [UIColor purpleColor];
    xlabel.font = [UIFont boldSystemFontOfSize:21.5];
    xlabel.text = @"All 21.5pt";
    
    [self.view addSubview:xlabel];
    
    
    UILabel *x1label = [[UILabel alloc]initWithFrame:CGRectMake(65, 213, 300, 50)];
    [x1label setBackgroundColor:[UIColor clearColor]];
    x1label.textColor = [UIColor purpleColor];
    x1label.font = [UIFont systemFontOfSize:16.0];      // 14
    x1label.text = @"U2 16pt";
    
    [self.view addSubview:x1label];
    */
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return 50;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 4;
}


- (UILabel*)cellAtRowCol:(NSString*)data label:(NSString*)label col:(int)col row:(int)row
{
    int x,y,width,height;
    
    height = 10;
    width = 290 / 3;
    x = 5 + (width * (col-1));
    y = 20 + (12 * (row-1));
    
    UILabel *c = [[UILabel alloc]initWithFrame:CGRectMake(x, y, width, height)];
    c.font = [UIFont systemFontOfSize:10];
    c.backgroundColor = [UIColor clearColor];
    c.text = [NSString stringWithFormat:@"%@ %@", data, label];
        
    return c;
}


- (UILabel*)header:(NSString*)label
{
    int x,y,width,height;

    x = 5;
    y = 5;
    width = 290;
    height = 10;
    
    UILabel *header = [[UILabel alloc]initWithFrame:CGRectMake(x, y, width, height)];
    header.font = [UIFont boldSystemFontOfSize:12];
    header.backgroundColor = [UIColor clearColor];
    header.text = label;

    return header;
}


-(UITableViewCell*)cell1ForData:(NSString*)dataKey section:(NSString*)section
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];

    UILabel *c;
    NSString *str;
    
    NSDictionary *data = [_sysData objectForKey:dataKey];
    
    str = [_formatter stringFromNumber:[data objectForKey:@"total"]];
    str = [NSString stringWithFormat:@"%@ %@", str, section];
    c = [self header:str];
    [cell.contentView addSubview:c];
    
    
    str = [_formatter stringFromNumber:[data objectForKey:@"today"]];
    c = [self cellAtRowCol:str label:@"Today" col:1 row:1];
    [cell.contentView addSubview:c];
    
    str = [_formatter stringFromNumber:[data objectForKey:@"yesterday"]];
    c = [self cellAtRowCol:str label:@"Yesterday" col:1 row:2];
    [cell.contentView addSubview:c];
    
    str = [_formatter stringFromNumber:[data objectForKey:@"this_week"]];
    c = [self cellAtRowCol:str label:@"This Week" col:2 row:1];
    [cell.contentView addSubview:c];
    
    str = [_formatter stringFromNumber:[data objectForKey:@"last_week"]];
    c = [self cellAtRowCol:str label:@"Last Week" col:2 row:2];
    [cell.contentView addSubview:c];
    
    str = [_formatter stringFromNumber:[data objectForKey:@"this_month"]];
    c = [self cellAtRowCol:str label:@"This Month" col:3 row:1];
    [cell.contentView addSubview:c];
    
    str = [_formatter stringFromNumber:[data objectForKey:@"last_month"]];
    c = [self cellAtRowCol:str label:@"Last Month" col:3 row:2];
    [cell.contentView addSubview:c];
    
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    /*
    int pos = [indexPath indexAtPosition: 1];
    
    switch (pos) {
        case 0:
        {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
            cell.textLabel.text = @"Style Default";
            cell.detailTextLabel.text = @"Details";
            
            NSLog(@"size: %f", cell.textLabel.font.pointSize);
            
            return cell;
        }
            break;
            
        case 1: 
        {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
            cell.textLabel.text = @"Style Value1";
            cell.detailTextLabel.text = @"Details";
            
            NSLog(@"size: %f", cell.textLabel.font.pointSize);
            
            return cell;

        }
            break;
            
            
        case 2: 
        {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@""];
            cell.textLabel.text = @"Style Value2";
            cell.detailTextLabel.text = @"Details";
            
            NSLog(@"size: %f", cell.textLabel.font.pointSize);
        
            return cell;

        }
            break;
            
            
        case 3: 
        {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
            cell.textLabel.text = @"Style Subtitle";
            cell.detailTextLabel.text = @"Details";
            
            NSLog(@"size: %f", cell.textLabel.font.pointSize);
            
            return cell;

        }
            break;
            
        default:
            break;
    }

    
    return;
    */
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    
    int pos = [indexPath indexAtPosition: 1];
    
    switch (pos) {
        case 0:
        {
            cell = [self cell1ForData:@"users" section:@"Users"];
        }
            break;
            
        case 1: 
        {
            cell = [self cell1ForData:@"invited_users" section:@"Invited By"];
        }
            break;
            
            
        case 2: 
        {
            cell = [self cell1ForData:@"albums" section:@"Albums"];
        }
            break;
            
            
        case 3: 
        {
            cell = [self cell1ForData:@"photos" section:@"Photos"];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}


-(void)cancelButtonPressed:(id)sender
{
    [_timer invalidate];
    _timer = nil;
    
    [self dismissModalViewControllerAnimated:YES];
}


- (void)handleTimer: (NSTimer*)timer 
{
    //_sysData = [_systemZZAPI systemStats];
    //[_systemStats reloadData];
}


-(void)update:(id)sender
{
    _sysData = [_systemZZAPI systemStats];
    [_systemStats reloadData];
}


@end
