//
//  NSDate+Extension.m
//  Self-examination
//
//  Created by milk on 2017/6/22.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

+ (NSString *)getNowMonthAndDay {

    NSDate *date = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"MM月dd日 EEEE";
    return [fmt stringFromDate:date];
}

+ (NSString *)getNowWeek {
    
    NSDate *date = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"EEEE";
    return [fmt stringFromDate:date];
}

+ (NSString *)getNowYear {

    NSDate *date = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy年";
    return [fmt stringFromDate:date];
}

+ (NSString *)formatterDateForSQL:(NSDate *)date {
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [fmt stringFromDate:date];
}

+ (NSString *)formatterDate:(NSDate *)date {
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"MM月dd日 EEEE";
    return [fmt stringFromDate:date];
}

+ (NSString *)formatterDateForWeek:(NSDate *)date {
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"EEEE";
    return [fmt stringFromDate:date];
}

+ (NSString *)formatterDateForYear:(NSDate *)date {
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy";
    return [fmt stringFromDate:date];
}

+ (NSDate *)formatterDateFromInteger:(NSString *)timeIntervalStr {

    NSDateFormatter *inputFormatter= [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [inputFormatter dateFromString:timeIntervalStr];
}

@end
