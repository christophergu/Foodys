//
//  RestaurantViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/13/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "RestaurantViewController.h"
#import "RestaurantMenuTableViewCell.h"
#import "ShareViewController.h"
#import "DirectionsViewController.h"
#import "WebViewController.h"
#import <Parse/Parse.h>
#import "SearchViewController.h"

@interface RestaurantViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *myAtmosphereImageView;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *telephoneIndicatorLabel;
@property (strong, nonatomic) IBOutlet UIButton *phoneNumber;
@property (strong, nonatomic) IBOutlet UIButton *address;
@property (strong, nonatomic) NSDictionary *restaurantResultsDictionary;
@property (strong, nonatomic) IBOutlet UILabel *sundayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *mondayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *tuesdayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *wednesdayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *thursdayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *fridayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *saturdayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *sunLabel;
@property (strong, nonatomic) IBOutlet UILabel *monLabel;
@property (strong, nonatomic) IBOutlet UILabel *tueLabel;
@property (strong, nonatomic) IBOutlet UILabel *wedLabel;
@property (strong, nonatomic) IBOutlet UILabel *thuLabel;
@property (strong, nonatomic) IBOutlet UILabel *friLabel;
@property (strong, nonatomic) IBOutlet UILabel *satLabel;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSArray *restaurantUnfilteredMenu;
@property (strong, nonatomic) NSMutableArray *restaurantMenu;
@property (strong, nonatomic) IBOutlet UIView *menuView;
@property BOOL menuBoolForButton;
@property (strong, nonatomic) IBOutlet UIView *hoursView;
@property BOOL hoursBoolForButton;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) IBOutlet UIButton *saveToProfileButton;
@property (strong, nonatomic) IBOutlet UILabel *menuUnavailableLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursUnavailableLabel;
@property (strong, nonatomic) IBOutlet UIButton *reviewButton;
@property (strong, nonatomic) IBOutlet UIButton *locationButton;
@property (strong, nonatomic) NSString *locationCoordinatesString;
@property (strong, nonatomic) NSMutableString *locationSearchString;
@property (strong, nonatomic) IBOutlet UIImageView *favoriteStarImageView;
@property (strong, nonatomic) IBOutlet UILabel *cumulativeRatingLabel;
@property (strong, nonatomic) IBOutlet UILabel *cumulativeRatingStaticLabel;
@property (strong, nonatomic) IBOutlet UIImageView *ratingCircleImageView;

@property (strong, nonatomic) NSMutableArray *defaultMutableArray;

@property (strong, nonatomic) IBOutlet UILabel *hoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *menuLabel;


@end

@implementation RestaurantViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.reviewButton.font = [UIFont fontWithName:@"nevis" size:self.reviewButton.font.pointSize];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.hoursLabel.font = [UIFont fontWithName:@"nevis" size:self.hoursLabel.font.pointSize];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.menuLabel.font = [UIFont fontWithName:@"nevis" size:self.menuLabel.font.pointSize];
    
    self.navigationController.navigationBarHidden = YES;


    self.restaurantNameLabel.text = self.chosenRestaurantDictionary[@"name"];
    
    if ((self.chosenRestaurantDictionary[@"phone"] != (id)[NSNull null]))
    {
        [self.phoneNumber setTitle:self.chosenRestaurantDictionary[@"phone"] forState:UIControlStateNormal];
        self.phoneNumber.alpha = 1.0;
        self.telephoneIndicatorLabel.alpha = 1.0;
        self.phoneNumber.enabled = YES;
    }
    else
    {
        self.phoneNumber.enabled = NO;
        self.phoneNumber.alpha = 0.0;
        self.telephoneIndicatorLabel.alpha = 0.0;
    }
    
    if (self.chosenRestaurantDictionary[@"street_address"] != (id)[NSNull null]) {
        
        self.addressLabel.text = self.chosenRestaurantDictionary[@"street_address"];
    }
    else
    {
        self.address.enabled = NO;
        self.address.alpha = 0.0;
    }

    self.navigationItem.title = self.chosenRestaurantDictionary[@"name"];
    self.myAtmosphereImageView.clipsToBounds = YES;

    if (self.cameFromProfileFavorites)
    {
        self.saveToProfileButton.enabled = NO;
    }
    else
    {
        self.saveToProfileButton.enabled = YES;
    }
    
    self.currentUser = [PFUser currentUser];
    
    PFQuery *favoritesQuery = [PFUser query];
    [favoritesQuery whereKey:@"username" equalTo:self.currentUser[@"username"]];
    [favoritesQuery includeKey:@"favorites"];
    [favoritesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        int counter = 0;

        for (PFObject *alreadyFavorite in objects.firstObject[@"favorites"])
        {
            NSLog(@"chosen dict %@",objects.firstObject[@"favorites"]);
            
            if ([self.chosenRestaurantDictionary[@"name"] isEqualToString: alreadyFavorite[@"name"]])
            {
                counter++;
            }
        }
        if (counter > 0)
        {
            self.favoriteStarImageView.image = [UIImage imageNamed:@"favorite_sel"];
            [self.favoriteStarImageView setNeedsDisplay];
        }
    }];
    
    [self loadFlickrImageForAtmosphere];
    [self getVenueDetail];
    
    self.sunLabel.alpha = 0.0;
    self.monLabel.alpha = 0.0;
    self.tueLabel.alpha = 0.0;
    self.wedLabel.alpha = 0.0;
    self.thuLabel.alpha = 0.0;
    self.friLabel.alpha = 0.0;
    self.satLabel.alpha = 0.0;
    
    self.menuBoolForButton = 0.0;
    self.hoursBoolForButton = 0.0;
    
    self.menuUnavailableLabel.alpha = 0.0;
    self.hoursUnavailableLabel.alpha = 0.0;

    
    self.reviewButton.layer.cornerRadius=4.0f;
    self.reviewButton.layer.masksToBounds=YES;
    self.reviewButton.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

