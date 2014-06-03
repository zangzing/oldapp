//
//  ZZAlbumPrivacySelector.m
//  ZangZing
//
//  Created by Mauricio Alvarez on 2/8/12.
//  Copyright (c) 2012 ZangZing. All rights reserved.
//

#import "ZZAlbumPrivacySelector.h"

#define PRIVACY_SEGMENT_COUNT        3
#define PRIVACY_SEGMENT_WIDTH       92
#define PRIVACY_SEGMENT_HEIGHT      29
#define PRIVACY_TAGLINE_TOP         35
#define PRIVACY_TAGLINE_FONT        13.0

#define PRIVACY_PUBLIC_LABEL        @"Public"
#define PRIVACY_HIDDEN_LABEL        @"Hidden"
#define PRIVACY_PASSWORD_LABEL      @"Invite Only"

#define PRIVACY_PUBLIC_TAGLINE      @"Your Album is publicly available for all to see.\n No sign-in required"
#define PRIVACY_HIDDEN_TAGLINE      @"Anyone who knows the web address can access.\n No sign-in required"
#define PRIVACY_PASSWORD_TAGLINE    @"Only the Group you invite has access.\n Sign-in required"
#define PRIVACY_SELECTOR_MAX_HEIGHT 200

#define PRIVACY_PUBLIC_SEG_INDEX    0
#define PRIVACY_HIDDEN_SEG_INDEX    1
#define PRIVACY_PASSWORD_SEG_INDEX  2


@implementation ZZAlbumPrivacySelector

@synthesize privacy=_privacy;

-(id) initWithAlbumPrivacy:(ZZAPIAlbumPrivacy) privacy
{
    
    self = [super init];
    if( self){
        //decode the selected privacy argument
        _privacy = privacy;
        NSUInteger selectedSegment;
        switch( privacy ){
            case kPublic:   selectedSegment = PRIVACY_PUBLIC_SEG_INDEX;   break;
            case kHidden:   selectedSegment = PRIVACY_HIDDEN_SEG_INDEX;   break;
            case kPassword: selectedSegment = PRIVACY_PASSWORD_SEG_INDEX; break;                       
        }
        
        // Add the custom privacy selector
        NSDictionary *controlDef = [NSDictionary dictionaryWithObjectsAndKeys:
                                    /* button titles */ [NSArray arrayWithObjects:NSLocalizedString( PRIVACY_PUBLIC_LABEL,@"Album Privacy Public Label"),
                                                         NSLocalizedString( PRIVACY_HIDDEN_LABEL,@"Album Privacy Hidden Label"),
                                                         NSLocalizedString( PRIVACY_PASSWORD_LABEL,@"Album Privacy Invite Only Label"),
                                                         nil], @"titles",
                                    /* button images */ [NSArray arrayWithObjects:@"privacy-public-icon.png", @"privacy-hidden-icon.png", @"privacy-password-icon.png", nil], @"images",
                                    /* control size  */ [NSValue valueWithCGSize:CGSizeMake(PRIVACY_SEGMENT_WIDTH,PRIVACY_SEGMENT_HEIGHT)], @"size",
                                    /* button image  */ @"privacy-selector-btn.png", @"button-image",
                                    /* hl-button img */ @"privacy-selector-btn-hl.png", @"button-highlight-image",
                                    /* button sep    */ @"privacy-selector-btn-bar.png", @"divider-image",
                                    /* btn cap width */ [NSNumber numberWithFloat:3.0], @"cap-width",
                                    /* btn color     */ [UIColor blackColor], @"button-color",
                                    /* hl-btn color  */ [UIColor blackColor], @"button-highlight-color",
                                    nil];
        
        _privacySelector = [[ZZSegmentedControl alloc] initWithSegmentCount:PRIVACY_SEGMENT_COUNT
                                                            selectedSegment:selectedSegment
                                                                 segmentdef:controlDef 
                                                                        tag:ZZSEGMENTED_ALBUM_PRIVACY_CONTROL 
                                                                   delegate:self];
        [self addSubview: _privacySelector];
        
                
        //Add the tagline
        CGFloat taglineHeight = [self taglineHeight:PRIVACY_PUBLIC_TAGLINE]; 
        _tagline = [[UILabel alloc] initWithFrame:CGRectMake(0, PRIVACY_TAGLINE_TOP, PRIVACY_SEGMENT_WIDTH*3, taglineHeight)];
        _tagline.backgroundColor = [UIColor clearColor];
        _tagline.font = [UIFont systemFontOfSize: PRIVACY_TAGLINE_FONT];
        _tagline.textAlignment = UITextAlignmentCenter;
        _tagline.lineBreakMode = UILineBreakModeWordWrap;
        _tagline.numberOfLines = 0;
        //fake a touch down event to set privacy tagline
        [self touchDownAtSegmentIndex:selectedSegment];
        [self addSubview: _tagline];
        
        // Size the selector
        self.frame = CGRectMake(8,10,_privacySelector.frame.size.width, PRIVACY_TAGLINE_TOP+taglineHeight); 
        //self.backgroundColor = [UIColor whiteColor];
               
        return self;
    }
    return NULL;  
}

