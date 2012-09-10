//
//  OBTabBarController.m
//  Fever
//
//  Created by Oriol Blanc on 11/22/11.
//  Copyright (c) 2011 Oriol Blanc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBTabBarController : UIViewController

@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, assign) NSInteger selectedIndex;

- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

+ (CGFloat)tabBarHeight;

@end