-(void)viewWillAppear:(BOOL)animated
{
    PFQuery *cumulativeReviewQuery = [PFQuery queryWithClassName:@"ReviewedRestaurant"];
    [cumulativeReviewQuery whereKey:@"name" containsString:self.chosenRestaurantDictionary[@"name"]];
    [cumulativeReviewQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (![objects.firstObject[@"rating"] isEqual: [NSNull null]] && !(objects.firstObject[@"rating"] == nil))
        {
            self.cumulativeRatingLabel.text = [NSString stringWithFormat:@"%@%%",objects.firstObject[@"rating"]];
            self.ratingCircleImageView.alpha = 1.0;
        }
        else
        {
            self.ratingCircleImageView.alpha = 0.0;
        }
    }];
    

}

#pragma mark - tableview delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.restaurantMenu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCellReuseID"];
    NSDictionary *currentFoodItem = self.restaurantMenu[indexPath.row];
    cell.nameLabel.text = currentFoodItem[@"name"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (currentFoodItem[@"price"])
    {
        cell.priceLabel.text = [NSString stringWithFormat:@"$%@",currentFoodItem[@"price"]];
    }
    if (!(currentFoodItem[@"description"] == nil))
    {
        cell.descriptionTextView.text = currentFoodItem[@"description"];
        cell.descriptionTextView.textColor = [UIColor lightGrayColor];
        [cell.descriptionTextView setUserInteractionEnabled:YES];
    }
    else
    {
        [cell.descriptionTextView setUserInteractionEnabled:NO];
    }

    return cell;
}

#pragma mark - menu and hours display button methods

- (IBAction)onMenuButtonPressed:(id)sender
{
    NSString *hasMenuString = [NSString stringWithFormat:@"%@",self.chosenRestaurantDictionary[@"has_menu"]];
    NSLog(@"%@",hasMenuString);
    if ([hasMenuString isEqualToString:@"1"])
    {
        self.menuBoolForButton = !self.menuBoolForButton;
        
        if (self.menuBoolForButton)
        {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:
             ^{
                 self.menuView.frame = CGRectMake(0, 211, 320, 514);
             }
                             completion:
             ^(BOOL finished){
             }
             ];
        }
        else
        {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:
             ^{
                 self.menuView.frame = CGRectMake(0, 452, 320, 514);
             }
                             completion:
             ^(BOOL finished){
             }
             ];
        }
    }
    else
    {
        self.menuBoolForButton = !self.menuBoolForButton;
        
        if (self.menuBoolForButton)
        {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:
             ^{
                 self.menuView.frame = CGRectMake(0, 398, 320, 514);
                 self.menuUnavailableLabel.alpha = 1.0;
             }
                             completion:
             ^(BOOL finished){
             }
             ];
        }
        else
        {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:
             ^{
                 self.menuView.frame = CGRectMake(0, 452, 320, 514);
             }
                             completion:
             ^(BOOL finished){
                 self.menuUnavailableLabel.alpha = 0.0;
             }
             ];
        }
    }
}

