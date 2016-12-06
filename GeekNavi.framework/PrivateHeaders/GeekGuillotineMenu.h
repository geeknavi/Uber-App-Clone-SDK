#import <UIKit/UIKit.h>
#define LOGOUTBTN @"LGBTN"
#undef weak_delegate
#if __has_feature(objc_arc_weak)
#define weak_delegate weak
#else
#define weak_delegate unsafe_unretained
#endif

typedef NS_ENUM(NSUInteger, GeekGuillotineMenuStyle) {
	GeekGuillotineMenuStyleTable,
	GeekGuillotineMenuStyleCollection,
};


@protocol GeekGuillotineMenuDelegate <NSObject>

@optional
-(void)didTapLogoutButton;
@end

@interface GeekGuillotineMenu : UIViewController <UITableViewDataSource, UITableViewDelegate, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIViewController  *currentViewController;

@property (nonatomic, strong) UIButton  *menuButton;
@property (nonatomic, strong) UIButton  *rightBarButton;
@property (nonatomic, strong) NSString  *menuButtonImageTitle;
@property (nonatomic, strong) NSArray   *viewControllers;
@property (nonatomic, strong) NSArray   *menuTitles;
@property (nonatomic, strong) NSArray   *images;
@property (nonatomic, strong) UIColor   *menuColor;
@property (nonatomic, strong) UIColor   *separatorColor;
@property (nonatomic) GeekGuillotineMenuStyle menuStyle;
@property (nonatomic, weak_delegate) id<GeekGuillotineMenuDelegate> menuDelegate;

// -Init method
- (id)initWithViewControllers:(NSArray *)vCs MenuTitles:(NSArray *)titles andImages:(NSArray *)imgs;
- (id)initWithViewControllers:(NSArray *)vCs MenuTitles:(NSArray *)titles andImages:(NSArray *)imgs andStyle:(GeekGuillotineMenuStyle)style;

// -
- (BOOL)isOpen;

// -
- (void)switchMenuState;
- (void)openMenu;
- (void)dismissMenu;

@end
