//
//  FriendsViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/14/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendProfileViewController.h"
#import "AllUserBrowseViewController.h"
#import "AddFriendsViewController.h"
#import "CollectionViewCellWithImage.h"
#import <Parse/Parse.h>

@interface FriendsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (strong, nonatomic) PFUser *currentFriendUser;
@property (strong, nonatomic) NSArray *userArray;
@property int numberOfReviewsAndRecommendations;
@property (strong, nonatomic) NSArray *rankings;
@property (strong, nonatomic) IBOutlet UILabel *rankingLabel;
@property (strong, nonatomic) NSString *rankingStringForLabel;

@property (strong, nonatomic) NSMutableArray *favoritesArray;

@property (strong, nonatomic) NSMutableArray *requestorsToAddArray;

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSArray *userFriendsArray;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addFriendButton;

@property (strong, nonatomic) NSMutableArray *selectedFriends;


@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUsers];
    
    self.rankings = @[@"Shy Foodie",
                      @"Novice Foodie",
                      @"Mentor Foodie",
                      @"Master Foodie",
                      @"Genius Foodie",
                      @"Celebrity Foodie",
                      @"Rockstar Foodie",
                      @"Superhero Foodie"];
    
    self.favoritesArray = [NSMutableArray new];
    self.myCollectionView.backgroundColor = [UIColor whiteColor];
    
    self.currentUser = [PFUser currentUser];
    self.userFriendsArray = self.currentUser[@"friends"];
    
    // hiding the choose friends button
    self.addFriendButton.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    self.addFriendButton.enabled = NO;
    
    self.requestorsToAddArray = [NSMutableArray new];
    [self acceptFriends];
    [self autoAddFriendsThatAccepted];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

}

#pragma mark - collection view delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int numberOfItems;
    
    // have to check for null instead of nil here
    if ([self.currentUser[@"friends"] isEqual:[NSNull null]])
        numberOfItems = 0;
    else
    {
        numberOfItems = [self.currentUser[@"friends"] count];
    }
    
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCellWithImage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellReuseID" forIndexPath:indexPath];

    self.currentFriendUser = self.userFriendsArray[indexPath.row];
    [self.currentFriendUser fetchIfNeeded];
    
    NSLog(@"from user friends array %@",self.currentFriendUser);
    
    [self.currentFriendUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *photo = [UIImage imageWithData:data];
            cell.friendImageView.image = photo;
        }
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self retrieveFavorites:indexPath];
}

- (void)retrieveFavorites:(NSIndexPath *)indexPath
{
    
//    NSLog(@"%@",[self.currentUser[@"friends"][indexPath.row][@"favorites"] class]);
    PFObject* friend = self.currentUser[@"friends"][indexPath.row];
                        
    [friend fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        int favoriteCount = [object[@"favorites"] count];
        
        self.currentFriendUser = self.currentUser[@"friends"][indexPath.row];
        
        if (favoriteCount > 0 )
        {
            for (int i = 0; i < favoriteCount; i++)
            {
                PFObject *favorite = self.currentUser[@"friends"][indexPath.row][@"favorites"][i];
                [favorite fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (![self.favoritesArray containsObject:favorite[@"restaurantDictionary"]]) {
                        [self.favoritesArray addObject:favorite[@"restaurantDictionary"]];
                    }
                    [self performSegueWithIdentifier:@"FriendsProfileSegue" sender:self];
                }];
            }
        }
        else
        {
            self.favoritesArray = [NSMutableArray new];
            [self performSegueWithIdentifier:@"FriendsProfileSegue" sender:self];
        }
    }];
                        
}


#pragma mark - friend request and accept management methods

- (void)acceptFriends
{
    PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"FriendRequest"];
    [friendRequestQuery whereKey:@"requestee" equalTo:self.currentUser];
    
    [friendRequestQuery includeKey:@"requestor"];
    
    [friendRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         self.requestorsToAddArray = [objects mutableCopy];
         
         if (self.requestorsToAddArray.firstObject)
         {
             self.addFriendButton.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
             self.addFriendButton.enabled = YES;
         }
         else
         {
             self.addFriendButton.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
             self.addFriendButton.enabled = NO;
         }
     }];
}

