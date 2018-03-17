//
//  KIMPlanModel.m
//  Self-examination
//
//  Created by milk on 2017/6/22.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "KIMPlanModel.h"
#import "NSDate+Extension.h"

@implementation KIMPlanModel

+ (instancetype)initWithDate:(NSDate *)date title:(NSString *)title planID:(NSString *)planID {

    KIMPlanModel *model = [KIMPlanModel new];
    model.date = date;
    model.dateStr = [NSDate formatterDate:model.date];
    model.title = title;
    model.isDone = false;
    model.planID = planID;
    
    CGFloat height = [title boundingRectWithSize:CGSizeMake(kTitleWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13], NSBackgroundColorAttributeName: kTitleColor} context:nil].size.height;
    model.cellHeight = height < 75 ? 75 : height + kDateHeight + 10;
    
    return model;
}

@end
