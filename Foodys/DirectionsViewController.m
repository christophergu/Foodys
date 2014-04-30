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



@end

@implementation DirectionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    [self.myMapView setShowsUserLocation:YES];
    self.currentLocation = [CLLocation new];
    self.currentLocation = self.locationManager.location;
    
    CLLocationCoordinate2D centerCoordinate = self.locationManager.location.coordinate;
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.015, 0.015);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, coordinateSpan);
    self.myMapView.region = region;
    
//    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//    annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees latitude, CLLocationDegrees longitude);
//    [self.myMapView addAnnotation:annotation];
//    
    

    
}

@end
