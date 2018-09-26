//
//  LocationNative.m
//  YXBuilder
//
//  Created by guoxd on 2017/12/12.
//  Copyright © 2017年 YUSYS. All rights reserved.
//

#import "LocationNative.h"
#import "CallBackObject.h"
@interface LocationNative()
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (nonatomic,strong) CallBackObject *callbackID;
@end
@implementation LocationNative
-(void)call:(NSString *)action param:(NSString *)param callback:(id<ICallBackDelegate>)callback{
    NSLog(@"action = %@",action);
    self.callbackID = callback;
    if ([action isEqualToString:@"getLocation"]) {
        [self startLocation];
    }
}

-(void)startLocation
{
    if ([CLLocationManager locationServicesEnabled]) {//判断定位操作是否被允许
        
        self.locationManager = [[CLLocationManager alloc] init];
        
        self.locationManager.delegate = self;//遵循代理
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        self.locationManager.distanceFilter = 10.0f;
        
        [_locationManager requestWhenInUseAuthorization];//使用程序其间允许访问位置数据（iOS8以上版本定位需要）
        
        [self.locationManager startUpdatingLocation];//开始定位
        
    }else{//不能定位用户的位置的情况再次进行判断，并给与用户提示
        
        //1.提醒用户检查当前的网络状况
        
        //2.提醒用户打开定位开关
        [self.callbackID run:CallBackObject.ERROR message:@"定位功能关闭，请在设置中打开定位" data:@""];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    //当前所在城市的坐标值
    CLLocation *currLocation = [locations lastObject];
    
    NSLog(@"经度=%f 纬度=%f 高度=%f", currLocation.coordinate.latitude, currLocation.coordinate.longitude, currLocation.altitude);
    
    //根据经纬度反向地理编译出地址信息
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    
    [geoCoder reverseGeocodeLocation:currLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        for (CLPlacemark * placemark in placemarks) {
            
            NSDictionary *address = [placemark addressDictionary];
            
            //  Country(国家)  State(省)  City（市）
            NSLog(@"#####%@",address);
            
            NSLog(@"%@", [address objectForKey:@"Country"]);
            
            NSLog(@"%@", [address objectForKey:@"State"]);
            
            NSLog(@"%@", [address objectForKey:@"City"]);
            
            [self.callbackID run:CallBackObject.SUCCESS message:@"" data:address];
        }
    }];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    if ([error code] == kCLErrorDenied){
        //访问被拒绝
        [self.callbackID run:CallBackObject.ERROR message:@"访问被拒绝" data:@""];
    }
    if ([error code] == kCLErrorLocationUnknown) {
        //无法获取位置信息
        [self.callbackID run:CallBackObject.ERROR message:@"无法获取位置信息" data:@""];
    }
}

@end
