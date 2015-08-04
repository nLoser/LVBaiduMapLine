
//
//  LVBlueCentral.m
//  Scanperipheral
//
//  Created by LV on 15/7/17.
//  Copyright (c) 2015年 linkdow. All rights reserved.
//

#import "LVBlueCentral.h"

@interface LVBlueCentral ()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    
    CBCentralManager * _manager;
    
    NSMutableDictionary * _dicoverDataDic;
}

@property (nonatomic, strong)NSString * dataPath;
@property (nonatomic, strong)NSFileHandle * handle;
@end

@implementation LVBlueCentral

#pragma mark - CBCentral Deleagte Action

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString * uuid = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    if ([[uuid substringToIndex:8] isEqualToString:@"linkdow_"])
    {
        uuid = [uuid substringFromIndex:8];
        if (RSSI&&self.isWrite)
        {
            
            NSDate * since1970 = [NSDate date];
            register NSInteger num = [since1970 timeIntervalSince1970];
            
            NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:_dataPath];
            
            [handle seekToEndOfFile];
            register NSString * dataContent = [NSString stringWithFormat:@"\n%@ %@ %ld",uuid,RSSI,(long)num];
            NSLog(@"%@",dataContent);
            NSData * data = [dataContent dataUsingEncoding:NSUTF8StringEncoding];
            [handle writeData:data];
        }
    }
    
    
}

#pragma mark - start Scan

- (void)startCreateAndScan
{
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.isWrite = NO;
    _dataPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"TWO"];
    _handle = [NSFileHandle fileHandleForWritingAtPath:_dataPath];
}



#pragma mark - Life Cycle

+ (instancetype)sharedInstance
{
    static LVBlueCentral * instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LVBlueCentral alloc] init];
    });
    return instance;
}

@end
