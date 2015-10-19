#import "AppDelegate.h"
#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "LoginViewController.h"
#import "DataSource.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    // dependency injection, model entirely separate from controller and view
//    ImagesTableViewController *vc = [[ImagesTableViewController alloc] init];
//    vc.items = [DataSource sharedInstance].mediaItems;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; //define main window
    
    [DataSource sharedInstance]; // create the data source (so it can receive the access token notification)
    
    UINavigationController *navVC = [[UINavigationController alloc] init];
    
    if (![DataSource sharedInstance].accessToken) {
    
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        [navVC setViewControllers:@[loginVC] animated:YES];
    
        [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            ImagesTableViewController *imagesVC = [[ImagesTableViewController alloc] init];
            [navVC setViewControllers:@[imagesVC] animated:YES];
        }];
        
    } else {
        ImagesTableViewController *imagesVC = [[ImagesTableViewController alloc] init];
        [navVC setViewControllers:@[imagesVC] animated:YES];
    }
    
    self.window.rootViewController = navVC;
    
    [self.window makeKeyAndVisible]; //key window is the default window, only one per app
    
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
