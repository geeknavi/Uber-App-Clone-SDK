#import "SEPaymentViewController.h"
#import "MBProgressHUD.h"
#import "PTKView.h"
#import "PaymentViewController.h"
#import "STPCard.h"
#import "STPAPIClient.h"
#import "StripeError.h"


@interface PaymentViewController () <PTKViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topnavi;
@property (weak, nonatomic) PTKView *paymentView;
@end

@implementation PaymentViewController
@synthesize typeStr;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Checkout";
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Setup save button
    NSString *title;
    if([typeStr isEqualToString:@"updateToken"]){
            title = [NSString stringWithFormat:@"Save card"];
            label.text = @"Card Register";
    }else{
        title = [NSString stringWithFormat:@"Pay %@ %@", self.amount,currency];
    }
    
    saveButton.enabled = NO;
    saveButton.alpha= 0.5;
    [self.navigationController.navigationBar setHidden:YES];
    
    [saveButton setTitle:title forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    // Setup checkout
    PTKView *paymentView = [[PTKView alloc] init];
    paymentView.frame=CGRectMake(15, 75, 290, 55);
    
    paymentView.delegate = self;
    self.paymentView = paymentView;
    
    [self.paymentView.cardZipField addTarget:self action:@selector(checkingvalidofzip) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:paymentView];
    
    [self.topnavi setBackgroundColor:MAIN_THEME_COLOR];
    [saveButton setTitleColor:SUB_THEME_COLOR forState:UIControlStateNormal];
    [cancelButton setTitleColor:SUB_THEME_COLOR forState:UIControlStateNormal];
}

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
}
-(void)checkingvalidofzip{
    NSString *converting = [NSString stringWithFormat:@"%@", self.paymentView.cardZipField.text];
    
    NSUInteger length = [converting length];
    
    if(length >= 5){
        saveButton.enabled = YES;
        saveButton.alpha= 1.0;
    }
    if (length >= 7){
        saveButton.enabled = NO;
        saveButton.alpha=0.5;
    }
    if (length <= 4){
        saveButton.enabled=NO;
        saveButton.alpha=0.5;
    }
}

- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)save:(id)sender {
    
    if (![self.paymentView isValid]) {
        return;
    }
    if (![Stripe defaultPublishableKey]) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Please specify a Stripe Publishable Key in Constant.m"
                                                    }];
        @throw error;
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *fullnameowner = [NSString stringWithFormat:@"%@ %@", userInformation[@"vFirst"], userInformation[@"vLast"]];
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    NSString *cardnumber = [NSString stringWithFormat:@"%@",card.number];
    NSString *typeofcard;
    NSString *firstDigit = [cardnumber substringToIndex:1];
    if ([firstDigit isEqualToString:@"5"]) {
        typeofcard = @"Mastercard";
    }else if([firstDigit isEqualToString:@"4"]){
        typeofcard = @"Visa";
    }else if([firstDigit isEqualToString:@"6"]){
        typeofcard = @"Discover";
    }else if([firstDigit isEqualToString:@"3"]){
        typeofcard = @"American";
    }else{
        typeofcard=@"";
    }
    
    [GeekNavi updateLastFourDigits:card.last4 typeOfCard:typeofcard];
    
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    card.addressZip = self.paymentView.card.addressZip;
    card.name = fullnameowner;
    
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                                                  [self.backendCharger createBackendChargeWithToken:token error:error];
                                              }];
                                          }];
}

@end
