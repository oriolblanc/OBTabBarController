//
//  OBTabBarController.m
//
//  Created by Oriol Blanc on 11/22/11.
//  Copyright (c) 2011 Oriol Blanc. All rights reserved.
//

#import "OBTabBarController.h"

#define kNoViewControllerSelected -1

@interface OBTabBarController ()

@property (nonatomic) NSUInteger selectedIndexInternal; // To store the previous selected index when the view is unloaded

@property (nonatomic, strong) UIView *tabBar;
@property (nonatomic, strong) UIView *viewForVisibleViewController;
@property (nonatomic) BOOL tabBarHidden;
@property (nonatomic) BOOL tabBarHiddenBeforePresentingModalViewController;

@property (nonatomic, strong) NSMutableArray *tabBarButtons;
@property (nonatomic, strong) NSMutableArray *tabBarLabels;
@property (nonatomic, copy) NSArray *tabBarImages;
@property (nonatomic, copy) NSArray *selectedTabBarImages;
@property (nonatomic, strong) UIImage *backgroundImage;

- (UIColor *)textColor;
- (UIColor *)textBackgroundColor;
- (UIColor *)textHighlightedColor;

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end

@implementation OBTabBarController

- (id)initWithViewControllers:(NSArray *)viewControllers delegate:(id <OBTabBarControllerDelegate>)delegate
{
    if ((self = [super init]))
    {
        if (delegate == nil)
            return self;
        
        self.delegate = delegate;
        self.viewControllers = viewControllers;
        self.tabBarButtons = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
        self.tabBarLabels = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
        
        _selectedIndex = kNoViewControllerSelected;
        _selectedIndexInternal = kNoViewControllerSelected;
        
        self.view.frame = CGRectMake(0, 20, 320, self.view.bounds.size.height - 20);
    }
    
    return self;
}

- (void)loadView
{
    if (self.delegate != nil && [self.delegate conformsToProtocol:@protocol(OBTabBarControllerDelegate)])
    {    
        if ([self.delegate respondsToSelector:@selector(tabBarBackground)])
        {
            self.backgroundImage = [self.delegate tabBarBackground];
        }
        
        NSMutableArray *images = [NSMutableArray array];
        NSMutableArray *highlighedImages = [NSMutableArray array];

        for (NSUInteger index = 0; index < self.viewControllers.count; index++) 
        {
            UIImage *tabBarIcon = [self.delegate imageTabAtIndex:index];
            if(tabBarIcon != nil)
            {
                [images addObject:tabBarIcon];
            }
            
            
            if ([self.delegate respondsToSelector:@selector(highlightedImageTabAtIndex:)])
            {
                UIImage *tabBarHighlightedIcon = [self.delegate highlightedImageTabAtIndex:index];
                if(tabBarHighlightedIcon != nil)
                {
                    [highlighedImages addObject:tabBarHighlightedIcon];
                }
            }
        }
        
        self.tabBarImages = images;
        self.selectedTabBarImages = highlighedImages;
    }

    CGRect tabBarControllerFrame = [self frameForTabBarControllerView];
    UIView *mainView = [[UIView alloc] initWithFrame:tabBarControllerFrame];
    
    mainView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mainView.backgroundColor = [UIColor clearColor];
    
    UIView *tabBarView = self.tabBar;
    
    [mainView addSubview:self.viewForVisibleViewController];    
    
    [mainView addSubview:tabBarView];
    
    self.view = mainView;
    
    if (_selectedIndexInternal != kNoViewControllerSelected)
    {
        [self setSelectedIndex:_selectedIndexInternal];
        _selectedIndexInternal = kNoViewControllerSelected;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (_selectedIndex == kNoViewControllerSelected)
    {
        self.selectedIndex = 0;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak typeof(self) blockSafeSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UINavigationControllerWillShowViewControllerNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary *transitionInfo = note.userInfo;
        
        UIViewController *willShowViewController = [transitionInfo valueForKey:@"UINavigationControllerNextVisibleViewController"];
        BOOL isTheFirstViewControllerInTheNavigationStack = willShowViewController == [willShowViewController.navigationController.viewControllers objectAtIndex:0];
        
        BOOL controllerIsBeingPresentedModally = NO;
        
        BOOL hide = (willShowViewController.hidesBottomBarWhenPushed && !isTheFirstViewControllerInTheNavigationStack) || controllerIsBeingPresentedModally;
        
        BOOL animated = [[transitionInfo valueForKey:@"UINavigationControllerTransitionIsAnimated"] boolValue];        
        
        [blockSafeSelf setTabBarHidden:hide animated:animated];
    }];
}

