//
//  GeekGuillotineMenu.m
//  GeekNavi
//
//  Created by GeekNavi on 09/06/14.
//  Copyright (c) 2016 GeekNavi. All rights reserved.
//

#import <GeekNavi/GeekNavi.h>
#import <GeekNavi/GeekDrawMenuButton.h>
#import "GeekGuillotineMenu.h"

static float delayNumber = 0.0f;

@interface GeekGuillotineMenu (){
    float screenW;
    float screenH;
    
    float navBarH;
    
    UIButton    *menuButton;
    UITableView *menuTableView;
    UICollectionView *menuCollectionView;
    
    BOOL isOpen;
    BOOL supportBoundaryAdded;
    
    UIPushBehavior *pushInit;
    UIPushBehavior *pushOpen;
    UIAttachmentBehavior *attachmentBehavior;
    
    // - Dynamics
    UIDynamicAnimator   *dynamicAnimator;
    UICollisionBehavior *collision;
    UIGravityBehavior   *gravity;
    
    CGPoint puntoAncoraggio;
}
@property (nonatomic, retain) UIView * menuView;
    // - Menu Button Rotation
@property (nonatomic, assign) float oldAngle;
@property (nonatomic, assign) float currentAngle;

@property (nonatomic, assign) BOOL isPresentedFirst;
@end

@interface CustomCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation CustomCollectionViewCell

@end

@implementation GeekGuillotineMenu

@synthesize menuButton, menuColor, menuTitles, images, viewControllers,menuDelegate;

- (id)initWithViewControllers:(NSArray *)vCs MenuTitles:(NSArray *)titles andImages:(NSArray *)imgs{
    
    self = [super init];
    
    if (self) {
        
        self.isPresentedFirst = NO;
        
        self.viewControllers    = [vCs copy];
        self.menuTitles         = [titles copy];
        self.images       = [imgs copy];
        
        screenW = [[UIScreen mainScreen] bounds].size.width;
        screenH = [[UIScreen mainScreen] bounds].size.height;
        
        isOpen = YES;
        supportBoundaryAdded = NO;
        
        self.oldAngle        = 0.0;
        self.currentAngle    = 0.0;
    }
    
    return  self;
}

- (id)initWithViewControllers:(NSArray *)vCs MenuTitles:(NSArray *)titles andImages:(NSArray *)imgs andStyle:(GeekGuillotineMenuStyle)style{
	
    self = [self initWithViewControllers:vCs MenuTitles:titles andImages:imgs];
	
	self.menuStyle = style;
	
	return self;
}

- (void)viewDidLoad {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setTranslucent:NO];
    [navBar setBarTintColor:MAIN_THEME_COLOR];
    [navBar setShadowImage:[UIImage new]];
    [navBar setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    
    // - Setup Menu
    [self setupMenu];
    
    // - Setup UiKit Dynamics
    [self initAnimation];
    
    [self presentController:[self.viewControllers objectAtIndex:0]];
}

