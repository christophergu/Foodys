//
//  TestPartTwo.m
//  Foodys
//
//  Created by Matt Brax on 4/29/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "TestPartTwo.h"

@implementation TestPartTwo


#pragma mark - Common initializer
- (void)commonInit
{
    NSAssert(NO, @"Subclasses must override %@", NSStringFromSelector(_cmd));
}

#pragma mark - Other standard init methods

- (id)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

@end