- (CGRect)frameForTabBarControllerView
{
    CGRect tabBarControllerFrame = [[UIScreen mainScreen] bounds];
    
    return tabBarControllerFrame;
}

- (UIView *)tabBar
{
    if (!_tabBar)
    {
        CGRect tabBarControllerFrame = [self frameForTabBarControllerView];
        _tabBar = [[UIView alloc] initWithFrame:CGRectMake(0, tabBarControllerFrame.size.height - [[self class] tabBarHeight], tabBarControllerFrame.size.width, [[self class] tabBarHeight])];
        _tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _tabBar.backgroundColor = [UIColor whiteColor];
        
        UIImageView *tabBarBackground = [[UIImageView alloc] initWithImage:self.backgroundImage];
        tabBarBackground.frame = _tabBar.bounds;
        [_tabBar addSubview:tabBarBackground];
        
        CGFloat buttonLeftMargin = 0;
        CGFloat buttonWidth = _tabBar.frame.size.width / (float)self.viewControllers.count;
        CGFloat buttonHeight = _tabBar.frame.size.height;
        
        [self.tabBarLabels removeAllObjects];
        [self.tabBarButtons removeAllObjects];
        
        for (int i = 0; i < self.viewControllers.count; i++)
        {
            UIImage *tabImage = nil;

            if(self.tabBarImages.count > i)
            {
                tabImage = [self.tabBarImages objectAtIndex:i];
            }
            
            CGRect buttonFrame = CGRectMake(buttonLeftMargin, 0, buttonWidth, buttonHeight);
            
            UIButton *tabBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
            tabBarButton.tag = i;
            [tabBarButton addTarget:self action:@selector(tabBarButtonPressed:) forControlEvents:UIControlEventTouchDown];
            
            tabBarButton.frame = buttonFrame;
            
            [tabBarButton setImage:tabImage forState:UIControlStateNormal];
            
            tabBarButton.adjustsImageWhenHighlighted = NO;
            [_tabBar addSubview:tabBarButton];
            [self.tabBarButtons addObject:tabBarButton];
            
            if ([self.delegate respondsToSelector:@selector(shouldShowLabelForIndex:)])
            {
                if ([self.delegate shouldShowLabelForIndex:i])
                {
                    CGFloat fontPointSize;
                    UILabel *titleLabel;
                    
                    static CGFloat padding = 2.0f;
                    fontPointSize = [self textFont].pointSize;
                    
                    titleLabel = [[UILabel alloc] initWithFrame:(CGRect){
                        .origin.x = buttonLeftMargin,
                        .origin.y = CGRectGetHeight(_tabBar.frame) - fontPointSize - padding,
                        .size.width = buttonWidth,
                        .size.height = fontPointSize
                    }];
                    
                    titleLabel.textColor = [self textColor];
                    titleLabel.highlightedTextColor = [self textHighlightedColor];
                    titleLabel.font = [self textFont];
                    titleLabel.text = ((UIViewController *)self.viewControllers[i]).title;
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    titleLabel.backgroundColor = [self textBackgroundColor];
                    
                    [_tabBar addSubview:titleLabel];
                    [self.tabBarLabels addObject:titleLabel];
                }
            }
            
            
            buttonLeftMargin += buttonWidth;
        }
    }
    
    return _tabBar;
}

- (void)tabBarButtonPressed:(UIButton *)button
{
    self.selectedIndex = button.tag;
}

- (UIView *)viewForVisibleViewController
{
    if (!_viewForVisibleViewController)
    {
        CGRect tabBarControllerFrame = [self frameForTabBarControllerView];
        
        _viewForVisibleViewController = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tabBarControllerFrame.size.width, tabBarControllerFrame.size.height - self.tabBar.frame.size.height)];
        _viewForVisibleViewController.backgroundColor = [UIColor clearColor];
        _viewForVisibleViewController.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _viewForVisibleViewController.clipsToBounds = YES;
    }
    
    return _viewForVisibleViewController;
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    CGFloat viewForVisibleViewControllerHeight = hidden ? self.view.frame.size.height : self.view.frame.size.height - self.tabBar.frame.size.height;
    _viewForVisibleViewController.frame = CGRectMake(0, 0, self.view.frame.size.width, viewForVisibleViewControllerHeight);
    
    static const CGFloat kPushAnimationDuration = 0.35;
    [UIView animateWithDuration:(animated ? kPushAnimationDuration : 0) delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.tabBar.alpha = hidden ? 0.0 : 1.0;

    } completion:^(BOOL finished) {
        if (finished)
        {
            self.tabBarHidden = hidden;
        }
    }];
}

