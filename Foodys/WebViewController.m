//
//  WebViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/20/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()<UIWebViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *myWebView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *forwardButton;
@property (strong, nonatomic) IBOutlet UINavigationItem *navTitle;

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myWebView.scrollView.delegate = self;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.websiteUrl]];
    [self.myWebView loadRequest:request];
}

- (void) webViewDidFinishLoad: (UIWebView *)myWebView
{
    [self.backButton setEnabled: [myWebView canGoBack]];
    [self.forwardButton setEnabled: [myWebView canGoForward]];
}

- (IBAction)onBackButtonPressed:(id)sender {
    [self.myWebView goBack];
}

- (IBAction)onForwardButtonPressed:(id)sender {
    [self.myWebView goForward];
}

- (IBAction)onStopLoadingButtonPressed:(id)sender {
    [self.myWebView stopLoading];
}

- (IBAction)onReloadButtonPressed:(id)sender {
    [self.myWebView reload];
}

@end
