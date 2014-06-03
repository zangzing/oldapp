//
//  ZZActivityTableViewCell.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/8/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZZActivityTableViewCell : UITableViewCell
{
    UILabel *_actionLabel;
    UILabel *_timeLabel;
    UIImageView *_frameView;
    UIImageView *_photoView;
    UILabel *_likesLabel;
    
}

@property (nonatomic, retain) IBOutlet  UILabel *actionLabel;
@property (nonatomic, retain) IBOutlet  UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet  UIImageView *frameView;;
@property (nonatomic, retain) IBOutlet  UIImageView *photoView;
@property (nonatomic, retain) IBOutlet  UILabel *likesLabel;


@end
