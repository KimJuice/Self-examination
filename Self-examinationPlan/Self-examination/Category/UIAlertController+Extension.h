//
//  UIAlertController+Extension.h
//  Self-examination
//
//  Created by milk on 2017/6/29.
//  Copyright © 2017年 milk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^okBlock)(NSArray<NSString *> *);
typedef void(^TestPaperBlock)(NSString *);
typedef void(^MindMappingBlock)(NSString *);

@interface UIAlertController (Extension)

+ (void)alertWithTextFiled:(NSArray<NSString *> *)placeholders isPre_write:(BOOL)isPre_write message:(NSString *)message con:(UIViewController *)con ok:(okBlock)ok;

+ (void)alertWithTextFiled:(NSString *)placeholder message:(NSString *)message con:(UIViewController *)con testPaper:(TestPaperBlock)testPaper mindMapping:(MindMappingBlock)mindMapping;

+ (void)alertWithMessage:(NSString *)message con:(UIViewController *)con ok:(okBlock)ok;

@end
