//
//  OBTabBarController.m
//
//  Created by Oriol Blanc on 11/22/11.
//  Copyright (c) 2011 Oriol Blanc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBTabBarController;

@protocol OBTabBarControllerDelegate <NSObject>
    - (UIImage *)imageTabAtIndex:(NSUInteger)index;
    
    @optional
    - (UIImage *)tabBarBackground;
    - (UIImage *)highlightedImageTabAtIndex:(NSUInteger)index;
    - (BOOL)shouldSelectTabAtIndex:(NSUInteger)index;
    - (void)didSelectedTabAtIndex:(NSUInteger)index;
    - (BOOL)shouldShowLabelForIndex:(NSUInteger)index;
@end

@interface OBTabBarController : UIViewController

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, weak) id <OBTabBarControllerDelegate> delegate;
@property (nonatomic) NSInteger selectedIndex;

- (id)initWithViewControllers:(NSArray *)viewControllers delegate:(id <OBTabBarControllerDelegate>)delegate;

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
- (void)dismissModalViewControllerAnimated:(BOOL)animated;
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

+ (CGFloat)tabBarHeight;

@end

@interface UIActionSheet(OBTabBarActionSheetAdditions)
- (void)showFromTabBar:(OBTabBarController *)tabBarController;
@end