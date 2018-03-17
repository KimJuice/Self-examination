//
//  KIMPlanCell.h
//  Self-examination
//
//  Created by milk on 2017/6/22.
//  Copyright © 2017年 milk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIMPlanModel.h"

@interface KIMPlanCell : UITableViewCell

@property (nonatomic, strong) KIMPlanModel *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
