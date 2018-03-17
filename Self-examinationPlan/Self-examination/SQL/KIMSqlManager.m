//
//  KIMSqlManager.m
//  Self-examination
//
//  Created by milk on 2017/6/22.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "KIMSqlManager.h"
#import "NSDate+Extension.h"

@implementation KIMSqlManager

+ (instancetype)sharedInstance {
    
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (FMDatabaseQueue *)queue {
    
    if (!_queue) {
        
        _queue = [FMDatabaseQueue new];
        if (![[NSFileManager defaultManager] fileExistsAtPath:NSDocumentSQLPath]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:NSDocumentSQLPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *filePath = [NSString stringWithFormat:@"%@Plan.db", NSDocumentSQLPath];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            _queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
            [self creatDataBaseTable];
        }else {
            
            _queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
        }
    }
    
    return _queue;
}

- (void)creatDataBaseTable {
    
    NSMutableString *sql = [NSMutableString string];
    
    [sql appendString:@"CREATE TABLE IF NOT EXISTS KIM_PLAN (id integer primary key autoincrement, PLAN_ID VARCHAR, YEAR DATETIME, PLAN_TIME DATETIME, PLAN_TIMESTR VARCHAR, TITLE VARCHAR, IS_DONE INTEGER, CELL_HEIGHT FLOAT);"];
    [sql appendString:@"CREATE TABLE IF NOT EXISTS KIM_DIRECTORY (id integer primary key autoincrement, DIRECTORY_ID VARCHAR, DIRECTORY_NUM INTEGER, DIRECTORY_NAME VARCHAR, DIRECTORY_TYPE INTEGER);"];
    [sql appendString:@"CREATE TABLE IF NOT EXISTS KIM_FILE (id integer primary key autoincrement, DIRECTORY_ID VARCHAR, FILE_ID VARCHAR, FILE_NUM INTEGER, FILE_NAME VARCHAR);"];
    
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        BOOL isOK = [db executeStatements:sql];
        NSLog(@"建表结果 -> %d", isOK);
    }];
}

- (BOOL)insertData:(KIMPlanModel *)model {
    
    __block BOOL isOK = NO;
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO KIM_PLAN (PLAN_ID, YEAR, PLAN_TIME, PLAN_TIMESTR, TITLE, IS_DONE, CELL_HEIGHT) VALUES ('%@', '%@', '%@', '%@', '%@', '%d', '%f')", model.planID, [NSDate formatterDateForYear:model.date], [NSDate formatterDateForSQL:model.date], model.dateStr, model.title, model.isDone, model.cellHeight];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        isOK = [db executeUpdate:sql];
    }];
    
    return isOK;
}

- (BOOL)updateData:(KIMPlanModel *)model {
    
    __block BOOL isOK = NO;
    NSString *sql = [NSString stringWithFormat:@"UPDATE KIM_PLAN set IS_DONE = '%d', TITLE = '%@', PLAN_TIME = '%@', PLAN_TIMESTR = '%@' WHERE PLAN_ID = '%@'", model.isDone, model.title, [NSDate formatterDateForSQL:model.date], model.dateStr, model.planID];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        isOK = [db executeUpdate:sql];
    }];
    
    return isOK;
}

- (BOOL)deleteData:(KIMPlanModel *)model {
    
    __block BOOL isOK = NO;
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM KIM_PLAN WHERE PLAN_ID = '%@'", model.planID];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        isOK = [db executeUpdate:sql];
    }];
    
    return isOK;
}

- (NSMutableArray *)readAllPlanData {
    
    __block NSMutableArray *temp = [NSMutableArray array];
    NSString *year = [NSDate formatterDateForYear:[NSDate date]];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM KIM_PLAN WHERE YEAR = '%@' AND PLAN_TIME >= '%@-01-01 00:00:00' ORDER BY PLAN_TIME ASC", year, year];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        FMResultSet *rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            KIMPlanModel *model = [KIMPlanModel new];
            model.dateStr = [rs stringForColumn:@"PLAN_TIMESTR"];
            model.date = [NSDate formatterDateFromInteger:[rs stringForColumn:@"PLAN_TIME"]];
            model.title = [rs stringForColumn:@"TITLE"];
            model.planID = [rs stringForColumn:@"PLAN_ID"];
            model.isDone = [rs intForColumn:@"IS_DONE"];
            model.cellHeight = [rs doubleForColumn:@"CELL_HEIGHT"];
            
            [temp addObject:model];
        }
        
        [rs close];
    }];
    
    return temp;
}

