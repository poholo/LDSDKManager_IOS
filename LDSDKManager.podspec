Pod::Spec.new do |s|
    s.name             = 'LDSDKManager'
    s.version          = '1.0.5'
    s.summary          = 'iOS第三方聚合库'
    s.description      = '主要聚合QQ、微信、微博、支付宝等第三方库，抽象封装分享、授权、支付功能，以便其他开发者能快速接入。'
    s.license          = 'MIT'
    s.author           = { 'littleplayer' => 'mailjiancheng@163.com' }
    s.homepage         = 'https://github.com/poholo/LDSDKManager_IOS'
    s.source           = { :git => "https://github.com/poholo/PlayerKit.git", :tag => "#{s.version}" }

    s.platform     = :ios, '8.0'
    s.requires_arc = true

    #组件对外提供服务接口
    s.subspec 'CoreService' do |ss|
        ss.public_header_files = 'LDSDKManager/CoreService/*.h'
        ss.source_files = 'LDSDKManager/CoreService/**/*.{h,m,mm}'
                          'LDSDKManager/CoreService/*.{h,m,mm}'
    end

    #QQ平台SDK集成
    s.subspec 'QQPlatform' do |ss|
        ss.public_header_files = 'LDSDKManager/QQPlatform/*.h'
        ss.source_files = 'LDSDKManager/QQPlatform/*.{h,m,mm}'
        ss.dependency 'LDSDKManager/CoreService'
    end

    #微信平台SDK集成
    s.subspec 'WechatPlatform' do |ss|
        ss.public_header_files = 'LDSDKManager/WechatPlatform/*.h'
        ss.source_files = 'LDSDKManager/WechatPlatform/**/*.{h,m,mm}'
                          'LDSDKManager/WechatPlatform/*.{h,m,mm}'
        ss.dependency 'LDSDKManager/CoreService'
    end

    #新浪微博平台SDK集成
    s.subspec 'WeiboPlatform' do |ss|
        ss.public_header_files = 'LDSDKManager/WeiboPlatform/*.h'
        ss.source_files = 'LDSDKManager/WeiboPlatform/*{h,m,mm}'
        ss.dependency 'LDSDKManager/CoreService'
    end

    #支付宝平台SDK集成
    s.subspec 'AlipayPlatform' do |ss|
        ss.public_header_files = 'LDSDKManager/AlipayPlatform/*.h'
        ss.source_files = 'LDSDKManager/AlipayPlatform/*{h,m,mm}'
        ss.dependency 'LDSDKManager/CoreService'
    end

    s.frameworks = 'UIKit', 'CoreGraphics', 'Foundation'
    s.dependency 'MCTencentOpenAPI'
    s.dependency 'WechatOpenSDK'
    s.dependency 'Weibo_SDK'
    s.dependency 'AlipaySDK-iOS'

end