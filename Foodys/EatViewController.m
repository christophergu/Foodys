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

@property (strong, nonatomic) NSMutableArray *recommendationsArray;
@property (strong, nonatomic) IBOutlet UITableView *myRecommendationsTableView;

@end

@implementation EatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentUser = [PFUser currentUser];
    self.bookmarksArray = [NSMutableArray new];
    self.recommendationsArray = [NSMutableArray new];
    [self retrieveBookmarks];
    [self retrieveRecommendations];
}

#pragma mark - bookmarks table view methods

- (void)retrieveBookmarks
{
    int bookmarkCount = [self.currentUser[@"bookmarks"] count];
    for (int i = 0; i < bookmarkCount; i++)
    {
        PFObject *bookmark = self.currentUser[@"bookmarks"][i];
        [bookmark fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.bookmarksArray addObject:bookmark];
            
            [self.myTableView reloadData];
        }];
    }
}

- (void)retrieveRecommendations
{
    [self autoAddReceivedRecommendations];
    
    int recommendationCount = [self.currentUser[@"recommendations"] count];
    for (int i = 0; i < recommendationCount; i++)
    {
        PFObject *recommendation = self.currentUser[@"recommendations"][i];
        [recommendation fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.recommendationsArray addObject:recommendation];
            
            [self.myTableView reloadData];
        }];
    }
}

- (void)autoAddReceivedRecommendations
{
    NSArray *currentUserArray = @[self.currentUser];
    
    PFQuery *receivedRecommendationsQuery = [PFQuery queryWithClassName:@"Recommendation"];
    [receivedRecommendationsQuery whereKey:@"receivers" containsAllObjectsInArray:currentUserArray];
    [receivedRecommendationsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *recommendation in objects) {
            [self.currentUser addUniqueObject:recommendation forKey:@"recommendations"];

            [self.currentUser save];
        }
    }];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int number;
    if(self.mySegmentedControl.selectedSegmentIndex==0)
    {
        number = self.bookmarksArray.count;
    }
    else if (self.mySegmentedControl.selectedSegmentIndex==1)
    {
        number = self.recommendationsArray.count;
    }
    
    return number;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkCellReuseID"];

    if(self.mySegmentedControl.selectedSegmentIndex==0)
    {
        cell.textLabel.text = self.bookmarksArray[indexPath.row][@"name"];
    }
    else if (self.mySegmentedControl.selectedSegmentIndex==1)
    {
        cell.textLabel.text = self.recommendationsArray[indexPath.row][@"name"];
    }
    
    return cell;
}

-(IBAction) segmentedControlIndexChanged
{
    switch (self.mySegmentedControl.selectedSegmentIndex)
    {
        case 0:
            [self.myTableView reloadData];
            break;
        case 1:
            [self.myTableView reloadData];
        default:
            break;
    }
}

@end