- (void)setupMenu {
    
    if (!self.separatorColor || [self.separatorColor isKindOfClass:[NSNull class]]) {
        self.separatorColor = [UIColor darkGrayColor];
    }
    
    navBarH = 0;
    
    puntoAncoraggio = CGPointMake((navBarH/2.0),(navBarH/2.0));
    
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, screenW, screenH)];
    self.menuView.backgroundColor = menuColor;
    self.menuView.alpha = 0.0;
    [self.view addSubview:self.menuView];
    
    
    // - Menu Button
    float buttonMenuH = self.navigationController.navigationBar.frame.size.height - 20;
    float buttonMenuW = buttonMenuH;
    
    self.menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonMenuW, buttonMenuH)];
    if(!self.menuButtonImageTitle) {
        [self.menuButton setImage:[GeekDrawMenuButton imageOfMenuCanvas:self.separatorColor] forState:UIControlStateNormal];
    } else {
        [self.menuButton setImage:[UIImage imageNamed:self.menuButtonImageTitle] forState:UIControlStateNormal];
    }
    [self.menuButton addTarget:self action:@selector(switchMenuState) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
    
    float tableViewMarginTop = 50.0;
    float tableViewW = 200.0;
	
	if (self.menuStyle == GeekGuillotineMenuStyleCollection) {
		 UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
		menuCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(40, 80, screenW - 80, screenH - 164) collectionViewLayout:layout];
		menuCollectionView.center = self.view.center;
		menuCollectionView.backgroundColor = [UIColor clearColor];
		menuCollectionView.delegate = self;
		menuCollectionView.dataSource = self;
		menuCollectionView.alpha = 0.0;
		[menuCollectionView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
		[self.menuView addSubview:menuCollectionView];
	}
	else {
		menuTableView = [[UITableView alloc] initWithFrame:CGRectMake((screenW - tableViewW)/2, tableViewMarginTop + navBarH, tableViewW, screenH - 200.0 - tableViewMarginTop)];
		menuTableView.center = self.view.center;
		menuTableView.backgroundColor = [UIColor clearColor];
		menuTableView.delegate = self;
		menuTableView.dataSource = self;
		[menuTableView setSeparatorColor:[UIColor clearColor]];
		menuTableView.alpha = 0.0;
        menuTableView.scrollEnabled = NO;
		[self.menuView addSubview:menuTableView];
	}
	
}

- (void)initAnimation {
    
    // - Dynamic Animator
    dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    dynamicAnimator.delegate = self;
    
    
    // - Gravity Behavior
    gravity = [[UIGravityBehavior alloc] initWithItems:@[self.menuView]];
    
    
    // - Item Behavior
    UIDynamicItemBehavior* itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.menuView]];
    itemBehaviour.elasticity = 0.53;
    itemBehaviour.resistance = 1.2;
    itemBehaviour.allowsRotation = YES;
    [dynamicAnimator addBehavior:itemBehaviour];
    
    
    // - Collision Behavior
    collision = [[UICollisionBehavior alloc] initWithItems:@[self.menuView]];
    collision.collisionDelegate = self;
    [collision addBoundaryWithIdentifier:@"Collide End" fromPoint:CGPointMake(-2, screenH/2.0) toPoint:CGPointMake(-2, screenH)];
    [collision addBoundaryWithIdentifier:@"Collide Start" fromPoint:CGPointMake(screenH/2,-screenW + navBarH) toPoint:CGPointMake(screenH, -screenW + navBarH)];
    [dynamicAnimator addBehavior:collision];
    
    
    // - Attachment Behavior
    UIOffset offset = UIOffsetMake(-self.view.bounds.size.width/2 + puntoAncoraggio.x , -self.view.bounds.size.height/2 + puntoAncoraggio.y);
    attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.menuView offsetFromCenter:offset attachedToAnchor:puntoAncoraggio];
    [dynamicAnimator addBehavior:attachmentBehavior];
    
    
    // - Push Init
    pushInit = [[UIPushBehavior alloc] initWithItems:@[self.menuView] mode:UIPushBehaviorModeContinuous];
    CGVector vector = CGVectorMake(1000, 0);
    pushInit.pushDirection = vector;
    UIOffset offsetPush = UIOffsetMake(0, screenH/2);
    [pushInit setTargetOffsetFromCenter:offsetPush forItem:self.menuView];
    [dynamicAnimator addBehavior:pushInit];
    
    __weak typeof(self) weakSelf = self;
    // -
    collision.action =  ^{
        __strong typeof(self) strongSelf = weakSelf;
        CGFloat radians = atan2( strongSelf.menuView.transform.b, strongSelf.menuView.transform.a);
        
        strongSelf.currentAngle = radians;
        
        if(!strongSelf.isPresentedFirst){
            strongSelf.currentAngle = -M_PI_2;
            CABasicAnimation *rota = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            rota.duration = 0.001;
            rota.autoreverses = NO;
            rota.removedOnCompletion = NO;
            rota.fillMode = kCAFillModeForwards;
            rota.fromValue = [NSNumber numberWithFloat: strongSelf.oldAngle];
            rota.toValue = [NSNumber numberWithFloat: strongSelf.currentAngle ];
            [strongSelf.menuButton.layer addAnimation: rota forKey: @"rotation"];
            strongSelf.oldAngle = strongSelf.currentAngle;
        }
		else if(strongSelf.currentAngle != strongSelf.oldAngle){
            CABasicAnimation *rota = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            rota.duration = 0.01;
            rota.autoreverses = NO;
            rota.removedOnCompletion = NO;
            rota.fillMode = kCAFillModeForwards;
            rota.fromValue = [NSNumber numberWithFloat: strongSelf.oldAngle];
            rota.toValue = [NSNumber numberWithFloat: strongSelf.currentAngle ];
            [strongSelf.menuButton.layer addAnimation: rota forKey: @"rotation"];
            strongSelf.oldAngle = strongSelf.currentAngle;
        }
    };
    
    
}

