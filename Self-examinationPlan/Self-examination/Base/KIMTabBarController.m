//
//  KIMTabBarController.m
//  Self-examination
//
//  Created by milk on 2017/6/29.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "KIMTabBarController.h"
#import "KIMPlanController.h"

@interface KIMTabBarController ()

@end

@implementation KIMTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    KIMPlanController *plan = [KIMPlanController new];
    plan.tabBarItem.title = @"Plan";
//    UINavigationController *navOne = [[UINavigationController alloc] initWithRootViewController:plan];
    
    [self addChildViewController:plan];
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
