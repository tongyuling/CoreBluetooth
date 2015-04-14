//
//  ShowServiceController.m
//  ble4.0
//
//  Created by rejoin on 15/4/8.
//  Copyright (c) 2015年 rejoin. All rights reserved.
//

#import "ShowServiceController.h"
#import "SVProgressHUD.h"
#import "ReadValueController.h"
#import "BLEServer.h"

@interface ShowServiceController () <UITableViewDataSource,UITableViewDelegate,BLEServerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UILabel *lbPeripheral;
@property (weak, nonatomic) IBOutlet UILabel *lbService;

@property (strong,nonatomic) BLEServer * defaultBLEServer;

@property (nonatomic)BOOL readLock;
@property (nonatomic)BOOL notifyLock;

@end

@implementation ShowServiceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.defaultBLEServer = [BLEServer defaultBLEServer];
    self.defaultBLEServer.delegate = self;
    self.lbPeripheral.text = self.defaultBLEServer.selectPeripheral.name;
    self.lbService.text = [self.defaultBLEServer.discoveredSevice.UUID UUIDString];
    
    self.navigationItem.title=@"Characteristic";
    //设置title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    
    //添加左导航栏按钮
    UIBarButtonItem * leftBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    _readLock = NO;
    _notifyLock=NO;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.defaultBLEServer.delegate = self;
    
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)didDisconnect
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismissWithError:@"断开连接"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}


-(void)didReadvalue
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _readLock = NO;
        [SVProgressHUD dismiss];
        
        //开启iOS7的滑动返回效果
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
        
    });
    
}

-(void)didNotifyData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _notifyLock = NO;
        [SVProgressHUD dismiss];
        
        //开启iOS7的滑动返回效果
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    });
}


#pragma mark -- table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([self.defaultBLEServer getCharacteristicState] == KING) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
        return 0;
    }else if([self.defaultBLEServer getCharacteristicState] == KFAILED){
        return 0;
    }
    return [self.defaultBLEServer.discoveredSevice.characteristics count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBCharacteristic* ch = self.defaultBLEServer.discoveredSevice.characteristics[indexPath.row];
    
    if (_notifyLock==NO) {
        [self.defaultBLEServer notifyValue:ch];
        [SVProgressHUD dismissWithSuccess:@"订阅成功"];
    }
    
    if (_readLock==NO) {
        [self.defaultBLEServer readValue:ch];
        [SVProgressHUD dismissWithSuccess:@"读取成功"];
    }

    ReadValueController * r=[[ReadValueController alloc]init];
    [self.navigationController pushViewController:r animated:YES];
    
}


-(NSString*)getPropertiesString:(CBCharacteristicProperties)properties
{
    NSMutableString *s = [[NSMutableString alloc]init];
    [s appendString:@""];
    
    if ((properties & CBCharacteristicPropertyBroadcast) == CBCharacteristicPropertyBroadcast) {
        [s appendString:@" Broadcast"];
    }
    if ((properties & CBCharacteristicPropertyRead) == CBCharacteristicPropertyRead) {
        [s appendString:@" Read"];
    }
    if ((properties & CBCharacteristicPropertyWriteWithoutResponse) == CBCharacteristicPropertyWriteWithoutResponse) {
        [s appendString:@" WriteWithoutResponse"];
    }
    
    if ((properties & CBCharacteristicPropertyWrite) == CBCharacteristicPropertyWrite) {
        [s appendString:@" Write"];
    }
    if ((properties & CBCharacteristicPropertyNotify) == CBCharacteristicPropertyNotify) {
        [s appendString:@" Notify"];
    }
    if ((properties & CBCharacteristicPropertyIndicate) == CBCharacteristicPropertyIndicate) {
        [s appendString:@" Indicate"];
    }
    if ((properties & CBCharacteristicPropertyAuthenticatedSignedWrites) == CBCharacteristicPropertyAuthenticatedSignedWrites) {
        [s appendString:@" AuthenticatedSignedWrites"];
    }
    if ((properties & CBCharacteristicPropertyExtendedProperties) == CBCharacteristicPropertyExtendedProperties) {
        [s appendString:@" ExtendedProperties"];
    }
    if ((properties & CBCharacteristicPropertyNotifyEncryptionRequired) == CBCharacteristicPropertyNotifyEncryptionRequired) {
        [s appendString:@" NotifyEncryptionRequired"];
    }
    if ((properties & CBCharacteristicPropertyIndicateEncryptionRequired) == CBCharacteristicPropertyIndicateEncryptionRequired) {
        [s appendString:@" IndicateEncryptionRequired"];
    }
    
    if ([s length]<2) {
        [s appendString:@"unknow"];
    }
    return s;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"CharacteristicCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    CBCharacteristic * cc = self.defaultBLEServer.discoveredSevice.characteristics[indexPath.row];
    cell.textLabel.text = [cc.UUID UUIDString];
    
    
    NSString * s = [self getPropertiesString:cc.properties];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"UUID:%@  Properities:%@",[cc.UUID UUIDString],s];
    
    return cell;
}


@end
