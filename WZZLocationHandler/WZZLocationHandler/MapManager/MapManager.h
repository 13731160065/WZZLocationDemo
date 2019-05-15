//
//  MapManager.h
//  地图
//
//  Created by 潘儒贞 on 2017/12/7.
//  Copyright © 2017年 潘儒贞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MapManager : NSObject

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, copy, readonly) NSString *longitude;
@property (nonatomic, copy, readonly) NSString *latitude;
@property (strong, nonatomic) NSDictionary * geoDic;
@property (strong, nonatomic) NSString * sheng;
@property (strong, nonatomic) NSString * shi;
@property (strong, nonatomic) NSString * qu;
@property (strong, nonatomic) NSString * jiedao;

@property (strong, nonatomic) NSString * merarea_name;
@property (strong, nonatomic) NSString * business_area;

@property (nonatomic, copy) void(^locationMapBlcok)(NSDictionary *dic);

+ (instancetype)shareMap;

/**
 检测第一次请求定位权限是否被用户点击

 @param selectBlock 点击回调
 */
- (void)checkLocationAuthStateWithUserSelected:(void(^)(void))selectBlock;

/**
 开始定位
 */
- (void)startLocation;

@end
