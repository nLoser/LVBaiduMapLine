//
//  LVBlueCentral.h
//  Scanperipheral
//
//  Created by LV on 15/7/17.
//  Copyright (c) 2015年 linkdow. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

typedef void(^BLEListDic)(NSMutableDictionary *);

@interface LVBlueCentral : NSObject

@property (nonatomic, copy) BLEListDic ListDic;

/// 是否开始写入数据
@property (nonatomic, assign) BOOL isWrite;

+ (instancetype)sharedInstance;

- (void)startCreateAndScan;

@end
