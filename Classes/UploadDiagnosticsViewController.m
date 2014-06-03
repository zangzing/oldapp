//
//  UploadDiagnosticsViewController.m
//  ZangZing
//
//  Created by Phil Beisel on 11/21/11.
//  Copyright (c) 2011 ZangZing. All rights reserved.
//

#import "photouploader.h"
#import "zzglobal.h"
#import "MainViewController.h"
#import "UploadDiagnosticsViewController.h"

#define kLineHeight     15
#define kRows           7

@implementation UploadDiagnosticsViewController

@synthesize log;
@synthesize navbar;
@synthesize statuslabel1;
@synthesize statuslabel2;
@synthesize statuslabel3;

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
 
    [gV hideTabbar:YES];
    
    [NSTimer scheduledTimerWithTimeInterval: 5 target: self selector: @selector(handleTimer:) userInfo: nil repeats: YES];

    navbar.topItem.title = @"Upload Diagnostics";
    
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemDone) target:self action:@selector(done:)];
    navbar.topItem.rightBarButtonItem = rightButton;
    
    log.rowHeight = kLineHeight * kRows;
    
    _logcount = [gPhotoUploader logCount];
    [self refresh];
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


-(void)refresh
{
    NSString *s1,*s2,*s3;
    
    BOOL suspended = [gPhotoUploader suspended];
    int readyCount = [gPhotoUploader readyToUploadCount];
    int queueCount = [gPhotoUploader queueCount];
    int createPhotosCount = [gPhotoUploader createPhotosCount];
    
    s1 = [NSString stringWithFormat:@"%d photos on upload queue", queueCount];
    if (suspended)
        s1 = [NSString stringWithFormat:@"%d photos on upload queue (waiting for WiFi)", queueCount];
        
    
    if ([gPhotoUploader uploading])
        s2 = [NSString stringWithFormat:@"%d photos ready to upload; 1 photo uploading", readyCount-1];
    else
        s2 = [NSString stringWithFormat:@"%d photos ready to upload", readyCount];
    
    s3 = [NSString stringWithFormat:@"%d create_photos pending", createPhotosCount];
    
    statuslabel1.text = s1;
    [statuslabel1 setNeedsDisplay];
    statuslabel2.text = s2;
    [statuslabel2 setNeedsDisplay];
    statuslabel3.text = s3;
    [statuslabel3 setNeedsDisplay];
    
    if ([gPhotoUploader logCount] != _logcount) {
        _logcount = [gPhotoUploader logCount];
        [log reloadData];
    }
}

