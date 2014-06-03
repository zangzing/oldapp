//
//  ZZUINavigationBar.h
//  ZangZing
//
//  Created by Phil Beisel on 10/21/11.
//  Copyright (c) 2011 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZUINavigationBar : UINavigationBar
{
    UIImageView *navigationBarBackgroundImage;
    CGFloat backButtonCapWidth;
    IBOutlet UINavigationController* navigationController;
}

@property (nonatomic, retain) UIImageView *navigationBarBackgroundImage;
@property (nonatomic, retain) IBOutlet UINavigationController* navigationController;

-(void) setBackgroundWith:(UIImage*)backgroundImage;
-(void) clearBackground;
-(UIButton*) backButtonWith:(UIImage*)backButtonImage highlight:(UIImage*)backButtonHighlightImage leftCapWidth:(CGFloat)capWidth;
-(void) setText:(NSString*)text onBackButton:(UIButton*)backButton;
-(UIButton*) greenSquareButtonWith:(NSString *)text;
-(UIButton*) graySquareButtonWith:(NSString *)text;

@end
