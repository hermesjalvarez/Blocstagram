#import <Foundation/Foundation.h>

@interface DataSource : NSObject

 +(instancetype) sharedInstance;

 @property (nonatomic, strong, readonly) NSArray *mediaItems;

@end
