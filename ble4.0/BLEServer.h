//
//  BLEServer.h
//  ble4.0
//
//  Created by rejoin on 15/4/8.
//  Copyright (c) 2015年 rejoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "PeriperalInfo.h"


typedef void (^eventBlock)(CBPeripheral *peripheral, BOOL status, NSError *error);
typedef enum{
    KNOT = 0,
    KING = 1,
    KSUCCESS = 2,
    KFAILED = 3,
}myStatus;



@protocol BLEServerDelegate

@optional
-(void)didStopScan;
-(void)didFoundPeripheral;
-(void)didReadvalue;
-(void)didNotifyData;

@required
-(void)didDisconnect;

@end


@interface BLEServer : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

+(BLEServer *)defaultBLEServer;

@property(weak, nonatomic) id<BLEServerDelegate> delegate;

@property (strong,nonatomic)NSMutableArray *discoveredPeripherals; //发现的外设数组
@property (strong,nonatomic)CBPeripheral* selectPeripheral; //选中的外设
@property (strong,nonatomic)CBService* discoveredSevice; //发现的服务
@property (strong,nonatomic)CBCharacteristic *selectCharacteristic; //选中的特征
@property (strong,nonatomic)CBCentralManager *myCenter;

//
-(void)startScan;
-(void)startScan:(NSInteger)forLastTime;

-(void)stopScan;
-(void)stopScan:(BOOL)withOutEvent;

-(void)connect:(PeriperalInfo *)peripheralInfo withFinishCB:(eventBlock)callback;
-(void)disConnect;
-(void)discoverService:(CBService*)service;

-(void)readValue:(CBCharacteristic*)characteristic;
-(void)notifyValue:(CBCharacteristic *)characteristic;


//state
-(NSInteger)getConnectState;
-(NSInteger)getServiceState;
-(NSInteger)getCharacteristicState;

@end
