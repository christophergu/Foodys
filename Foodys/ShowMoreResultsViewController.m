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

-(void)mapLoad
{
    for (NSDictionary *restaurant in self.searchResultsArray) {
        
        NSString *restaurantAddress = [NSString stringWithFormat:@"%@, %@, %@ %@",
                                       restaurant[@"street_address"],
                                       restaurant[@"locality"],
                                       restaurant[@"region"],
                                       restaurant[@"postal_code"]];
        
        CLGeocoder *geocoder = [CLGeocoder new];
        [geocoder geocodeAddressString:restaurantAddress completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark* place in placemarks) {
                MKPointAnnotation *annotation = [MKPointAnnotation new];
                annotation.coordinate = place.location.coordinate;
                annotation.title = restaurant[@"name"];
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
    //    NSString* postalCodeString = [[chosenPinStringArrayTwo objectAtIndex: 0]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
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
        
        [self performSegueWithIdentifier:@"RestaurantViewControllerSegue" sender:self];
    }
     ];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResultsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsReuseCellID"];
    cell.restaurantTitle.text = self.searchResultsArray[indexPath.row][@"name"];
    cell.addressLabel.text = self.searchResultsArray[indexPath.row][@"street_address"];
    
    NSDictionary *currentRestaurant = self.searchResultsArray[indexPath.row];

    if (!(currentRestaurant[@"lat"] == nil) && !(currentRestaurant[@"long"] == nil))
    {
        double latitude = [currentRestaurant[@"lat"] doubleValue];
        double longitude = [currentRestaurant[@"long"] doubleValue];
        
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
        MKMapItem *currentMapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        
        float distance = [currentMapItem.placemark.location distanceFromLocation:self.currentLocation];
        
        cell.distanceLabel.text = [NSString stringWithFormat:@"%d meters", (int)distance];
    }

    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)cell
{
    RestaurantViewController *rvc = segue.destinationViewController;
    
    if (self.mySegmentedControl.selectedSegmentIndex == 1)
    {
        rvc.chosenRestaurantDictionary = self.chosenRestaurantDictionary;
    }
    else if ([[segue identifier]isEqualToString:@"RestaurantViewControllerSegue"])
    {
        NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
        NSLog(@"%@",self.searchResultsArray[indexPath.row]);
        rvc.chosenRestaurantDictionary = self.searchResultsArray[indexPath.row];
    }
}
@end
