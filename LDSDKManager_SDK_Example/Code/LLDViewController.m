//
//  LDViewController.m
//  LDSDKManager
//
//  Created by 张海洋 on 08/19/2015.
//  Copyright (c) 2015 张海洋. All rights reserved.
//

#import "LLDViewController.h"

#import <MCBase/MCLog.h>
#import "LDSDKAuthService.h"
#import "LDSDKManager.h"

#import "LLDViewDataVM.h"
#import "LLDPlatformDto.h"
#import "LLDPlatformCell.h"
#import "LDSDKPayService.h"

@interface LLDViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UILabel *infoLabel;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) LLDViewDataVM *dataVM;

@end

@implementation LLDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"LDSDKManager";

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.infoLabel];

    [self.dataVM prepareData];
    [self.tableView reloadData];
}

#pragma mark - getter

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) return 1;
    return 44;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return nil;
    UITableViewHeaderFooterView *headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];
    LLDCategoriryDto *categoriryDto = [self.dataVM categroryAtIndex:section - 1];
    headerFooterView.textLabel.text = categoriryDto.name;
    return headerFooterView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LLDPlatformCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LLDPlatformCell class]) forIndexPath:indexPath];
        [cell loadData:self.dataVM.dataList];
        __weak typeof(self) weakSelf = self;
        cell.callBack = ^(NSUInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.dataVM.platformIndx = index;
            [strongSelf.tableView reloadData];
        };
        return cell;
    }
    LLDShareInfoDto *infoDto = [self.dataVM shareInfoDtoAtCateIndex:indexPath.section - 1 index:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = infoDto.name;
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LLDPlatformDto *platformDto = self.dataVM.curPlatformDto;
    return platformDto.cates.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    LLDPlatformDto *platformDto = self.dataVM.curPlatformDto;
    LLDCategoriryDto *categoriryDto = platformDto.cates[section - 1];
    return categoriryDto.shareInfos.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return;
    LLDCategoriryDto *categoriryDto = [self.dataVM categroryAtIndex:indexPath.section - 1];

    if (categoriryDto.type == 99) {
        if (indexPath.row == 0) {
            [self authLogin];
        } else if (indexPath.row == 1) {
            [self authQRLogin];
        } else if (indexPath.row == 2) {
            [self authLogout];
        }
        return;
    } else if (categoriryDto.type == 98) {
        [self action2Pay:categoriryDto];
    }

    LLDShareInfoDto *infoDto = [self.dataVM shareInfoDtoAtCateIndex:indexPath.section - 1 index:indexPath.row];
    [self share:infoDto cate:categoriryDto];
}

- (void)authLogin {
    id <LDSDKAuthService> authService = [[LDSDKManager share] authService:self.dataVM.curPlatformDto.type];
    __weak typeof(self) weakSelf = self;
    [authService authPlatformCallback:^(LDSDKLoginCode code, NSError *error, NSDictionary *oauthInfo, NSDictionary *userInfo) {
                MCLog(@"[Login] %@ %@ %@", oauthInfo, userInfo, error);
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (code == LDSDKLoginSuccess) {
                    if (userInfo == nil && oauthInfo != nil) {
                        [strongSelf.infoLabel setText:@"授权成功"];
                    } else {
                        NSString *alert = [NSString stringWithFormat:@"昵称：%@  头像url：%@",
                                                                     userInfo[LDSDK_NICKNAME_KEY],
                                                                     userInfo[LDSDK_AVATARURL_KEY]];
                        NSLog(@"message = %@", alert);
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登陆成功"
                                                                            message:alert
                                                                           delegate:self
                                                                  cancelButtonTitle:@"cancel"
                                                                  otherButtonTitles:@"ok", nil];
                        [alertView show];
                    }
                } else {
                    [strongSelf.infoLabel setText:error.userInfo[kErrorMessage]];
                }
            }
                                  ext:@{LDSDKAuthUrlKey:
                                          @"apiname=com.alipay.account.auth&app_id=2018081361035295&app_name=mc&auth_type=AUTHACCOUNT&biz_type=openservice&method=alipay.open.auth.sdk.code.get&pid=2088812474291242&product_id=APP_FAST_LOGIN&scope=kuaijie&sign_type=RSA2&target_id=bSLlYCJNFvoQkSJkU1552896876841&sign=UffKQaCgHFl9d2Quiwws05PlEu6Iz0hvhoEXcO%2BMpyLcEGXYO%2FIKkZ0bn9KqO2be8kE8TQb7zftIvPFXd4dkSfvsZY%2BsgQQYhiB5IAPGN2xYe3nzfnDIUXD2CsiqRaU85rxOLmslS%2BK1ZwjRxX0vj0r%2B7i480fXzVufzLJus6R4UMHg6AQ%2Bd5faLGMcPx5mDa0o7TNhjABruSHya3kyWmutlmpNu%2Bari64OZuhinsMlqo4CJj3EmqOly13nbl7A6H2oARFcs29M7R1agSe%2Batlvt5ZnmKrUNT%2BCJV8LITQFs3SCEFSCw5FPzADWeEMzvbH%2BHckBShYso2PRWCxiZtg%3D%3D",
                                          LDSDKAuthSchemaKey: @"alipay://"}];
}

