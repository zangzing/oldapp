//
//  ZZAlbumPrivacySelector.h
//  ZangZing
//
//  Created by Mauricio Alvarez on 2/8/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZAPI.h"
#import "ZZSegmentedControl.h"


@interface ZZAlbumPrivacySelector : UIControl <ZZSegmentedControlDelegate>{

    ZZSegmentedControl *_privacySelector;
    ZZAPIAlbumPrivacy _privacy;
    UILabel *_tagline;
    
}
-(id) initWithAlbumPrivacy:(ZZAPIAlbumPrivacy) privacy;

// ZZSegmentedControlDelegate implementation
- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex;
- (void) touchDownAtSegmentIndex:(NSUInteger)segmentIndex;
- (float) taglineHeight:(NSString *)text;

@property (nonatomic, readwrite) ZZAPIAlbumPrivacy privacy;
@end
