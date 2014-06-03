
#import "Moment.h"


@implementation Moment


static NSString *name;
static NSString *build;
static NSString *version;

+(void) initialize
{   
    //init version build and name
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    name    = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    build   = [infoDictionary objectForKey:@"CFBundleVersion"];
    version = [[NSString alloc] initWithFormat:@"%@ v%@ (build %@)", name, version, build];
}

+(NSString *) name
{
    return name;
}

+(NSString *) build
{
    return build;
}

+(NSString *) version
{
    return version;
}

@end