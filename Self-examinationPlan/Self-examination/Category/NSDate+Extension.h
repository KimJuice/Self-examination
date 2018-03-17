//
//  NSDate+Extension.h
//  Self-examination
//
//  Created by milk on 2017/6/22.
//  Copyright © 2017年 milk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)

+ (NSString *)getNowMonthAndDay;

+ (NSString *)getNowYear;

+ (NSString *)formatterDate:(NSDate *)date;

+ (NSString *)formatterDateForSQL:(NSDate *)date;

+ (NSString *)formatterDateForWeek:(NSDate *)date;

+ (NSString *)formatterDateForYear:(NSDate *)date;

+ (NSString *)getNowWeek;

+  (NSDate *)formatterDateFromInteger:(NSString *)timeIntervalStr;

@end
