//
//  ZZActivityTableViewCell.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/8/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZActivityTableViewCell.h"



@implementation ZZActivityTableViewCell

@synthesize actionLabel=_actionLabel;
@synthesize timeLabel=_timeLabel;
@synthesize frameView=_frameView;
@synthesize photoView=_photoView;
@synthesize likesLabel=_likesLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