- (void)autoAddFriendsThatAccepted
{
    NSArray *currentUserArray = @[self.currentUser];
    
    PFQuery *friendsThatAcceptedQuery = [PFUser query];
    [friendsThatAcceptedQuery whereKey:@"friends" containsAllObjectsInArray:currentUserArray];
    [friendsThatAcceptedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFUser *newFriend in objects)
        {
            int beforeCount = (int)[self.currentUser[@"friends"] count];
            [self.currentUser addUniqueObject:newFriend forKey:@"friends"];
            int afterCount = (int)[self.currentUser[@"friends"] count];
            [self.currentUser saveInBackground];
            
            if (beforeCount != afterCount)
            {
                UIAlertView *friendAddedAlert = [[UIAlertView alloc] initWithTitle:@"Friend Request Accepted!"
                                                                           message:[NSString stringWithFormat:@"You have new friends!"]
                                                                          delegate:self
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                [friendAddedAlert show];
            }
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSLog(@"alerttt");
    }
    else
    {
        NSLog(@"zeroo");
    }
}

#pragma mark - segue methods or related

- (void)loadUsers
{
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         self.userArray = (id)objects;
     }];
}

- (void)countReviewsAndRecommendations
{
    self.numberOfReviewsAndRecommendations = 0;
    PFQuery *userPostQuery = [PFQuery queryWithClassName:@"PublicPost"];
    [userPostQuery whereKey:@"author" equalTo:self.currentFriendUser[@"username"]];
    
    [userPostQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.numberOfReviewsAndRecommendations += number;
        
        PFQuery *userRecommendationQuery = [PFQuery queryWithClassName:@"Recommendation"];
        [userRecommendationQuery whereKey:@"author" equalTo:self.currentFriendUser[@"username"]];
        
        [userRecommendationQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            self.numberOfReviewsAndRecommendations += number;
            [self rankingSetter:self.numberOfReviewsAndRecommendations];
        }];
    }];
}

- (void)rankingSetter:(int)numberOfReviewsAndRecommendations
{
    if (numberOfReviewsAndRecommendations == 0)
    {
        self.rankingStringForLabel = self.rankings[0];
    }
    else if (numberOfReviewsAndRecommendations < 4)
    {
        self.rankingStringForLabel = self.rankings[1];
    }
    else if (numberOfReviewsAndRecommendations < 8)
    {
        self.rankingStringForLabel = self.rankings[2];
    }
    else if (numberOfReviewsAndRecommendations < 12)
    {
        self.rankingStringForLabel = self.rankings[3];
    }
    else if (numberOfReviewsAndRecommendations < 16)
    {
        self.rankingStringForLabel = self.rankings[4];
    }
    else if (numberOfReviewsAndRecommendations < 20)
    {
        self.rankingStringForLabel = self.rankings[5];
    }
    else if (numberOfReviewsAndRecommendations < 24)
    {
        self.rankingStringForLabel = self.rankings[6];
    }
    else if (numberOfReviewsAndRecommendations > 23)
    {
        self.rankingStringForLabel = self.rankings[7];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendRankNotification" object:self.rankingStringForLabel];
}

- (IBAction)unwindAfterAdd:(UIStoryboardSegue *)unwindSegue
{
    AddFriendsViewController *afvc = unwindSegue.sourceViewController;
    self.selectedFriends = afvc.selectedFriends;
    
    for (PFUser *friend in self.selectedFriends)
    {
        [self.currentUser addUniqueObject:friend forKey:@"friends"];
        [self.currentUser saveInBackground];
        
        [self.selectedFriends removeObject:friend];
        
        PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"FriendRequest"];
        [friendRequestQuery whereKey:@"requestee" equalTo:self.currentUser];
        [friendRequestQuery whereKey:@"requestor" equalTo:friend];
        
        [friendRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             [objects.firstObject deleteInBackground];
             [self.myCollectionView reloadData];
         }];
    }
}

- (IBAction)unwindAfterReject:(UIStoryboardSegue *)unwindSegue
{
    AddFriendsViewController *afvc = unwindSegue.sourceViewController;
    self.selectedFriends = afvc.selectedFriends;
    
    for (PFUser *friend in self.selectedFriends)
    {
        [self.selectedFriends removeObject:friend];
        
        PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"FriendRequest"];
        [friendRequestQuery whereKey:@"requestee" equalTo:self.currentUser];
        [friendRequestQuery whereKey:@"requestor" equalTo:friend];
        
        [friendRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             [objects.firstObject deleteInBackground];
             [self.myCollectionView reloadData];
         }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"FriendsProfileSegue"]) {
        FriendProfileViewController *fpvc = segue.destinationViewController;
        
        fpvc.currentFriendUser = self.currentFriendUser;
        fpvc.favoritesArray = self.favoritesArray;
        [self countReviewsAndRecommendations];
    }
    else if ([[segue identifier] isEqualToString:@"AllUserBrowseSegue"])
    {
        AllUserBrowseViewController *aubvc = segue.destinationViewController;
        aubvc.userArray = self.userArray;
    }
    else if ([[segue identifier] isEqualToString:@"AddFriendsSegue"])
    {
        AddFriendsViewController *afvc = segue.destinationViewController;
        afvc.requestorsToAddArray = self.requestorsToAddArray;
    }
}

@end
