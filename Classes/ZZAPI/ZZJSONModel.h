

#import <Foundation/Foundation.h>

@interface ZZJSONModel : NSObject <NSCoding, NSCopying, NSMutableCopying> {

}

-(id) initWithDictionary:(NSDictionary*) jsonObject;

@end
