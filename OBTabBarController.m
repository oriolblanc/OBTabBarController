//
//  OBTabBarController.m
//  Fever
//
//  Created by Oriol Blanc on 11/22/11.
//  Copyright (c) 2011 Oriol Blanc. All rights reserved.
//

#import "OBTabBarController.h"

@implementation OBTabBarController

@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    if ((self = [super init]))
    {   
        _selectedIndex = 0;
        
        self.view.frame = CGRectMake(0, 20, 320, 460);
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

+ (CGFloat)tabBarHeight
{
    return 44.0f;
}

#pragma mark - Memory Management

- (void)dealloc
{
    [_viewControllers release];
    
    [super dealloc];
}

@end