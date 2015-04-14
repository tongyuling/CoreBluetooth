//
//  CentralScanController.m
//  ble4.0
//
//  Created by rejoin on 15/4/8.
//  Copyright (c) 2015年 rejoin. All rights reserved.
//

#import "CentralScanController.h"
#import "myCell.h"
#import "BLEServer.h"
#import "PeriperalInfo.h"
#import "SVProgressHUD.h"
#import "ShowPeripheralController.h"

#define viewWidth [UIScreen mainScreen].bounds.size.width

@interface CentralScanController ()<UITableViewDataSource,UITableViewDelegate,BLEServerDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextField *textInfo;

@property (strong,nonatomic)BLEServer * defaultBLEServer;

@end

@implementation CentralScanController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.defaultBLEServer = [BLEServer defaultBLEServer];
    self.defaultBLEServer.delegate = self;
    [self.defaultBLEServer startScan];
    [SVProgressHUD dismiss];
    self.textInfo.delegate=self;
    self.textInfo.text = @"扫描中...";
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav"] forBarMetrics:UIBarMetricsDefault];
//    UINavigationBar * bar=[[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, viewWidth, 44)];
//    [bar setBackgroundImage:[UIImage imageNamed:@"nav"] forBarMetrics:UIBarMetricsDefault];
//    [self.view addSubview:bar];
    
}

#pragma mark -- bleserver delegate
-(void)didStopScan
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textInfo.text = @"停止扫描";
    });
}

-(void)didFoundPeripheral
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.myTableView reloadData];
    });
}

-(void)didDisconnect
{
    [SVProgressHUD dismissWithError:@"断开连接"];
}


#pragma mark -- tableview delegate
#pragma mark 每个分组的数目
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.defaultBLEServer.discoveredPeripherals count];
}
#pragma mark 点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.defaultBLEServer stopScan:YES];

    [SVProgressHUD show];
    
    [self.defaultBLEServer connect:self.defaultBLEServer.discoveredPeripherals[indexPath.row] withFinishCB:^(CBPeripheral *peripheral, BOOL status, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (status) {
                [SVProgressHUD dismissWithSuccess:@"连接外设成功"];
                
                //storyboard切换视图
                [self performSegueWithIdentifier:@"getService" sender:self];
            }else{
                [SVProgressHUD dismissWithError:@"连接失败"];
            }
        });
        
    }];
    
}
#pragma mark cell显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *MyIdentifier = @"PeripheralCell";
    myCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[myCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    PeriperalInfo *pi = self.defaultBLEServer.discoveredPeripherals[indexPath.row];
    
    cell.topName.text = pi.name;
    cell.uuid.text = pi.uuid;
    cell.name.text = pi.localName;
    cell.service.text = pi.serviceUUIDS;
    cell.RSSI.text = [pi.RSSI stringValue];
    cell.RSSI.textColor = [UIColor blackColor];
    int rssi = [pi.RSSI intValue];
    
    if(rssi>-60){
        cell.RSSI.textColor = [UIColor redColor];
    }else if(rssi > -70){
        cell.RSSI.textColor = [UIColor orangeColor];
    }else if(rssi > -80){
        cell.RSSI.textColor = [UIColor blueColor];
    }else if(rssi > -90){
        cell.RSSI.textColor = [UIColor blackColor];
    }
    
    return cell;
}

#pragma mark textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}


- (IBAction)refreshBtn:(UIBarButtonItem *)sender {
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    [self.defaultBLEServer stopScan:YES];
    
    self.textInfo.text = @"扫描中...";
    self.defaultBLEServer.delegate = self;
    [self.defaultBLEServer startScan];
    [self.myTableView reloadData];
}



@end
