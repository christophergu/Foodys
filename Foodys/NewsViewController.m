//
//  NewsViewController.m
//  Foodys
//
//  Created by Matt Brax on 4/16/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsDetailViewController.h"
#import <Parse/Parse.h>

@interface NewsViewController () <UITableViewDataSource, UITabBarDelegate>
@property (strong,nonatomic) PFObject* currentPost;
@property (strong,nonatomic) PFUser* currentUser;
@property (strong,nonatomic) NSArray* currentUserPostsArray;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation NewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.currentUser = [PFUser currentUser];
    
    NSMutableArray *friendsObjectIdMutableArray = [NSMutableArray new];
    for (PFUser *friend in self.currentUser[@"friends"])
    {
        [friendsObjectIdMutableArray addObject:friend.objectId];
    }
    
    PFQuery *postsQuery = [PFQuery queryWithClassName:@"PublicPost"];
    [postsQuery whereKey:@"authorObjectId" containedIn:friendsObjectIdMutableArray];
    
    PFQuery *userPostQuery = [PFQuery queryWithClassName:@"PublicPost"];
    [userPostQuery whereKey:@"author" equalTo:self.currentUser[@"username"]];
    
    PFQuery *userAndFriendsPostsQuery = [PFQuery orQueryWithSubqueries:@[postsQuery, userPostQuery]];
    
    [userAndFriendsPostsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        self.currentUserPostsArray = objects;
        [self.myTableView reloadData];
    }];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.currentUserPostsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellReuseID"];
    
    self.currentPost = self.currentUserPostsArray[indexPath.row];
    
    cell.textLabel.text = self.currentPost[@"title"];
    
    return cell;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"NewsDetailSegue"]) {
        NewsDetailViewController *ndvc = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:sender];
        
        ndvc.currentPost = self.currentUserPostsArray[indexPath.row];
    }
}

@end