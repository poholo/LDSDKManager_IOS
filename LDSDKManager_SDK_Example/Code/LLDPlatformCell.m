//
// Created by majiancheng on 2018/12/6.
// Copyright (c) 2018 majiancheng. All rights reserved.
//

#import "LLDPlatformCell.h"

#import "LLDPlatformDto.h"

@interface LLDPlatformCollectionCell : UICollectionViewCell

@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation LLDPlatformCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = self.contentView.bounds;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end

@interface LLDPlatformCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, weak) NSArray<LLDPlatformDto *> *datas;
@property(nonatomic, assign) NSUInteger index;
@end

@implementation LLDPlatformCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.contentView.bounds;
}

- (void)loadData:(NSArray<LLDPlatformDto *> *)datas {
    self.datas = datas;
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LLDPlatformCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LLDPlatformCollectionCell class]) forIndexPath:indexPath];
    LLDPlatformDto *dto = self.datas[indexPath.row];
    cell.titleLabel.text = dto.name;
    cell.titleLabel.textColor = (self.index == indexPath.row) ? [UIColor redColor] : [UIColor blackColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.index = indexPath.row;
    if (self.callBack) {
        self.callBack(self.index);
    }
    [self.collectionView reloadData];
}


#pragma mark - getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(80, [LLDPlatformCell height]);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [LLDPlatformCell height]) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[LLDPlatformCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([LLDPlatformCollectionCell class])];
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

+ (CGFloat)height {
    return 60;
}


@end
