//
//  ProfileViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/13/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "ProfileViewController.h"
#import "FriendsViewController.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIButton *myAvatarPhotoButton;
@property (strong, nonatomic) IBOutlet UILabel *friendsCounterLabel;
@property (strong, nonatomic) NSArray *userArray;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSMutableArray *favoritesArray;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UITextField *favoriteTextField;

@property (strong, nonatomic) NSArray *rankings;
@property (strong, nonatomic) IBOutlet UILabel *rankingLabel;

@property int numberOfReviewsAndRecommendations;

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

}

- (void)viewWillAppear:(BOOL)animated
{
    self.currentUser = [PFUser currentUser];
    self.navigationItem.title = self.currentUser[@"username"];
    self.rankingLabel.text = self.currentUser[@"rank"];
    
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
    
    [self friendsSetter];
    
    self.favoritesArray = [NSMutableArray new];
    
    if (self.currentUser[@"currentFavorite"])
    {
        self.favoriteTextField.text = self.currentUser[@"currentFavorite"];
    }
    
    [self retrieveFavorites];
    
    [self countReviewsAndRecommendations];
    [self acceptFriends];
    [self autoAddFriendsThatAccepted];
}

#pragma mark - populate view methods

- (void)friendsSetter
{
    if ([self.currentUser[@"friends"] count] != 0)
    {
        self.friendsCounterLabel.text = [NSString stringWithFormat:@"%d",[self.currentUser[@"friends"] count]];
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
    if (numberOfReviewsAndRecommendations == 0)
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
    else if (numberOfReviewsAndRecommendations < 28)
    {
        self.currentUser[@"rank"] = self.rankings[7];
    }
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.rankingLabel.text = self.currentUser[@"rank"];
    }];
}

#pragma mark - table view methods

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

#pragma mark - friend request and accept management methods

- (void)acceptFriends
{
    PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"FriendRequest"];
    [friendRequestQuery whereKey:@"requestee" equalTo:self.currentUser];
    [friendRequestQuery includeKey:@"requestor"];
    
    [friendRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         NSArray *requestorsToAddArray = objects;
         for (PFObject *requestorsAndRequestees in requestorsToAddArray) {
             
             // the objects that were fetched were _NSarrayM objects so this refetches the objects as PFUser objects
             NSString *tempStringBeforeCutting = [NSString stringWithFormat:@"%@",requestorsAndRequestees[@"requestor"]];
             NSArray* cutStringArray = [tempStringBeforeCutting componentsSeparatedByString: @":"];
             
             PFQuery *friendToIncludeQuery = [PFUser query];
             [friendToIncludeQuery whereKey:@"objectId" equalTo:cutStringArray[1]];
             [friendToIncludeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                 [self.currentUser addUniqueObject:objects.firstObject forKey:@"friends"];
                 [self.currentUser saveInBackground];
             }];
         }
     }];
}

- (void)autoAddFriendsThatAccepted
{
    NSArray *currentUserArray = @[self.currentUser];
    
    PFQuery *friendsThatAcceptedQuery = [PFUser query];
    [friendsThatAcceptedQuery whereKey:@"friends" containsAllObjectsInArray:currentUserArray];
    [friendsThatAcceptedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFUser *newFriend in objects) {
            if ([newFriend isEqual:self.currentUser])
            {
                continue;
            }
            [self.currentUser addUniqueObject:newFriend forKey:@"friends"];
            [self.currentUser saveInBackground];
        }
    }];
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
    }
}

@end
