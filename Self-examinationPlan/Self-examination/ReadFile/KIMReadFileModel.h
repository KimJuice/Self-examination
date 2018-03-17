//
//  KIMReadFileModel.h
//  Self-examination
//
//  Created by milk on 2017/6/29.
//  Copyright © 2017年 milk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FileType) {

    FileTestPaperType = 1,
    FileMindMappingType
};

@interface KIMReadFileModel : NSObject

@property (nonatomic, copy) NSString *directoryUUID;
@property (nonatomic, assign) NSInteger directoryNum;
@property (nonatomic, strong) NSString *directoryName;
@property (nonatomic, assign) FileType fileType;
@property (nonatomic, strong) NSString *fileUUID;
@property (nonatomic, assign) NSInteger fileNum;
@property (nonatomic, copy) NSString *fileName;

@end
