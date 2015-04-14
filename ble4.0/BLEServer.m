//
//  BLEServer.m
//  ble4.0
//
//  Created by rejoin on 15/4/8.
//  Copyright (c) 2015年 rejoin. All rights reserved.
//

#import "BLEServer.h"
#import <UIKit/UIKit.h>

@interface BLEServer ()

{
    BOOL inited;
    
    NSInteger scanState;
    NSInteger connectState;
    NSInteger serviceState;
    NSInteger characteristicState;
    
    NSInteger readState;
    NSInteger notifyState;
    
    
    eventBlock connectBlock;
}

@end

@implementation BLEServer

static BLEServer* _defaultBTServer = nil;

-(NSInteger)getScanState
{
    return scanState;
}
-(NSInteger)getConnectState
{
    return connectState;
}
-(NSInteger)getServiceState
{
    return serviceState;
}
-(NSInteger)getCharacteristicState
{
    return characteristicState;
}
-(NSInteger)getReadState
{
    return readState;
}
-(NSInteger)getNotifyState
{
    return notifyState;
}


#pragma mark 初始化
+(BLEServer*)defaultBLEServer
{
    if (nil == _defaultBTServer) {
        _defaultBTServer = [[BLEServer alloc]init];
        
        [_defaultBTServer initBLE];
    }
    
    return _defaultBTServer;
}

-(void)initBLE
{
    if (inited) {
        return;
    }
    inited = YES;
    self.delegate = nil;
    self.discoveredPeripherals = [NSMutableArray array];
    self.selectPeripheral = nil;
    connectState = KNOT;
    connectBlock = nil;
    
    NSDictionary * dict=[NSDictionary dictionaryWithObjectsAndKeys:CBCentralManagerOptionRestoreIdentifierKey,CBCentralManagerOptionShowPowerAlertKey, nil];
    
    self.myCenter=[[CBCentralManager alloc]initWithDelegate:self queue:dispatch_queue_create("rejoin.BLEQueue",NULL ) options:dict];
    
    NSLog(@"myCenter初始化 ........");
    
}

#pragma mark 扫描15秒
-(void)startScan
{
    [self startScan:15];
}

-(void)startScan:(NSInteger)forLastTime
{
    [self.discoveredPeripherals removeAllObjects];
    scanState = KING;
    
    NSArray * array=[NSArray array];
    NSArray *retrivedArray = [self.myCenter retrieveConnectedPeripheralsWithServices:array];
    
    for (CBPeripheral* peripheral in retrivedArray) {
        [self addPeripheral:peripheral advertisementData:nil  RSSI:nil];
        
    }
    
    
    [self.myCenter scanForPeripheralsWithServices:nil options:nil];
    
    
    if (forLastTime > 0) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopScan) object:nil];
        [self performSelector:@selector(stopScan) withObject:nil afterDelay:forLastTime];
    }
}

-(void)stopScan:(BOOL)withOutEvent
{
    
    if (scanState != KING) {
        return;
    }
    
    NSLog(@"stop scan ...");
    
    scanState = KSUCCESS;
    [self.myCenter stopScan];
    
    if(withOutEvent)
        return;
    
    if (self.delegate) {
        if([(id)self.delegate respondsToSelector:@selector(didStopScan)]){
            [self.delegate didStopScan];
        }
    }
}
-(void)stopScan
{
    [self stopScan:YES];
}

#pragma mark 取消连接
-(void)cancelConnect
{
    if (self.myCenter && self.selectPeripheral) {
        if(self.selectPeripheral.state == CBPeripheralStateConnecting){
            NSLog(@"%@连接超时",self.selectPeripheral.name);
            
            [self.myCenter cancelPeripheralConnection:self.selectPeripheral];
            connectState = KNOT;
        }
    }
}

#pragma mark 连接外设
-(void)connect:(PeriperalInfo *)peripheralInfo
{
    NSLog(@"要连接的外设:%@",peripheralInfo.peripheral.name);
    //连接外设
    [self.myCenter connectPeripheral:peripheralInfo.peripheral options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES, CBConnectPeripheralOptionNotifyOnNotificationKey: @YES,
        CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
    
    self.selectPeripheral = peripheralInfo.peripheral;
    connectState = KING;
    
    
    double delayInSeconds = 120.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //延迟操作@selector的方法
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelConnect) object:nil];

    });

    
    
//    //延迟操作@selector的方法
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelConnect) object:nil];
//    //@selector的方法里的操作将在10秒后执行
//    [self performSelector:@selector(stopScan) withObject:nil afterDelay:10];
}

#pragma mark block回调
-(void)connect:(PeriperalInfo *)peripheralInfo withFinishCB:(eventBlock)callback
{
    [self connect:peripheralInfo];
    connectBlock = callback;
}


-(void)disConnect
{
    if(self.myCenter && self.selectPeripheral){
        //断开方法
        [self.myCenter cancelPeripheralConnection:self.selectPeripheral];
    }
}

#pragma mark 发现服务的方法
-(void)discoverService:(CBService*)service
{
    if(self.selectPeripheral){
        characteristicState = KING;
        self.discoveredSevice = service;
        [self.selectPeripheral discoverCharacteristics:nil forService:service];
    }
    
}

#pragma mark 读取特征的值
-(void)readValue:(CBCharacteristic*)characteristic
{
    if (characteristic != nil) {
        self.selectCharacteristic = characteristic;
    }
    readState = KING;
    //读取特征的值
    [self.selectPeripheral readValueForCharacteristic:self.selectCharacteristic];
    readState=KSUCCESS;
    
}

