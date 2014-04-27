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
#import "WebViewController.h"
#import <Parse/Parse.h>

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

@end

@implementation RestaurantViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    
//    if ((self.chosenRestaurantDictionary[@"website_url"] != (id)[NSNull null]))
//    {
//        [self.websiteURL setTitle:self.chosenRestaurantDictionary[@"website_url"] forState:UIControlStateNormal];
//        self.websiteURL.enabled = YES;
//    }
//    else
//    {
//        self.websiteURL.enabled = NO;
//        self.websiteURL.alpha = 0.0;
//    }
    
    if (self.chosenRestaurantDictionary[@"street_address"] != (id)[NSNull null]) {
        
        self.addressLabel.text = self.chosenRestaurantDictionary[@"street_address"];
//        NSString *fullAddress = [NSString stringWithFormat:@"%@\n%@, %@",self.chosenRestaurantDictionary[@"street_address"],self.chosenRestaurantDictionary[@"region"], self.chosenRestaurantDictionary[@"postal_code"]];
//        [self.address setTitle:fullAddress forState:UIControlStateNormal];
//        [self.address.titleLabel setTextAlignment: NSTextAlignmentCenter];
//        self.address.enabled = YES;
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(locationCoordinatesStringMethod:)
//                                                 name:@"locationNotification"
//                                               object:nil];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

//-(void)locationCoordinatesStringMethod:(NSNotification *)notification
//{
//    self.locationCoordinatesString = notification.object;
//    NSLog(@"work? %@",self.locationCoordinatesString);
//}

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
                 self.menuView.frame = CGRectMake(0, 256, 320, 514);
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
                 self.menuView.frame = CGRectMake(0, 388, 320, 514);
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
                 self.hoursView.frame = CGRectMake(0, 354, 320, 514);
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
                 self.hoursView.frame = CGRectMake(0, 256, 320, 514);
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
    
    [favorite saveInBackground];
    
    self.currentUser = [PFUser currentUser];
    [self.currentUser addUniqueObject:favorite forKey:@"favorites"];
    [self.currentUser saveInBackground];
}

- (IBAction)onLocationButtonPressed:(id)sender
{
//    self.locationSearchString = [@"https://www.google.com/maps" mutableCopy];
//    
//    if (self.locationManager.location)
//    {
//        locationTextForSearch = [NSString stringWithFormat:@"&location=%.1f,%.1f&radius=1000000",
//                                 self.locationManager.location.coordinate.latitude,
//                                 self.locationManager.location.coordinate.longitude];
//        
//        NSLog(@"%@",self.locationManager.location);
//        [locationSearchString appendString:locationTextForSearch];
//    }
//    
//    @"https://www.google.com/maps";     // /dir/long,lat/self.chosenRestaurantDictionary[@"name"],self.chosenRestaurantDictionary[@"streetAddress"],self.chosenRestaurantDictionary[@"locality"],self.chosenRestaurantDictionary[@"region"],self.chosenRestaurantDictionary[@"postal_code"]/";
//    
    [self performSegueWithIdentifier:@"WebSegue" sender:self];
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
    NSString *name = self.chosenRestaurantDictionary[@"name"];
    
    NSString *flickrSearchString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&sort=relevance&per_page=1&format=json&nojsoncallback=1",
                                    apiKey,
                                    [name stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    
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
             
             self.myAtmosphereImageView.image = [UIImage imageWithData: imageData];
         }
         else
         {
             // do something else
         }
         
     }];
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
    else if ([[segue identifier] isEqualToString:@"WebSegue"]) {
        WebViewController *wvc = segue.destinationViewController;
        wvc.websiteUrl = @"https://www.google.com/maps";     // /dir/long,lat/self.chosenRestaurantDictionary[@"name"],self.chosenRestaurantDictionary[@"streetAddress"],self.chosenRestaurantDictionary[@"locality"],self.chosenRestaurantDictionary[@"region"],self.chosenRestaurantDictionary[@"postal_code"]/";
    }
}
@end
