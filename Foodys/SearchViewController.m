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
@property (strong, nonatomic) NSArray *searchResultsArray;

@property (strong, nonatomic) NSArray *pickerArray;

@property (strong, nonatomic) IBOutlet UIPickerView *myPickerView;
@property (strong, nonatomic) NSString *stringForSelectedPickerRow;


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
    
//    peruvian,
//    mediterranean,
//    moroccan,
//    persian,
//    cambodian,
//    "latin american",
//    caribbean,
//    vietnamese,
//    "dim sum",
//    german,
//    "steakhouse / grill",
//    brazilian,
//    venezuelan,
//    taiwanese,
//    "middle eastern",
//    vegan,
//    afghan,
//    cuban,
//    tapas,
//    malaysian,
//    british,
//    african
    
    self.pickerArray = @[@"american", @"chinese", @"italian", @"german", @"japanese"];
}

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
-(void)viewWillAppear:(BOOL)animated
{
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser)
    {
        [self performSegueWithIdentifier:@"LogInSegue" sender:self];
    }
}

- (void)foodSearch
{
    self.searchResultsArray = nil;
    
    NSMutableString *itemSearchString = nil;
    itemSearchString = [@"http://api.locu.com/v1_0/venue/search/?api_key=aea05d0dffb636cb9aad86f6482e51035d79e84e" mutableCopy];
    
    NSString *cuisineTextForSearch;
    NSString *locationTextForSearch;
    
    if (!(self.stringForSelectedPickerRow.length < 1))
    {
        cuisineTextForSearch = [NSString stringWithFormat:@"&cuisine=%@",self.stringForSelectedPickerRow];
        cuisineTextForSearch = [cuisineTextForSearch stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        [itemSearchString appendString:cuisineTextForSearch];
    }
    
    if (self.locationManager.location)
    {
        NSLog(@"hi");
        NSLog(@"lat %.1f", self.locationManager.location.coordinate.latitude);
        NSLog(@"long %.1f", self.locationManager.location.coordinate.longitude);
        locationTextForSearch = [NSString stringWithFormat:@"&location=%.1f,%.1f&radius=50000",
                                 self.locationManager.location.coordinate.latitude,
                                 self.locationManager.location.coordinate.longitude];
        [itemSearchString appendString:locationTextForSearch];
    }

    
    NSLog(@"%@",itemSearchString);
    
    NSURL *url = [NSURL URLWithString: itemSearchString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
        NSDictionary *intermediateDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        self.searchResultsArray = intermediateDictionary[@"objects"];
        
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
