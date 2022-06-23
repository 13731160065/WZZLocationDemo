//
//  WZZLocationHandlerTests.m
//  WZZLocationHandlerTests
//
//  Created by 王泽众 on 2018/1/14.
//  Copyright © 2018年 王泽众. All rights reserved.
//

#import <XCTest/XCTest.h>
@import CoreLocation;
#import "../WZZLocationHandler/ChangeLoction.h"

@interface WZZLocationHandlerTests : XCTestCase

@end

@implementation WZZLocationHandlerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    //http://lbs.amap.com/console/show/picker
//    116.185668,39.904346
    CLLocationDegrees lat = 39.904346;
    CLLocationDegrees lon = 116.185668;
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(lat, lon);
    CLLocationCoordinate2D WGSlocation2D = [ChangeLoction gcj02ToWgs84:location2D];
    NSLog(@"lat：%f,lon：%f",WGSlocation2D.latitude , WGSlocation2D.longitude);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
