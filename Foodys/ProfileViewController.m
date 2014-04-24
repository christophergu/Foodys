//
//  ProfileViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/13/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "ProfileViewController.h"
#import "FriendsViewController.h"
#import "RestaurantViewController.h"
#import "ShareViewController.h"
#import "AddFriendsViewController.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIButton *myAvatarPhotoButton;
@property (strong, nonatomic) IBOutlet UILabel *friendsCounterLabel;
@property (strong, nonatomic) NSArray *userFriendsArray;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSMutableArray *favoritesArray;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UITextField *favoriteTextField;

@property (strong, nonatomic) NSArray *rankings;
@property (strong, nonatomic) IBOutlet UILabel *rankingLabel;

@property int numberOfReviewsAndRecommendations;

@property (strong, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (strong, nonatomic) NSMutableArray *recommendationsArray;

@property (strong, nonatomic) NSDictionary *chosenRestaurantFavoriteDictionary;
@property (strong, nonatomic) NSDictionary *chosenRestaurantRecommendationDictionary;
@property (strong, nonatomic) PFObject *chosenRestaurantRecommendationObject;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addFriendButton;

@property (strong, nonatomic) NSMutableArray *requestorsToAddArray;

@property BOOL isEditModeEnabled;

@property (strong, nonatomic) NSMutableArray *selectedFriends;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rankings = @[@"Shy Foodie",
                      @"Novice Foodie",
                      @"Mentor Foodie",
                      @"Master Foodie",
                      @"Genius Foodie",
                      @"Celebrity Foodie",
                      @"Rockstar Foodie",
                      @"Superhero Foodie"];

    // hiding the choose friends button
    self.addFriendButton.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    self.addFriendButton.enabled = NO;
    
    self.requestorsToAddArray = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.currentUser = [PFUser currentUser];
    self.navigationItem.title = self.currentUser[@"username"];
    self.rankingLabel.text = self.currentUser[@"rank"];
    
    
    self.recommendationsArray = [NSMutableArray new];
    [self retrieveRecommendations];
    [self friendsSetter];
    
    if (self.currentUser[@"avatar"])
    {
        [self.currentUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *photo = [UIImage imageWithData:data];
                self.avatarImageView.image = photo;
            }
        }];
    }
    else
    {
        self.avatarImageView.image = [UIImage imageNamed:@"defaultUserImage"];
    }
    self.avatarImageView.clipsToBounds = YES;
    
    
    self.favoritesArray = [NSMutableArray new];
    
    if (self.currentUser[@"currentFavorite"])
    {
        self.favoriteTextField.text = self.currentUser[@"currentFavorite"];
    }
    else
    {
        self.favoriteTextField.text = @"";
    }
    
    [self retrieveFavorites];
    
    [self countReviewsAndRecommendations];
    [self acceptFriends];
    [self autoAddFriendsThatAccepted];
    self.isEditModeEnabled = NO;
    
    // this is loaded for the friends friends vc page, so it isn't slow
    PFQuery *currentUserFriendsQuery = [PFUser query];
    [currentUserFriendsQuery whereKey:@"username" equalTo:self.currentUser[@"username"]];
    [currentUserFriendsQuery includeKey:@"friends"];
    
    [currentUserFriendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.userFriendsArray = objects.firstObject[@"friends"];
    }];
}

#pragma mark - table view delete methods

