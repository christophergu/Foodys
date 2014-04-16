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
         NSArray *requestorsToAddArray = objects;
         for (PFObject *requestorsAndRequestees in requestorsToAddArray) {
             
             // the objects that were fetched were _NSarrayM objects so this refetches the objects as PFUser objects
             NSString *tempStringBeforeCutting = [NSString stringWithFormat:@"%@",requestorsAndRequestees[@"requestor"]];
             NSArray* cutStringArray = [tempStringBeforeCutting componentsSeparatedByString: @":"];
             
             PFQuery *friendToIncludeQuery = [PFUser query];
             [friendToIncludeQuery whereKey:@"objectId" equalTo:cutStringArray[1]];
             [friendToIncludeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                 NSLog(@"yaaa %@",objects.firstObject);
                 [self.currentUser addUniqueObject:objects.firstObject forKey:@"friends"];
                 [self.currentUser saveInBackground];
             }];
         }
     }];
}

- (void)friendsSetter
{
    self.friendsCounterLabel.text = [NSString stringWithFormat:@"%d",[self.currentUser[@"friends"] count]];
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
        fvc.currentUser = self.currentUser;
    }
}

@end
