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
#import "NewsTableViewCell.h"

@interface NewsViewController () <UITableViewDataSource, UITabBarDelegate, UIImagePickerControllerDelegate>
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
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
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
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellReuseID"];
    
    self.currentPost = self.currentUserPostsArray[indexPath.row];
    
    cell.title.text = self.currentPost[@"title"];
    cell.recommended.text = self.currentPost[@"wouldGoAgain"];
    
   if ([cell.recommended.text isEqualToString:@"YES"])
    {
        cell.recommended.textColor = [UIColor greenColor];
    }
    else if ([cell.recommended.text isEqualToString:@"NO"])
    {
        cell.recommended.textColor = [UIColor redColor];
    }
    
    cell.reviewerNameLabel.text = self.currentPost[@"author"];
    cell.content.text = self.currentPost[@"body"];
    cell.content.layer.cornerRadius=8.0f;
    cell.content.layer.masksToBounds=YES;
    cell.content.layer.borderColor=[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    cell.content.layer.borderWidth= 1.0f;
    
//    cell.avatarImageView = self.currentPost[@"avatar"];
    
//    cell.avatarImageView.image = [UIImage imageNamed:@"avatar"];
    
    PFFile *userImageFile = self.currentPost[@"avatar"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            cell.avatarImageView.image = [UIImage imageWithData:imageData];
        }
    }];
    

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
