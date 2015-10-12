#import "AppDelegate.h"
#import "ImagesTableViewController.h"
#import "DataSource.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // dependency injection, model entirely separate from controller and view
    ImagesTableViewController *vc = [[ImagesTableViewController alloc] init];
    vc.items = [DataSource sharedInstance].mediaItems;
    
    // 3 key lines, done if you use storyboard
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; //define main window
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:vc]; //
    
    [self.window makeKeyAndVisible]; //key window is the default window, only one per app
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
