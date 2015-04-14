//
//  ShowPeripheralController.m
//  ble4.0
//
//  Created by rejoin on 15/4/8.
//  Copyright (c) 2015年 rejoin. All rights reserved.
//

#import "ShowPeripheralController.h"
#import "BLEServer.h"
#import "SVProgressHUD.h"
#import "PeriperalInfo.h"

@interface ShowPeripheralController () <UITableViewDataSource,UITableViewDelegate,BLEServerDelegate>

@property(strong,nonatomic)BLEServer * defaultBLEServer;
@property (weak, nonatomic) IBOutlet UILabel *lbName;



@end

@implementation ShowPeripheralController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.defaultBLEServer = [BLEServer defaultBLEServer];
    self.defaultBLEServer.delegate = self;
    self.lbName.text = self.defaultBLEServer.selectPeripheral.name;
    
    self.navigationItem.title=@"Service";
    //设置title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    
    //添加左导航栏按钮
    UIBarButtonItem * leftBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
}
-(void)viewDidAppear:(BOOL)animated{
    self.defaultBLEServer.delegate = self;
}

-(void)didDisconnect
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismissWithError:@"断开连接"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (void)back
{
//    [self.defaultBLEServer disConnect];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -- table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.defaultBLEServer getServiceState] == KING) {
        
        //延迟一段时间把一项任务提交到队列中执行，返回之后就不能取消（常用来在在主队列上延迟执行一项任务）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
        
        return 0;
    }else if([self.defaultBLEServer getServiceState] == KFAILED){
        return 0;
    }
    
    return [self.defaultBLEServer.selectPeripheral.services count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CBService* ser = self.defaultBLEServer.selectPeripheral.services[indexPath.row];
    [self.defaultBLEServer discoverService:ser];
    [SVProgressHUD dismissWithSuccess:@"连接服务成功"];
    [self performSegueWithIdentifier:@"getCharacteristic" sender:self];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"ServiceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    CBService* ser = self.defaultBLEServer.selectPeripheral.services[indexPath.row];
    NSLog(@"ser===%@",ser);
    cell.textLabel.text =[NSString stringWithFormat:@"%@",ser.UUID];
    cell.detailTextLabel.text =[NSString stringWithFormat:@"UUID:%@",[ser.UUID UUIDString]];
    NSLog(@"textLabel=%@,detailTextLabel=%@",cell.textLabel.text,cell.detailTextLabel.text);
    
    return cell;
}


@end
