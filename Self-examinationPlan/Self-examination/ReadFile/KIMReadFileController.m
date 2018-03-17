//
//  KIMReadFileController.m
//  Self-examination
//
//  Created by milk on 2017/6/29.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "KIMReadFileController.h"
#import "KIMReadFileCell.h"
#import "KIMReadFileModel.h"
#import "UIAlertController+Extension.h"
#import "KIMFileInfoController.h"
#import "KIMSqlManager.h"
#import "NSString+Extension.h"

@interface KIMReadFileController ()

@end

@implementation KIMReadFileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIBarButtonItem *uploadRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(uploadDirectory)];
    UIBarButtonItem *deleteRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAllDirectory)];
    self.navigationItem.rightBarButtonItems = @[uploadRight, deleteRight];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"Back";
    self.navigationItem.backBarButtonItem = backItem;

    self.title = @"文件阅览";
    
    [self.view addSubview:self.tableView];
    self.dataSource = [[KIMSqlManager sharedInstance] readAllDirectoryData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <Private Methods>

- (void)deleteAllDirectory {

    [UIAlertController alertWithMessage:@"确定删除所有文件夹?" con:self ok:^(NSArray<NSString *> *temp) {
        
        [[KIMSqlManager sharedInstance] deleteDirectoryAllData];
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:NSDocumentFilePath]) {
            
            NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:NSDocumentFilePath];
            for (NSString *fileName in enumerator) {
                
                [[NSFileManager defaultManager] removeItemAtPath:[NSDocumentFilePath stringByAppendingPathComponent:fileName] error:nil];
            }
        }
    }];
}

- (void)uploadDirectory {

    __block KIMReadFileModel *model = [KIMReadFileModel new];
    model.directoryUUID = [NSString uuidString];
    model.directoryNum = self.dataSource.count + 1;

    [UIAlertController alertWithTextFiled:@"输入文件夹名称" message:@"新建文件夹" con:self testPaper:^(NSString *name) {
        
        model.directoryName = name;
        model.fileType = FileTestPaperType;
        [self.dataSource addObject:model];
        [self.tableView reloadData];
        [[KIMSqlManager sharedInstance] insertDirectoryData:model];
        
    } mindMapping:^(NSString *name) {
        
        model.directoryName = name;
        model.fileType = FileMindMappingType;
        [self.dataSource addObject:model];
        [self.tableView reloadData];
        [[KIMSqlManager sharedInstance] insertDirectoryData:model];
    }];
}

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KIMReadFileCell *cell = [KIMReadFileCell cellWithTableView:tableView indexPath:indexPath];
    
    KIMReadFileModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KIMReadFileModel *model = self.dataSource[indexPath.row];
    KIMFileInfoController *info = [KIMFileInfoController new];
    info.directoryModel = model;
    info.url = self.url.copy;
    [self.navigationController pushViewController:info animated:YES];
    
    self.url = nil;
}

#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    KIMReadFileModel *model = self.dataSource[indexPath.row];
    [self.dataSource removeObject:model];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[KIMSqlManager sharedInstance] deleteDirectoryData:model];
    
    NSString *directoryPath = [NSDocumentFilePath stringByAppendingPathComponent:model.directoryUUID];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        
        BOOL isDelete = [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
        if (!isDelete) {
            
            [UIAlertController alertWithMessage:@"删除文件夹失败" con:self ok:nil];
        }
    }
}

#pragma mark <Getter And Setter>

@end
