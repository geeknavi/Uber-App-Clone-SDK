//
//  SETermsLoginScreenViewController.m
//  Ride
//
//  Created by GeekNavi on 2/18/15.
//  Copyright (c) 2015 iHeart_Taxi. All rights reserved.
//

#import "SETermsLoginScreenViewController.h"

@interface SETermsLoginScreenViewController (){
    
    __weak IBOutlet UIView *topnavi;
}

@end

@implementation SETermsLoginScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [topnavi setBackgroundColor:THEME_COLOR];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
