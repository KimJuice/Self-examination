//
//  KIMReadFileCell.h
//  Self-examination
//
//  Created by milk on 2017/6/29.
//  Copyright © 2017年 milk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIMReadFileModel.h"

@interface KIMReadFileCell : UITableViewCell

@property (nonatomic, strong) KIMReadFileModel *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
