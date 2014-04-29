//
//  TestFont.m
//  Foodys
//
//  Created by Matt Brax on 4/29/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "TestFont.h"
#import "TestPartTwo.h"


@implementation TestFont

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
//    for (id obj in UIFont.familyNames)
//        NSLog(@"%@: %@", obj, [UIFont fontNamesForFamilyName:obj]);

    self.font = [UIFont fontWithName:@"NotoSans-Bold" size:self.font.pointSize];
    
    return self;
}

@end




