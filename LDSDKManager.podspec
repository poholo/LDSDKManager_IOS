Pod::Spec.new do |s|
    s.name             = 'LDSDKManager'
    s.version          = '1.0.8'
    s.summary          = 'iOS第三方聚合库'
    s.description      = '聚合QQ、微信、微博、支付宝、钉钉、Telegram等第三方库，抽象封装分享、授权、支付功能，以便其他开发者能快速接入。'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'littleplayer' => 'mailjiancheng@163.com' }
    s.homepage         = 'https://github.com/poholo/LDSDKManager_IOS'
    s.source           = { :git => "https://github.com/poholo/LDSDKManager_IOS.git", :tag => "#{s.version}" }

    s.platform     = :ios, '8.0'
    s.requires_arc = true

    s.default_subspec = 'All'

    #组件对外提供服务接口
    s.subspec 'Core' do |ss|
        ss.source_files = 'SDK/Core/**/*.{h,m,mm}',
                          'SDK/Core/*.{h,m,mm}'
        ss.public_header_files = 'SDK/Core/*.h'
        ss.public_header_files = 'SDK/Core/**/*.h'
        ss.dependency 'MCBase/Dto'
        ss.dependency 'MCBase/Log'
    end
    
    #QQ平台SDK集成
    s.subspec 'QQ' do |ss|
        ss.source_files = 'SDK/QQPlatform/*.{h,m,mm}'
        ss.public_header_files = 'SDK/QQPlatform/*.h'
        ss.dependency 'LDSDKManager/Core'
        ss.dependency 'MCTencentOpenAPI'
    end

    #微信平台SDK集成
    s.subspec 'Wechat' do |ss|
        ss.source_files = 'SDK/WechatPlatform/**/*.{h,m,mm}',
                          'SDK/WechatPlatform/*.{h,m,mm}'
        ss.public_header_files = 'SDK/WechatPlatform/*.h'
        ss.dependency 'LDSDKManager/Core'
        ss.dependency 'WechatOpenSDK'
    end

    #新浪微博平台SDK集成
    s.subspec 'Weibo' do |ss|
        ss.source_files = 'SDK/WeiboPlatform/*{h,m,mm}'
        ss.public_header_files = 'SDK/WeiboPlatform/*.h'
        ss.dependency 'LDSDKManager/Core'
        ss.dependency 'Weibo_SDK'
    end

    #支付宝平台SDK集成
    s.subspec 'Alipay' do |ss|
        ss.source_files = 'SDK/AlipayPlatform/*{h,m,mm}'
        ss.public_header_files = 'SDK/AlipayPlatform/*.h'
        ss.dependency 'AlipaySDK-iOS'
        ss.dependency 'LDSDKManager/Core'
        ss.dependency 'APOpenSdk'
    end

    #DingTalk_SDK集成
    s.subspec 'DingTalk' do |ss|
        ss.source_files = 'SDK/DingTalkPlatform/*{h,m,mm}'
        ss.public_header_files = 'SDK/DingTalkPlatform/*.h'
        ss.dependency 'LDSDKManager/Core'
        ss.dependency 'MCDingTalk'
    end

    #Telegram
    s.subspec 'Telegram' do |ss|
        ss.source_files = 'SDK/TelegramPlatform/*{h,m,mm}'
        ss.public_header_files = 'SDK/TelegramPlatform/*.h'
        ss.dependency 'LDSDKManager/Core'
    end

    s.subspec 'All' do |all|
        all.dependency 'LDSDKManager/QQ'
        all.dependency 'LDSDKManager/Wechat'
        all.dependency 'LDSDKManager/Weibo'
        all.dependency 'LDSDKManager/Alipay'
        all.dependency 'LDSDKManager/DingTalk'
        all.dependency 'LDSDKManager/Telegram'
    end
    
    s.xcconfig = {
       'VALID_ARCHS' => 'arm64 x86_64',
       'USER_HEADER_SEARCH_PATHS' => '${PROJECT_DIR}/Pods/**'
    }
    s.pod_target_xcconfig = {
          'VALID_ARCHS' => 'arm64 x86_64'
    }

    s.frameworks = 'UIKit', 'CoreGraphics', 'Foundation'

end