//
//  SEBecomeADriver.m
//  GeekNavi
//
//  Created by GeekNavi on 6/6/15.
//  Copyright (c) 2015 GeekNavi. All rights reserved.
//

#import "SEBecomeADriver.h"
#import "Constant.h"
#import "ApplyToDriveViewController.h"

@interface SEBecomeADriver (){
    // UITextFields
    __weak IBOutlet UITextField *selectCityTextField;
    __weak IBOutlet UITextField *referralTextField;
    
    // UIButtons
    __weak IBOutlet UIButton *applyButton;
    
    // UIPickerView
    __weak IBOutlet UIPickerView *cityPicker;
    
    // Instance Variables
    NSArray *_pickerData;
    NSString *selectedCity;
    NSString *referralCode;
}

@end

@implementation SEBecomeADriver

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // As always, start with customizing the screen (MAIN/SUB Colors)
    [self customizeScreen];
    [self initializePicker];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Drive";
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self getApplicationState];
}

#pragma mark - Get Application State
-(void)getApplicationState{
    addLoading(@"");
    [GeekNavi getApplicationState:^(id JSON, WebServiceResult geekResult) {
        if (geekResult==WebServiceResultSuccess) {
            if (![JSON[@"data"] isKindOfClass:[NSNull class]]) {
                if ([JSON[@"data"]isEqualToString:@"insurance"] || [JSON[@"data"]isEqualToString:@"registration"] || [JSON[@"data"]isEqualToString:@"carpicture"] || [JSON[@"data"]isEqualToString:@"picture"] || [JSON[@"data"]isEqualToString:@"pending"] || [JSON[@"data"] isEqualToString:@"progress"] || [JSON[@"data"] isEqualToString:@"driver"]) {
                    [applyButton setTitle:@"Applied!" forState:UIControlStateNormal];
                    [applyButton setEnabled:NO];
                    [applyButton setBackgroundColor:[UIColor lightGrayColor]];
                }else{
                    [applyButton setEnabled:YES];
                }
            }
            removeLoading();
        }
    }];
}

#pragma mark - Select City Action
- (IBAction)selectCityAction:(id)sender {
    cityPicker.hidden=NO;
}

#pragma mark - Continue with Application Action
- (IBAction)continueApplication:(id)sender {
    if (referralTextField.text.length == 0){
        referralCode = @"None";
    }else{
        referralCode = referralTextField.text;
    }
    
    if ([selectedCity isEqualToString:@"Select your City"]){
        showAlertViewWithTitleAndMessage(nil,NSLocalizedString(@"selected_city_blank", nil));
    }else{
        [self performSegueWithIdentifier:@"applyToDriveSegue" sender:nil];
    }
}

#pragma mark - City Picker Delegates
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
    selectCityTextField.text = selectedCity;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 55)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = SUB_THEME_COLOR;
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:23.0f];
    label.text = [NSString stringWithFormat:@" %@", _pickerData[row]];
    
    return label;
}

#pragma mark - Initialize Picker
-(void)initializePicker{
    _pickerData = @[@"Select your City", @"Demo City"];
    
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

#pragma mark - TextField Did Begin Editing
-(void)textFieldRefferalBegin{
    cityPicker.hidden=YES;
}

#pragma mark - TextField Done Editing
-(void)resignrefferalkeyboard{
    [referralTextField resignFirstResponder];
}

#pragma mark - Customize Screen
-(void)customizeScreen{
    self.view.backgroundColor = MAIN_THEME_COLOR;
    
    [applyButton.titleLabel setTextColor:MAIN_THEME_COLOR];
    [applyButton setBackgroundColor:SUB_THEME_COLOR];
    applyButton.layer.cornerRadius = 10.0f;
    applyButton.layer.masksToBounds = YES;
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"applyToDriveSegue"]) {
        ApplyToDriveViewController *vc = (ApplyToDriveViewController *)[segue destinationViewController];
        vc.selectedCity = selectedCity;
        vc.referralCode = referralCode;
    }
}

@end
