#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "Media.h"
#import "User.h"
#import "Comment.h"
#import "MediaTableViewCell.h"

@interface ImagesTableViewController ()
@end

@implementation ImagesTableViewController

- (NSArray *) items {
    return [DataSource sharedInstance].mediaItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // at least one type of cell must be registered for tableview
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self items].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.mediaItem = [DataSource sharedInstance].mediaItems[indexPath.row];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // returns actual pixel height w/ right aspect ratio w/ width of phone screen
    // image_height * (screen_width / image_width) = image w/ correct aspect ratio
    Media *item = [self items][indexPath.row];
    return [MediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
}

@end