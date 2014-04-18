//
//  RestaurantViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/13/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "RestaurantViewController.h"

@interface RestaurantViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *myAtmosphereImageView;
@property (strong, nonatomic) IBOutlet UIButton *phoneNumber;
@property (strong, nonatomic) IBOutlet UIButton *websiteURL;
@property (strong, nonatomic) IBOutlet UIButton *address;
@property (strong, nonatomic) NSDictionary *restaurantResultsDictionary;
@property (strong, nonatomic) IBOutlet UILabel *sundayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *mondayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *tuesdayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *wednesdayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *thursdayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *fridayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *saturdayHoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *sunLabel;
@property (strong, nonatomic) IBOutlet UILabel *monLabel;
@property (strong, nonatomic) IBOutlet UILabel *tueLabel;
@property (strong, nonatomic) IBOutlet UILabel *wedLabel;
@property (strong, nonatomic) IBOutlet UILabel *thuLabel;
@property (strong, nonatomic) IBOutlet UILabel *friLabel;
@property (strong, nonatomic) IBOutlet UILabel *satLabel;

@end

@implementation RestaurantViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.phoneNumber setTitle:self.chosenRestaurantDictionary[@"phone"] forState:UIControlStateNormal];
    [self.websiteURL setTitle:self.chosenRestaurantDictionary[@"website_url"] forState:UIControlStateNormal];
    NSString *fullAddress = [NSString stringWithFormat:@"%@\n%@, %@",self.chosenRestaurantDictionary[@"street_address"],self.chosenRestaurantDictionary[@"region"], self.chosenRestaurantDictionary[@"postal_code"]];
    [self.address setTitle:fullAddress forState:UIControlStateNormal];
    [self.address.titleLabel setTextAlignment: NSTextAlignmentCenter];


    self.navigationItem.title = self.chosenRestaurantDictionary[@"name"];
    self.myAtmosphereImageView.clipsToBounds = YES;

    [self loadFlickrImageForAtmosphere];
    [self getVenueDetail];
    
    self.sunLabel.alpha = 0.0;
    self.monLabel.alpha = 0.0;
    self.tueLabel.alpha = 0.0;
    self.wedLabel.alpha = 0.0;
    self.thuLabel.alpha = 0.0;
    self.friLabel.alpha = 0.0;
    self.satLabel.alpha = 0.0;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    
    
    

}

- (void)getVenueDetail
{
    NSMutableString *itemSearchString = [[NSString stringWithFormat:@"http://api.locu.com/v1_0/venue/%@/?api_key=aea05d0dffb636cb9aad86f6482e51035d79e84e",self.chosenRestaurantDictionary[@"id"]] mutableCopy];
    
    NSURL *url = [NSURL URLWithString: itemSearchString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
        NSDictionary *intermediateDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        self.restaurantResultsDictionary = intermediateDictionary[@"objects"][0];
        
        NSLog(@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Friday"]);
        
        if (![self.restaurantResultsDictionary[@"open_hours"][@"Thursday"]  isEqual: @[]])
        {
            NSLog(@"yaaa");
            self.sundayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Sunday"][0]];
            self.mondayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Monday"][0]];
            self.tuesdayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Tuesday"][0]];
            self.wednesdayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Wednesday"][0]];
            self.thursdayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Thursday"][0]];
            self.fridayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Friday"][0]];
            self.saturdayHoursLabel.text = [NSString stringWithFormat:@"%@",self.restaurantResultsDictionary[@"open_hours"][@"Saturday"][0]];
            
            self.sunLabel.alpha = 1.0;
            self.monLabel.alpha = 1.0;
            self.tueLabel.alpha = 1.0;
            self.wedLabel.alpha = 1.0;
            self.thuLabel.alpha = 1.0;
            self.friLabel.alpha = 1.0;
            self.satLabel.alpha = 1.0;
        };
    }];
}

- (void)loadFlickrImageForAtmosphere
{
    NSString *apiKey = @"0a0bffa4d380be872ecba2aa0630065b";
    
    NSString *flickrSearchString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&tags=%@&text=%@&sort=relevance&per_page=10&format=json&nojsoncallback=1",
                                    apiKey,
                                    self.chosenRestaurantDictionary[@"cuisine"],
                                    self.chosenRestaurantDictionary[@"cuisine"]];
    NSURL *flickrSearchURL = [NSURL URLWithString:flickrSearchString];
    NSURLRequest *flickrSearchRequest = [NSURLRequest requestWithURL:flickrSearchURL];
    [NSURLConnection sendAsynchronousRequest:flickrSearchRequest queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *tempSearchResultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
         NSArray *flickrPhotosArray = tempSearchResultsDictionary[@"photos"][@"photo"];
         
         if (flickrPhotosArray) {
             NSDictionary *flickrElement = flickrPhotosArray.firstObject;
             NSString *flickrURLstring = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg",
                                          [flickrElement[@"farm"] stringValue],
                                          flickrElement[@"server"],
                                          flickrElement[@"id"],
                                          flickrElement[@"secret"]];
             NSURL * flickrImageURL = [NSURL URLWithString:flickrURLstring];
             
             NSData * imageData = [[NSData alloc] initWithContentsOfURL: flickrImageURL];
             
             self.myAtmosphereImageView.image = [UIImage imageWithData: imageData];
         }
         else
         {
             // do something else
         }
         
     }];
}
@end
