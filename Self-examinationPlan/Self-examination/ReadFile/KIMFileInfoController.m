//
//  KIMFileInfoController.m
//  Self-examination
//
//  Created by milk on 2017/6/29.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "KIMFileInfoController.h"
#import "KIMSqlManager.h"
#import <Photos/Photos.h>
#import "UIAlertController+Extension.h"
#import "NSString+Extension.h"

@interface KIMFileInfoController ()
<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIDocumentInteractionControllerDelegate
>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIDocumentInteractionController *documentCon;

@end

@implementation KIMFileInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *addRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFile)];
    UIBarButtonItem *otherRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(addShareFile)];
    UIBarButtonItem *deleteRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAllFile)];
    self.navigationItem.rightBarButtonItems = @[addRight, otherRight, deleteRight];
    
    self.title = @"所有文件";
    self.imagePicker.delegate = self;
    
    [self.view addSubview:self.tableView];
    self.dataSource = [[KIMSqlManager sharedInstance] readAllFileData:self.directoryModel.directoryUUID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <Private Methods>

- (void)deleteAllFile {

    [UIAlertController alertWithMessage:@"确定删除所有文件夹?" con:self ok:^(NSArray<NSString *> *temp) {
        
        [[KIMSqlManager sharedInstance] deleteFileAllData:self.directoryModel];
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        
        NSString *directoryPath = [NSString stringWithFormat:@"%@%@/", NSDocumentFilePath, self.directoryModel.directoryUUID];

        if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
            
            NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
            for (NSString *fileName in enumerator) {
                
                [[NSFileManager defaultManager] removeItemAtPath:[directoryPath stringByAppendingPathComponent:fileName] error:nil];
            }
        }
    }];
}

- (void)addShareFile {

    if (self.url) {
        
        __block NSString *urlPath = [self.url absoluteString];
        NSString *extension = [urlPath pathExtension];
        NSArray *temp = [urlPath componentsSeparatedByString:@"file:///private"];
        urlPath = [temp.lastObject URLEncodedString];
        
        NSArray *names = [urlPath componentsSeparatedByString:@"/"];
        NSString *name = names.count ? names.lastObject : @"";
        names = [name componentsSeparatedByString:@"."];
        name = names.count ? names.firstObject : @"";
        
        __block BOOL isOK = NO;
        [UIAlertController alertWithTextFiled:@[name] isPre_write:YES message:@"上传文件" con:self ok:^(NSArray<NSString *> *texts) {
            
            KIMReadFileModel *model = [KIMReadFileModel new];
            model.directoryUUID = self.directoryModel.directoryUUID;
            model.fileUUID = [NSString uuidString];
            
            NSString *directoryPath = [NSDocumentFilePath stringByAppendingPathComponent:model.directoryUUID];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
                
                [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString *path = [NSString stringWithFormat:@"%@/%@.%@", directoryPath, model.fileUUID, extension];
            NSData *data = [NSData dataWithContentsOfURL:self.url];
            isOK = [data writeToFile:path atomically:YES];
            
            if (isOK) {

                model.fileNum = self.dataSource.count + 1;
                model.fileName = [NSString stringWithFormat:@"%@.%@", texts.firstObject, extension];
                [[KIMSqlManager sharedInstance] insertFileData:model];
                
                [self.dataSource addObject:model];
                [self.tableView reloadData];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:urlPath]) {
                    
                    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:NSDocumentInboxPath];
                    for (NSString *fileName in enumerator) {
                        
                        [[NSFileManager defaultManager] removeItemAtPath:[NSDocumentInboxPath stringByAppendingPathComponent:fileName] error:nil];
                    }
                    
//                    BOOL isDeleted = [[NSFileManager defaultManager] removeItemAtURL:self.url error:nil];
//                    if (!isDeleted) [UIAlertController alertWithMessage:@"删除源文件失败!" con:self ok:nil];
                    self.url = nil;
                }
            }else {
                
                [UIAlertController alertWithMessage:@"上传失败!" con:self ok:nil];
            }
        }];
        
    }else {
    
        [UIAlertController alertWithMessage:@"没有分享过来的文件!" con:self ok:nil];
    }
}