- (void)authQRLogin {
    id <LDSDKAuthService> authService = [[LDSDKManager share] authService:self.dataVM.curPlatformDto.type];
    __weak typeof(self) weakSelf = self;
    [authService authPlatformQRCallback:^(LDSDKLoginCode code, NSError *error, NSDictionary *oauthInfo, NSDictionary *userInfo) {
        MCLog(@"[Login] %@ %@ %@", oauthInfo, userInfo, error);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (code == LDSDKLoginSuccess) {
            if (userInfo == nil && oauthInfo != nil) {
                [strongSelf.infoLabel setText:@"授权成功"];
            } else {
                NSString *alert = [NSString stringWithFormat:@"昵称：%@  头像url：%@",
                                                             userInfo[LDSDK_NICKNAME_KEY],
                                                             userInfo[LDSDK_AVATARURL_KEY]];
                NSLog(@"message = %@", alert);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"登陆成功"
                                                                    message:alert
                                                                   delegate:self
                                                          cancelButtonTitle:@"cancel"
                                                          otherButtonTitles:@"ok", nil];
                [alertView show];
            }
        } else {
            [strongSelf.infoLabel setText:error.userInfo[kErrorMessage]];
        }
    }                               ext:nil];
}

- (void)authLogout {
    id <LDSDKAuthService> authService = [[LDSDKManager share] authService:self.dataVM.curPlatformDto.type];
    __weak typeof(self) weakSelf = self;
    [authService authLogoutPlatformCallback:^(LDSDKLoginCode code, NSError *error, NSDictionary *oauthInfo, NSDictionary *userInfo) {
        MCLog(@"[Login] %@ %@ %@", oauthInfo, userInfo, error);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (code == LDSDKLoginSuccess) {
            [strongSelf.infoLabel setText:@"退出登录成功"];
        } else {
            [strongSelf.infoLabel setText:error.userInfo[kErrorMessage]];
        }
    }];
}

- (void)share:(LLDShareInfoDto *)shareInfoDto cate:(LLDCategoriryDto *)categoriryDto {
    __weak typeof(self) weakSelf = self;
    NSDictionary *shareDict = [self.dataVM shareContentWithShareType:shareInfoDto.type
                                                         shareMoudle:categoriryDto.type
                                                            callBack:^(LDSDKErrorCode errorCode, NSError *error) {
                                                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                                                strongSelf.infoLabel.text = [NSString stringWithFormat:@"Code:%zd Result:%@", error.code, error.userInfo[kErrorMessage]];
                                                                strongSelf.infoLabel.textColor = errorCode == LDSDKSuccess ? [UIColor greenColor] : [UIColor redColor];
                                                            }];
    [[[LDSDKManager share] shareService:self.dataVM.curPlatformDto.type] shareContent:shareDict];
}

