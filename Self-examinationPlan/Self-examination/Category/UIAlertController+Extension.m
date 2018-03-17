//
//  UIAlertController+Extension.m
//  Self-examination
//
//  Created by milk on 2017/6/29.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "UIAlertController+Extension.h"

@implementation UIAlertController (Extension)

+ (void)alertWithTextFiled:(NSArray<NSString *> *)placeholders isPre_write:(BOOL)isPre_write message:(NSString *)message con:(UIViewController *)con ok:(okBlock)ok {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    for (NSString *placeholder in placeholders) {
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
            if (isPre_write) {
                
                textField.text = placeholder;
            }else {
                
                textField.placeholder = placeholder;
            }
        }];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:alert.textFields.count];
        for (UITextField *textField in alert.textFields) {
            
            [temp addObject:textField.text];
        }
        ok(temp.copy);
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [con presentViewController:alert animated:YES completion:nil];
}

+ (void)alertWithTextFiled:(NSString *)placeholder message:(NSString *)message con:(UIViewController *)con testPaper:(TestPaperBlock)testPaper mindMapping:(MindMappingBlock)mindMapping {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.placeholder = placeholder;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *testPaperAction = [UIAlertAction actionWithTitle:@"试卷文件夹" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *name = alert.textFields.firstObject.text;
        if (name.length) {
            
            testPaper(name);
        }
    }];
    
    UIAlertAction *mindMappingAction = [UIAlertAction actionWithTitle:@"思维导图文件夹" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *name = alert.textFields.firstObject.text;
        if (name.length) {
            
            mindMapping(name);
        }
    }];
    
    [alert addAction:mindMappingAction];
    [alert addAction:testPaperAction];
    [alert addAction:cancelAction];
    [con presentViewController:alert animated:YES completion:nil];
}

+ (void)alertWithMessage:(NSString *)message con:(UIViewController *)con ok:(okBlock)ok {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        if (ok) {
            
            ok(@[]);
        }
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [con presentViewController:alert animated:YES completion:nil];
}

@end
