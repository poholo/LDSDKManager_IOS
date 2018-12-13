
# LDSDKManager_IOS
主要聚合QQ、微信、微博、支付宝等第三方库，抽象封装分享、授权、支付功能，以便其他开发者能快速接入。

```xml
source 1.0.3 版本基于 Lede-Inc/LDSDKManager_IOS, 网易团队对此项目已经不在维护，联系无果后，基于业务需求，逐渐演化出现在的版本。
```

## 集成方式

```
pod 'LDSDKManager'
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
</array>
```

## LDSDKManager的框架层次
LDSDKManager目前有五个submodule，分别是CoreService，QQService，WechatService，AlipayService。后边四个分别整合了QQSDK、微信SDK、支付宝SDK，他们都依赖于CoreService。

整合的优点在于：
1. 开发者无需调用SDK头文件，方便SDK的升级；

2. 易拓展，可以通过增加模块使得开发者无需修改代码即可支持更多的第三方SDK。


## 如何新增一个第三方SDK

1. 如果是已有的模块，导入子模块即可；
2. 如果要导入新的SDK，实现步骤：
SDKManager中LDSDKPlatformType添加相应type；
建立新文件夹，导入SDK文件，编写代码实现[SDKServiceInterface文件夹](LDSDKManager/CoreService/SDKServiceInterface) 中的protocol;
修改SDKServiceConfig.plist，添加新SDK支持的Service以及对应实现的文件名。

## updates
```xml

1.0.4 更新依赖方式（pod版），支持最新的sdk

1.0.5 a.三方库均用官方和poholo维护的三方库
      b.更新sdk，增加更多的分享类型，以及平台特性。
      c.授权-微博增加用户信息获取
```

## Author
littleplayer mailjiancheng@163.com

## License

LDSDKManager is available under the MIT license. See the LICENSE file for more info.
