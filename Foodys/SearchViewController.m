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

@interface SearchViewController ()<CLLocationManagerDelegate, MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *cuisineTextField;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UIButton *resultsButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UIButton *allowLocationButton;
@property (strong, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutlet UIButton *foodysSuggestionButton;

@property CLLocationManager *locationManager;
@property (strong, nonatomic) LogInViewController *modalLogInViewController;
@property (strong, nonatomic) SignInViewController *modalSignInViewController;
@property (strong, nonatomic) NSArray *searchResultsArray;


@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.resultsButton.alpha = 0.0;
    self.foodysSuggestionButton.alpha = 0.0;
    
    self.allowLocationButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.locationManager = [CLLocationManager new];
    
    self.locationManager.delegate = self;
    
    if (self.locationManager.location)
    {
        [self.allowLocationButton setTitle:@"Using Current Location" forState:UIControlStateNormal];
    }
    
    // locu api: aea05d0dffb636cb9aad86f6482e51035d79e84e
    // locu widget api: 71747ca57e325a86544c9edc0d96a9c5b95026f7
}

-(void)viewWillAppear:(BOOL)animated
{
    [self performSegueWithIdentifier:@"LogInSegue" sender:self];
}

- (void)foodSearch
{
    self.searchResultsArray = nil;
    
    NSMutableString *itemSearchString;
    itemSearchString = [@"http://api.locu.com/v1_0/venue/search/?api_key=aea05d0dffb636cb9aad86f6482e51035d79e84e" mutableCopy];
    
    [self nameAutoCorrect];
    
    NSString *nameTextForSearch;
    NSString *cuisineTextForSearch;
    NSString *locationTextForSearch;
    NSString *regionTextForSearch;
    
    if (![self.cuisineTextField.text isEqualToString:@""])
    {
        cuisineTextForSearch = [NSString stringWithFormat:@"&cuisine=%@",self.cuisineTextField.text];
        cuisineTextForSearch = [cuisineTextForSearch stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        [itemSearchString appendString:cuisineTextForSearch];
    }
    
    if (![self.nameTextField.text isEqualToString:@""])
    {
        nameTextForSearch = [NSString stringWithFormat:@"&name=%@",self.nameTextField.text];
        nameTextForSearch = [nameTextForSearch stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        [itemSearchString appendString:nameTextForSearch];
    }
    
    if ([self.locationTextField.text isEqualToString:@""])
    {
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
    }
    else if (![self.locationTextField.text isEqualToString:@""])
    {
        if ([self.locationTextField.text intValue] <= 99999 && !(self.locationTextField.text.intValue == 0))
        {
            locationTextForSearch = [NSString stringWithFormat:@"&postal_code=%@",self.locationTextField.text];
        }
        else if ([self.locationTextField.text rangeOfString:@","].location == NSNotFound)
        {
            locationTextForSearch = [NSString stringWithFormat:@"&locality=%@",self.locationTextField.text];
            locationTextForSearch = [locationTextForSearch stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        }
        else if ([self.locationTextField.text rangeOfString:@","].location)
        {
            NSArray* searchedStringArray = [self.locationTextField.text componentsSeparatedByString: @","];
            NSString* locationWord = [searchedStringArray objectAtIndex: 0];
            NSString* regionWord = [searchedStringArray objectAtIndex: 1];
            regionWord = [regionWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            locationTextForSearch = [NSString stringWithFormat:@"&locality=%@",locationWord];
            locationTextForSearch = [locationTextForSearch stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            regionTextForSearch = [NSString stringWithFormat:@"&region=%@",regionWord];
            [itemSearchString appendString:regionTextForSearch];
        }
        [itemSearchString appendString:locationTextForSearch];
    }
    
    NSLog(@"%@",itemSearchString);
    
    NSURL *url = [NSURL URLWithString: itemSearchString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
        NSDictionary *intermediateDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        self.searchResultsArray = intermediateDictionary[@"objects"];
    }];
}

-(void)nameAutoCorrect
{
    if ([self.nameTextField.text isEqualToString:@"macdonalds"] ||
        [self.nameTextField.text isEqualToString:@"macdonald's"] ||
        [self.nameTextField.text isEqualToString:@"mcdonalds"])
    {
        self.nameTextField.text = @"McDonald's";
    }
    else if ([self.nameTextField.text isEqualToString:@"wendys"])
    {
        self.nameTextField.text = @"Wendy's";
    }
    else if ([self.nameTextField.text isEqualToString:@"chikfila"] ||
             [self.nameTextField.text isEqualToString:@"chickfila"] ||
             [self.nameTextField.text isEqualToString:@"chickfilla"] ||
             [self.nameTextField.text isEqualToString:@"chick-fill-a"])
    {
        self.nameTextField.text = @"Chick-fil-a";
    }
    else if ([self.nameTextField.text isEqualToString:@"burgerking"] ||
             [self.nameTextField.text isEqualToString:@"burger-king"])
    {
        self.nameTextField.text = @"Burger King";
    }
}

#pragma mark - text field methods

- (IBAction)cuisineTextFieldEndEditing:(id)sender
{
    [self.cuisineTextField endEditing:YES];
    [self.cuisineTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.2] CGColor]];
    [self.cuisineTextField.layer setBorderWidth:3.0];
    self.cuisineTextField.layer.cornerRadius = 5;
    self.cuisineTextField.clipsToBounds = YES;
}

// highlights if a field is being used
- (IBAction)cuineseTextFieldEditingDidEnd:(id)sender
{
    [self.cuisineTextField endEditing:YES];
    if (![self.cuisineTextField.text isEqualToString:@""])
    {
        [self.cuisineTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.2] CGColor]];
        [self.cuisineTextField.layer setBorderWidth:3.0];
        self.cuisineTextField.layer.cornerRadius = 5;
        self.cuisineTextField.clipsToBounds = YES;
    }
    else
    {
        [self.cuisineTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.0] CGColor]];
        [self.cuisineTextField.layer setBorderWidth:0.0];
    }
}

