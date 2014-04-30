//
//  DirectionsViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/29/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "DirectionsViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface DirectionsViewController ()
@property (strong, nonatomic) IBOutlet MKMapView *myMapView;

//@property location *location;
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property (strong, nonatomic) IBOutlet UITextView *directionsTextView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;



@end

@implementation DirectionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.locationManager = [CLLocationManager new];
    [self.myMapView setShowsUserLocation:YES];
    self.currentLocation = [CLLocation new];
    self.currentLocation = self.locationManager.location;
    
    self.mySegmentedControl.tintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    
    [self loadMapAndDirections:0];
}

- (IBAction)onSegmentedControlValueChanged:(id)sender
{
    [self.myMapView setNeedsDisplay];
    
    if (self.mySegmentedControl.selectedSegmentIndex == 0) {
        [self loadMapAndDirections:0];
    }
    else if (self.mySegmentedControl.selectedSegmentIndex == 1) {
        [self loadMapAndDirections:1];
    }
}


-(void)loadMapAndDirections:(BOOL)walkOrDrive
{
    double latitude = [[NSString stringWithFormat:@"%@", self.chosenRestaurantDictionary[@"lat"]] doubleValue];
    double longitude = [[NSString stringWithFormat:@"%@", self.chosenRestaurantDictionary[@"long"]] doubleValue];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    annotation.title = self.chosenRestaurantDictionary[@"name"];
    
    [self.myMapView addAnnotation:annotation];
    
    double centerLatitude = (self.locationManager.location.coordinate.latitude + latitude)/2.0;
    double centerLongitude = (self.locationManager.location.coordinate.longitude + longitude)/2.0;
    
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(centerLatitude, centerLongitude);
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.1, 0.1);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, coordinateSpan);
    self.myMapView.region = region;
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    CLLocationCoordinate2D destinationRestaurant = CLLocationCoordinate2DMake(latitude, longitude);
    MKPlacemark *placemark = [[MKPlacemark alloc]initWithCoordinate:destinationRestaurant addressDictionary:nil];
    MKMapItem   *mapItem   = [[MKMapItem alloc]initWithPlacemark:placemark];
    request.destination = mapItem;
    
    request.requestsAlternateRoutes = NO;
    
    if (walkOrDrive) {
        request.transportType = MKDirectionsTransportTypeAutomobile;
    }
    else
    {
        request.transportType = MKDirectionsTransportTypeWalking;
    }
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         if (error)
         {
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Data Connection Error"
                                                          message:@"Unable to retrieve direction data, try again later!"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
             
             [av show];
         }
         else
         {
             [self showRoute:response];
         }
     }];

}

-(void)showRoute:(MKDirectionsResponse *)response

{
    for (MKRoute *route in response.routes)
    {
        [self.myMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        for (MKRouteStep *step in route.steps)
        {
            self.directionsTextView.text = [NSString stringWithFormat:@"%@\n%@", self.directionsTextView.text, step.instructions];
        }
    }
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc]initWithOverlay:overlay];
    renderer.strokeColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    NSLog(@"Blue");
    renderer.lineWidth   = 5.0;
    return renderer;
}

@end