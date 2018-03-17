//
//  KIMPlanModel.h
//  Self-examination
//
//  Created by milk on 2017/6/22.
//  Copyright © 2017年 milk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KIMPlanModel : NSObject

@property (nonatomic, copy) NSString *planID;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *dateStr;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isDone;
@property (nonatomic, assign) CGFloat cellHeight;

+ (instancetype)initWithDate:(NSDate *)date title:(NSString *)title planID:(NSString *)planID;

@end
