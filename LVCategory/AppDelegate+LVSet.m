//
//  AppDelegate+LVSet.m
//  Scanperipheral
//
//  Created by LV on 15/7/17.
//  Copyright (c) 2015年 linkdow. All rights reserved.
//

#import "AppDelegate+LVSet.h"
#import "LVTools.h"
@implementation AppDelegate (LVSet)

- (void)initlizationSet
{
    NSString * isLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"];
    if (!isLogin)
    {
        //nil
        NSString * bluetoothUUID = [LVTools GetUUIDString];
        [[NSUserDefaults standardUserDefaults] setValue:bluetoothUUID forKey:@"BLUEUUID"];
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"isLogin"];
        //5F9CD991-F9A8-4C27-BC8A-D58741C055FE
    }
}

//- (void)initCreateFile
//{
//    NSString * isAppOne = [[NSUserDefaults standardUserDefaults] objectForKey:kLVOne];
//    
//    if (!isAppOne)
//    {
//        NSString * documentsPath = [LVTools GetDocdir];
//        NSFileManager * fileManager = [NSFileManager defaultManager];
//        NSString * testPath = [documentsPath stringByAppendingPathComponent:@"BlueTooth.txt"];
//        BOOL res = [fileManager createFileAtPath:testPath contents:nil attributes:nil];
//        if (res)
//        {
//            NSLog(@"文件创建成功:%@",testPath);
//        }else
//        {
//            NSLog(@"文件创建失败");
//        }
//        [[NSUserDefaults standardUserDefaults] setValue:testPath forKey:kLVOne];
//    }
//
//}



@end
