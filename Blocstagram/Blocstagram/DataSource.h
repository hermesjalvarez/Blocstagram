#import <Foundation/Foundation.h>
@class Media;

@interface DataSource : NSObject

@property (nonatomic, strong, readonly) NSArray *mediaItems;

+(instancetype) sharedInstance;

 - (void) deleteMediaItem:(Media *)item;

@end
