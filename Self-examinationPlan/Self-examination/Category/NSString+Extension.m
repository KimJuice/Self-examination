//
//  NSString+Extension.m
//  Self-examination
//
//  Created by Milk on 2017/6/25.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

+ (NSString *)uuidString {
    
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

- (NSString *)URLEncodedString {

    NSString *encodedString = [self stringByRemovingPercentEncoding];
    return encodedString;
}

@end
