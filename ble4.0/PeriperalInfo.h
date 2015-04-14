//
//  PeriperalInfo.h
//  ble4.0
//
//  Created by rejoin on 15/4/8.
//  Copyright (c) 2015年 rejoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeriperalInfo : NSObject

@property (strong,nonatomic)CBPeripheral* peripheral;

@property (strong,nonatomic)NSString* uuid;
@property (strong,nonatomic)NSString* name;
@property (strong,nonatomic)NSString* state;//状态

//advertisement
@property (strong,nonatomic)NSString* channel;//内存路径
@property (strong,nonatomic)NSString* isConnectable;
@property (strong,nonatomic)NSString* localName;//当前的name

@property (strong,nonatomic)NSString* manufactureData;//生成的数据
@property (strong,nonatomic)NSString* serviceUUIDS;//服务的uuid
//rssi
@property (strong,nonatomic)NSNumber *RSSI;

@end