- (float) taglineHeight:(NSString *)text
{
    CGSize boundingSize = CGSizeMake(PRIVACY_SEGMENT_WIDTH*3, PRIVACY_SELECTOR_MAX_HEIGHT );
    CGSize requiredSize = [text sizeWithFont:[UIFont systemFontOfSize: PRIVACY_TAGLINE_FONT]
                           constrainedToSize:boundingSize
                               lineBreakMode:UILineBreakModeWordWrap];
    return requiredSize.height;
}

-(void) setPrivacy:(ZZAPIAlbumPrivacy)newPrivacy
{
    _privacy = newPrivacy;
    NSUInteger newSegment;
    switch( _privacy ){
        case kPublic:   newSegment = PRIVACY_PUBLIC_SEG_INDEX;   break;
        case kHidden:   newSegment = PRIVACY_HIDDEN_SEG_INDEX;   break;
        case kPassword: newSegment = PRIVACY_PASSWORD_SEG_INDEX; break;                       
    }
    //Select the segment on the bar
    [_privacySelector selectSegment: newSegment];
    //Set the tagline text by faking a touch on the segment
    [self touchDownAtSegmentIndex: newSegment];
}

// For the _privacySelector
- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    
}

// For the _privacySelector
- (void) touchDownAtSegmentIndex:(NSUInteger)segmentIndex
{
    NSString *text;
    switch( segmentIndex ){
        case PRIVACY_PUBLIC_SEG_INDEX:
            text = NSLocalizedString( PRIVACY_PUBLIC_TAGLINE, @"Album privacy selector public tagline");
            _privacy= kPublic;
            break;
        case PRIVACY_HIDDEN_SEG_INDEX:
            text = NSLocalizedString( PRIVACY_HIDDEN_TAGLINE, @"Album privacy selector hidden tagline");
            _privacy=kHidden;
            break;
        case PRIVACY_PASSWORD_SEG_INDEX:
            text = NSLocalizedString( PRIVACY_PASSWORD_TAGLINE, @"Album privacy selector invite only tagline");
            _privacy=kPassword;
            break;
        default:
            [NSException raise:@"Invalid Album Privacy Selector Segment Index" 
                        format:@"Segment Index %i is greater than %i (the number of segments)", segmentIndex, PRIVACY_SEGMENT_COUNT];
    }
    
    // We assume all taglines are a max of 2 lines so no need to recalc the size but
    // if we have a variable number of lines, this is the place to recalc the height
    _tagline.text = text;
    
    // notify targets of the change
    [self sendActionsForControlEvents:UIControlEventTouchDown];
}




@end
