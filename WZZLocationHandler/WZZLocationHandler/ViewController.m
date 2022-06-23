//
//  ViewController.m
//  WZZLocationHandler
//
//  Created by 王泽众 on 2018/1/14.
//  Copyright © 2018年 王泽众. All rights reserved.
//

#import "ViewController.h"
#import "SULocationTransform.h"
#import "ChangeLoction.h"
@import AVFoundation;
@import CoreLocation;
#import "MapManager/MapManager.h"

@interface ViewController ()
{
    NSFileHandle * file;
}
@property (weak, nonatomic) IBOutlet UILabel *aLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self changeLocation];
    [self testExample];
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

- (void)changeLocation {
    __weak typeof(self) weakSelf = self;
    [MapManager shareMap].locationMapBlcok = ^(NSDictionary *dic) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"定位成功" message:[NSString stringWithFormat:@"%@", dic] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [weakSelf presentViewController:alert animated:YES completion:nil];
    };
    [[MapManager shareMap] startLocation];
}

@end
