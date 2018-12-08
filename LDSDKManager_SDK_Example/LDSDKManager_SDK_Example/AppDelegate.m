//
//  AppDelegate.m
//  LDSDKManager
//
//  Created by majiancheng on 2018/11/29.
//  Copyright © 2018 张海洋. All rights reserved.
//

#import "AppDelegate.h"

#import "LDSDKManager.h"
#import "LLDViewController.h"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


    NSArray *regPlatformConfigList = @[
            @{
                    LDSDKConfigAppIdKey: @"wxd6b4d4ada6beb442",
                    LDSDKConfigAppSecretKey: @"a2be3d08a304c26d1e538cd3f02e5362",
                    LDSDKConfigAppDescriptionKey: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                    LDSDKConfigAppPlatformTypeKey: @(LDSDKPlatformWeChat)
            },
            @{
                    LDSDKConfigAppIdKey: @"1106976672",
                    LDSDKConfigAppSecretKey: @"D76uzXaBnfC4hxyO",
                    LDSDKConfigAppPlatformTypeKey: @(LDSDKPlatformQQ)
            },

            @{
                    LDSDKConfigAppSchemeKey: @"alipay://",
                    LDSDKConfigAppPlatformTypeKey: @(LDSDKPlatformAliPay)
            },
            @{
                    LDSDKConfigAppIdKey: @"3780912137",
                    LDSDKConfigAppSecretKey: @"9b005c1c44deeb4b8c58f71a447ed780",
                    LDSDKConfigAppPlatformTypeKey: @(LDSDKPlatformWeibo)
            },
    ];


    [[LDSDKManager share] registerWithPlatformConfigList:regPlatformConfigList];

    LLDViewController *view = [[LLDViewController alloc] init];
    self.window.rootViewController = view;
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL success = [[LDSDKManager share] handleURL:url];
    return success;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL success = [[LDSDKManager share] handleURL:url];
    return success;
}


@end