#pragma mark 订阅特征
-(void)notifyValue:(CBCharacteristic *)characteristic
{
    if (characteristic!=nil) {
        self.selectCharacteristic=characteristic;
    }
    notifyState=KING;
    //订阅
    [self.selectPeripheral setNotifyValue:YES forCharacteristic:self.selectCharacteristic];
    notifyState=KSUCCESS;
}


#pragma mark CBCentralManagerDelegate
-(void)addPeripheralInfo:(PeriperalInfo *)peripheralInfo
{
    for(int i=0;i<self.discoveredPeripherals.count;i++){
        PeriperalInfo * pi = self.discoveredPeripherals[i];
        
        if([peripheralInfo.uuid isEqualToString:pi.uuid]){
            [self.discoveredPeripherals replaceObjectAtIndex:i withObject:peripheralInfo];
            return;
        }
    }
    
    [self.discoveredPeripherals addObject:peripheralInfo];
    
    if (self.delegate) {
        if([(id)self.delegate respondsToSelector:@selector(didFoundPeripheral)]){
            [self.delegate didFoundPeripheral];
        }
    }
}

-(void)addPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
    PeriperalInfo *pi = [[PeriperalInfo alloc]init];
    
    pi.peripheral = peripheral;
    pi.uuid = [peripheral.identifier UUIDString];
    
    if (peripheral.name) {
        pi.name=peripheral.name;
    }
    else
    {
        pi.name=@"Undisclosed Name";
    }
    
    switch (peripheral.state) {
        case CBPeripheralStateDisconnected:
            pi.state = @"disConnected";
            break;
        case CBPeripheralStateConnecting:
            pi.state = @"connecting";
            break;
        case CBPeripheralStateConnected:
            pi.state = @"connected";
            break;
        default:
            break;
    }
    if (advertisementData) {
        
        if ([advertisementData objectForKey:CBAdvertisementDataLocalNameKey]) {
            pi.localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
        }
        else
        {
            pi.localName=@"Undisclosed localName";
        }
        
        if ([advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey]) {
            NSArray *array = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
            pi.serviceUUIDS = [array componentsJoinedByString:@"; "];
        }
        else
        {
            pi.serviceUUIDS=@"Undisclosed serviceUUIDS";
        }
    }
    
    
    if (RSSI) {
        pi.RSSI = RSSI;
        
        NSLog(@"rssi:%@",pi.RSSI);
    }
    
    [self addPeripheralInfo:pi];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSLog(@"发现外设:%@;RSSI:%@", peripheral.name, RSSI);
    
    [self addPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}

#pragma mark 调用完centralManager:didDiscoverPeripheral:advertisementData:RSSI:方法连接外设
#pragma mark 如果连接成功会调用如下方法：
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接外设:%@",peripheral.name);
    
    connectState = KSUCCESS;
    if (connectBlock) {
        connectBlock(peripheral,true,nil);
        connectBlock = nil;
    }
    
    
    self.selectPeripheral = peripheral;
    self.selectPeripheral.delegate = self;
    serviceState = KING;
    [self.selectPeripheral discoverServices:nil];
}

#pragma mark 外设断开回调这个方法:
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"断开外设:%@",peripheral.name);
    
    connectState = KFAILED;
    if (connectBlock) {
        connectBlock(peripheral,false,nil);
        connectBlock = nil;
    }
    
    if (self.delegate) {
        if([(id)self.delegate respondsToSelector:@selector(didDisconnect)]){
            [self.delegate didDisconnect];
        }
    }
}

#pragma mark 如果连接失败会调用如下方法：
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接失败的原因:%@",error.localizedDescription);
}


#pragma mark 初始化central之后，执行的方法

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"Bluetooth处于打开状态");
    }
    else if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"Bluetooth处于关闭状态");
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"Bluetooth的状态是未经授权的");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth处于状态未知");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        
        NSLog(@"CoreBluetooth硬件不支持这个平台");
    }
    
}


#pragma mark CBPeripheralDelegate
#pragma mark 外设连接之后，找到该设备上的指定服务 调用CBPeripheralDelegate方法

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (nil == error) {
        serviceState = KSUCCESS;
        NSLog(@"发现的服务:%@",peripheral.services);
    }
    else{
        serviceState = KFAILED;
        NSLog(@"寻找服务失败:%@",error.localizedDescription);
    }
}


#pragma mark 找到特征之后调用这个方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (nil == error) {
        characteristicState = KSUCCESS;
        self.discoveredSevice = service;
    }else{
        characteristicState = KFAILED;
        self.discoveredSevice = nil;
        NSLog(@"寻找特征失败:%@",error.localizedDescription);
    }
    
}


#pragma mark 订阅之后调用这个方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    else
    {
        return;
    }
}


#pragma mark 当设备有数据返回时会调用如下方法：
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error){
        if (readState==KFAILED) {
            NSLog(@"特征:%@ 的值错误error: %@", characteristic.UUID, [error localizedDescription]);
        }
        if (notifyState==KFAILED) {
            NSLog(@"特征:%@ 的值错误error: %@", characteristic.UUID, [error localizedDescription]);
        }
        
        return;
    }
    
    if (readState==KSUCCESS) {
        self.selectCharacteristic=characteristic;
        if ([(id)self.delegate respondsToSelector:@selector(didReadvalue)]){
            [self.delegate didReadvalue];
        }
    }
    
    else if (notifyState==KSUCCESS) {
        self.selectCharacteristic=characteristic;
        if ([(id)self.delegate respondsToSelector:@selector(didNotifyData)]) {
            [self.delegate didNotifyData];
        }
    }
}



@end
