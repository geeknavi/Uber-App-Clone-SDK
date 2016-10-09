//
//  SEBecomeADriver.m
//  Ride
//
//  Created by GeekNavi on 6/6/15.
//  Copyright (c) 2015 iHeart_Taxi. All rights reserved.
//

#import "SEBecomeADriver.h"
#import "SEApplicationPage.h"
#import "Constant.h"

@interface SEBecomeADriver (){
    NSArray *_pickerData;
    NSString *selectedCity;
    NSString *referralCode;
    
    __weak IBOutlet UIButton *applyBtn;
    __weak IBOutlet UIPickerView *cityPicker;
    __weak IBOutlet UITextField *selectcitytext;
    __weak IBOutlet UITextField *referralTextField;
}

@end

@implementation SEBecomeADriver

- (void)viewDidLoad {
    [super viewDidLoad];
    addLoading(@"");
    
    [applyBtn.titleLabel setTextColor:THEME_COLOR];
    
    _pickerData = @[@"Select your City", @"Demo City"];
    
    cityPicker.dataSource = self;
    cityPicker.delegate = self;
    
    selectedCity = @"Select your City";
    
    [referralTextField addTarget:self action:@selector(textFieldRefferalBegin) forControlEvents:UIControlEventEditingDidBegin];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignrefferalkeyboard)],
                           nil];
    [numberToolbar sizeToFit];
    referralTextField.inputAccessoryView = numberToolbar;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Drive";
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [GeekNavi getApplicationState:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            if (![JSON[@"data"] isKindOfClass:[NSNull class]]) {
                if ([JSON[@"data"]isEqualToString:@"insurance"] || [JSON[@"data"]isEqualToString:@"registration"] || [JSON[@"data"]isEqualToString:@"carpicture"] || [JSON[@"data"]isEqualToString:@"picture"] || [JSON[@"data"]isEqualToString:@"pending"] || [JSON[@"data"] isEqualToString:@"progress"] || [JSON[@"data"] isEqualToString:@"driver"]) {
                    [applyBtn setTitle:@"Applied!" forState:UIControlStateNormal];
                    [applyBtn setEnabled:NO];
                }else{
                    [applyBtn setEnabled:YES];
                }
            }
            removeLoading();
        }
    }];
}

-(void)textFieldRefferalBegin{
    cityPicker.hidden=YES;
}
-(void)resignrefferalkeyboard{
    [referralTextField resignFirstResponder];
}

#pragma mark - IBActions
- (IBAction)selectcitybtn:(id)sender {
    cityPicker.hidden=NO;
}
- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)continueapplication:(id)sender {
    if ([referralTextField.text isEqualToString:@""]) {
        referralCode = @"None";
    }else{
        referralCode = referralTextField.text;
    }
    
    if ([selectedCity isEqualToString:@"Select your City"]){
        showAlertViewWithMessage(NSLocalizedString(@"selected_city_blank", nil));
    }else{
        [self performSegueWithIdentifier:@"segueToAuth" sender:nil];
    }
}

#pragma mark - City Picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _pickerData[row];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component{
    selectedCity = _pickerData[row];
    selectcitytext.text = selectedCity;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 55)];
    label.backgroundColor = THEME_COLOR;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:23.0f];
    label.text = [NSString stringWithFormat:@" %@", _pickerData[row]];
    
    return label;
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"segueToAuth"]) {
        SEApplicationPage *vc = (SEApplicationPage *)[segue destinationViewController];
        vc.selectedCity = selectedCity;
        vc.referralCode = referralCode;
    }
}
-(IBAction)popToBecomeADriver:(UIStoryboardSegue *)segue{
    //
}


@end
