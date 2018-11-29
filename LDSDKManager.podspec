Pod::Spec.new do |s|
    s.name             = 'LDSDKManager'
    s.version          = '1.0.4'
    s.summary          = '第三方SDK统一管理组件'
    s.description      = '对应用中集成的第三方SDK（目前包括QQ,微信,易信,支付宝）进行集中管理，按照功能（目前包括第三方登录,分享,支付）开放给各个产品使用。通过接口的方式进行产品集成，方便对第三方SDK进行升级维护。'
    s.license          = 'MIT'
    s.author           = { 'littleplayer' => 'mailjiancheng@163.com' }
    #origin athor {张海洋' => 'zhanghaiyang@corp.netease.com' }
    s.homepage         = 'https://github.com/poholo/LDSDKManager_IOS'
    s.source           = { :git => 'https://github.com/poholo/LDSDKManager_IOS.git', :tag => s.version.to_s }

    s.platform     = :ios, '8.0'
    s.requires_arc = true

    #组件对外提供服务接口
    s.subspec 'CoreService' do |ss|
        ss.public_header_files = 'LDSDKManager/CoreService/LDSDKManager.h',
                                 'LDSDKManager/CoreService/LDSDKConfig.h',
                                 'LDSDKManager/CoreService/SDKServiceInterface/*.h'
        ss.source_files = 'LDSDKManager/CoreService/**/*.{h,m,mm}'
        ss.resources = ['LDSDKManager/CoreService/SDKServiceConfig.plist']
    end

    #QQ平台SDK集成
    s.subspec 'QQPlatform' do |ss|
        ss.public_header_files = 'LDSDKManager/QQPlatform/*.h'
        ss.source_files = 'LDSDKManager/QQPlatform/*.{h,m,mm}'
        ss.dependency 'MCTencentOpenAPI', '3.3.3'
        ss.dependency 'LDSDKManager/CoreService'
    end

    #微信平台SDK集成
    s.subspec 'WechatPlatform' do |ss|
        ss.public_header_files = 'LDSDKManager/WechatPlatform/*.h'
        ss.source_files = 'LDSDKManager/WechatPlatform/**/*.{h,m,mm}'
                          'LDSDKManager/WechatPlatform/*.{h,m,mm}'
        ss.dependency 'SNWeChatSDK'
        ss.dependency 'LDSDKManager/CoreService'
    end

    #易信平台SDK集成
    s.subspec 'YixinPlatform' do |ss|
        ss.public_header_files = 'LDSDKManager/YixinPlatform/YiXinSDK/*.h'
        ss.source_files = 'LDSDKManager/YixinPlatform/**/*.{h,m,mm}'
        ss.vendored_library = 'LDSDKManager/YixinPlatform/YiXinSDK/libYixinSDK.a'
        ss.dependency 'LDSDKManager/CoreService'
    end

    #新浪微博平台SDK集成
    s.subspec 'WeiboPlatform' do |ss|
        ss.public_header_files = 'LDSDKManager/WeiboPlatform/*.h'
        ss.source_files = 'LDSDKManager/WeiboPlatform/*{h,m,mm}'
        ss.dependency 'Weibo_SDK', '3.2.3'
        ss.dependency 'LDSDKManager/CoreService'
    end

    #支付宝平台SDK集成
    s.subspec 'AlipayPlatform' do |ss|
        ss.public_header_files = 'LDSDKManager/AlipayPlatform/*.h'
        ss.source_files = 'LDSDKManager/AlipayPlatform/*{h,m,mm}'
        ss.dependency 'AlipaySDK-iOS'
        ss.dependency 'LDSDKManager/CoreService'
    end

    s.frameworks = 'UIKit', 'CoreGraphics', 'Foundation'

end