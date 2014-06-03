//
//  AlbumSettingsViewController.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/23/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhoOptionsViewController.h"

@interface AlbumSettingsViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource, WhoOptionsViewDelegate>{
        UITableView *settings;
        WhoOptionsViewController *optionsController;
         id<WhoOptionsViewDelegate> _delegate;
}


@property (nonatomic, retain) IBOutlet  UITableView *settings;
@property (nonatomic, retain) id<WhoOptionsViewDelegate> delegate;
@property (nonatomic) ZZAPIAlbumWhoOption whoCanDownload;
@property (nonatomic) ZZAPIAlbumWhoOption  whoCanUpload;
@property (nonatomic) ZZAPIAlbumWhoOption  whoCanBuy;

- (IBAction) back:(id)sender;
@end