#import <Foundation/Foundation.h>

@interface DataSource : NSObject

@property (nonatomic, strong, readonly) NSArray *mediaItems;

+(instancetype) sharedInstance;

@end