- (void)addFile {
    
    void (^addFileBlock)() = ^(){
    
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        }
    };

    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusAuthorized) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                
                addFileBlock();
            }else {
            
                [UIAlertController alertWithMessage:@"请开启相册权限" con:self ok:^(NSArray<NSString *> *temp) {
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"] options:@{} completionHandler:nil];
                }];
            }
        }];
    }else {
    
        addFileBlock();
    }
}

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *ID = NSStringFromClass([KIMFileInfoController class]);
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    KIMReadFileModel *model = self.dataSource[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [NSString stringWithFormat:@"%zd☃ %@", model.fileNum, model.fileName];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = kColorAlone(50);
    
    return cell;
}

#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KIMReadFileModel *model = self.dataSource[indexPath.row];
    NSString *directoryPath = [NSDocumentFilePath stringByAppendingPathComponent:model.directoryUUID];
    NSString *path = [NSString stringWithFormat:@"%@/%@.%@", directoryPath, model.fileUUID, [model.fileName pathExtension]];
    self.documentCon = [UIDocumentInteractionController interactionControllerWithURL:[[NSURL alloc] initFileURLWithPath:path]];
    self.documentCon.delegate = self;
    BOOL isOpen = [self.documentCon presentPreviewAnimated:YES];
    if (!isOpen) {
        
        [UIAlertController alertWithMessage:@"无法预览此类型文件" con:self ok:nil];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KIMReadFileModel *model = self.dataSource[indexPath.row];
    [self.dataSource removeObject:model];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[KIMSqlManager sharedInstance] deleteFileData:model];
    
    NSString *directoryPath = [NSDocumentFilePath stringByAppendingPathComponent:model.directoryUUID];
    NSString *path = [NSString stringWithFormat:@"%@/%@.%@", directoryPath, model.fileUUID, [model.fileName pathExtension]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        BOOL isDelete = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        if (!isDelete) {
            
            [UIAlertController alertWithMessage:@"删除源文件失败" con:self ok:nil];
        }
    }
}

#pragma mark <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    __block BOOL isOK = NO;
    [UIAlertController alertWithTextFiled:@[@"输入文件名称"] isPre_write:NO message:@"上传图片" con:self ok:^(NSArray<NSString *> *texts) {
        
        KIMReadFileModel *model = [KIMReadFileModel new];
        model.directoryUUID = self.directoryModel.directoryUUID;
        model.fileUUID = [NSString uuidString];
        
        NSString *directoryPath = [NSDocumentFilePath stringByAppendingPathComponent:model.directoryUUID];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *path = [NSString stringWithFormat:@"%@/%@.PNG", directoryPath, model.fileUUID];
        NSData *data = UIImagePNGRepresentation(image);
        isOK = [data writeToFile:path atomically:YES];
        
        if (isOK) {
            
            model.fileNum = self.dataSource.count + 1;
            model.fileName = [NSString stringWithFormat:@"%@.PNG", texts.firstObject];
            [[KIMSqlManager sharedInstance] insertFileData:model];
            
            [self.dataSource addObject:model];
            [self.tableView reloadData];
        }else {
        
            [UIAlertController alertWithMessage:@"上传失败!" con:self ok:nil];
        }
    }];
}

#pragma mark <UIDocumentInteractionControllerDelegate>

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {

    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {

    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {

    return self.view.frame;
}

#pragma mark <Getter And Setter>

- (UIImagePickerController *)imagePicker {

    if (!_imagePicker) {
        
        _imagePicker = [UIImagePickerController new];
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker.allowsEditing = YES;
    }
    
    return _imagePicker;
}

- (UIDocumentInteractionController *)documentCon {

    if (!_documentCon) {
        
        _documentCon = [UIDocumentInteractionController new];
    }
    
    return _documentCon;
}

@end
