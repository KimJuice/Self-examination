//
//  KIMReadFileCell.m
//  Self-examination
//
//  Created by milk on 2017/6/29.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "KIMReadFileCell.h"
#import "Masonry.h"
#import "UIImage+Extension.h"
#import "UIAlertController+Extension.h"
#import "KIMSqlManager.h"

@interface KIMReadFileCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *editBtn;

@end

@implementation KIMReadFileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    NSString *ID = NSStringFromClass([KIMReadFileCell class]);
    [tableView registerClass:[KIMReadFileCell class] forCellReuseIdentifier:ID];
    KIMReadFileCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[KIMReadFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self setupUI];
    }
    
    return self;
}

#pragma mark <Private Methods>

- (void)setupUI {
    
    WEAKSELF
    
    [self.contentView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.contentView).offset(15);
        make.centerY.equalTo(weakSelf.contentView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.iconView.mas_right).offset(10);
        make.centerY.equalTo(weakSelf.contentView);
        make.height.mas_equalTo(30);
        make.right.equalTo(weakSelf.contentView).offset(-10);
    }];
    
    [self.contentView addSubview:self.editBtn];
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(weakSelf.contentView).offset(-20);
        make.centerY.equalTo(weakSelf.contentView);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
}

- (void)setModel:(KIMReadFileModel *)model {

    _model = model;
    
    UIImage *image = [UIImageName(ICON_MINDMAPPING) imageWithColor:[UIColor redColor]];
    
    switch (model.fileType) {
            
        case FileTestPaperType: {
            
            image = [UIImageName(ICON_TESTPAPER) imageWithColor:[UIColor redColor]];
        } break;
            
        default: {
            
        } break;
    }
    
    self.iconView.image = image;
    self.titleLabel.text = [NSString stringWithFormat:@"%zd. %@", model.directoryNum, model.directoryName];
}

- (void)clickEditBtn {
    
    [UIAlertController alertWithTextFiled:@[self.model.directoryName] isPre_write:YES message:@"修改文件夹名称" con:[UIApplication sharedApplication].keyWindow.rootViewController ok:^(NSArray<NSString *> *texts) {
        
        self.model.directoryName = texts.firstObject;
        [[KIMSqlManager sharedInstance] updateDirectoryData:self.model];
        [self setModel:self.model];
    }];
}

#pragma mark <Getters And Setters>

- (UIImageView *)iconView {

    if (!_iconView) {
        
        _iconView = [UIImageView new];
    }
    
    return _iconView;
}

- (UILabel *)titleLabel {

    if (!_titleLabel) {
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = kColorAlone(50);
    }
    
    return _titleLabel;
}

- (UIButton *)editBtn {

    if (!_editBtn) {
        
        _editBtn = [UIButton new];
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_editBtn setTitle:@"📝" forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(clickEditBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _editBtn;
}

@end
