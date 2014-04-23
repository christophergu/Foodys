//
//  AddFriendsViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/23/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "AddFriendsViewController.h"
#import <Parse/Parse.h>

@interface AddFriendsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation AddFriendsViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.requestorsToAddArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendRequestCellReuseID"];
    
    PFUser *potentialFriend = self.requestorsToAddArray[indexPath.row][@"requestor"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", potentialFriend];
    
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"aaaa %@",self.requestorsToAddArray);
}

@end
