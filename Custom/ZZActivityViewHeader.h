//
//  ZZActivityViewHeader.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 4/15/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface ZZActivityViewHeader : UIView
{
 
    TTTAttributedLabel *_label;
    UIImageView *_image;
    
}

@property (nonatomic, retain) IBOutlet TTTAttributedLabel *label;
@property (nonatomic, retain) IBOutlet UIImageView *image;


@end
