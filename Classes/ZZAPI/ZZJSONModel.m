
#import "ZZJSONModel.h"


@implementation ZZJSONModel

-(id) initWithDictionary:(NSDictionary*) serverJson
{
    if((self = [super init]))
    {
        self = [self init];
        [self setValuesForKeysWithDictionary:serverJson];
    }
    return self;
}

-(BOOL) allowsKeyedCoding
{
	return YES;
}

- (id) initWithCoder:(NSCoder *)decoder
{	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// do nothing.
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
  // subclass implementation should do a deep mutable copy
  // this class doesn't have any ivars so this is ok
	ZZJSONModel *newModel = [[ZZJSONModel allocWithZone:zone] init];
	return newModel;
}

-(id) copyWithZone:(NSZone *)zone
{    
  // subclass implementation should do a deep mutable copy
  // this class doesn't have any ivars so this is ok
	ZZJSONModel *newModel = [[ZZJSONModel allocWithZone:zone] init];
	return newModel;
}

- (id)valueForUndefinedKey:(NSString *)key
{
    // subclass implementation should provide correct key value mappings for custom keys
    NSLog(@"Undefined Key: %@", key);
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    // subclass implementation should set the correct key value mappings for custom keys
    NSLog(@"Undefined Key: %@", key);
}



@end
