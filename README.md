# LDSDKManager_IOS
聚合QQ、微信、微博、支付宝、钉钉、Telegram等第三方库，抽象封装分享、授权、支付功能，以便其他开发者能快速接入。

## updates
```text

1.0.4 更新依赖方式（pod版），支持最新的sdk

1.0.5 a.三方库均用官方和poholo维护的三方库
      b.更新sdk，增加更多的分享类型，以及平台特性。
      c.授权-微博增加用户信息获取
1.0.8 support MCBase/Dto & Log
1.0.9 support Wechat & Alipay 支付
```


## 集成方式

```
pod 'LDSDKManager'

```

默认配置LDSDKManager集成的所有库，如果你有选择性的集成，请按照如下集成
```ruby

pod 'LDSDKManager/QQ'
pod 'LDSDKManager/Wechat'
pod 'LDSDKManager/Weibo'
pod 'LDSDKManager/Alipay'
pod 'LDSDKManager/DingTalk'
pod 'LDSDKManager/Telegram'

or 
pod 'LDSDKManager/All'

```



## 集成步骤

#### 1.注册第三方keys
```objectivec

     NSArray *regPlatformConfigList = @[
    	@{
    	    LDSDKConfigAppIdKey:@"微信appid",
    	    LDSDKConfigAppSecretKey:@"微信appsecret",
    	    LDSDKConfigAppDescriptionKey:@"应用描述",
    	    LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformWeChat)
    	},
    	@{
    	    LDSDKConfigAppIdKey:@"QQ appid",
    	    LDSDKConfigAppSecretKey:@"qq appkey",
    	    LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformQQ)
    	},
    	@{
    	    LDSDKConfigAppIdKey:@"易信appid",
    	    LDSDKConfigAppSecretKey:@"易信appsecret",
    	    LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformYiXin)
    	},
    	@{
    	    LDSDKConfigAppSchemeKey:@"支付宝 appScheme",
            LDSDKConfigAppPlatformTypeKey:@(LDSDKPlatformAliPay)
    	},
    	];
    	[[LDSDKManager share] registerWithPlatformConfigList:regPlatformConfigList];

```
    	

#### 2.在Appdelegate中
```objectivec
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL success = [[LDSDKManager share] handleURL:url];
    return success;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL success = [[LDSDKManager share] handleURL:url];
    return success;
}

```

#### 3.分享能力和授权能力
```objectivec
请参照LDSDKManager-SDK-Example & 
```

#### 4.其他配置

###### 4.1 info.plist add schemes
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>wechat</string>
    <string>weixin</string>
    <string>sinaweibohd</string>
    <string>sinaweibo</string>
    <string>sinaweibosso</string>
    <string>weibosdk</string>
    <string>weibosdk2.5</string>
    <string>mqqapi</string>
    <string>mqq</string>
    <string>mqqOpensdkSSoLogin</string>
    <string>mqqconnect</string>
    <string>mqqopensdkdataline</string>
    <string>mqqopensdkgrouptribeshare</string>
    <string>mqqopensdkfriend</string>
    <string>mqqopensdkapi</string>
    <string>mqqopensdkapiV2</string>
    <string>mqqopensdkapiV3</string>
    <string>mqzoneopensdk</string>
    <string>wtloginmqq</string>
    <string>wtloginmqq2</string>
    <string>mqqwpa</string>
    <string>mqzone</string>
    <string>mqzonev2</string>
    <string>mqzoneshare</string>
    <string>wtloginqzone</string>
    <string>mqzonewx</string>
    <string>mqzoneopensdkapiV2</string>
    <string>mqzoneopensdkapi19</string>
    <string>mqzoneopensdkapi</string>
    <string>mqqbrowser</string>
    <string>mttbrowser</string>
    <string>waquchild</string>
    <string>tencentapi.qq.reqContent</string>
    <string>tencentapi.qzone.reqContent</string>
    <string>dingtalk</string>
    <string>dingtalk-open</string>
    <string>dingtalk-sso</string>
</array>
```

###### 4.1 info.plist add URL types
```xml
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>com.poholo.MCShare</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>mcshare</string>
		</array>
	</dict>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>weixin</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>xxxxx</string>
		</array>
	</dict>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>tencent</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>xxxxx</string>
		</array>
	</dict>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLName</key>
		<string>weibo</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>sina.xxxxxxxx</string>
		</array>
	</dict>
	<dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>alipayShare</string>
        <key>CFBundleURLSchemes</key>
        <array>
        	<string>apxxxxxxxx</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>dingtalk</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>dingoak5hqhuvmpfhpnjvt</string>
        </array>
    </dict>

</array>
```


#### 5 Wechat & Alipay 支付

```objectivec
  id <LDSDKPayService> payService = [[LDSDKManager share] payService:self.dataVM.curPlatformDto.type];
    __weak typeof(self) weakSelf = self;

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


    {
        //wechatpay

        NSDictionary *dict = @{
                @"partnerId": @"1524065151",
                @"prepayId": @"wx02165310195992877a8ffe572614495967",
                @"packageValue": @"Sign=WXPay",
                @"nonceStr": @"XnRFNB3DgrxQ8BtC",
                @"timeStamp": @"1554195190",
                @"sign": @"FC861275AB2E24EB69484641C6FCC2B7"};
        NSString *orderInfo = [dict query];
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
```

## LDSDKManager的框架层次
LDSDKManager目前有五个submodule，分别是CoreService，QQService，WechatService，AlipayService。后边四个分别整合了QQSDK、微信SDK、支付宝SDK，他们都依赖于CoreService。

整合的优点在于：
a. 开发者无需调用SDK头文件，方便SDK的升级；

b. 易拓展，可以通过增加模块使得开发者无需修改代码即可支持更多的第三方SDK。


## 如何新增一个第三方SDK

1. 如果是已有的模块，导入子模块即可；
2. 如果要导入新的SDK，实现步骤：
SDKManager中LDSDKPlatformType添加相应type；
建立新文件夹，导入SDK文件，编写代码实现[SDKServiceInterface文件夹](LDSDKManager/CoreService/SDKServiceInterface) 中的protocol;
修改SDKServiceConfig.plist，添加新SDK支持的Service以及对应实现的文件名。

## Author
littleplayer mailjiancheng@163.com

## License

LDSDKManager is available under the MIT license. See the LICENSE file for more info.
