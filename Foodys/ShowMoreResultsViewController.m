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

@interface ShowMoreResultsViewController ()<UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *myMapView;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;

@property (strong, nonatomic) NSDictionary *chosenRestaurantDictionary;

@end

@implementation ShowMoreResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myMapView.alpha = 0.0;
    [self mapLoad];
}

#pragma mark - segmented control methods

- (IBAction)onSegmentedControlValueChanged:(id)sender
{
    if (self.mySegmentedControl.selectedSegmentIndex == 0)
    {
        self.myMapView.alpha = 0.0;
    }
    else if (self.mySegmentedControl.selectedSegmentIndex == 1)
    {
        self.myMapView.alpha = 1.0;
    }
}

#pragma mark - map methods

-(void)mapLoad
{
    for (NSDictionary *restaurant in self.searchResultsArray) {
        
        NSString *restaurantAddress;
        
        if (self.cameFromAdvancedSearch)
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
                if (self.cameFromAdvancedSearch)
                {
                    annotation.title = restaurant[@"name"];
                }
                else
                {
                    annotation.title = restaurant[@"venue"][@"name"];
                }
                annotation.subtitle = restaurantAddress;
                
                [self.myMapView addAnnotation:annotation];
            }
            [self.myMapView showAnnotations:self.myMapView.annotations animated:YES];
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
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
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
    return self.searchResultsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsReuseCellID"];
    
    NSDictionary *currentRestaurant = self.searchResultsArray[indexPath.row];
    
    if (self.cameFromAdvancedSearch)
    {
        cell.restaurantTitle.text = self.searchResultsArray[indexPath.row][@"name"];
        cell.addressLabel.text = self.searchResultsArray[indexPath.row][@"street_address"];
        
        if (!(currentRestaurant[@"lat"] == nil) && !(currentRestaurant[@"long"] == nil))
        {
            double latitude = [currentRestaurant[@"venue"][@"lat"] doubleValue];
            double longitude = [currentRestaurant[@"venue"][@"long"] doubleValue];
            
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
            MKMapItem *currentMapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            
            float distance = [currentMapItem.placemark.location distanceFromLocation:self.currentLocation];
            
            cell.distanceLabel.text = [NSString stringWithFormat:@"%d meters", (int)distance];
        }
    }
    else
    {
        cell.restaurantTitle.text = self.searchResultsArray[indexPath.row][@"venue"][@"name"];
        cell.addressLabel.text = self.searchResultsArray[indexPath.row][@"venue"][@"street_address"];
        
        if (!(currentRestaurant[@"venue"][@"lat"] == nil) && !(currentRestaurant[@"venue"][@"long"] == nil))
        {
            double latitude = [currentRestaurant[@"venue"][@"lat"] doubleValue];
            double longitude = [currentRestaurant[@"venue"][@"long"] doubleValue];
            
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
            MKMapItem *currentMapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
            
            float distance = [currentMapItem.placemark.location distanceFromLocation:self.currentLocation];
            
            cell.distanceLabel.text = [NSString stringWithFormat:@"%d meters", (int)distance];
        }
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
    
    if (self.cameFromAdvancedSearch) {
        nameString = self.searchResultsArray[indexPath.row][@"name"];
        postalCodeString = self.searchResultsArray[indexPath.row][@"postal_code"];
        localityString = self.searchResultsArray[indexPath.row][@"locality"];
        regionString = self.searchResultsArray[indexPath.row][@"region"];
        streetAddressString = self.searchResultsArray[indexPath.row][@"street_address"];
    }
    else
    {
        nameString = self.searchResultsArray[indexPath.row][@"venue"][@"name"];
        postalCodeString = self.searchResultsArray[indexPath.row][@"venue"][@"postal_code"];
        localityString = self.searchResultsArray[indexPath.row][@"venue"][@"locality"];
        regionString = self.searchResultsArray[indexPath.row][@"venue"][@"region"];
        streetAddressString = self.searchResultsArray[indexPath.row][@"venue"][@"street_address"];

    }
    
    NSString *venueSearchString = [NSString stringWithFormat:@"http://api.locu.com/v1_0/venue/search/?api_key=aea05d0dffb636cb9aad86f6482e51035d79e84e&radius=500&name=%@&postal_code=%@&locality=%@&region=%@",
                                   nameString,
                                   postalCodeString,
                                   localityString,
                                   regionString];
    venueSearchString = [venueSearchString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSURL *url = [NSURL URLWithString: venueSearchString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
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
        
        NSLog(@"%@",self.chosenRestaurantDictionary);
        [self performSegueWithIdentifier:@"RestaurantViewControllerSegue" sender:self];

        }
    ];
}

#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)cell
{
    RestaurantViewController *rvc = segue.destinationViewController;
    
    if (self.mySegmentedControl.selectedSegmentIndex == 1)
    {
        rvc.chosenRestaurantDictionary = self.chosenRestaurantDictionary;
    }
    else if ([[segue identifier]isEqualToString:@"RestaurantViewControllerSegue"])
    {
        rvc.chosenRestaurantDictionary = self.chosenRestaurantDictionary;
        
    }
}
@end
