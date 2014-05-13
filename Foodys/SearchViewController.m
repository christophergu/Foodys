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
#import "AdvancedSearchViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface SearchViewController ()<CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation* currentLocation;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UITextField *cuisineTextField;
@property (strong, nonatomic) IBOutlet UILabel *rankingLabel;
@property (strong, nonatomic) NSArray *suggestionsArray;
@property (strong, nonatomic) NSArray *rankings;
@property (strong, nonatomic) NSMutableArray *searchResultsArray;
@property (strong, nonatomic) NSString *locationCoordinatesString;
@property (strong, nonatomic) PFUser *currentUser;
@property int numberOfReviewsAndRecommendations;
@property BOOL venueSearch;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    
    self.locationManager.delegate = self;

    self.suggestionsArray = @[@"bagel",
                              @"burrito",
                              @"burger",
                              @"coffee",
                              @"hot dog",
                              @"lasagna",
                              @"pad thai",
                              @"pancakes",
                              @"pizza",
                              @"salad",
                              @"sandwich",
                              @"smoothie",
                              @"steak",
                              @"sushi",
                              @"taco"];
    
    self.rankings = @[@"Shy Foodie",
                      @"Novice Foodie",
                      @"Mentor Foodie",
                      @"Master Foodie",
                      @"Genius Foodie",
                      @"Celebrity Foodie",
                      @"Rockstar Foodie",
                      @"Superhero Foodie"];
    
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f]];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.locationManager startUpdatingLocation];
    self.currentLocation = self.locationManager.location;
    
    self.currentUser = [PFUser currentUser];
    
    self.cuisineTextField.text = @"";
    [self.myTableView deselectRowAtIndexPath:[self.myTableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - table view methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.suggestionsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuggestionCellReuseID"];
    cell.textLabel.text = self.suggestionsArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedSuggestionFoodItem = self.suggestionsArray[indexPath.row];
    
    [self suggestionFoodSearch:selectedSuggestionFoodItem];
}

#pragma mark - search helper method

- (void)foodSearch
{
    self.searchResultsArray = nil;
    
    NSMutableString *itemSearchString = nil;
    itemSearchString = [@"http://api.locu.com/v1_0/venue/search/?api_key=aea05d0dffb636cb9aad86f6482e51035d79e84e" mutableCopy];
    
    [self nameAutoCorrect];
    
    NSString *nameTextForSearch;
    NSString *locationTextForSearch;

    if (![self.cuisineTextField.text isEqualToString:@""])
    {
        nameTextForSearch = [NSString stringWithFormat:@"&name=%@",self.cuisineTextField.text];
        nameTextForSearch = [nameTextForSearch stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        [itemSearchString appendString:nameTextForSearch];
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
        self.searchResultsArray = intermediateDictionary[@"objects"];
                
        self.venueSearch = 1;
        [self performSegueWithIdentifier:@"ShowMoreResultsSegue" sender:self];
    }];
}

- (void)nearbySearch
{
    NSMutableString *itemSearchString = nil;
    itemSearchString = [@"http://api.locu.com/v1_0/venue/search/?api_key=aea05d0dffb636cb9aad86f6482e51035d79e84e" mutableCopy];
    
    NSString *locationTextForSearch;
    
    if (self.locationManager.location)
    {
        locationTextForSearch = [NSString stringWithFormat:@"&location=%.1f,%.1f&radius=10000",
                                 self.locationManager.location.coordinate.latitude,
                                 self.locationManager.location.coordinate.longitude];
        [itemSearchString appendString:locationTextForSearch];
    }
    
    NSURL *url = [NSURL URLWithString: itemSearchString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
        NSDictionary *intermediateDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        self.searchResultsArray = intermediateDictionary[@"objects"];
        
        self.venueSearch = 1;
        [self performSegueWithIdentifier:@"ShowMoreResultsSegue" sender:self];
    }];
}

-(void)nameAutoCorrect
{
    if ([self.cuisineTextField.text isEqualToString:@"macdonalds"] ||
        [self.cuisineTextField.text isEqualToString:@"macdonald's"] ||
        [self.cuisineTextField.text isEqualToString:@"mcdonalds"])
    {
        self.cuisineTextField.text = @"McDonald's";
    }
    else if ([self.cuisineTextField.text isEqualToString:@"wendys"])
    {
        self.cuisineTextField.text = @"Wendy's";
    }
    else if ([self.cuisineTextField.text isEqualToString:@"chikfila"] ||
             [self.cuisineTextField.text isEqualToString:@"chickfila"] ||
             [self.cuisineTextField.text isEqualToString:@"chickfilla"] ||
             [self.cuisineTextField.text isEqualToString:@"chick-fill-a"])
    {
        self.cuisineTextField.text = @"Chick-fil-a";
    }
    else if ([self.cuisineTextField.text isEqualToString:@"burgerking"] ||
             [self.cuisineTextField.text isEqualToString:@"burger-king"])
    {
        self.cuisineTextField.text = @"Burger King";
    }
}

- (void)suggestionFoodSearch:(NSString *)selectedSuggestedFoodItem;
{
    self.searchResultsArray = [NSMutableArray new];
    
    NSMutableString *itemSearchString = nil;
    itemSearchString = [@"http://api.locu.com/v1_0/menu_item/search/?api_key=aea05d0dffb636cb9aad86f6482e51035d79e84e" mutableCopy];
    
    NSString *nameFoodForSearch;
    NSString *locationTextForSearch;
    
    nameFoodForSearch = [NSString stringWithFormat:@"&name=%@",selectedSuggestedFoodItem];
    nameFoodForSearch = [nameFoodForSearch stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [itemSearchString appendString:nameFoodForSearch];
    
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
        
        if (connectionError != nil) {
            
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Data Connection Error"
                                                        message:@"No data connection try again later"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
            [av show];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        else
        {
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
        self.venueSearch = 0;
        [self performSegueWithIdentifier:@"ShowMoreResultsSegue" sender:self];
        }
    }];
}

#pragma mark - button methods

- (IBAction)cuisineTextFieldDidEndOnExitButtonPressed:(id)sender
{
    if ([self.cuisineTextField.text isEqualToString:@""] ||
        [self.cuisineTextField.text.lowercaseString isEqualToString:@"nearby"] ||
        [self.cuisineTextField.text.lowercaseString isEqualToString:@"food"] ||
        [self.cuisineTextField.text.lowercaseString isEqualToString:@"anything"]||
        [self.cuisineTextField.text.lowercaseString isEqualToString:@"whatever"])
    {
        [self nearbySearch];
    }
    else
    {
        [self foodSearch];
    }
}

#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.locationManager stopUpdatingLocation];
    
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
        
        if (self.venueSearch)
        {
            smrvc.cameFromAdvancedSearch = 1;
        }
        else
        {
            smrvc.cameFromAdvancedSearch = 0;
        }
    }
    else if ([[segue identifier] isEqualToString:@"SuggestionToResultsSegue"])
    {
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:sender];
        NSString *selectedSuggestionFoodItem = self.suggestionsArray[indexPath.row];
        
        [self suggestionFoodSearch:selectedSuggestionFoodItem];
        
        ShowMoreResultsViewController *smrvc = segue.destinationViewController;
        smrvc.searchResultsArray = self.searchResultsArray;
    }
}

@end
