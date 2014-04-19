//
//  EatViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/19/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "EatViewController.h"
#import <Parse/Parse.h>

@interface EatViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (strong, nonatomic) NSMutableArray *bookmarksArray;
@property (strong, nonatomic) PFUser *currentUser;


@end

@implementation EatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentUser = [PFUser currentUser];
    self.bookmarksArray = [NSMutableArray new];
    [self retrieveBookmarks];
}

#pragma mark - bookmarks table view methods

- (void)retrieveBookmarks
{
    int favoriteCount = [self.currentUser[@"bookmarks"] count];
    NSLog(@"%@",self.currentUser[@"bookmarks"]);
    for (int i = 0; i < favoriteCount; i++)
    {
        PFObject *bookmark = self.currentUser[@"bookmarks"][i];
        [bookmark fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.bookmarksArray addObject:bookmark];
            
            [self.myTableView reloadData];
        }];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bookmarksArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkCellReuseID"];
    cell.textLabel.text = self.bookmarksArray[indexPath.row][@"name"];
    return cell;
}


@end