- (void)action2Pay:(LLDCategoriryDto *)categoriryDto {
    id <LDSDKPayService> payService = [[LDSDKManager share] payService:self.dataVM.curPlatformDto.type];
    __weak typeof(self) weakSelf = self;

#if 1
    {
        //alipay
        NSString *orderInfo = @"alipay_sdk=alipay-sdk-java-3.0.52.ALL&app_id=2019021863246757&biz_content=%7B%22body%22%3A%2210000%E5%83%8F%E7%B4%A0%22%2C%22out_trade_no%22%3A%22040215341515541%22%2C%22passback_params%22%3A%225ca310778fc839662f756450%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22subject%22%3A%22%E8%B1%A1%E7%B4%A0%E5%85%85%E5%80%BC%22%2C%22timeout_express%22%3A%2230m%22%2C%22total_amount%22%3A%220.01%22%7D&charset=UTF-8&format=json&method=alipay.trade.app.pay&notify_url=http%3A%2F%2Fwwwtest.54a64.cn%2F%2Fapi%2Fv1%2Fpay%2Falipay%2Fcallback.json&sign=Qq33pY8IrOvqzK%2B9GFfNZqgpiAPC6imj%2Bh1nyzJI8Cc0x%2BOajBC1gXTyltpqEITxsofa269oe9mh3l3cBSWQ7IHlpzPkYqb7ekZ8FGe3LW%2Btmo9yhBouGQyutvfgRTH3SCQ%2Btb1FK3bSYiu8DnYyaHj64fh%2Few%2B43hUr8%2BnJuo6fEWkzfqfmyAiNsKZx7kkeEdlJFD8IQmKgNJni8yX7EdxdhJg0QacH%2F%2FxQRcJ7zEVRE%2FnV%2FQ58Pk3MLRl0oPGwg7R6lZrIvqu1wbganSViPKWJkLIHZ8ThJ1GCJ81V%2FEqCqD8BajeSc0cL8YfR4Lih%2B8c3Kh3HLE5WbtqwgD4AEA%3D%3D&sign_type=RSA2&timestamp=2019-04-02+15%3A34%3A15&version=1.0";
        [payService payOrder:orderInfo
                    callback:^(id result, NSError *error) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        if (error) {
                            strongSelf.infoLabel.text = [NSString stringWithFormat:@"Code:%zd Result:%@", error.code, error.userInfo[kErrorMessage]];
                            strongSelf.infoLabel.textColor = [UIColor redColor];
                        } else {
                            //支付结果信息
                            /*
                             * {
                                    memo = "";
                                    result = "{\"alipay_trade_app_pay_response\":{\"code\":\"10000\",\"msg\":\"Success\",\"app_id\":\"2019021863246757\",\"auth_app_id\":\"2019021863246757\",\"charset\":\"UTF-8\",\"timestamp\":\"2019-04-02 16:23:31\",\"out_trade_no\":\"040215341515541\",\"total_amount\":\"0.01\",\"trade_no\":\"2019040222001427751034899210\",\"seller_id\":\"2088431140429592\"},\"sign\":\"Cvj8szxrdNHN6I+B76cl6rJsOX1BNz/8MUANiv/rgHm0c53KVCBidqFaX9P6cZAWxDDVHflAt3HN+siEq9xcS44dK5mnFagkaAMsR6CD4CcVqSHb/P5qLShjuvD8QlFEuEZT8pgZlb+03xAPYx4JzbzXMEYdogb6gWRH9v14TNAXoyzTxWj0EdtLKA58Ml5cJMAnIUQGNU48hwXoELem5vLA2AWFzknRDIS/p84kx9L4tKqDG/BLT4AgqN9pjCXAqu4+qMG6k7H6npFeVoNXROIkuKmKTsdO6ESRA5N0YhjAoNrIN3LMFKHcrOiB+gaQoOjoYYu21sFaxfvPNF7i5g==\",\"sign_type\":\"RSA2\"}";
                                    resultStatus = 9000;
                                }
                             */
                            strongSelf.infoLabel.text = @"支付成功";
                            strongSelf.infoLabel.textColor = [UIColor greenColor];
                        }
                    }];
    }

#else

    {
        //wechatpay

    }
#endif
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"click");
    alertView = nil;
}

#pragma mark - getter

- (LLDViewDataVM *)dataVM {
    if (!_dataVM) {
        _dataVM = [LLDViewDataVM new];
    }
    return _dataVM;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [UILabel new];
        _infoLabel.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 60, CGRectGetWidth(self.view.frame), 60);
        _infoLabel.backgroundColor = [UIColor orangeColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.textColor = [UIColor blackColor];
        _infoLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    return _infoLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 60) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        [_tableView registerClass:[LLDPlatformCell class] forCellReuseIdentifier:NSStringFromClass([LLDPlatformCell class])];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];

    }
    return _tableView;
}

@end
