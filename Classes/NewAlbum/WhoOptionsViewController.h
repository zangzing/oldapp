//
//  WhoOptionsViewController.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 1/23/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZAlbum.h"
#import "ZZBaseViewController.h"
// Used to control which options to display
typedef enum{
    WhoOptionsViewUploadStyle,
    WhoOptionsViewDownloadStyle,
    WhoOptionsViewBuyStyle
} WhoOptionsViewStyle;


// Whoever implements this Data delegate will be used to set the current value
// and will receive notifications whenever the value changes
@protocol WhoOptionsViewDelegate
    - (void)didChangeWhoOption:(WhoOptionsViewStyle)style whoOption:(ZZAPIAlbumWhoOption)option;
    - (ZZAPIAlbumWhoOption) whoCanDownload;
    - (ZZAPIAlbumWhoOption) whoCanUpload;
    - (ZZAPIAlbumWhoOption) whoCanBuy;
@end


@interface WhoOptionsViewController : ZZBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    
    //Model
    ZZAPIAlbumWhoOption whoCan;
    
    // UI elements
    int cellCount;
    ZZAPIAlbumWhoOption list[5];
    UITableView *optionsTable;
    WhoOptionsViewStyle viewStyle;
     id<WhoOptionsViewDelegate> delegate;
} 

@property (nonatomic, retain) IBOutlet  UITableView *optionsTable;
@property (nonatomic, retain) id<WhoOptionsViewDelegate> delegate;
@property (nonatomic) ZZAPIAlbumWhoOption whoCan;

- (id) initWithStyle: (WhoOptionsViewStyle) style  optionsDelegate:(id<WhoOptionsViewDelegate>) optionsDelegate;

@end




