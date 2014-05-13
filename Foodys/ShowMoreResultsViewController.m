//
//  ShowMoreResultsViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/13/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "ShowMoreResultsViewController.h"
#import "RestaurantViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ResultsTableViewCell.h"
#import <Parse/Parse.h>

@interface ShowMoreResultsViewController ()<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *myMapView;
@property (strong, nonatomic) IBOutlet MKMapView *myRecommendedMapView;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (strong, nonatomic) IBOutlet UIView *locuBackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *locuLogo;
@property (strong, nonatomic) NSDictionary *chosenRestaurantDictionary;
@property (strong, nonatomic) NSMutableArray *recommendedOverlapArray;
@property (strong, nonatomic) PFUser *currentUser;
@property BOOL mapDisplayBool;

@end

@implementation ShowMoreResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myMapView.alpha = 0.0;
    self.myRecommendedMapView.alpha = 0.0;
    self.mapDisplayBool = 0;
    
    self.recommendedOverlapArray = [NSMutableArray new];
    
    [self mapLoadOnMap:self.myMapView withArray:self.searchResultsArray];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.mySegmentedControl.tintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.currentUser = [PFUser currentUser];
    
    NSArray *currentUserArray = @[self.currentUser];
    self.recommendedOverlapArray = [NSMutableArray new];
    
    PFQuery *recommendationsQuery = [PFQuery queryWithClassName:@"Recommendation"];
    [recommendationsQuery whereKey:@"receivers" containsAllObjectsInArray:currentUserArray];
    [recommendationsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *recommendation in objects)
        {
            for (NSDictionary *searchResultDictionary in self.searchResultsArray)
            {
                if ([searchResultDictionary[@"venue"][@"name"] isEqualToString:recommendation[@"name"]])
                {
                    if (![self.recommendedOverlapArray containsObject:recommendation])
                    {
                        [self.recommendedOverlapArray addObject: recommendation];
                    }
                }
            }
        }
        [self mapLoadOnMap:self.myRecommendedMapView withArray:self.recommendedOverlapArray];
    }];
}

#pragma mark - segmented control methods

- (IBAction)onSegmentedControlValueChanged:(id)sender
{
    if (self.mapDisplayBool == 1 && self.myMapView.alpha == 1.0)
    {
        self.myMapView.alpha = 0.0;
        self.myRecommendedMapView.alpha = 1.0;
    }
    else if (self.mapDisplayBool == 1 && self.myMapView.alpha == 0.0)
    {
        self.myMapView.alpha = 1.0;
        self.myRecommendedMapView.alpha = 0.0;
    }
    
    [self.myTableView reloadData];
}

#pragma mark - map methods

- (IBAction)onMapButtonPressed:(id)sender
{
    self.mapDisplayBool = !self.mapDisplayBool;
    
    if (self.mapDisplayBool)
    {
        if (self.mySegmentedControl.selectedSegmentIndex == 0)
        {
            self.myMapView.alpha = 1.0;
            self.myRecommendedMapView.alpha = 0.0;
        }
        else if (self.mySegmentedControl.selectedSegmentIndex == 1)
        {
            self.myMapView.alpha = 0.0;
            self.myRecommendedMapView.alpha = 1.0;
        }
    }
    else
    {
        self.myMapView.alpha = 0.0;
        self.myRecommendedMapView.alpha = 0.0;
    }
}