- (IBAction)nameTextFieldEndEditing:(id)sender
{
    [self.nameTextField endEditing:YES];
    [self.nameTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.2] CGColor]];
    [self.nameTextField.layer setBorderWidth:3.0];
    self.nameTextField.layer.cornerRadius = 5;
    self.nameTextField.clipsToBounds = YES;
}

// highlights if a field is being used
- (IBAction)nameTextFieldEditingDidEnd:(id)sender
{
    [self.nameTextField endEditing:YES];
    if (![self.nameTextField.text isEqualToString:@""])
    {
        [self.nameTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.2] CGColor]];
        [self.nameTextField.layer setBorderWidth:3.0];
        self.nameTextField.layer.cornerRadius = 5;
        self.nameTextField.clipsToBounds = YES;
    }
    else
    {
        [self.nameTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.0] CGColor]];
        [self.nameTextField.layer setBorderWidth:0.0];
    }
}

- (IBAction)locationTextFieldEndEditing:(id)sender
{
    [self.locationTextField endEditing:YES];
    [self.locationTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.2] CGColor]];
    [self.locationTextField.layer setBorderWidth:3.0];
    self.locationTextField.layer.cornerRadius = 5;
    self.locationTextField.clipsToBounds = YES;
}

// highlights if a field is being used
- (IBAction)locationTextFieldEditingDidEnd:(id)sender
{
    [self.locationTextField endEditing:YES];
    if (![self.locationTextField.text isEqualToString:@""])
    {
        [self.locationTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.2] CGColor]];
        [self.locationTextField.layer setBorderWidth:3.0];
        self.locationTextField.layer.cornerRadius = 5;
        self.locationTextField.clipsToBounds = YES;
    }
    else
    {
        [self.locationTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.0] CGColor]];
        [self.locationTextField.layer setBorderWidth:0.0];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.cuisineTextField endEditing:YES];
    [self.nameTextField resignFirstResponder];
}

#pragma mark - button methods

- (IBAction)onAllowLocationButtonPressed:(id)sender
{
    [self.locationManager startUpdatingLocation];
    NSLog(@"%@",self.locationManager.location);
    [self.allowLocationButton setTitle:@"Using Current Location" forState:UIControlStateNormal];
}

- (IBAction)onSearchButtonPressed:(id)sender
{
    [self foodSearch];
    
    if (self.resultsButton.alpha == 0.0)
    {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.nameTextField.alpha = 0.0;
                             self.cuisineTextField.alpha = 0.0;
                             self.locationTextField.alpha = 0.0;
                             self.resultsButton.alpha = 1.0;
                             self.foodysSuggestionButton.alpha = 1.0;
                             self.allowLocationButton.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [self removeHighlightingOnTextFields];
                         }];
    }
    else if (self.resultsButton.alpha == 1.0)
    {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.resultsButton.alpha = 0.0;
                             self.foodysSuggestionButton.alpha = 0.0;
                             self.nameTextField.alpha = 1.0;
                             self.cuisineTextField.alpha = 1.0;
                             self.locationTextField.alpha = 1.0;
                             self.allowLocationButton.alpha = 1.0;
                         }];
    }
}

-(void)removeHighlightingOnTextFields
{
    [self.cuisineTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.0] CGColor]];
    [self.cuisineTextField.layer setBorderWidth:0.0];
    [self.nameTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.0] CGColor]];
    [self.nameTextField.layer setBorderWidth:0.0];
    [self.locationTextField.layer setBorderColor:[[[UIColor greenColor] colorWithAlphaComponent:0.0] CGColor]];
    [self.locationTextField.layer setBorderWidth:0.0];
}

#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"RestaurantViewControllerSegue"]) {
        RestaurantViewController *rvc = segue.destinationViewController;
        rvc.chosenRestaurantDictionary = self.searchResultsArray.firstObject;
    }
    else if ([[segue identifier] isEqualToString:@"ShowMoreResultsSegue"]) {
        ShowMoreResultsViewController *smrvc = segue.destinationViewController;
        smrvc.searchResultsArray = self.searchResultsArray;
        smrvc.currentLocation = self.locationManager.location;
    }
}

@end
