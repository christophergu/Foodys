//
//  FriendProfileViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/15/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "FriendsFriendsViewController.h"

@interface FriendProfileViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *friendsCounterLabel;
@property (strong, nonatomic) NSArray *userArray;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *favoritesArray;
@property (strong, nonatomic) IBOutlet UITextField *favoriteTextField;
@property (strong, nonatomic) IBOutlet UILabel *rankingLabel;

@property (strong, nonatomic) NSArray *rankings;
@property int numberOfReviewsAndRecommendations;

@end

@implementation FriendProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self friendsSetter];
    
    self.favoritesArray = [NSMutableArray new];
    
    [self retrieveFavorites];
    
    if (self.currentFriendUser[@"currentFavorite"])
    {
        self.favoriteTextField.text = self.currentFriendUser[@"currentFavorite"];
    }
    
    self.rankings = @[@"Shy Foodie",
                      @"Novice Foodie",
                      @"Mentor Foodie",
                      @"Master Foodie",
                      @"Genius Foodie",
                      @"Celebrity Foodie",
                      @"Rockstar Foodie",
                      @"Superhero Foodie"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self countReviewsAndRecommendations];
    self.navigationItem.title = self.currentFriendUser[@"username"];
    
    if (self.currentFriendUser[@"avatar"]) {
        [self.currentFriendUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *photo = [UIImage imageWithData:data];
                self.avatarImageView.image = photo;
                self.avatarImageView.clipsToBounds = YES;
            }
        }];
    }
}

#pragma mark - populate view methods

- (void)friendsSetter
{
    self.friendsCounterLabel.text = [NSString stringWithFormat:@"%d",[self.currentFriendUser[@"friends"] count]];
}

- (void)countReviewsAndRecommendations
{
    self.numberOfReviewsAndRecommendations = 0;
    PFQuery *userPostQuery = [PFQuery queryWithClassName:@"PublicPost"];
    [userPostQuery whereKey:@"author" equalTo:self.currentFriendUser[@"username"]];
    
    [userPostQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.numberOfReviewsAndRecommendations += number;
        NSLog(@"%d",self.numberOfReviewsAndRecommendations);
        
        PFQuery *userRecommendationQuery = [PFQuery queryWithClassName:@"Recommendation"];
        [userRecommendationQuery whereKey:@"author" equalTo:self.currentFriendUser[@"username"]];
        
        [userRecommendationQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            self.numberOfReviewsAndRecommendations += number;
            NSLog(@"%d",self.numberOfReviewsAndRecommendations);
            [self rankingSetter:self.numberOfReviewsAndRecommendations];
        }];
    }];
}

- (void)rankingSetter:(int)numberOfReviewsAndRecommendations
{
    if (numberOfReviewsAndRecommendations == 0)
    {
        self.rankingLabel.text = self.rankings[0];
    }
    else if (numberOfReviewsAndRecommendations < 4)
    {
        self.rankingLabel.text = self.rankings[1];
    }
    else if (numberOfReviewsAndRecommendations < 8)
    {
        self.rankingLabel.text = self.rankings[2];
    }
    else if (numberOfReviewsAndRecommendations < 12)
    {
        self.rankingLabel.text = self.rankings[3];
    }
    else if (numberOfReviewsAndRecommendations < 16)
    {
        self.rankingLabel.text = self.rankings[4];
    }
    else if (numberOfReviewsAndRecommendations < 20)
    {
        self.rankingLabel.text = self.rankings[5];
    }
    else if (numberOfReviewsAndRecommendations < 24)
    {
        self.rankingLabel.text = self.rankings[6];
    }
    else if (numberOfReviewsAndRecommendations < 28)
    {
        self.rankingLabel.text = self.rankings[7];
    }
}

#pragma mark - table view methods

- (void)retrieveFavorites
{
    int favoriteCount = [self.currentFriendUser[@"favorites"] count];
    
    for (int i = 0; i < favoriteCount; i++)
    {
        PFObject *favorite = self.currentFriendUser[@"favorites"][i];
        [favorite fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.favoritesArray addObject:favorite];
            
            [self.myTableView reloadData];
        }];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.favoritesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteCellReuseID"];
    cell.textLabel.text = self.favoritesArray[indexPath.row][@"name"];
    return cell;
}

#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"FriendsFriendsCollectionSegue"])
    {
        FriendsFriendsViewController *fvc = segue.destinationViewController;
        fvc.friendsFriendsArray = self.currentFriendUser[@"friends"];
    }
}

@end
