//
//  KIMSqlManager.h
//  Self-examination
//
//  Created by milk on 2017/6/22.
//  Copyright © 2017年 milk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "KIMPlanModel.h"
#import "KIMReadFileModel.h"

typedef NS_ENUM(NSInteger, QueueType) {

    QueuePlanType = 1,
    QueueDirectoryType,
    QueueFileType
};

@interface KIMSqlManager : NSObject

@property (nonatomic, strong) FMDatabaseQueue *queue;

+ (instancetype)sharedInstance;

// 计划
- (BOOL)insertData:(KIMPlanModel *)model;
- (BOOL)updateData:(KIMPlanModel *)model;
- (BOOL)deleteData:(KIMPlanModel *)model;
- (NSMutableArray *)readAllPlanData;

// 阅览目录
- (BOOL)insertDirectoryData:(KIMReadFileModel *)model;
- (BOOL)updateDirectoryData:(KIMReadFileModel *)model;
- (BOOL)deleteDirectoryData:(KIMReadFileModel *)model;
- (NSMutableArray *)readAllDirectoryData;
- (BOOL)deleteDirectoryAllData;

// 文件目录
- (BOOL)insertFileData:(KIMReadFileModel *)model;
//- (BOOL)updateFileData:(KIMReadFileModel *)model;
- (BOOL)deleteFileData:(KIMReadFileModel *)model;
- (NSMutableArray *)readAllFileData:(NSString *)directoryUUID;
- (BOOL)deleteFileAllData:(KIMReadFileModel *)model;

@end
