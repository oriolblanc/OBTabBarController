//
//  OBTabBarController.m
//
//  Created by Oriol Blanc on 11/22/11.
//  Copyright (c) 2011 Oriol Blanc. All rights reserved.
//

#import "OBTabBarController.h"
#import "UIButton+OBAdditions.h"

#define kNoViewControllerSelected -1

@interface OBTabBarController ()
{
    NSUInteger _selectedIndexInternal; // To store the previous selected index when the view is unloaded
}

@property (nonatomic, retain) UIView *tabBar;
@property (nonatomic, retain) UIView *viewForVisibleViewController;
@property (nonatomic, assign) BOOL tabBarHidden;
@property (nonatomic, assign) BOOL tabBarHiddenBeforePresentingModalViewController;

@property (nonatomic, retain) NSMutableArray *tabBarButtons;
@property (nonatomic, copy) NSArray *tabBarImages;
@property (nonatomic, copy) NSArray *selectedTabBarImages;
@property (nonatomic, retain) UIImage *backgroundImage;

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;
@end

@implementation OBTabBarController

@synthesize viewControllers = _viewControllers;
@synthesize delegate = _delegate;

@synthesize tabBar = _tabBar;
@synthesize viewForVisibleViewController = _viewForVisibleViewController;
@synthesize tabBarHidden = _tabBarHidden, tabBarHiddenBeforePresentingModalViewController = _tabBarHiddenBeforePresentingModalViewController;
@synthesize tabBarButtons = _tabBarButtons;
@synthesize tabBarImages = _tabBarImages, selectedTabBarImages = _selectedTabBarImages, backgroundImage = _backgroundImage;
@synthesize selectedIndex = _selectedIndex;

- (id)initWithViewControllers:(NSArray *)viewControllers delegate:(id <OBTabBarControllerDelegate>)delegate
{
    if ((self = [super init]))
    {
        if (delegate == nil)
            return self;
        
        self.delegate = delegate;
        self.viewControllers = viewControllers;
        self.tabBarButtons = [NSMutableArray arrayWithCapacity:self.viewControllers.count];
        
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
            [images addObject:[self.delegate imageTabAtIndex:index]];
            
            if ([self.delegate respondsToSelector:@selector(highlightedImageTabAtIndex:)])
            {
                [highlighedImages addObject:[self.delegate highlightedImageTabAtIndex:index]];
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
    [mainView release];
    
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
    
    __block typeof(self) blockSafeSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UINavigationControllerWillShowViewControllerNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary *transitionInfo = note.userInfo;
        
        UIViewController *willShowViewController = [transitionInfo valueForKey:@"UINavigationControllerNextVisibleViewController"];
        BOOL isTheFirstViewControllerInTheNavigationStack = willShowViewController == [willShowViewController.navigationController.viewControllers objectAtIndex:0];
        
        //        BOOL controllerIsBeingPresentedModally = (![blockSafeSelf.viewControllers containsObject:willShowViewController.parentViewController]);
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
        _tabBar = [[UIView alloc] initWithFrame:CGRectMake(0, tabBarControllerFrame.size.height - [OBTabBarController tabBarHeight], tabBarControllerFrame.size.width, [OBTabBarController tabBarHeight])];
        _tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        UIImageView *tabBarBackground = [[UIImageView alloc] initWithImage:self.backgroundImage];
        tabBarBackground.frame = _tabBar.bounds;
        [_tabBar addSubview:tabBarBackground];
        [tabBarBackground release];
        
        CGFloat buttonLeftMargin = 0;
        CGFloat buttonWidth = _tabBar.frame.size.width / (float)self.viewControllers.count;
        CGFloat buttonHeight = _tabBar.frame.size.height;
        
        [self.tabBarButtons removeAllObjects];
        
        __block typeof(self) blockSafeSelf = self;
        
        for (int i = 0; i < self.viewControllers.count; i++)
        {
            CGFloat defaultHeight = 44;
            CGFloat defaultWidth = buttonWidth;
            UIImage *tabImage = [self.tabBarImages objectAtIndex:i];
            CGRect buttonFrame = CGRectMake(buttonLeftMargin - (tabImage.size.width - defaultWidth), defaultHeight - tabImage.size.height, buttonWidth + (tabImage.size.width - defaultWidth), buttonHeight + (tabImage.size.height - defaultHeight));

#warning guarrada de código
            UIButton *tabBarButton = [UIButton buttonWithType:UIButtonTypeCustom forControlEvents:(i != 2) ? UIControlEventTouchDown : UIControlEventTouchUpInside tapCallback:^(UIButton *button) {
                blockSafeSelf.selectedIndex = i;                
            }];
            
            tabBarButton.frame = buttonFrame;
            
            [tabBarButton setImage:tabImage forState:UIControlStateNormal];
            [tabBarButton setImage:[self.selectedTabBarImages objectAtIndex:i] forState:UIControlStateHighlighted];
            [tabBarButton setImage:[self.selectedTabBarImages objectAtIndex:i] forState:UIControlStateSelected];
            tabBarButton.adjustsImageWhenHighlighted = NO;
            [_tabBar addSubview:tabBarButton];
            [self.tabBarButtons addObject:tabBarButton];
            buttonLeftMargin += buttonWidth;
        }
    }
    
    return _tabBar;
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

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    [super presentModalViewController:modalViewController animated:animated];
    self.tabBarHiddenBeforePresentingModalViewController = self.tabBarHidden;
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
    [super dismissModalViewControllerAnimated:animated];
    [self setTabBarHidden:self.tabBarHiddenBeforePresentingModalViewController animated:NO];
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
    
    for (int i = 0; i < self.selectedTabBarImages.count; i++)
    {
        UIButton *tabBarButton = [self.tabBarButtons objectAtIndex:i];
        
        if (i != index)
        {
            [tabBarButton setImage:[self.tabBarImages objectAtIndex:i] forState:UIControlStateNormal];
            [tabBarButton setImage:[self.selectedTabBarImages objectAtIndex:i] forState:UIControlStateHighlighted];
            [tabBarButton setImage:[self.selectedTabBarImages objectAtIndex:i] forState:UIControlStateSelected];   
        }
        else
        {
            [tabBarButton setImage:[self.selectedTabBarImages objectAtIndex:i] forState:UIControlStateNormal];        
            [tabBarButton setImage:[self.selectedTabBarImages objectAtIndex:i] forState:UIControlStateHighlighted];        
            [tabBarButton setImage:[self.selectedTabBarImages objectAtIndex:i] forState:UIControlStateSelected];        
        }
    }
    
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
    return 44.0f;
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

- (void)dealloc
{
    [_viewControllers release];

    [_tabBar release];
    [_viewForVisibleViewController release];

    [_tabBarButtons release];
    [_tabBarImages release];
    [_selectedTabBarImages release];
    [_backgroundImage release];
    
    
    [super dealloc];
}

@end

#pragma mark - UIActionSheet Category

@implementation UIActionSheet (OBTabBarActionSheetAdditions)

- (void)showFromTabBar:(OBTabBarController *)tabBarController
{
    [self showFromTabBar:((UITabBar *)tabBarController.tabBar)];
}

@end