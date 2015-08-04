//
//  ViewController.m
//  BaiduMapLine
//
//  Created by LV on 15/8/2.
//  Copyright (c) 2015年 linkdow. All rights reserved.
//

#import "LVViewController.h"
#import <BaiduMapAPI/BMKMapView.h>
#import <BaiduMapAPI/BMKPolyline.h>
#import <BaiduMapAPI/BMKPolylineView.h>
#import <BaiduMapAPI/BMKLocationService.h>
#import "JZLocationConverter.h"
#import "SVProgressHUD.h"

#import "LVBlueCentral.h"
#import "LVBluePeripheral.h"

@interface LVViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate>
{
    LVBlueCentral *_CentralManagr;
    LVBluePeripheral * _PerManager;
}
@property (nonatomic, strong)BMKMapView * mapView;
@property (nonatomic, strong)BMKPolyline *polyline;
@property (nonatomic, strong)BMKLocationService *locationService;

@property (nonatomic, strong) UITextField * locationText;
@property (nonatomic, strong) UIButton * startBtn;
@property (nonatomic, strong) UIButton * stopBtn;
@property (nonatomic, strong) UIButton * clearDataBtn;

@property (nonatomic, strong) NSString * pathStr;
@property (nonatomic, strong) NSString * pathStr2;
@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation LVViewController

#pragma mark - BMKLocationServiceDelegate

/// 处理防线变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    
}
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSDate * since1970 = [NSDate date];
    register NSInteger num = [since1970 timeIntervalSince1970];
    register NSString * dataStr = [NSString stringWithFormat:@"\n%.6f %.6f %ld",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude,(long)num];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:_pathStr];
        [handle seekToEndOfFile];
        NSData * data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        [handle writeData:data];
        
        [_dataArray addObject:userLocation.location];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initOverLine:_dataArray];
        });
    });
}

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]])
    {
        BMKPolylineView * polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [UIColor purpleColor];
        polylineView.lineWidth = 1.0;
        return polylineView;
    }
    return nil;
}

/// 初始化路线
- (void)initOverLine:(NSMutableArray *)dataArray
{
    NSInteger num = dataArray.count;
    CLLocationCoordinate2D *coors = (CLLocationCoordinate2D *)malloc(num * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i<num; i++)
    {
        CLLocation * location = dataArray[i];
        coors[i] = location.coordinate;
    }
    _polyline = [BMKPolyline polylineWithCoordinates:coors count:num];
    [_mapView setVisibleMapRect:[_polyline boundingMapRect]];
    [_mapView addOverlay:_polyline];
}

#pragma mark - Handle Action
/// 开始定位
- (void)startLocation
{
    if (_locationText.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入测试地点/环境" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:_pathStr];
    [handle seekToEndOfFile];
    NSData * data = [[NSString stringWithFormat:@"\n%@",_locationText.text] dataUsingEncoding:NSUTF8StringEncoding];
    [handle writeData:data];
    
    handle = [NSFileHandle fileHandleForWritingAtPath:_pathStr2];
    [handle seekToEndOfFile];
    [handle writeData:data];
    
    _CentralManagr.isWrite = YES;
    
    [_locationText resignFirstResponder];
    [_locationService startUserLocationService];
    
    _startBtn.userInteractionEnabled = NO;
    _stopBtn.userInteractionEnabled = YES;
    [SVProgressHUD showWithStatus:@"正在定位" maskType:SVProgressHUDMaskTypeNone];
    UIOffset offset = {0,-CGRectGetHeight(self.view.frame)/2+100};
    [SVProgressHUD setOffsetFromCenter:offset];
}

/// 停止定位
- (void)stopLocation
{
    [SVProgressHUD showSuccessWithStatus:@"停止定位" maskType:SVProgressHUDMaskTypeBlack];
    
    _CentralManagr.isWrite = NO;
    
    _stopBtn.userInteractionEnabled = NO;
    _startBtn.userInteractionEnabled = YES;
    [_locationService stopUserLocationService];
}

#pragma mark - Class Method

- (UITextField *)locationText
{
    if (!_locationText)
    {
        _locationText = [[UITextField alloc] initWithFrame:CGRectMake(30, 20, CGRectGetWidth(self.view.frame)-60, 40)];
        _locationText.placeholder = @"请输入测试地点/环境";
        _locationText.backgroundColor = [UIColor whiteColor];
        _locationText.leftViewMode = UITextFieldViewModeAlways;
        _locationText.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
        
        _locationText.layer.cornerRadius = 3;
        _locationText.layer.borderWidth = 0.4;
        _locationText.layer.borderColor = [[UIColor orangeColor] CGColor];
        _locationText.layer.masksToBounds = YES;
    }
    return _locationText;
}

- (UIButton *)startBtn
{
    if (!_startBtn)
    {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startBtn.backgroundColor = [UIColor orangeColor];
        _startBtn.frame = CGRectMake(30, CGRectGetMaxY(_locationText.frame)+10, 120, 40);
        [_startBtn setBackgroundImage:[UIImage imageNamed:@"1"] forState:UIControlStateHighlighted];
        [_startBtn setTitle:@"开始定位" forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(startLocation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (UIButton *)stopBtn
{
    if (!_stopBtn)
    {
        _stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stopBtn.backgroundColor = [UIColor orangeColor];
        _stopBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame)-30-120, CGRectGetMaxY(_locationText.frame)+10, 120, 40);
        [_stopBtn setBackgroundImage:[UIImage imageNamed:@"1"] forState:UIControlStateHighlighted];
        [_stopBtn setTitle:@"停止定位" forState:UIControlStateNormal];
        [_stopBtn addTarget:self action:@selector(stopLocation) forControlEvents:UIControlEventTouchUpInside];
        _stopBtn.userInteractionEnabled = NO;
    }
    return _stopBtn;
}

#pragma mark - 🔨 Initlization
/// 初始化蓝牙广播
- (void)initBlueweb
{
    _PerManager = [LVBluePeripheral shareInstance];
    [_PerManager createAndNotify];
    
    @try {
        _CentralManagr = [LVBlueCentral sharedInstance];
        [_CentralManagr startCreateAndScan];
    }
    @catch (NSException *exception)
    {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@",exception] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

/// 初始化地图
- (void)initMapView
{
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.frame];
    _mapView.showsUserLocation = YES;
    _mapView.showMapScaleBar = YES;
    [self.view addSubview:_mapView];
    
    _pathStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"ONE"];
    _pathStr2 = [[NSUserDefaults standardUserDefaults] valueForKey:@"TWO"];
    _dataArray = @[].mutableCopy;
}
/// 获得定位manager
- (void)initLocation
{
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
    [BMKLocationService setLocationDistanceFilter:1.0f];
    /// 初始化BMKlocationService
    _locationService = [[BMKLocationService alloc] init];
    _locationService.delegate = self;
}

- (void)initToolView
{
    [self.view addSubview:self.locationText];
    [self.view addSubview:self.startBtn];
    [self.view addSubview:self.stopBtn];
    [_mapView addSubview:self.clearDataBtn];
}

#pragma mark - ♻️ Life Cycle
- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    [super viewDidLoad];
    [self initBlueweb];
    [self initMapView];
    [self initLocation];
    [self initToolView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
