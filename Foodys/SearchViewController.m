//
//  SearchViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/11/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "SearchViewController.h"
#import "LogInViewController.h"
#import "SignInViewController.h"
#import "RestaurantViewController.h"
#import "ShowMoreResultsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "AdvancedSearchViewController.h"

@interface SearchViewController ()<CLLocationManagerDelegate, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UIButton *searchButton;

@property CLLocationManager *locationManager;
@property (strong, nonatomic) LogInViewController *modalLogInViewController;
@property (strong, nonatomic) SignInViewController *modalSignInViewController;
@property (strong, nonatomic) NSMutableArray *searchResultsArray;

@property (strong, nonatomic) NSArray *pickerArray;

@property (strong, nonatomic) IBOutlet UIPickerView *myPickerView;
@property (strong, nonatomic) NSString *stringForSelectedPickerRow;

@property int numberOfReviewsAndRecommendations;

@property (strong, nonatomic) NSArray *rankings;

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) IBOutlet UILabel *rankingLabel;


@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    
    self.locationManager.delegate = self;
    
    [self.locationManager startUpdatingLocation];

    // locu api: aea05d0dffb636cb9aad86f6482e51035d79e84e
    // locu widget api: 71747ca57e325a86544c9edc0d96a9c5b95026f7
    
    self.pickerArray = @[@"burrito", @"burger", @"pizza", @"steak", @"sushi", @"taco"];
    
    // default
    self.stringForSelectedPickerRow = self.pickerArray[0];
    
    
    self.rankings = @[@"Shy Foodie",
                      @"Novice Foodie",
                      @"Mentor Foodie",
                      @"Master Foodie",
                      @"Genius Foodie",
                      @"Celebrity Foodie",
                      @"Rockstar Foodie",
                      @"Superhero Foodie"];
}

#pragma mark - check if there is a current user method

-(void)viewWillAppear:(BOOL)animated
{
    self.currentUser = [PFUser currentUser];
//    [self countReviewsAndRecommendations];

    if (!self.currentUser)
    {
        [self performSegueWithIdentifier:@"LogInSegue" sender:self];
    }
}

//- (void)countReviewsAndRecommendations
//{
//    NSLog(@"username %@",self.currentUser[@"username"]);
//    
//    self.numberOfReviewsAndRecommendations = 0;
//    PFQuery *userPostQuery = [PFQuery queryWithClassName:@"PublicPost"];
//    [userPostQuery whereKey:@"author" equalTo:self.currentUser[@"username"]];
//    
//    [userPostQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//        self.numberOfReviewsAndRecommendations += number;
//        
//        PFQuery *userRecommendationQuery = [PFQuery queryWithClassName:@"Recommendation"];
//        [userRecommendationQuery whereKey:@"author" equalTo:self.currentUser[@"username"]];
//        
//        [userRecommendationQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//            self.numberOfReviewsAndRecommendations += number;
//            [self rankingSetter:self.numberOfReviewsAndRecommendations];
//        }];
//    }];
//}
//
//- (void)rankingSetter:(int)numberOfReviewsAndRecommendations
//{
//    if (numberOfReviewsAndRecommendations == 0)
//    {
//        self.currentUser[@"rank"] = self.rankings[0];
//    }
//    else if (numberOfReviewsAndRecommendations < 4)
//    {
//        self.currentUser[@"rank"] = self.rankings[1];
//    }
//    else if (numberOfReviewsAndRecommendations < 8)
//    {
//        self.currentUser[@"rank"] = self.rankings[2];
//    }
//    else if (numberOfReviewsAndRecommendations < 12)
//    {
//        self.currentUser[@"rank"] = self.rankings[3];
//    }
//    else if (numberOfReviewsAndRecommendations < 16)
//    {
//        self.currentUser[@"rank"] = self.rankings[4];
//    }
//    else if (numberOfReviewsAndRecommendations < 20)
//    {
//        self.currentUser[@"rank"] = self.rankings[5];
//    }
//    else if (numberOfReviewsAndRecommendations < 24)
//    {
//        self.currentUser[@"rank"] = self.rankings[6];
//    }
//    else if (numberOfReviewsAndRecommendations > 23)
//    {
//        self.currentUser[@"rank"] = self.rankings[7];
//    }
//    
//    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        self.rankingLabel.text = self.currentUser[@"rank"];
//    }];
//}

#pragma mark - picker view methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerArray[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.stringForSelectedPickerRow = self.pickerArray[row];
}


#pragma mark - search helper method

- (void)foodSearch
{
    self.searchResultsArray = [NSMutableArray new];
    
    NSMutableString *itemSearchString = nil;
    itemSearchString = [@"http://api.locu.com/v1_0/menu_item/search/?api_key=aea05d0dffb636cb9aad86f6482e51035d79e84e" mutableCopy];
    
    NSString *nameFoodForSearch;
    NSString *locationTextForSearch;
    
    if (!(self.stringForSelectedPickerRow.length < 1))
    {
        nameFoodForSearch = [NSString stringWithFormat:@"&name=%@",self.stringForSelectedPickerRow];
        nameFoodForSearch = [nameFoodForSearch stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        [itemSearchString appendString:nameFoodForSearch];
    }
    
    if (self.locationManager.location)
    {
        locationTextForSearch = [NSString stringWithFormat:@"&location=%.1f,%.1f&radius=50000",
                                 self.locationManager.location.coordinate.latitude,
                                 self.locationManager.location.coordinate.longitude];
        [itemSearchString appendString:locationTextForSearch];
    }

    NSURL *url = [NSURL URLWithString: itemSearchString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
        NSDictionary *intermediateDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        NSMutableArray *venues = [NSMutableArray new];
        
        for (NSDictionary *result in intermediateDictionary[@"objects"])
        {
            if (![venues containsObject:result[@"venue"][@"name"]])
            {
                [self.searchResultsArray addObject:result];
                [venues addObject:result[@"venue"][@"name"]];
            }
        }
        [self performSegueWithIdentifier:@"ShowMoreResultsSegue" sender:self];
    }];
}

#pragma mark - button methods

- (IBAction)onSearchButtonPressed:(id)sender
{
    [self foodSearch];
}

#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"RestaurantViewControllerSegue"])
    {
        RestaurantViewController *rvc = segue.destinationViewController;
        rvc.chosenRestaurantDictionary = self.searchResultsArray.firstObject;
    }
    else if ([[segue identifier] isEqualToString:@"ShowMoreResultsSegue"])
    {
        ShowMoreResultsViewController *smrvc = segue.destinationViewController;
        smrvc.searchResultsArray = self.searchResultsArray;
        smrvc.currentLocation = self.locationManager.location;        
    }
    else if ([[segue identifier] isEqualToString:@"AdvancedSearchSegue"])
    {
        AdvancedSearchViewController *asvc = segue.destinationViewController;
        asvc.currentLocation = self.locationManager.location;
    }
}

@end
