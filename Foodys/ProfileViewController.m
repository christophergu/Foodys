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

@interface ProfileViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIButton *myAvatarPhotoButton;
@property (strong, nonatomic) IBOutlet UILabel *friendsCounterLabel;
@property (strong, nonatomic) NSArray *userArray;
@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];
    self.navigationItem.title = self.currentUser[@"username"];
    
    if (self.avatarImageView.image == nil) {
        self.avatarImageView.image = [UIImage imageNamed:@"defaultUserImage"];
    }
    [self friendsSetter];
    [self loadUsers];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    // trying to accept friends here
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         self.userArray = (id)objects;
     }];
    
    PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"FriendRequest"];
    [friendRequestQuery whereKey:@"requestee" equalTo:self.currentUser];
    [friendRequestQuery includeKey:@"requestor"];

    [friendRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         NSLog(@"objects %@",objects);
         NSArray *requestorsToAddArray = (id)objects;
         for (PFObject *requestorsAndRequestees in requestorsToAddArray) {
             [self.currentUser addUniqueObject:requestorsAndRequestees[@"requestor"] forKey:@"friends"];
             NSLog(@"friends array %@",self.currentUser[@"friends"]);
         }
     }];
}

- (void)friendsSetter
{    
    PFQuery *query = [PFUser query];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            // The count request succeeded. Log the count
//            NSLog(@"Sean has played %d games", count);
            self.friendsCounterLabel.text = [NSString stringWithFormat:@"%d",count];
        } else {
            // The request failed
        }
    }];
    

}

- (void)loadUsers
{
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         self.userArray = (id)objects;
     }];
}

- (IBAction)onLogOutButtonPressed:(id)sender
{
    [PFUser logOut];
    [self performSegueWithIdentifier:@"LogInSegue" sender:self];
}

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
    [user saveInBackground];
    
    // getting a uiimage from pffile
    [user[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *photo = [UIImage imageWithData:data];
            self.avatarImageView.image = photo;
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"FriendsCollectionSegue"])
    {
        FriendsViewController *fvc = segue.destinationViewController;
        fvc.userArray = self.userArray;
    }
}

@end
