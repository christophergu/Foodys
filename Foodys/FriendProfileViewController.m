//
//  FriendProfileViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/15/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "FriendsFriendsViewController.h"
#import "RestaurantViewController.h"

@interface FriendProfileViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *friendsCounterLabel;
@property (strong, nonatomic) IBOutlet UILabel *reviewsCounterLabel;
@property (strong, nonatomic) NSArray *userArray;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UITextField *favoriteTextField;

@property (strong, nonatomic) NSArray *rankings;
@property int numberOfReviewsAndRecommendations;
@property (strong, nonatomic) IBOutlet UILabel *rankingLabel;

@property (strong, nonatomic) NSDictionary *chosenRestaurantFavoriteDictionary;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *friendDeleteButton;


@end

@implementation FriendProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self friendsSetter];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(friendRank:)
                                                 name:@"FriendRankNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reviewCounter:)
                                                 name:@"FriendReviewCounterNotification"
                                               object:nil];
    
    self.friendDeleteButton.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)friendRank:(NSNotification *)notification
{
    self.rankingLabel.text = notification.object;
}

- (void)reviewCounter:(NSNotification *)notification
{
    self.reviewsCounterLabel.text = notification.object;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = self.currentFriendUser[@"username"];
    self.nameLabel.text = self.currentFriendUser[@"username"];
    
    self.rankingLabel.text = self.currentFriendUser[@"rank"];
    
    if (self.currentFriendUser[@"currentFavorite"])
    {
        self.favoriteTextField.text = self.currentFriendUser[@"currentFavorite"];
    }
    else
    {
        self.favoriteTextField.text = @"";
    }
    
    if (self.currentFriendUser[@"avatar"]) {
        [self.currentFriendUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *photo = [UIImage imageWithData:data];
                self.avatarImageView.image = photo;
                self.avatarImageView.clipsToBounds = YES;
            }
        }];
    }
    
    // this is loaded for the friends friends vc page, so it isn't slow
    PFQuery *friendsFriendsQuery = [PFUser query];
    [friendsFriendsQuery whereKey:@"username" equalTo:self.currentFriendUser[@"username"]];
    [friendsFriendsQuery includeKey:@"friends"];
    
    [friendsFriendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.userArray = objects.firstObject[@"friends"];
    }];
    
    [self.myTableView reloadData];
}

#pragma mark - populate view methods

- (void)friendsSetter
{
    self.friendsCounterLabel.text = [NSString stringWithFormat:@"%d Friends",[self.currentFriendUser[@"friends"] count]];
}

#pragma mark - table view methods

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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        self.chosenRestaurantFavoriteDictionary = self.favoritesArray[indexPath.row];
        [self performSegueWithIdentifier:@"FavoriteToRestaurantSegue" sender:self];
}


#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"FriendsFriendsCollectionSegue"])
    {
        FriendsFriendsViewController *fvc = segue.destinationViewController;
        
        fvc.friendsFriendsArray = self.userArray;
    }
    else if ([[segue identifier] isEqualToString:@"FavoriteToRestaurantSegue"])
    {
        RestaurantViewController *rvc = segue.destinationViewController;
        rvc.chosenRestaurantDictionary = self.chosenRestaurantFavoriteDictionary;
        rvc.cameFromProfileFavorites = 1;
    }
}

@end
