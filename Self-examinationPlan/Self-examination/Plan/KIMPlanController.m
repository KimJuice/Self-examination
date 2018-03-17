//
//  ViewController.m
//  Self-examination
//
//  Created by milk on 2017/6/22.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "KIMPlanController.h"
#import "KIMPlanCell.h"
#import "KIMPlanModel.h"
#import "NSDate+Extension.h"
#import "KIMSqlManager.h"
#import "Masonry.h"
#import "NSString+Extension.h"
#import "KIMReadFileController.h"

@interface KIMPlanController ()

@property (nonatomic, strong) UIView *editView;
@property (nonatomic, strong) UIButton *commitBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIDatePicker *picker;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *weekLabel;
@property (nonatomic, strong) KIMPlanModel *currentModel;
@property (nonatomic, strong) UIButton *clearBtn;

@end

@implementation KIMPlanController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    self.title = [NSDate getNowYear];

    UIBarButtonItem *addRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlan)];
    
    UIBarButtonItem *readRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(readFile)];
    
    self.navigationItem.rightBarButtonItems = @[addRight, readRight];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain target:self action:@selector(jumpToToday)];
    self.navigationItem.leftBarButtonItem = left;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"Back";
    self.navigationItem.backBarButtonItem = backItem;
    
    [self.view addSubview:self.tableView];
    
    self.editView.frame = CGRectMake(20, 20, kScreenWidth - 40, 0);
    [self.view addSubview:self.editView];
    
    WEAKSELF
    
    [self.editView addSubview:self.commitBtn];
    [self.commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(weakSelf.editView).offset(-15);
        make.right.equalTo(weakSelf.editView).offset(-20);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    [self.editView addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(weakSelf.editView).offset(-15);
        make.left.equalTo(weakSelf.editView).offset(20);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    [self.editView addSubview:self.clearBtn];
    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.commitBtn);
        make.centerX.equalTo(weakSelf.editView);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
 
    [self.editView addSubview:self.picker];
    [self.picker mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.editView).offset(20);
        make.left.equalTo(weakSelf.editView).offset(20);
        make.right.equalTo(weakSelf.editView).offset(-20);
        make.height.mas_equalTo(@180);
    }];
    
    [self.editView addSubview:self.weekLabel];
    self.weekLabel.text = [NSDate getNowWeek];
    [self.weekLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.picker.mas_bottom);
        make.left.equalTo(weakSelf.editView).offset(20);
        make.right.equalTo(weakSelf.editView).offset(-20);
        make.height.mas_equalTo(@30);
    }];
    
    [self.editView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.weekLabel.mas_bottom).offset(15);
        make.left.equalTo(weakSelf.editView).offset(20);
        make.right.equalTo(weakSelf.editView).offset(-20);
        make.bottom.equalTo(weakSelf.cancelBtn.mas_top).offset(-15);
    }];
    
    self.dataSource = [[KIMSqlManager sharedInstance] readAllPlanData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self.textView resignFirstResponder];
    [self.commitBtn setTitle:@"提交" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <Private Methods>

- (void)jumpToToday {

    [self.dataSource enumerateObjectsUsingBlock:^(KIMPlanModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([model.dateStr isEqualToString:[NSDate getNowMonthAndDay]]) {
            
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            *stop = YES;
        }
    }];
}

- (void)addPlan {

    [UIView animateWithDuration:0.25 animations:^{
       
        self.editView.frame = CGRectMake(20, 84, kScreenWidth - 40, kScreenHeight * 0.6);
        self.tableView.userInteractionEnabled = NO;
        self.picker.date = self.currentModel.date ?: [NSDate date];
        self.weekLabel.text = [NSDate formatterDateForWeek:self.picker.date];
    }];
}

- (void)readFile {

    KIMReadFileController *file = [KIMReadFileController new];
    [self.navigationController pushViewController:file animated:YES];
}

- (void)clickCommitBtn {
    
    if ([self.commitBtn.titleLabel.text isEqualToString:@"修改"]) {
        
        [self clickEditBtn];
        return;
    }

    KIMPlanModel *model = [KIMPlanModel initWithDate:self.currentDate title:self.textView.text  planID:[NSString uuidString]];
    [[KIMSqlManager sharedInstance] insertData:model];
    self.dataSource = [[KIMSqlManager sharedInstance] readAllPlanData];
    [self.tableView reloadData];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"是否继续新建计划?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.textView.text = @"";
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        self.textView.text = @"";
        [self.textView resignFirstResponder];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.editView.frame = CGRectMake(20, 84, kScreenWidth - 40, 0);
            self.tableView.userInteractionEnabled = YES;
        }];
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)clickEditBtn {
    
    if (!self.textView.text.length) {
        
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"是否确认修改?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSDate *date = [self.currentModel.dateStr isEqualToString:[NSDate formatterDate:self.picker.date]] ? self.currentModel.date : self.picker.date;
        KIMPlanModel *model = [KIMPlanModel initWithDate:date title:self.textView.text  planID:self.currentModel.planID];
        [[KIMSqlManager sharedInstance] updateData:model];
        self.dataSource = [[KIMSqlManager sharedInstance] readAllPlanData];
        [self.tableView reloadData];
        
        self.textView.text = @"";
        [self.textView resignFirstResponder];

        [UIView animateWithDuration:0.25 animations:^{
            
            self.editView.frame = CGRectMake(20, 84, kScreenWidth - 40, 0);
            self.tableView.userInteractionEnabled = YES;
            [self.commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        self.textView.text = @"";
        [self.textView resignFirstResponder];

        [UIView animateWithDuration:0.25 animations:^{
            
            self.editView.frame = CGRectMake(20, 84, kScreenWidth - 40, 0);
            self.tableView.userInteractionEnabled = YES;
            [self.commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        }];
    }];

    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)clickCancelBtn {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"是否保存草稿?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.textView resignFirstResponder];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        self.textView.text = @"";
        self.picker.date = [NSDate date];
        self.currentDate = [NSDate date];
        self.weekLabel.text = [NSDate getNowWeek];
        [self.textView resignFirstResponder];
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    if (self.textView.text.length && ![self.commitBtn.titleLabel.text isEqual:@"修改"]) {

        [self presentViewController:alert animated:YES completion:nil];
    }else {
    
        [self.textView resignFirstResponder];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.editView.frame = CGRectMake(20, 84, kScreenWidth - 40, 0);
        self.tableView.userInteractionEnabled = YES;
    }];
    
    [self.commitBtn setTitle:@"提交" forState:UIControlStateNormal];
}

- (void)clickDatePicker:(UIDatePicker *)sender {

    self.currentDate = sender.date;
    self.weekLabel.text = [NSDate formatterDateForWeek:sender.date];
}

- (void)clearTextView {

    self.textView.text = @"";
}

- (void)keyboardWillShow:(NSNotification *)aNotification {

    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    CGFloat editBottom = self.view.frame.size.height - CGRectGetMaxY(self.editView.frame);
    if (editBottom < height) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            self.view.frame = CGRectMake(0, editBottom - height, kScreenWidth, kScreenHeight);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification{

    [UIView animateWithDuration:0.2 animations:^{
       
        self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
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

    KIMPlanCell *cell = [KIMPlanCell cellWithTableView:tableView indexPath:indexPath];
    KIMPlanModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    KIMPlanModel *model = self.dataSource[indexPath.row];
    self.textView.text = model.title;
    self.currentModel = model;
    [self.commitBtn setTitle:@"修改" forState:UIControlStateNormal];
    [self addPlan];
}

#pragma mark <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    KIMPlanModel *model = self.dataSource[indexPath.row];
    
    return model.cellHeight;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    KIMPlanModel *model = self.dataSource[indexPath.row];
    [self.dataSource removeObject:model];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[KIMSqlManager sharedInstance] deleteData:model];
}

#pragma mark <Getter And Setter>

- (UIView *)editView {

    if (!_editView) {
        
        _editView = [UIView new];
        _editView.backgroundColor = kColorAlone(248);
        _editView.layer.cornerRadius = 10;
        _editView.clipsToBounds = YES;
        _editView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _editView.layer.borderWidth = 0.4;
    }
    
    return _editView;
}

- (UIButton *)commitBtn {

    if (!_commitBtn) {
        
        _commitBtn = [UIButton new];
        [_commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_commitBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _commitBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_commitBtn addTarget:self action:@selector(clickCommitBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _commitBtn;
}

- (UIButton *)cancelBtn {

    if (!_cancelBtn) {
        
        _cancelBtn = [UIButton new];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelBtn addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelBtn;
}

- (UIDatePicker *)picker {

    if (!_picker) {
        
        _picker = [UIDatePicker new];
        _picker.datePickerMode = UIDatePickerModeDate;
        _picker.timeZone = [NSTimeZone systemTimeZone];
        _picker.date = [NSDate date];
        _picker.calendar = [NSCalendar currentCalendar];
        _picker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [_picker addTarget:self action:@selector(clickDatePicker:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _picker;
}

- (UITextView *)textView {

    if (!_textView) {
        
        _textView = [UITextView new];
        _textView.tintColor = kColorAlone(120);
        _textView.textColor = kColorAlone(20);
        _textView.font = [UIFont systemFontOfSize:14];
    }
    
    return _textView;
}

- (UILabel *)weekLabel {

    if (!_weekLabel) {
        
        _weekLabel = [UILabel new];
        _weekLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _weekLabel;
}

- (NSDate *)currentDate {

    if (!_currentDate) {
        
        _currentDate = [NSDate date];
    }
    
    return _currentDate;
}

- (UIButton *)clearBtn {

    if (!_clearBtn) {
        
        _clearBtn = [UIButton new];
        [_clearBtn setTitle:@"🗑" forState:UIControlStateNormal]; //🔮
        [_clearBtn addTarget:self action:@selector(clearTextView) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _clearBtn;
}

@end