- (IBAction)onHoursButtonPressed:(id)sender
{
    if (([self.restaurantResultsDictionary[@"open_hours"][@"Sunday"] count] == 0) &&
        ([self.restaurantResultsDictionary[@"open_hours"][@"Monday"] count] == 0) &&
        ([self.restaurantResultsDictionary[@"open_hours"][@"Tuesday"] count] == 0) &&
        ([self.restaurantResultsDictionary[@"open_hours"][@"Wednesday"] count] == 0) &&
        ([self.restaurantResultsDictionary[@"open_hours"][@"Thursday"] count] == 0) &&
        ([self.restaurantResultsDictionary[@"open_hours"][@"Friday"] count] == 0) &&
        ([self.restaurantResultsDictionary[@"open_hours"][@"Saturday"] count] == 0))
    {
        self.hoursBoolForButton = !self.hoursBoolForButton;
        
        if (self.hoursBoolForButton)
        {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:
             ^{
                 self.hoursView.frame = CGRectMake(0, 360, 320, 514);
                 self.hoursUnavailableLabel.alpha = 1.0;
             }
                             completion:
             ^(BOOL finished){
             }
             ];
        }
        else
        {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:
             ^{
                 self.hoursView.frame = CGRectMake(0, 414, 320, 514);
             }
                             completion:
             ^(BOOL finished){
                 self.hoursUnavailableLabel.alpha = 0.0;
             }
             ];
        }
    }
    else
    {
        self.hoursBoolForButton = !self.hoursBoolForButton;
        
        if (self.hoursBoolForButton)
        {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:
             ^{
                 self.hoursView.frame = CGRectMake(0, 211, 320, 514);
             }
                             completion:
             ^(BOOL finished){
             }
             ];
        }
        else
        {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:
             ^{
                 self.hoursView.frame = CGRectMake(0, 414, 320, 514);
             }
                             completion:
             ^(BOOL finished){
             }
             ];
        }
    }
}

- (IBAction)onSaveToProfileButtonPressed:(id)sender
{
    PFObject *favorite = [PFObject objectWithClassName:@"Favorite"];
    favorite[@"name"]=self.chosenRestaurantDictionary[@"name"];
    favorite[@"restaurantDictionary"]=self.chosenRestaurantDictionary;
    
    int counter = 0;
    
    if (self.currentUser[@"favorites"] == nil) {
        [favorite saveInBackground];
        self.favoriteStarImageView.image = [UIImage imageNamed:@"favorite_sel"];
        [self.favoriteStarImageView setNeedsDisplay];
        
        self.currentUser = [PFUser currentUser];
        [self.currentUser addUniqueObject:favorite forKey:@"favorites"];
        [self.currentUser saveInBackground];
    }
    else
    {
        for (PFObject *alreadyFavorite in self.currentUser[@"favorites"])
        {
            [alreadyFavorite fetchIfNeeded];
            
            if ([favorite[@"name"] isEqualToString: alreadyFavorite[@"name"]])
            {
                counter++;
            }
        }
        if (counter == 0)
        {
            [favorite saveInBackground];
            self.favoriteStarImageView.image = [UIImage imageNamed:@"favorite_sel"];
            [self.favoriteStarImageView setNeedsDisplay];
            
            self.currentUser = [PFUser currentUser];
            [self.currentUser addUniqueObject:favorite forKey:@"favorites"];
            [self.currentUser saveInBackground];
        }
    }
}

- (IBAction)onLocationButtonPressed:(id)sender
{

    [self performSegueWithIdentifier:@"DirectionsSegue" sender:self];
}

#pragma mark - phone methods

- (IBAction)onTelephoneButtonPressed:(id)sender
{
    NSString *phNo = self.chosenRestaurantDictionary[@"phone"];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl])
    {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
    else
    {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}

#pragma mark - venue detail helper method

- (void)getVenueDetail
{
    NSMutableString *itemSearchString = [[NSString stringWithFormat:@"http://api.locu.com/v1_0/venue/%@/?api_key=aea05d0dffb636cb9aad86f6482e51035d79e84e",self.chosenRestaurantDictionary[@"id"]] mutableCopy];
    
    NSURL *url = [NSURL URLWithString: itemSearchString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
        NSDictionary *intermediateDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        self.restaurantResultsDictionary = intermediateDictionary[@"objects"][0];
        
        NSString *hasMenuString = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"has_menu"]];
        
        if ([hasMenuString isEqualToString:@"1"])
        {
            self.restaurantMenu = [NSMutableArray new];

            // instantiating the restaurant menu here
            for (NSDictionary *section in self.restaurantResultsDictionary[@"menus"][0][@"sections"])
            {
                for (NSDictionary *subsection in section[@"subsections"])
                {
                    for (NSDictionary *foodItem in subsection[@"contents"])
                    {
                        if (foodItem[@"name"])
                        {
                            [self.restaurantMenu addObject:foodItem];
                        }
                    }
                }
            }
            [self.myTableView reloadData];
        }
        
        int hasHoursCounter = 0;
        
        if (!([self.restaurantResultsDictionary[@"open_hours"][@"Sunday"] count] == 0))
        {
            self.sundayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Sunday"][0]];
            hasHoursCounter++;
        }
        if (!([self.restaurantResultsDictionary[@"open_hours"][@"Monday"] count] == 0))
        {
            self.mondayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Monday"][0]];
            hasHoursCounter++;
        }
        if (!([self.restaurantResultsDictionary[@"open_hours"][@"Tuesday"] count] == 0))
        {
            self.tuesdayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Tuesday"][0]];
            hasHoursCounter++;
        }
        if (!([self.restaurantResultsDictionary[@"open_hours"][@"Wednesday"] count] == 0))
        {
            self.wednesdayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Wednesday"][0]];
            hasHoursCounter++;
        }
        if (!([self.restaurantResultsDictionary[@"open_hours"][@"Thursday"] count] == 0))
        {
            self.thursdayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Thursday"][0]];
            hasHoursCounter++;
        }
        if (!([self.restaurantResultsDictionary[@"open_hours"][@"Friday"] count] == 0))
        {
            self.fridayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Friday"][0]];
            hasHoursCounter++;
        }
        if (!([self.restaurantResultsDictionary[@"open_hours"][@"Saturday"] count] == 0))
        {
            self.saturdayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Saturday"][0]];
            hasHoursCounter++;
        }
        
        if (hasHoursCounter) {
            self.sunLabel.alpha = 1.0;
            self.monLabel.alpha = 1.0;
            self.tueLabel.alpha = 1.0;
            self.wedLabel.alpha = 1.0;
            self.thuLabel.alpha = 1.0;
            self.friLabel.alpha = 1.0;
            self.satLabel.alpha = 1.0;
        }
        
    }];
}