- (BOOL)insertDirectoryData:(KIMReadFileModel *)model {
    
    __block BOOL isOK = NO;
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO KIM_DIRECTORY (DIRECTORY_ID, DIRECTORY_NUM, DIRECTORY_NAME, DIRECTORY_TYPE) VALUES ('%@', '%zd', '%@', '%zd')", model.directoryUUID, model.directoryNum, model.directoryName, model.fileType];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        isOK = [db executeUpdate:sql];
    }];
    
    return isOK;
}

- (BOOL)updateDirectoryData:(KIMReadFileModel *)model {
    
    __block BOOL isOK = NO;
    NSString *sql = [NSString stringWithFormat:@"UPDATE KIM_DIRECTORY set DIRECTORY_NAME = '%@', DIRECTORY_TYPE = '%zd' WHERE DIRECTORY_ID = '%@'", model.directoryName, model.fileType, model.directoryUUID];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        isOK = [db executeUpdate:sql];
    }];
    
    return isOK;
}

- (BOOL)deleteDirectoryData:(KIMReadFileModel *)model {
    
    __block BOOL isOK = NO;
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM KIM_DIRECTORY WHERE DIRECTORY_ID = '%@'", model.directoryUUID];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        isOK = [db executeUpdate:sql];
    }];
    
    return isOK;
}

- (NSMutableArray *)readAllDirectoryData {
    
    __block NSMutableArray *temp = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM KIM_DIRECTORY WHERE DIRECTORY_NUM >= '0' ORDER BY DIRECTORY_NUM ASC"];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        FMResultSet *rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            KIMReadFileModel *model = [KIMReadFileModel new];
            model.directoryUUID = [rs stringForColumn:@"DIRECTORY_ID"];
            model.directoryNum = [rs intForColumn:@"DIRECTORY_NUM"];
            model.directoryName = [rs stringForColumn:@"DIRECTORY_NAME"];
            model.fileType = [rs intForColumn:@"DIRECTORY_TYPE"];;
            
            [temp addObject:model];
        }
        
        [rs close];
    }];
    
    return temp;
}

- (BOOL)deleteDirectoryAllData {

    __block BOOL isOK = NO;
    NSString *sql = @"DELETE FROM KIM_DIRECTORY; DELETE FROM KIM_FILE;";
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        isOK = [db executeStatements:sql];
    }];
    
    return isOK;
}

- (BOOL)insertFileData:(KIMReadFileModel *)model {

    __block BOOL isOK = NO;
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO KIM_FILE (DIRECTORY_ID, FILE_ID, FILE_NUM, FILE_NAME) VALUES ('%@', '%@', '%zd', '%@')", model.directoryUUID, model.fileUUID, model.fileNum, model.fileName];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        isOK = [db executeUpdate:sql];
    }];
    
    return isOK;
}

- (BOOL)deleteFileData:(KIMReadFileModel *)model {

    __block BOOL isOK = NO;
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM KIM_FILE WHERE FILE_ID = '%@'", model.fileUUID];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        isOK = [db executeUpdate:sql];
    }];
    
    return isOK;
}

- (NSMutableArray *)readAllFileData:(NSString *)directoryUUID {

    __block NSMutableArray *temp = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM KIM_FILE WHERE DIRECTORY_ID = '%@' AND FILE_NUM >= '0' ORDER BY FILE_NUM ASC", directoryUUID];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        FMResultSet *rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            KIMReadFileModel *model = [KIMReadFileModel new];
            model.directoryUUID = [rs stringForColumn:@"DIRECTORY_ID"];
            model.fileUUID = [rs stringForColumn:@"FILE_ID"];
            model.fileNum = [rs intForColumn:@"FILE_NUM"];
            model.fileName = [rs stringForColumn:@"FILE_NAME"];
            
            [temp addObject:model];
        }
        
        [rs close];
    }];
    
    return temp;
}

- (BOOL)deleteFileAllData:(KIMReadFileModel *)model {

    __block BOOL isOK = NO;
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM KIM_FILE WHERE DIRECTORY_ID = '%@'", model.directoryUUID];
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        isOK = [db executeUpdate:sql];
    }];
    
    return isOK;
}

@end