- (BOOL)isOpen{
    return isOpen;
}


- (void)switchMenuState{
    if (delayNumber == 0) {
        return;
    }
    
    if (isOpen) {
        [self dismissMenu];
    }else{
        [self openMenu];
    }
}

- (void)openMenu{
    // - Menu Table
    [UIView animateWithDuration:0.15 animations:^{
		if (self.menuStyle == GeekGuillotineMenuStyleCollection)
			menuCollectionView.alpha = 1.0;
		else
			menuTableView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    
    [collision removeBoundaryWithIdentifier:@"Collide Right"];
    supportBoundaryAdded = NO;
    [dynamicAnimator addBehavior:gravity];
    
    
    // - Push Open
    pushOpen = [[UIPushBehavior alloc] initWithItems:@[self.menuView] mode:UIPushBehaviorModeContinuous];
    CGVector vectorOpen = CGVectorMake(0, self.view.frame.size.height * (M_PI + M_2_PI));
    
    //M_2_PI
    pushOpen.pushDirection = vectorOpen;
    [dynamicAnimator addBehavior:pushOpen];
    
    isOpen = YES;
}

- (void)dismissMenu{
    [dynamicAnimator removeBehavior:pushOpen];
    
    // - Push Init
    pushInit = [[UIPushBehavior alloc] initWithItems:@[self.menuView] mode:UIPushBehaviorModeInstantaneous];
    CGVector vector = CGVectorMake(self.view.frame.size.height * M_PI_2, 100);

    pushInit.pushDirection = vector;
    UIOffset offsetPush = UIOffsetMake(0, screenH/2);
    [pushInit setTargetOffsetFromCenter:offsetPush forItem:self.menuView];
    [dynamicAnimator addBehavior:pushInit];
    
    isOpen = NO;
}


- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item
   withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
    
    
    NSString *identifierString = [NSString stringWithFormat:@"%@", identifier];
    
    if([identifierString isEqualToString:@"Collide Start"]){
        
        if(!supportBoundaryAdded){
            
            float offsetBounce = 0.0;
            [collision addBoundaryWithIdentifier:@"Collide Right" fromPoint:CGPointMake(screenH/2, navBarH + offsetBounce) toPoint:CGPointMake(screenH, navBarH + offsetBounce)];
            supportBoundaryAdded = YES;
        }
        
        [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.menuView.alpha = 1.0;
        } completion:nil];
        
        
        [dynamicAnimator removeBehavior:pushInit];
        isOpen = NO;
        
        if(!self.isPresentedFirst){
            
            self.isPresentedFirst = YES;
        }
        
        
        // - Menu Table
        [UIView animateWithDuration:0.1 animations:^{
			if (self.menuStyle == GeekGuillotineMenuStyleCollection)
				menuCollectionView.alpha = 0.0;
			else
				menuTableView.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
        
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuTitles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"menuCell"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.textColor = SUB_THEME_COLOR;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = [UIFont fontWithName:@"Futura-Medium" size:19.f];
    cell.textLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
    
    cell.imageView.image = [self.images objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!isOpen)
        return;
    
    [self dismissMenu];
    [menuTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row != 0) {
        [self.rightBarButton setHidden:YES];
    }else{
        [self.rightBarButton setHidden:NO];
    }
    
    if ([[self.viewControllers objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        if ([[self.viewControllers objectAtIndex:indexPath.row] isEqualToString:LOGOUTBTN]) {
            if ([self.menuDelegate respondsToSelector:@selector(didTapLogoutButton)]) {
                __strong id<GeekGuillotineMenuDelegate> strongDelegate = menuDelegate;
                [strongDelegate didTapLogoutButton];
            }
        }
    }else{
        [self performSelector:@selector(presentController:) withObject:[self.viewControllers objectAtIndex:indexPath.row] afterDelay:delayNumber/8];
    }
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.menuTitles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
	
	if (cell == nil){
		cell = (CustomCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
	}
	
	cell.backgroundColor = [UIColor clearColor];

	CGFloat width = cell.bounds.size.width;
	CGFloat height = cell.bounds.size.height;
	
	if (!cell.imageView) {
		cell.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 2*height/3)];
		[cell.imageView setContentMode:UIViewContentModeBottom];
		[cell.imageView setClipsToBounds:YES];
		[cell.contentView addSubview:cell.imageView];
	}
	
	if (!cell.textLabel) {
		cell.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2*height/3, width, height/3)];
		cell.textLabel.textColor = SUB_THEME_COLOR;
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.font = [UIFont fontWithName:@"Futura-Medium" size:17.f];
		[cell.contentView addSubview:cell.textLabel];
	}
	
	cell.imageView.image = [self.images objectAtIndex:indexPath.row];
	cell.textLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
	
	return cell;
}

#pragma mark - Collection view delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
	if(!isOpen)
		return;
	
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
    if (indexPath.row != 0) {
        [self.rightBarButton setHidden:YES];
    }else{
        [self.rightBarButton setHidden:NO];
    }
    
    if ([[self.viewControllers objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        if ([[self.viewControllers objectAtIndex:indexPath.row] isEqualToString:LOGOUTBTN]) {
            if ([self.menuDelegate respondsToSelector:@selector(didTapLogoutButton)]) {
                __strong id<GeekGuillotineMenuDelegate> strongDelegate = menuDelegate;
                [strongDelegate didTapLogoutButton];
            }
        }
    }else{
        [self performSelector:@selector(presentController:) withObject:[self.viewControllers objectAtIndex:indexPath.row] afterDelay:delayNumber/8];
    }
    
	[self dismissMenu];
	
}

#pragma mark - Collection view delegate flow layout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat size = (screenW - 80 - 24)/2;
	return CGSizeMake(size, size);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	return 24.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	return 24.f;
}

#pragma mark - Presentation Logic

- (void)presentController:(UIViewController*)controller{
    if(self.currentViewController){
        [self removeCurrentViewController];
        self.currentViewController = nil;
    }
    
    [self addChildViewController:controller];
    [controller.view setFrame:self.view.frame];
    
    [self.view insertSubview:controller.view belowSubview:self.menuView];

    self.currentViewController = controller;
    
    //4. Complete the add flow calling the function didMoveToParentViewController
    [controller didMoveToParentViewController:self];
}

-(void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator{
    if (delayNumber == 0) {
        delayNumber = animator.elapsedTime;
    }
}


- (void)removeCurrentViewController{
    
    [self.currentViewController willMoveToParentViewController:nil];
    
    [self.currentViewController.view removeFromSuperview];
    
    [self.currentViewController removeFromParentViewController];
}

@end
