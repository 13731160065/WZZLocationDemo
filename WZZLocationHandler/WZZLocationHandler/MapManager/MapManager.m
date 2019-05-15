//
//  MapManager.m
//  地图
//
//  Created by 潘儒贞 on 2017/12/7.
//  Copyright © 2017年 潘儒贞. All rights reserved.
//

#import "MapManager.h"

static MapManager * mapManager;

@interface MapManager ()<CLLocationManagerDelegate> {
    BOOL isSelectAuth;//选择了定位权限
}

@end

@implementation MapManager

//单例
+ (instancetype)shareMap{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapManager = [[MapManager alloc] init];
    });
    return mapManager;
}

//检查有没有选择定位权限
- (void)checkLocationAuthStateWithUserSelected:(void(^)(void))selectBlock {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkLocationAuthStateWithUserSelected:selectBlock];
        });
    } else {
        if (selectBlock) {
            selectBlock();
        }
    }
}

//MARK:开始定位
- (void)startLocation {
    //初始化定位管理类
    [self.locationManager stopUpdatingLocation];
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:100];
    [self.locationManager setActivityType:CLActivityTypeOther];// 普通用途
    self.locationManager.delegate = self;
    
    //初始化地理编码类
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    //定位
    [_locationManager startUpdatingLocation];
}

//MARK:循环判断
- (void)loopLocation {
    //获取定位信息
    NSDictionary * addressDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyHomeAddressOnlyBeyondMe"];
    if (addressDict) {
        //存在定位信息，等待30秒再去定位
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startLocation];
        });
    } else {
        //不存在定位信息，再去定位
        [self startLocation];
    }
}

#pragma mark - 定位代理
//获取到定位
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations{
    [self.locationManager stopUpdatingLocation];
    //获取定位
    CLLocation *location = locations[0];
    CLLocationCoordinate2D coordinate = location.coordinate;
    _longitude = [NSString stringWithFormat:@"%lf", coordinate.longitude];
    _latitude = [NSString stringWithFormat:@"%lf", coordinate.latitude];
    
    __weak typeof(self) weakSelf = self;

    //保存系统语言
    NSMutableArray *userDefaultLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    //强制简体中文
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-hans",nil] forKey:@"AppleLanguages"];
    //逆地理编码
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *place = placemarks[0];
            NSLog(@"字典%@", place.addressDictionary);
            NSLog(@"**** %@", place.addressDictionary[@"FormattedAddressLines"][0]);
            NSString *loginAddress = nil;
            @try {
                loginAddress = [NSString stringWithFormat:@"%@",place.addressDictionary[@"FormattedAddressLines"][0]];
            } @catch (NSException *exception) {
                
            }
            NSString *loginLongitude = [NSString stringWithFormat:@"%f", self.longitude.doubleValue];
            NSString *loginLatitude = [NSString stringWithFormat:@"%f", self.latitude.doubleValue];
            NSString * state = [place.addressDictionary objectForKey:@"State"];
            NSString * city = [place.addressDictionary objectForKey:@"City"];
            NSString * subLocality = [place.addressDictionary objectForKey:@"SubLocality"];
            
            NSMutableArray * loginPArr = [NSMutableArray array];
            if (state) {
                [loginPArr addObject:state];
                weakSelf.sheng = state;
            }
            if (city) {
                [loginPArr addObject:city];
                weakSelf.shi = city;
            }
            if (subLocality) {
                [loginPArr addObject:subLocality];
                weakSelf.qu = subLocality;
            }
            NSString *loginProvinces = [loginPArr componentsJoinedByString:@","];
            
            //存储定位
            NSMutableDictionary * addressDict = [NSMutableDictionary dictionary];
            addressDict[@"provinces"] = loginProvinces;
            addressDict[@"longitude"] = loginLongitude;
            addressDict[@"latitude"] = loginLatitude;
            addressDict[@"address"] = loginAddress;
            
            //定位到位置更新
            if (addressDict) {
                [[NSUserDefaults standardUserDefaults] setObject:addressDict forKey:@"MyHomeAddressOnlyBeyondMe"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (weakSelf.locationMapBlcok) {
                    weakSelf.locationMapBlcok(addressDict);
                }
            }
            
            weakSelf.merarea_name = loginProvinces;
            weakSelf.business_area = loginAddress;
            
            //定位成功，进入循环判断
            [self loopLocation];
        }
        // 还原系统语言
        [[NSUserDefaults standardUserDefaults] setObject:userDefaultLanguages forKey:@"AppleLanguages"];
    }];
}

//定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    NSLog(@"未获取到位置信息");
    //定位失败，进入循环判断
    [self loopLocation];
}
@end
