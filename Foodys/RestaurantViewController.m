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
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UILabel *phoneNumber;
@property (strong, nonatomic) IBOutlet UILabel *websiteURL;

@end

@implementation RestaurantViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//NSLog(@"%@",self.chosenRestaurantDictionary);
  self.address.text = self.chosenRestaurantDictionary[@"street_address"];
    self.phoneNumber.text = self.chosenRestaurantDictionary[@"phone"];
  self.websiteURL.text = self.chosenRestaurantDictionary [@"website_url"];
    
    self.navigationItem.title = self.chosenRestaurantDictionary[@"name"];
    self.myAtmosphereImageView.clipsToBounds = YES;
    
    //    // trying out gradients here
    //    CAGradientLayer *l = [CAGradientLayer layer];
    //    l.frame = self.myAtmosphereImageView.bounds;
    //    l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    //    l.startPoint = CGPointMake(1.0, 1.0f);
    //    l.endPoint = CGPointMake(0.0f, 0.0f);
    //    self.myAtmosphereImageView.layer.mask = l;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self loadFlickrImageForAtmosphere];
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
