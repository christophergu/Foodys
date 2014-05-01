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

@interface SearchViewController ()<CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property CLLocationManager *locationManager;
@property (strong, nonatomic) LogInViewController *modalLogInViewController;
@property (strong, nonatomic) SignInViewController *modalSignInViewController;
@property (strong, nonatomic) NSMutableArray *searchResultsArray;

@property (strong, nonatomic) NSArray *suggestionsArray;

@property int numberOfReviewsAndRecommendations;

@property (strong, nonatomic) NSArray *rankings;

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) IBOutlet UILabel *rankingLabel;
@property (strong, nonatomic) IBOutlet UITextField *cuisineTextField;

@property (strong, nonatomic) CLLocation* currentLocation;

@property BOOL venueSearch;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) NSString *locationCoordinatesString;
@property (strong, nonatomic) IBOutlet UILabel *suggestionsLabel;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    

    

    
    
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes =
    @{NSFontAttributeName: [UIFont fontWithName:@"NotoSans-Bold" size:16],
      NSForegroundColorAttributeName: [UIColor whiteColor]};
    
//    [self.navigationController.navigationBar setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:
//      [UIFont fontWithName:@"NotoSans-Bold" size:21],
//      NSFontAttributeName, nil]];
    
    self.suggestionsLabel.font = [UIFont fontWithName:@"nevis" size:self.suggestionsLabel.font.pointSize];
//
//    self.navigationController.navigationBarHidden = YES;
    

    
    self.locationManager = [CLLocationManager new];
    
    self.locationManager.delegate = self;
    
    [self.locationManager startUpdatingLocation];
    
    self.currentLocation = self.locationManager.location;
    
    self.suggestionsArray = @[@"burrito", @"burger", @"pizza", @"steak", @"sushi", @"taco"];
    
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

}

//- (void)locationManager: (CLLocationManager *)manager
//       didFailWithError: (NSError *)error
//{
//    [manager stopUpdatingLocation];
//    NSLog(@"error%@",error);
//    switch([error code])
//    {
//        case kCLErrorNetwork: // general, network-related error
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"please check your network connection or that you are not in airplane mode" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
//            //[alert release];
//        }
//            break;
//        case kCLErrorDenied:{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"user has denied to use current Location " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
//            //[alert release];
//        }
//            break;
//        default:
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"unknown network error" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
//            //[alert release];
//        }
//            break;
//    }
//}



#pragma mark - check if there is a current user method

-(void)viewWillAppear:(BOOL)animated
{
    self.currentUser = [PFUser currentUser];
    
    [self.myTableView deselectRowAtIndexPath:[self.myTableView indexPathForSelectedRow] animated:YES];
    
//    self.locationCoordinatesString = [NSString stringWithFormat:@"%.1f,%.1f",
//                                      self.locationManager.location.coordinate.latitude,
//                                      self.locationManager.location.coordinate.longitude];
//    NSLog(@"lcs %@",self.locationCoordinatesString);
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationNotification" object:self.locationCoordinatesString];
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
        NSLog(@"hi");
        NSLog(@"lat %.1f", self.locationManager.location.coordinate.latitude);
        NSLog(@"long %.1f", self.locationManager.location.coordinate.longitude);
        locationTextForSearch = [NSString stringWithFormat:@"&location=%.1f,%.1f&radius=1000000",
                                 self.locationManager.location.coordinate.latitude,
                                 self.locationManager.location.coordinate.longitude];
        
        NSLog(@"%@",self.locationManager.location);
        [itemSearchString appendString:locationTextForSearch];
    }
    
    NSLog(@"%@",itemSearchString);
    
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
        NSLog(@"hi");
        NSLog(@"lat %.1f", self.locationManager.location.coordinate.latitude);
        NSLog(@"long %.1f", self.locationManager.location.coordinate.longitude);
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
        NSLog(@"%@",intermediateDictionary);
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
            
    
        
        } else {
        
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
    if ([[segue identifier] isEqualToString:@"RestaurantViewControllerSegue"])
    {
        RestaurantViewController *rvc = segue.destinationViewController;
//        rvc.chosenRestaurantDictionary = ?.searchTerm;
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
