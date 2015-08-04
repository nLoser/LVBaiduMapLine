//
//  AppDelegate.m
//  BaiduMapLine
//
//  Created by LV on 15/8/2.
//  Copyright (c) 2015年 linkdow. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+LVSet.h"
#import <BaiduMapAPI/BMapKit.h>
#import "LVViewController.h"

NSString * const BaiduMapKey  = @"FKLGd0XldzKhMQh82j0RAOZG";

@interface AppDelegate ()<BMKGeneralDelegate>

@property (nonatomic, strong) BMKMapManager * mapManager;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _mapManager = [[BMKMapManager alloc] init];
    [_mapManager start:BaiduMapKey generalDelegate:self];

    NSString * oneStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"ONE"];
    NSString * TwoStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"TWO"];
    if (!oneStr&&!TwoStr)
    {
        NSFileManager * manager = [[NSFileManager alloc] init];
        NSString * docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * dataStr = [docStr stringByAppendingString:@"/coreLocation.txt"];
        NSString * dataStr2 = [docStr stringByAppendingString:@"/coreBluetooth.txt"];
        
        BOOL res = [manager createFileAtPath:dataStr contents:nil attributes:nil];
        BOOL res2 = [manager createFileAtPath:dataStr2 contents:nil attributes:nil];
        if (res&&res2)
        {
            [[NSUserDefaults standardUserDefaults] setValue:dataStr forKey:@"ONE"];
            [[NSUserDefaults standardUserDefaults] setValue:dataStr2 forKey:@"TWO"];
        }else
        {
            NSLog(@"创建文件失败");
        }
    }
    
    [self initlizationSet];
    
    LVViewController * vc = [[LVViewController alloc] init];
    self.window.rootViewController = vc;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
