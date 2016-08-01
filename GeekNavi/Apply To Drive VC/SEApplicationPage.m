//
//  SEApplicationPage.m
//  GeekNavi
//
//  Created by GeekNavi on 6/6/15.
//  Copyright (c) 2015 GeekNavi. All rights reserved.
//

#import "SEApplicationPage.h"
#import "SESecondApplicationPage.h"

@interface SEApplicationPage (){
    __weak IBOutlet UIButton *nxtBtn;
    __weak IBOutlet UIButton *checkedBox;
    __weak IBOutlet UITextField *zipcodetext;
}
@end

@implementation SEApplicationPage
@synthesize selectedCity,referralCode;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *nonCheckedImage = [UIImage imageNamed:@"unchecked_box.png"];
    UIImage *checkedImage = [UIImage imageNamed:@"checked_box.png"];
    
    [checkedBox setImage:checkedImage forState:UIControlStateSelected];
    [checkedBox setImage:nonCheckedImage forState:UIControlStateNormal];
    
    [nxtBtn.titleLabel setTextColor:THEME_COLOR];
    
    [zipcodetext addTarget:self action:@selector(textchanged) forControlEvents:UIControlEventAllEditingEvents];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignzipcodetext)],
                           nil];
    [numberToolbar sizeToFit];
    zipcodetext.inputAccessoryView = numberToolbar;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
#pragma mark - Textfield Methods
-(void)textchanged{
    if (zipcodetext.text.length == 5) {
        [self resignzipcodetext];
    }
}
-(void)resignzipcodetext{
    [zipcodetext resignFirstResponder];
}

#pragma mark - IBActions
- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)myCheckboxToggle:(id)sender{
    checkedBox.selected = !checkedBox.selected;
}
- (IBAction)nextBtn:(id)sender {
    if ([zipcodetext.text isEqualToString:@""]) {
        showAlertViewWithMessage(NSLocalizedString(@"zip_code_blank", nil));
    }else{
    if (checkedBox.selected) {
        [self performSegueWithIdentifier:@"segueToPersonal" sender:nil];
    }else{
        showAlertViewWithMessage(NSLocalizedString(@"agree_terms_application_blank", nil));
        }
    }
}


#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"segueToPersonal"]) {
        SESecondApplicationPage *vc = (SESecondApplicationPage *)[segue destinationViewController];
        vc.selectedCity = selectedCity;
        vc.referralCode = referralCode;
        vc.zipCode = zipcodetext.text;
    }
}

@end