- (IBAction)onEditButtonPressed:(UIButton *)sender
{
    self.isEditModeEnabled = !self.isEditModeEnabled;
    
    if (self.isEditModeEnabled) {
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        [self.myTableView setEditing:YES animated:YES];
        [self.myTableView deleteRowsAtIndexPaths:self.myTableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        [self.myTableView setEditing:NO animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.favoritesArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
//    UITableViewCell *cellToMove = [items objectAtIndex:sourceIndexPath.row];
//    [items removeObjectAtIndex:sourceIndexPath.row];
//    [items insertObject:cellToMove atIndex:destinationIndexPath.row];
//}

#pragma mark - helper populate view methods

- (void)friendsSetter
{
    // have to check for null instead of nil here
    if (![self.currentUser[@"friends"] isEqual:[NSNull null]])
    {
        self.friendsCounterLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[self.currentUser[@"friends"] count]];
    }
}

- (void)countReviewsAndRecommendations
{
    self.numberOfReviewsAndRecommendations = 0;
    PFQuery *userPostQuery = [PFQuery queryWithClassName:@"PublicPost"];
    [userPostQuery whereKey:@"author" equalTo:self.currentUser[@"username"]];
    
    [userPostQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        self.numberOfReviewsAndRecommendations += number;
        
        PFQuery *userRecommendationQuery = [PFQuery queryWithClassName:@"Recommendation"];
        [userRecommendationQuery whereKey:@"author" equalTo:self.currentUser[@"username"]];
        
        [userRecommendationQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            self.numberOfReviewsAndRecommendations += number;
            [self rankingSetter:self.numberOfReviewsAndRecommendations];
        }];
    }];
}

- (void)rankingSetter:(int)numberOfReviewsAndRecommendations
{
    if (numberOfReviewsAndRecommendations == 0 )
    {
        self.currentUser[@"rank"] = self.rankings[0];
    }
    else if (numberOfReviewsAndRecommendations < 4)
    {
        self.currentUser[@"rank"] = self.rankings[1];
    }
    else if (numberOfReviewsAndRecommendations < 8)
    {
        self.currentUser[@"rank"] = self.rankings[2];
    }
    else if (numberOfReviewsAndRecommendations < 12)
    {
        self.currentUser[@"rank"] = self.rankings[3];
    }
    else if (numberOfReviewsAndRecommendations < 16)
    {
        self.currentUser[@"rank"] = self.rankings[4];
    }
    else if (numberOfReviewsAndRecommendations < 20)
    {
        self.currentUser[@"rank"] = self.rankings[5];
    }
    else if (numberOfReviewsAndRecommendations < 24)
    {
        self.currentUser[@"rank"] = self.rankings[6];
    }
    else if (numberOfReviewsAndRecommendations > 23)
    {
        self.currentUser[@"rank"] = self.rankings[7];
    }
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.rankingLabel.text = self.currentUser[@"rank"];
    }];
}

- (void)retrieveFavorites
{
    int favoriteCount = [self.currentUser[@"favorites"] count];
    
    for (int i = 0; i < favoriteCount; i++)
    {
        PFObject *favorite = self.currentUser[@"favorites"][i];
        [favorite fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.favoritesArray addObject:favorite];
            
            [self.myTableView reloadData];
        }];
    }
    [self.myTableView reloadData];
}

#pragma mark - table view methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int number;
    if(self.mySegmentedControl.selectedSegmentIndex==0)
    {
        number = self.favoritesArray.count;
    }
    else if (self.mySegmentedControl.selectedSegmentIndex==1)
    {
        number = self.recommendationsArray.count;
    }
    
    return number;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteCellReuseID"];
    
    if(self.mySegmentedControl.selectedSegmentIndex==0)
    {
        cell.textLabel.text = self.favoritesArray[indexPath.row][@"name"];
        
//        PFQuery *reviewedRestaurantQuery = [PFQuery queryWithClassName:@"ReviewedRestaurant"];
//        [reviewedRestaurantQuery whereKey:@"name" containsString:self.favoritesArray[indexPath.row][@"name"]];
//        
//        [reviewedRestaurantQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//         {
//             cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%%", objects.firstObject[@"rating"]];
//         }];
    }
    else if (self.mySegmentedControl.selectedSegmentIndex==1)
    {
        cell.textLabel.text = self.recommendationsArray[indexPath.row][@"name"];
        
//        PFQuery *reviewedRestaurantQuery = [PFQuery queryWithClassName:@"ReviewedRestaurant"];
//        [reviewedRestaurantQuery whereKey:@"name" containsString:self.recommendationsArray[indexPath.row][@"name"]];
//        
//        [reviewedRestaurantQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//         {
//             cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%%", objects.firstObject[@"rating"]];
//         }];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.mySegmentedControl.selectedSegmentIndex==0)
    {
        self.chosenRestaurantFavoriteDictionary = self.favoritesArray[indexPath.row][@"restaurantDictionary"];
        [self performSegueWithIdentifier:@"FavoriteToRestaurantSegue" sender:self];
    }
    else if (self.mySegmentedControl.selectedSegmentIndex==1)
    {
        self.chosenRestaurantRecommendationObject = self.recommendationsArray[indexPath.row];
        [self performSegueWithIdentifier:@"RecommendToShareSegue" sender:self];
    }
}

