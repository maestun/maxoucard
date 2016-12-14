//
//  RootVC.m
//  maxoucard_app
//
//  Created by Olivier on 08/12/2016.
//  Copyright © 2016 CDV. All rights reserved.
//

#import "RootVC.h"
#import "SettingsVC.h"
#import "ClientVC.h"
#import "MenuVC.h"

@implementation RootVC

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    //    self.contentViewShadowColor = COLOR_SHADOW;
    self.contentViewShadowOffset = CGSizeMake(0, 0);
    self.contentViewShadowOpacity = 0.6;
    self.contentViewShadowRadius = 12;
    self.contentViewShadowEnabled = YES;
    
    [self setBouncesHorizontally:NO];
    [self setFadeMenuView:NO];
    [self setScaleContentView:NO];
    [self setScaleMenuView:NO];
    [self setPanGestureEnabled:NO];
    [self setDelegate:self];
    
    // front
    UINavigationController * nc = [[self storyboard] instantiateViewControllerWithIdentifier:@"idClientNC"];
    [self setContentViewController:nc];
    
    
    // settings
    SettingsVC * settings = [[self storyboard] instantiateViewControllerWithIdentifier:@"idSettingsVC"];
    [self setLeftMenuViewController:settings];
//    ClientVC * client = (ClientVC *)[nc topViewController];
//    [settings setDeviceDelegate:client];

//    MenuVC * menu = [[self storyboard] instantiateViewControllerWithIdentifier:@"idMenuVC"];
//    [self setLeftMenuViewController:menu];
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
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