- (void)handleTimer: (NSTimer*)timer 
{
    [self refresh];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return _logcount;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int pos = [indexPath indexAtPosition: 1];

    if (pos % 2)
        [cell setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1]];
    else 
        [cell setBackgroundColor:[UIColor clearColor]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // rect:  x,y,width,height
    int x;
    int y;
    int height;
    int width;
    
    int pos = [indexPath indexAtPosition: 1];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"log"];
    cell = nil;
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"log"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    NSDictionary *logitem = [gPhotoUploader logItem:pos];
    NSString *evt = [logitem objectForKey:@"evt"];
    
    x = 5;
    y = 5 + (kLineHeight*0);
    width = 320;
    height = kLineHeight;
    
    UILabel *evtLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
    [cell.contentView addSubview:evtLabel];

    evtLabel.backgroundColor = [UIColor clearColor];
    evtLabel.font = [UIFont boldSystemFontOfSize:12];
    evtLabel.text = evt;
    
    
    NSNumber *at = [logitem objectForKey:@"at"];
    NSDate *atd = [NSDate dateWithTimeIntervalSince1970:[at longValue]];
    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *dateString = [dateFormatter stringFromDate:atd];
	
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	NSString *timeString = [dateFormatter stringFromDate:atd];
	
    x = 125;
    y = 5 + (kLineHeight*0);
    width = 320;
    
    UILabel *dtLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
    [cell.contentView addSubview:dtLabel];
    
    dtLabel.backgroundColor = [UIColor clearColor];
    dtLabel.font = [UIFont boldSystemFontOfSize:12];
    dtLabel.text = [NSString stringWithFormat:@"%@ %@", dateString, timeString];

    x = 5;
    y = 5 + (kLineHeight*1);
    width = 320;
    
    UILabel *rLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
    [cell.contentView addSubview:rLabel];    
    
    NSNumber *result = [logitem objectForKey:@"result"];
    rLabel.text = [NSString stringWithFormat:@"result: %d", [result intValue]];
    
    if ([result intValue] != 0)
        rLabel.textColor = [UIColor redColor];
    
    rLabel.backgroundColor = [UIColor clearColor];
    rLabel.font = [UIFont boldSystemFontOfSize:10];
    
    if ([evt isEqualToString:@"create_photos"]) {

        x = 5;
        y = 5 + (kLineHeight*2);
        width = 320;
        
        UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
        [cell.contentView addSubview:cLabel];    
        
        NSNumber *count = [logitem objectForKey:@"count"];
        cLabel.text = [NSString stringWithFormat:@"count: %d", [count intValue]];
        
        cLabel.backgroundColor = [UIColor clearColor];
        cLabel.font = [UIFont boldSystemFontOfSize:10];
        
        NSString *error = [logitem objectForKey:@"error"];
        if (error) {
            x = 5;
            y = 5 + (kLineHeight*3);
            width = 320;
            
            UILabel *errLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
            [cell.contentView addSubview:errLabel];    
            
            errLabel.text = error;
            
            errLabel.font = [UIFont boldSystemFontOfSize:10];
            errLabel.backgroundColor = [UIColor clearColor];
        }
    }
    
    if ([evt isEqualToString:@"upload_begin"]) {
        
        x = 5;
        y = 5 + (kLineHeight*2);
        width = 320;
        
        UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
        [cell.contentView addSubview:cLabel];    
        
        NSString *photo = [logitem objectForKey:@"photo"];
        cLabel.text = [NSString stringWithFormat:@"photo: %@", photo];
        
        cLabel.font = [UIFont boldSystemFontOfSize:10];
        cLabel.backgroundColor = [UIColor clearColor];
        
    
        x = 5;
        y = 5 + (kLineHeight*3);
        width = 320;
        
        UILabel *reLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
        [cell.contentView addSubview:reLabel];    
        
        NSNumber *retryn = [logitem objectForKey:@"retry"];
        reLabel.text = [NSString stringWithFormat:@"retry %d", [retryn unsignedIntegerValue]];

        reLabel.font = [UIFont boldSystemFontOfSize:10];
        reLabel.backgroundColor = [UIColor clearColor];
    }
    
    
    if ([evt isEqualToString:@"upload_end"]) {
        
        x = 5;
        y = 5 + (kLineHeight*2);
        width = 320;
        
        UILabel *cLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
        [cell.contentView addSubview:cLabel];    
        
        NSString *photo = [logitem objectForKey:@"photo"];
        cLabel.text = [NSString stringWithFormat:@"photo: %@", photo];
        
        cLabel.font = [UIFont boldSystemFontOfSize:10];
        cLabel.backgroundColor = [UIColor clearColor];
        
        
        x = 5;
        y = 5 + (kLineHeight*3);
        width = 320;
        
        UILabel *bLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
        [cell.contentView addSubview:bLabel];    
        
        NSNumber *bytes = [logitem objectForKey:@"bytes"];
        bLabel.text = [NSString stringWithFormat:@"bytes: %llu", [bytes unsignedLongLongValue]];
        
        bLabel.font = [UIFont boldSystemFontOfSize:10];
        bLabel.backgroundColor = [UIColor clearColor];
        
        
        x = 125;
        y = 5 + (kLineHeight*3);
        width = 320;
        
        UILabel *tLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
        [cell.contentView addSubview:tLabel];    
        
        NSNumber *time = [logitem objectForKey:@"time"];
        //tLabel.text = [NSString stringWithFormat:@"upload time: %.1f (%d bytes/sec)", [time doubleValue], [bytes unsignedLongLongValue]/[time doubleValue]];
        tLabel.text = [NSString stringWithFormat:@"upload time: %.1f", [time doubleValue]];
        
        tLabel.font = [UIFont boldSystemFontOfSize:10];
        tLabel.backgroundColor = [UIColor clearColor];
        
        
        x = 5;
        y = 5 + (kLineHeight*4);
        width = 320;
        
        UILabel *nLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
        [cell.contentView addSubview:nLabel];    
        
        NSNumber *network = [logitem objectForKey:@"network"];
        NetworkStatus networkstatus = [network unsignedIntegerValue];
        NSString *n;
        switch (networkstatus) {
            case NotReachable:
                n = @"network: None";
                break;
                
            case ReachableViaWiFi:
                n = @"network: WiFi";
                break;
                
            case ReachableViaWWAN:   
                n = @"network: 3G";
                break;
        }
        
        nLabel.text = n;
        
        nLabel.font = [UIFont boldSystemFontOfSize:10];
        nLabel.backgroundColor = [UIColor clearColor];
        
        
        x = 125;
        y = 5 + (kLineHeight*4);
        width = 320;
        
        UILabel *reLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
        [cell.contentView addSubview:reLabel];    
        
        NSNumber *retryn = [logitem objectForKey:@"retry"];
        reLabel.text = [NSString stringWithFormat:@"retry %d", [retryn unsignedIntegerValue]];
        
        reLabel.font = [UIFont boldSystemFontOfSize:10];
        reLabel.backgroundColor = [UIColor clearColor];
        
        
        NSString *error = [logitem objectForKey:@"error"];
        if (error) {
            x = 5;
            y = 5 + (kLineHeight*5);
            width = 320;
            
            UILabel *errLabel = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
            [cell.contentView addSubview:errLabel];    
            
            errLabel.text = error;
            
            errLabel.font = [UIFont boldSystemFontOfSize:10];
            errLabel.backgroundColor = [UIColor clearColor];
        }
    }

    
    
    
    return cell;
}


- (void)done:(id)sender
{
    MLOG(@"done here");
    [self dismissModalViewControllerAnimated:YES];
    
    [gV hideTabbar:NO];
}

@end