#pragma mark - segmented control method

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

#pragma mark - recommendation methods

- (void)retrieveRecommendations
{
    [self autoAddReceivedRecommendations];
    
    int recommendationCount = [self.currentUser[@"recommendations"] count];
    for (int i = 0; i < recommendationCount; i++)
    {
        PFObject *recommendation = self.currentUser[@"recommendations"][i];
        [recommendation fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
             if (![self.recommendationsArray containsObject:recommendation])
             {
                 [self.recommendationsArray addObject:recommendation];
                 [self.myTableView reloadData];
             }
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

#pragma mark - button methods

- (IBAction)onLogOutButtonPressed:(id)sender
{
    [PFUser logOut];
    
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)favoriteTextFieldDidEndOnExit:(id)sender
{
    [self.favoriteTextField endEditing:YES];
    self.currentUser[@"currentFavorite"] = self.favoriteTextField.text;
    [self.currentUser saveInBackground];
}

#pragma mark - image picker delegate methods

- (IBAction)onImageViewButtonPressed:(id)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    
	if((UIButton *) sender == self.myAvatarPhotoButton) {
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	} else {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
    // saving a uiimage to pffile
    UIImage *pickedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSData* data = UIImageJPEGRepresentation(pickedImage,1.0f);
    PFFile *imageFile = [PFFile fileWithData:data];
    PFUser *user = [PFUser currentUser];
    
    user[@"avatar"] = imageFile;
    
    // getting a uiimage from pffile
    [user[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *photo = [UIImage imageWithData:data];
            self.avatarImageView.image = photo;
        }
    }];
    
    [user saveInBackground];
}

#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"FriendsCollectionSegue"])
    {        
        FriendsViewController *fvc = segue.destinationViewController;
        fvc.currentUser = self.currentUser;
        fvc.userFriendsArray = self.userFriendsArray;
    }
    else if ([[segue identifier] isEqualToString:@"FavoriteToRestaurantSegue"])
    {
        RestaurantViewController *rvc = segue.destinationViewController;
        rvc.chosenRestaurantDictionary = self.chosenRestaurantFavoriteDictionary;
        rvc.cameFromProfileFavorites = 1;
    }
    else if ([[segue identifier] isEqualToString:@"RecommendToShareSegue"])
    {
        ShareViewController *svc = segue.destinationViewController;
        svc.chosenRestaurantDictionary = self.chosenRestaurantRecommendationObject[@"restaurantDictionary"];
        svc.chosenRestaurantRecommendationObject = self.chosenRestaurantRecommendationObject;
        svc.cameFromProfileRecommendations = 1;
    }
    else if ([[segue identifier] isEqualToString:@"AddFriendsSegue"])
    {
        AddFriendsViewController *afvc = segue.destinationViewController;
        afvc.requestorsToAddArray = self.requestorsToAddArray;
    }
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
//             [self.myTableView reloadData];
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
//             [self.myTableView reloadData];
         }];
    }
}

@end