- (UIColor *)textColor
{
    return [[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal][UITextAttributeTextColor] ? : [UIColor grayColor];
}

- (UIColor *)textBackgroundColor
{
    return [[UINavigationBar appearance] tintColor] ? : [UIColor clearColor];
}

- (UIColor *)textHighlightedColor
{
    return [[UITabBarItem appearance] titleTextAttributesForState:UIControlStateSelected][UITextAttributeTextColor] ? : [UIColor whiteColor];
}

- (UIFont *)textFont
{
    return [[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal][UITextAttributeFont] ? :
                                                                [UIFont boldSystemFontOfSize:10.0f];
}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    [super presentViewController:modalViewController animated:animated completion:^{
        
        self.tabBarHiddenBeforePresentingModalViewController = self.tabBarHidden;
    }];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
    [super dismissViewControllerAnimated:animated completion:^{

        [self setTabBarHidden:self.tabBarHiddenBeforePresentingModalViewController animated:NO];
    }];
}

#pragma mark - View Controllers Logic

- (void)setSelectedIndex:(NSInteger)index
{
    NSAssert(index >= 0 && index < self.viewControllers.count, @"Trying to select a view controller off bounds!");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shouldSelectTabAtIndex:)] && ![self.delegate shouldSelectTabAtIndex:index])
    {
        if ([self.delegate respondsToSelector:@selector(didSelectedTabAtIndex:)])
        {
            [self.delegate didSelectedTabAtIndex:index];
            return;
        }
    }
    
    [self.tabBarButtons setValue:[NSNumber numberWithBool:NO] forKey:@"enabled"]; // Disable all buttons to avoid quick switching between tabs
    [self.tabBarButtons setValue:[NSNumber numberWithBool:NO] forKey:@"selected"]; // Deselect all
    [[self.tabBarButtons objectAtIndex:index] setSelected:YES];
    
    [self.selectedTabBarImages enumerateObjectsUsingBlock:^(UIImage *selectedTabImage, NSUInteger idx, BOOL *stop) {
        UIButton *tabBarButton = self.tabBarButtons[idx];
        [tabBarButton setImage:idx != index ? self.tabBarImages[idx] : selectedTabImage
                      forState:UIControlStateNormal];
    }];
    
    [self.tabBarLabels enumerateObjectsUsingBlock:^(UILabel *titleLabel, NSUInteger idx, BOOL *stop) {
        titleLabel.highlighted = idx == index;
    }];
    
    if (index != _selectedIndex || _selectedIndexInternal != kNoViewControllerSelected)
    {        
        // Remove last view controller from screen:
        if (_selectedIndex != kNoViewControllerSelected)
        {            
            [_viewForVisibleViewController.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
                
        UIViewController *viewControllerToAppear = [self.viewControllers objectAtIndex:index];
        
        [_viewForVisibleViewController addSubview:viewControllerToAppear.view];
        viewControllerToAppear.view.frame = _viewForVisibleViewController.bounds;
        
        if ([viewControllerToAppear isKindOfClass:[UINavigationController class]])
        {
            // Adjust (fix) nav bar position:
            UINavigationBar *navBar = ((UINavigationController *)viewControllerToAppear).navigationBar;
            CGRect navBarFrame = navBar.frame;
            navBarFrame.origin.y = 0;
            navBar.frame = navBarFrame;
        }
        
        _selectedIndex = index;
    }
    else // Back to root view controller in navigation stack
    {
        UINavigationController *selectedViewController = [self.viewControllers objectAtIndex:_selectedIndex];

        if ([selectedViewController isKindOfClass:[UINavigationController class]])
        {
            [selectedViewController popToRootViewControllerAnimated:YES];
        }
    }
    
    [self.tabBarButtons setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

+ (CGFloat)tabBarHeight
{
    return 44;
}

#pragma mark - Memory Management

- (void)viewDidUnload
{
    self.tabBar = nil;
    self.viewForVisibleViewController = nil;
    self.backgroundImage = nil;
    
    _selectedIndexInternal = _selectedIndex;
    _selectedIndex = kNoViewControllerSelected;
    
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UINavigationControllerWillShowViewControllerNotification" object:nil];
}

@end

#pragma mark - UIActionSheet Category

@implementation UIActionSheet (OBTabBarActionSheetAdditions)

- (void)showFromTabBar:(OBTabBarController *)tabBarController
{
    [self showFromTabBar:((UITabBar *)tabBarController.tabBar)];
}

@end