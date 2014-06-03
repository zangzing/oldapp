//
//  UIFactory.h
//  ZangZing
//
//  Created by Phil Beisel on 1/27/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZAPI.h"

@interface UIFactory : NSObject

+(void)setAlbumsCell:(NSDictionary*)albumdata cell:(UITableViewCell*)cell withDisclosure:(BOOL)withDisclosure;
+(void)setUserProfileCell:(ZZUser *)user cell:(UITableViewCell*)cell showSharePermission:(BOOL)showSharePermission;

+(UIButton*)screenWideGreenButton:(NSString*)text frame:(CGRect)frame;
+(UIButton*)screenWideRedButton:(NSString*)text frame:(CGRect)frame;
+(UIButton *)facebookConnectButton: (CGRect)frame;


@end
