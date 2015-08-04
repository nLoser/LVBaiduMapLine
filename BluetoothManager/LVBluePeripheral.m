//
//  LVBluePeripheral.m
//  Scanperipheral
//
//  Created by LV on 15/7/17.
//  Copyright (c) 2015年 linkdow. All rights reserved.
//

#import "LVBluePeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface LVBluePeripheral ()<CBPeripheralManagerDelegate>

@end

@implementation LVBluePeripheral
{
    CBPeripheralManager * _peripheralManager;
    
    CBMutableService * _peripheralService;
    
    CBMutableCharacteristic * _peripheralCharacteristic;
}

#pragma mark - Peripheral delegate Action

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state != CBPeripheralManagerStatePoweredOn)
    {
        return;
    }
    
    _peripheralCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"2121"] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    _peripheralService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:@"1212"] primary:YES];
    _peripheralService.characteristics = @[_peripheralCharacteristic];
    
    [_peripheralManager addService:_peripheralService];
    
    NSString * locname = [[NSUserDefaults standardUserDefaults] objectForKey:@"BLUEUUID"];
    
    [_peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:@"1212"]],CBAdvertisementDataLocalNameKey:[NSString stringWithFormat:@"linkdow_%@",locname]}];
}

#pragma mark - create notity

- (void)createAndNotify
{
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

#pragma mark - Life Cycle

+ (id)shareInstance
{
    static id instance = nil;
    
    if (instance == nil)
    {
        instance = [[LVBluePeripheral alloc] init];
    }
    return instance;
}

@end
