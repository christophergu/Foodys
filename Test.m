//
//  Test.m
//  Foodys
//
//  Created by Matt Brax on 4/29/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "Test.h"

@implementation Test

UIFont *newFont = [UIFont fontWithName:@"NonoSans-BodItalic" size:14];
[[UILabel appearance] setFont:newFont];

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
