//
//  KIMPlanCell.m
//  Self-examination
//
//  Created by milk on 2017/6/22.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "KIMPlanCell.h"
#import "Masonry.h"
#import "NSDate+Extension.h"
#import "KIMSqlManager.h"

@interface KIMPlanCell ()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation KIMPlanCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    NSString *ID = [NSString stringWithFormat:@"%@%zd", NSStringFromClass([KIMPlanCell class]), indexPath.row];
    [tableView registerClass:[KIMPlanCell class] forCellReuseIdentifier:ID];
    KIMPlanCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    if (cell == nil) {
        
        cell = [[KIMPlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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
    
    [self.contentView addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.contentView);
        make.left.equalTo(weakSelf.contentView).offset(10);
        make.right.equalTo(weakSelf.contentView);
        make.height.mas_equalTo(kDateHeight);
    }];
    
    [self.contentView addSubview:self.doneBtn];
    [self.contentView addSubview:self.titleLabel];
}

- (void)setModel:(KIMPlanModel *)model {

    _model = model;
    
    self.dateLabel.text = model.dateStr;
    if ([model.dateStr isEqualToString:[NSDate getNowMonthAndDay]]) {
        self.dateLabel.text = [NSString stringWithFormat:@"%@  🍓", model.dateStr];
    }
    self.titleLabel.text = model.title;
    self.doneBtn.selected = model.isDone;
    
    WEAKSELF
    
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(weakSelf.dateLabel).offset((weakSelf.model.cellHeight - kDateHeight) * 0.5 + 12);
        make.left.equalTo(weakSelf.contentView).offset(15);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(weakSelf.doneBtn).offset(-2);
        make.left.equalTo(weakSelf.doneBtn.mas_right).offset(15);
        make.right.equalTo(weakSelf.contentView).offset(-15);
    }];
}

- (void)clickDoneBtn:(UIButton *)sender {

    sender.selected = !sender.isSelected;
    self.model.isDone = sender.selected;
    [[KIMSqlManager sharedInstance] updateData:self.model];
}

#pragma mark <Getters And Setters>

- (UILabel *)dateLabel {

    if (!_dateLabel) {
        
        _dateLabel = [UILabel new];
        _dateLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
    }
    
    return _dateLabel;
}

- (UIButton *)doneBtn {

    if (!_doneBtn) {
        
        _doneBtn = [UIButton new];
        [_doneBtn setBackgroundImage:[UIImage imageNamed:@"btn_normal.png"] forState:UIControlStateNormal];
        [_doneBtn setBackgroundImage:[UIImage imageNamed:@"btn_selected.png"] forState:UIControlStateSelected];
        [_doneBtn addTarget:self action:@selector(clickDoneBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _doneBtn;
}

- (UILabel *)titleLabel {

    if (!_titleLabel) {
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textColor = kTitleColor;
        _titleLabel.numberOfLines = 0;
    }
    
    return _titleLabel;
}

@end
