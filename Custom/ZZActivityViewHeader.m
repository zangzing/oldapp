//
//  ZZActivityViewHeader.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/15/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZActivityViewHeader.h"

@implementation ZZActivityViewHeader

@synthesize label=_label;
@synthesize image=_image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