#pragma mark - flickr method

- (void)loadFlickrImageForAtmosphere
{
    NSString *apiKey = @"0a0bffa4d380be872ecba2aa0630065b";
    NSString* name = self.chosenRestaurantDictionary[@"name"];
    
    NSString *flickrSearchString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&sort=relevance&per_page=10&format=json&nojsoncallback=1",
                                    apiKey,[name stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    
   
    
    NSURL *flickrSearchURL = [NSURL URLWithString:flickrSearchString];
    NSURLRequest *flickrSearchRequest = [NSURLRequest requestWithURL:flickrSearchURL];
    [NSURLConnection sendAsynchronousRequest:flickrSearchRequest queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *tempSearchResultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
       NSArray *flickrPhotosArray = tempSearchResultsDictionary[@"photos"][@"photo"];
         
         if (flickrPhotosArray) {
             NSDictionary *flickrElement = flickrPhotosArray.firstObject;
             NSString *flickrURLstring = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg",
                                          [flickrElement[@"farm"] stringValue],
                                          flickrElement[@"server"],
                                          flickrElement[@"id"],
                                          flickrElement[@"secret"]];
             
             NSURL * flickrImageURL = [NSURL URLWithString:flickrURLstring];
             
             NSData * imageData = [[NSData alloc] initWithContentsOfURL: flickrImageURL];
             
             NSLog(@"%@", imageData);
             
             
             if ([imageData isEqual:[NSNull null]] || imageData == nil)
             {
                
                 
                 NSLog(@"it's nilnull");
                 
                NSMutableArray *defaultMutableArray = [NSMutableArray arrayWithArray:@[@"Silverware", @"Family", @"Couple"]];
                 
                 int randomNumber = arc4random_uniform([defaultMutableArray count]);
                 
                 self.myAtmosphereImageView.image = [UIImage imageNamed: defaultMutableArray[randomNumber]];

                 
//                 [self.myAtmosphereImageView setNeedsDisplay];
                 

                 
//                 NSUInteger count = [defaultMutableArray count];
//                 if (count > 1) {
//                     for (NSUInteger i = count - 1; i > 0; --i) {
//                         [defaultMutableArray exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform((int32_t)(i + 1))
//                          
//                          ];
//                     }
//                 }
                 
//                 NSArray *randomArray = [NSArray arrayWithArray:mutableArray];
             }
             else
             {
                 self.myAtmosphereImageView.image = [UIImage imageWithData: imageData];
             }
             
             
         }
         else
         {
             // do something else
         }
     }];
}

// used when sharing is finished and button is pressed
- (IBAction)unwindDoneSharing:(UIStoryboardSegue *)unwindSegue
{
    
}

#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SharePostViewControllerSegue"]) {
        ShareViewController *svc = segue.destinationViewController;
        svc.chosenRestaurantDictionary = self.chosenRestaurantDictionary;
        svc.cameToPost = 1;
    }
    else if ([[segue identifier] isEqualToString:@"ShareFriendViewControllerSegue"]) {
        ShareViewController *svc = segue.destinationViewController;
        svc.chosenRestaurantDictionary = self.chosenRestaurantDictionary;
        svc.cameForFriend = 1;
    }
    else if ([[segue identifier] isEqualToString:@"DirectionsSegue"]) {
        DirectionsViewController *dvc = segue.destinationViewController;
        dvc.chosenRestaurantDictionary = self.chosenRestaurantDictionary;
    }
        
}
@end