-(void)mapLoadOnMap:(MKMapView *)mapView withArray:(id)arrayToUse
{
    for (NSDictionary *restaurant in arrayToUse)
    {
        NSString *restaurantAddress;

        if ([restaurant isKindOfClass:[PFObject class]]) {
            restaurantAddress = [NSString stringWithFormat:@"%@, %@, %@ %@",
                                 restaurant[@"restaurantDictionary"][@"street_address"],
                                 restaurant[@"restaurantDictionary"][@"locality"],
                                 restaurant[@"restaurantDictionary"][@"region"],
                                 restaurant[@"restaurantDictionary"][@"postal_code"]];
        }
        else if (self.cameFromAdvancedSearch)
        {
            restaurantAddress = [NSString stringWithFormat:@"%@, %@, %@ %@",
                                 restaurant[@"street_address"],
                                 restaurant[@"locality"],
                                 restaurant[@"region"],
                                 restaurant[@"postal_code"]];
        }
        else
        {
            restaurantAddress = [NSString stringWithFormat:@"%@, %@, %@ %@",
                                  restaurant[@"venue"][@"street_address"],
                                  restaurant[@"venue"][@"locality"],
                                  restaurant[@"venue"][@"region"],
                                  restaurant[@"venue"][@"postal_code"]];
        }
        
        CLGeocoder *geocoder = [CLGeocoder new];
        [geocoder geocodeAddressString:restaurantAddress completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark* place in placemarks) {
                MKPointAnnotation *annotation = [MKPointAnnotation new];
                annotation.coordinate = place.location.coordinate;
                
                if([restaurant isKindOfClass:[PFObject class]])
                {
                    annotation.title = restaurant[@"restaurantDictionary"][@"name"];
                }
                else if (self.cameFromAdvancedSearch)
                {
                    annotation.title = restaurant[@"name"];
                }
                else
                {
                    annotation.title = restaurant[@"venue"][@"name"];
                }
                annotation.subtitle = restaurantAddress;
                
                [mapView addAnnotation:annotation];
            }
            [mapView showAnnotations:mapView.annotations animated:NO];
        }];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSArray* chosenPinStringArray = [view.annotation.subtitle componentsSeparatedByString: @","];
    NSString* streetAddressString = [chosenPinStringArray objectAtIndex: 0];
    NSString* localityString = [[chosenPinStringArray objectAtIndex: 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* regionAndPostalCodeString = [chosenPinStringArray objectAtIndex:2];
    
    NSArray* chosenPinStringArrayTwo = [regionAndPostalCodeString componentsSeparatedByString: @" "];
    NSString* postalCodeString = [[chosenPinStringArrayTwo objectAtIndex: 0]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
    NSString* regionString = [[chosenPinStringArrayTwo objectAtIndex: 1]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
    
    NSString *pinRestaurantSearchString = [NSString stringWithFormat:@"http://api.locu.com/v1_0/venue/search/?api_key=aea05d0dffb636cb9aad86f6482e51035d79e84e&radius=500&name=%@&street_address=%@&locality=%@&region=%@",
                                           view.annotation.title,
                                           streetAddressString,
                                           localityString,
                                           regionString];
    pinRestaurantSearchString = [pinRestaurantSearchString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *url = [NSURL URLWithString: pinRestaurantSearchString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        NSError *error;
        NSDictionary *intermediateDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSArray *chosenRestaurantResultsArray = intermediateDictionary[@"objects"];
        self.chosenRestaurantDictionary = chosenRestaurantResultsArray.firstObject;
        
        if (!self.chosenRestaurantDictionary)
        {
            self.chosenRestaurantDictionary = @{
                                                @"name": view.annotation.title,
                                                @"street_address": streetAddressString,
                                                @"locality": localityString,
                                                @"region": regionString,
                                                @"postal_code": postalCodeString
                                                };
        }
        
        [self performSegueWithIdentifier:@"RestaurantViewControllerSegue" sender:self];
    }
    ];
}

#pragma mark - table view methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int number;
    
    if(self.mySegmentedControl.selectedSegmentIndex==0)
    {
        number = (int)self.searchResultsArray.count;
    }
    else if (self.mySegmentedControl.selectedSegmentIndex==1)
    {
        number = (int)self.recommendedOverlapArray.count;
    }
    
    return number;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsReuseCellID"];
    
    cell.distanceLabel.text = @"";
    
    if(self.mySegmentedControl.selectedSegmentIndex==0)
    {
        if (self.cameFromAdvancedSearch)
        {
            cell.restaurantTitle.text = self.searchResultsArray[indexPath.row][@"name"];
            
            if (self.searchResultsArray[indexPath.row][@"street_address"] != (id)[NSNull null])
            {
                cell.addressLabel.text = self.searchResultsArray[indexPath.row][@"street_address"];
            }
            else
            {
                cell.addressLabel.text = @"";
            }
        }
        else
        {
            cell.restaurantTitle.text = self.searchResultsArray[indexPath.row][@"venue"][@"name"];
            cell.addressLabel.text = self.searchResultsArray[indexPath.row][@"venue"][@"street_address"];
        }
    }
    else if (self.mySegmentedControl.selectedSegmentIndex==1)
    {
        PFObject *currentRecommendedRestaurantObject = self.recommendedOverlapArray[indexPath.row];
        cell.restaurantTitle.text = currentRecommendedRestaurantObject[@"restaurantDictionary"][@"name"];
        cell.addressLabel.text = currentRecommendedRestaurantObject[@"restaurantDictionary"][@"street_address"];
        cell.distanceLabel.text = [NSString stringWithFormat:@"Recommended by %@",currentRecommendedRestaurantObject[@"author"]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* nameString;
    NSString* postalCodeString;
    NSString* localityString;
    NSString* regionString;
    NSString* streetAddressString;
    
    if (!self.cameFromAdvancedSearch)
    {
        if (self.mySegmentedControl.selectedSegmentIndex == 0)
        {
            nameString = self.searchResultsArray[indexPath.row][@"venue"][@"name"];
            postalCodeString = self.searchResultsArray[indexPath.row][@"venue"][@"postal_code"];
            localityString = self.searchResultsArray[indexPath.row][@"venue"][@"locality"];
            regionString = self.searchResultsArray[indexPath.row][@"venue"][@"region"];
            streetAddressString = self.searchResultsArray[indexPath.row][@"venue"][@"street_address"];
        }
        else if (self.mySegmentedControl.selectedSegmentIndex == 1)
        {
            nameString = self.recommendedOverlapArray[indexPath.row][@"restaurantDictionary"][@"name"];
            postalCodeString = self.recommendedOverlapArray[indexPath.row][@"restaurantDictionary"][@"postal_code"];
            localityString = self.recommendedOverlapArray[indexPath.row][@"restaurantDictionary"][@"locality"];
            regionString = self.recommendedOverlapArray[indexPath.row][@"restaurantDictionary"][@"region"];
            streetAddressString = self.recommendedOverlapArray[indexPath.row][@"restaurantDictionary"][@"street_address"];
        }
    
        NSString *venueSearchString = [NSString stringWithFormat:@"http://api.locu.com/v1_0/venue/search/?api_key=aea05d0dffb636cb9aad86f6482e51035d79e84e&radius=500&name=%@&postal_code=%@&locality=%@",
                                       nameString,
                                       postalCodeString,
                                       localityString];
        
        venueSearchString = [venueSearchString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                
        NSURL *url = [NSURL URLWithString: venueSearchString];
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
            NSArray *chosenRestaurantResultsArray = intermediateDictionary[@"objects"];
            self.chosenRestaurantDictionary = chosenRestaurantResultsArray.firstObject;
            
            if (!self.chosenRestaurantDictionary)
            {
                self.chosenRestaurantDictionary = @{
                                    @"name": nameString,
                                    @"street_address": streetAddressString,
                                    @"locality": localityString,
                                    @"region": regionString,
                                    @"postal_code": postalCodeString
                                    };
            }
            [self performSegueWithIdentifier:@"RestaurantViewControllerSegue" sender:self];
            }
        }
        ];
    }
    else
    {
        if (self.mySegmentedControl.selectedSegmentIndex == 0)
        {
            self.chosenRestaurantDictionary = self.searchResultsArray[indexPath.row];
        }
        else if (self.mySegmentedControl.selectedSegmentIndex == 0)
        {
            self.chosenRestaurantDictionary = self.recommendedOverlapArray[indexPath.row];
        }

        [self performSegueWithIdentifier:@"RestaurantViewControllerSegue" sender:self];
    }
}

#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)cell
{
    RestaurantViewController *rvc = segue.destinationViewController;

    if ([[segue identifier]isEqualToString:@"RestaurantViewControllerSegue"])
    {
        rvc.chosenRestaurantDictionary = self.chosenRestaurantDictionary;
    }
}
@end
