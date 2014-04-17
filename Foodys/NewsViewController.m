//
//  NewsViewController.m
//  Foodys
//
//  Created by Matt Brax on 4/16/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "NewsViewController.h"
#import <Parse/Parse.h>

@interface NewsViewController () <UITableViewDataSource, UITabBarDelegate>
@property (strong,nonatomic) PFObject* currentPost;
@property (strong,nonatomic) PFUser* currentUser;
@property (strong,nonatomic) NSArray* currentUserPostsArray;

@end

@implementation NewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.currentUser = [PFUser currentUser];
    PFQuery* query = [PFQuery queryWithClassName:@"PublicPost"];
    [query whereKey:@"author" equalTo:self.currentUser[@"username"]];
    self.currentUserPostsArray = [query findObjects];
    NSLog(@"%@", self.currentUserPostsArray );

}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.currentUserPostsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellReuseID"];
    
    self.currentPost = self.currentUserPostsArray[indexPath.row];
    
    
    cell.textLabel.text = self.currentPost[@"title"];
    
    
    return cell;
}








/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
