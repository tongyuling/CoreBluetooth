//
//  ReadValueController.m
//  ble4.0
//
//  Created by rejoin on 15/4/8.
//  Copyright (c) 2015年 rejoin. All rights reserved.
//

#import "ReadValueController.h"
#import "BLEServer.h"
#import "SVProgressHUD.h"
#import "NSData+HexDump.h"
#import "HHAlertView.h"

#define viewWidth [UIScreen mainScreen].bounds.size.width
#define viewHeight [UIScreen mainScreen].bounds.size.height

@interface ReadValueController () <BLEServerDelegate,HHAlertViewDelegate,UIAlertViewDelegate>

@property (strong ,nonatomic)UILabel * lbPeripheral;
@property (strong ,nonatomic)UILabel * lbService;
@property (strong ,nonatomic)UILabel * lbCharacteristic;
@property (strong ,nonatomic)UILabel * lbASCII; //二进制
@property (strong ,nonatomic)UILabel * lbHex; //十六进制
@property (strong ,nonatomic)UILabel * lbDecimal; //十进制

@property (strong,nonatomic)UIButton * btn1;
@property (strong,nonatomic) UIButton * btn2;

@property (strong,nonatomic) BLEServer * defaultBLEServer;

@property (nonatomic)BOOL readState;
@property (nonatomic)BOOL notifyState;

@end

@implementation ReadValueController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor=[UIColor whiteColor];
    
//    //背景图
//    UIImageView *image =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];
//    image.frame =CGRectMake(0, 0, viewWidth, viewHeight);
//    [self.view addSubview:image];
//    self.view.backgroundColor = [UIColor blackColor];
    
    self.defaultBLEServer = [BLEServer defaultBLEServer];
    self.defaultBLEServer.delegate = self;
    
    if (self.defaultBLEServer.selectCharacteristic.properties==CBCharacteristicPropertyRead) {
        self.navigationItem.title=@"Read";
    }
    if (self.defaultBLEServer.selectCharacteristic.properties==CBCharacteristicPropertyNotify) {
        self.navigationItem.title=@"Notify";
    }
    
    //设置title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    
    [self buildUI];
    
    if (self.defaultBLEServer.selectCharacteristic.properties==CBCharacteristicPropertyRead) {
        self.btn2.hidden=YES;
    }
    if (self.defaultBLEServer.selectCharacteristic.properties==CBCharacteristicPropertyNotify) {
        self.btn1.hidden=YES;
    }
    
    _readState=NO;
    _notifyState=NO;
    
    [[HHAlertView shared] setDelegate:self];
}

-(void)buildUI
{
    //添加左导航栏按钮
    UIBarButtonItem * leftBtn=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    [leftBtn setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UILabel * label0=[[UILabel alloc]init];
    label0.frame=CGRectMake(viewWidth/16 , viewHeight/3.7 , viewWidth/1.14 , viewHeight/2.5);
    [label0 setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lbl"]]];
    [self.view addSubview:label0];
    
    UILabel * label1=[[UILabel alloc]init];
    label1.font=[UIFont boldSystemFontOfSize:17];
    label1.frame=CGRectMake(viewWidth/5, viewHeight/7.5, viewWidth/3, 21);
    label1.text=@"Peripheral:";
    label1.textColor=[UIColor redColor];
    [self.view addSubview:label1];
    
    UILabel * label2=[[UILabel alloc]init];
    label2.font=[UIFont boldSystemFontOfSize:17];
    label2.frame=CGRectMake(viewWidth/3.7, viewHeight/5.7, viewWidth/3, 21);
    label2.text=@"Service:";
    label2.textColor=[UIColor redColor];
    [self.view addSubview:label2];
    
    UILabel * label3=[[UILabel alloc]init];
    label3.font=[UIFont boldSystemFontOfSize:17];
    label3.frame=CGRectMake(viewWidth/8.9, viewHeight/4.6, viewWidth/2.2 , 21);
    label3.text=@"Characteristic:";
    label3.textColor=[UIColor redColor];
    [self.view addSubview:label3];
    
    UILabel * label4=[[UILabel alloc]init];
    label4.font=[UIFont systemFontOfSize:17];
    label4.frame=CGRectMake(viewWidth/11, viewHeight/3.3, viewWidth/4.6 , 21);
    label4.textColor=[UIColor whiteColor];
    [label4 setBackgroundColor:[UIColor clearColor]];
    label4.text=@"Binary:";
    [self.view addSubview:label4];
    
    UILabel * label5=[[UILabel alloc]init];
    label5.font=[UIFont systemFontOfSize:17];
    label5.frame=CGRectMake(viewWidth/11, viewHeight/2.3, viewWidth/4.6 , 21);
    label5.textColor=[UIColor whiteColor];
    [label5 setBackgroundColor:[UIColor clearColor]];
    label5.text=@"Hex:";
    [self.view addSubview:label5];
    
    UILabel * label6=[[UILabel alloc]init];
    label6.font=[UIFont systemFontOfSize:17];
    label6.frame=CGRectMake(viewWidth/11, viewHeight/1.8, viewWidth/4.6 , 21);
    label6.textColor=[UIColor whiteColor];
    [label6 setBackgroundColor:[UIColor clearColor]];
    label6.text=@"Decimal:";
    [self.view addSubview:label6];
    
    UILabel * lbPeripheral=[[UILabel alloc]init];
    lbPeripheral.font=[UIFont boldSystemFontOfSize:17];
    lbPeripheral.frame=CGRectMake(viewWidth/2, viewHeight/7.5, viewWidth/2.1 , 21);
    self.lbPeripheral=lbPeripheral;
    self.lbPeripheral.text = self.defaultBLEServer.selectPeripheral.name;
    [self.view addSubview:lbPeripheral];
    
    
    UILabel * lbService=[[UILabel alloc]init];
    lbService.font=[UIFont boldSystemFontOfSize:17];
    lbService.frame=CGRectMake(viewWidth/2, viewHeight/5.6, viewWidth/2.4 , 21);
    self.lbService=lbService;
    self.lbService.text = [self.defaultBLEServer.discoveredSevice.UUID UUIDString];
    [self.view addSubview:lbService];
    
    
    UILabel * lbCharacteristic=[[UILabel alloc]init];
    lbCharacteristic.font=[UIFont boldSystemFontOfSize:17];
    lbCharacteristic.frame=CGRectMake(viewWidth/2, viewHeight/4.6, viewWidth/2.4 , 21);
    self.lbCharacteristic=lbCharacteristic;
    self.lbCharacteristic.text = [self.defaultBLEServer.selectCharacteristic.UUID UUIDString];
    [self.view addSubview:lbCharacteristic];
    
    
    UILabel * lbASCII=[[UILabel alloc]init];
    lbASCII.font=[UIFont boldSystemFontOfSize:12];
    lbASCII.frame=CGRectMake(viewWidth/10.7, CGRectGetMaxY(label4.frame)+16.5, viewWidth/1.2 , 21);
    [lbASCII setBackgroundColor:[UIColor clearColor]];
    lbASCII.textColor=[UIColor whiteColor];
    [self.view addSubview:lbASCII];
    self.lbASCII=lbASCII;
    
    UILabel * lbHex=[[UILabel alloc]init];
    lbHex.font=[UIFont boldSystemFontOfSize:12];
    lbHex.frame=CGRectMake(viewWidth/10.7, CGRectGetMaxY(label5.frame)+12.5, viewWidth/1.2 , 21);
    [lbHex setBackgroundColor:[UIColor clearColor]];
    lbHex.textColor=[UIColor whiteColor];
    [self.view addSubview:lbHex];
    self.lbHex=lbHex;
    
    UILabel * lbDecimal=[[UILabel alloc]init];
    lbDecimal.font=[UIFont boldSystemFontOfSize:12];
    lbDecimal.frame=CGRectMake(viewWidth/10.7, CGRectGetMaxY(label6.frame)+13, viewWidth/1.2 , 21);
    [lbDecimal setBackgroundColor:[UIColor clearColor]];
    lbDecimal.textColor=[UIColor whiteColor];
    [self.view addSubview:lbDecimal];
    self.lbDecimal=lbDecimal;
    
    //    UIButton * btn1=[UIButton buttonWithType:UIButtonTypeCustom];
    //    btn1.frame=CGRectMake(30, 420, 160, 40);
    //    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [btn1 setBackgroundColor:[UIColor orangeColor]];
    //    [btn1 setTitle:@"Read" forState:UIControlStateNormal];
    //    [btn1 addTarget:self action:@selector(readBtn:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:btn1];
    //    self.btn1=btn1;
    //
    //    UIButton * btn2=[UIButton buttonWithType:UIButtonTypeCustom];
    //    btn2.frame=CGRectMake(130, 420, 160, 40);
    //    [btn2 setBackgroundColor:[UIColor orangeColor]];
    //    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [btn2 setTitle:@"Notify" forState:UIControlStateNormal];
    //    [btn2 addTarget:self action:@selector(notifyBtn:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:btn2];
    //    self.btn2=btn2;
    
    UIButton * btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"退出此外设" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"nav"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    btn.frame=CGRectMake(111, 440, 100, 40);
    btn.frame=CGRectMake(viewWidth/2.9, viewHeight/1.3, viewWidth/3.2 , viewHeight/14.2);
    [btn addTarget:self action:@selector(pops) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
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
        _readState = NO;
        NSData *d = self.defaultBLEServer.selectCharacteristic.value;
        
        NSString *s = [d hexval];
        self.lbHex.text = s;
        
        NSString * str=[self turn16to10:s];
        self.lbDecimal.text=str;

        NSString * st=[self turn10to2:str];
        self.lbASCII.text=st;
        
        NSLog(@"=====");
        NSLog(@"s==%@,st==%@,str==%@",s,st,str);
    });
}

-(void)didNotifyData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _notifyState = NO;
        
        NSData *d = self.defaultBLEServer.selectCharacteristic.value;
        NSLog(@"d----%@",d);
        
        NSString *s = [d hexval];
        self.lbHex.text = s;
        
        NSString * str=[self turn16to10:s];
        self.lbDecimal.text=str;
        
        NSString * st=[self turn10to2:str];
        self.lbASCII.text=st;
        
        NSLog(@"-----");
        NSLog(@"s--%@,st--%@,str--%@",s,st,str);
    });
}

#pragma mark 二进制转十进制
-(NSString *)toDecimalSystemWithBinarySystem:(NSString *)binary
{
    int ll = 0 ;
    int  temp = 0 ;
    for (int i = 0; i < binary.length; i ++)
    {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    
    return result;
}
#pragma mark 二进制转十进制
- (NSString *) turn2to10:(NSString *)str{
    int sum = 0;
    for (int i = 0; i < str.length; i++) {
        sum *= 2;
        char c = [str characterAtIndex:i];
        sum += c - '0';
    }
    return [NSString stringWithFormat:@"%d",sum];
}
#pragma mark 十进制转二进制
- (NSString *) turn10to2:(NSString *)str{
    int num = [str intValue];
    
    NSMutableString * result = [[NSMutableString alloc]init];
    while (num > 0) {
        NSString * reminder = [NSString stringWithFormat:@"%d",num % 2];
        [result insertString:reminder atIndex:0];
        num = num / 2;
    }
    return result;
}
#pragma mark 十进制转十六进制
- (NSString *) turn10to16:(NSString *)str{
    int num = [str intValue];
    NSMutableString * result = [[NSMutableString alloc]init];
    while (num > 0) {
        int a = num % 16;
        char c;
        if (a > 9) {
            c = 'A' + (a - 10);
        }else{
            c = '0' + a;
        }
        NSString * reminder = [NSString stringWithFormat:@"%c",c];
        [result insertString:reminder atIndex:0];
        num = num / 16;
    }
    return result;
}
#pragma mark 十六进制转十进制
- (NSString *) turn16to10:(NSString *)str{
    int sum = 0;
    for (int i = 0; i < str.length; i++) {
        sum *= 16;
        char c = [str characterAtIndex:i] ;
        if (c >= 'A') {
            sum += c - 'A' + 10;
        }else{
            sum += c - '0';
        }
    }
    return [NSString stringWithFormat:@"%d",sum];
}

#pragma mark 普通字符串转换为十六进制
- (NSMutableData *)stringToHex:(NSString *)needToSendString
{
    const char *buf = [needToSendString UTF8String];
    NSMutableData *data = [NSMutableData data];
    if (buf)
    {
        uint64_t len = strlen(buf);
        
        char singleNumberString[3] = {'\0', '\0', '\0'};
        uint32_t singleNumber = 0;
        for(uint32_t i = 0 ; i < len; i+=2)
        {
            if ( ((i+1) < len) && isxdigit((char)buf) && (isxdigit(buf[i+1])) )
            {
                singleNumberString[0] = (char)buf;
                singleNumberString[1] = buf[i + 1];
                sscanf(singleNumberString, "%x", &singleNumber);
                uint8_t tmp = (uint8_t)(singleNumber & 0x000000FF);
                [data appendBytes:(void *)(&tmp) length:1];
            }
            else
            {
                break;
            }
        }
        
    }
    return data;
}
#pragma mark 普通字符串转换为十六进制
+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
#pragma mark 将16进制转化为二进制
-(NSString *)getBinaryByhex:(NSString *)hex
{
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [hexDic setObject:@"0000" forKey:@"0"];
    
    [hexDic setObject:@"0001" forKey:@"1"];
    
    [hexDic setObject:@"0010" forKey:@"2"];
    
    [hexDic setObject:@"0011" forKey:@"3"];
    
    [hexDic setObject:@"0100" forKey:@"4"];
    
    [hexDic setObject:@"0101" forKey:@"5"];
    
    [hexDic setObject:@"0110" forKey:@"6"];
    
    [hexDic setObject:@"0111" forKey:@"7"];
    
    [hexDic setObject:@"1000" forKey:@"8"];
    
    [hexDic setObject:@"1001" forKey:@"9"];
    
    [hexDic setObject:@"1010" forKey:@"A"];
    
    [hexDic setObject:@"1011" forKey:@"B"];
    
    [hexDic setObject:@"1100" forKey:@"C"];
    
    [hexDic setObject:@"1101" forKey:@"D"];
    
    [hexDic setObject:@"1110" forKey:@"E"];
    
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSMutableString *binaryString=[[NSMutableString alloc] init];
    
    for (int i=0; i<[hex length]; i++) {
        
        NSRange rage;
        
        rage.length = 1;
        
        rage.location = i;
        
        NSString *key = [hex substringWithRange:rage];
        
        //NSLog(@"%@",[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]);
        
        binaryString = (NSMutableString *)[NSString stringWithFormat:@"%@%@",binaryString,[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
        
    }
    
    //NSLog(@"转化后的二进制为:%@",binaryString);
    
    return binaryString;
}



#pragma mark 导航按钮
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark read按钮
-(void)readBtn:(UIButton *)sender
{
    if (self.defaultBLEServer.selectCharacteristic.properties==CBCharacteristicPropertyRead) {
        [self readAction];
    }
    if (self.defaultBLEServer.selectCharacteristic.properties==CBCharacteristicPropertyNotify) {
        [HHAlertView showAlertWithStyle:HHAlertStyleError inView:self.view Title:@"错误" detail:@"该特征只能用来订阅!" cancelButton:nil Okbutton:@"确定" block:^(HHAlertButton buttonindex) {
        }];
    }
}
-(void)readAction
{
    if (_readState == YES) {
        return;
    }
    _readState =YES;
    [self.defaultBLEServer readValue:nil];
}


#pragma mark 订阅按钮
-(void)notifyBtn:(UIButton *)sender
{
    if (self.defaultBLEServer.selectCharacteristic.properties==CBCharacteristicPropertyNotify) {
        [self notifyAction];
    }
    if (self.defaultBLEServer.selectCharacteristic.properties==CBCharacteristicPropertyRead) {
        [HHAlertView showAlertWithStyle:HHAlertStyleError inView:self.view Title:@"错误" detail:@"该特征不能用来订阅!" cancelButton:nil Okbutton:@"确定" block:^(HHAlertButton buttonindex) {
        }];
    }
    
}
-(void)notifyAction
{
    if (_notifyState == YES) {
        return;
    }
    _notifyState =YES;
    [self.defaultBLEServer notifyValue:nil];
}


#pragma mark 退出按钮
-(void)pops
{
    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"确定要进行此操作吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}


#pragma mark alertView的代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex==0) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        //返回指定的根视图
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
//        [self.defaultBLEServer.myCenter cancelPeripheralConnection:self.defaultBLEServer.selectPeripheral];
        [self.defaultBLEServer disConnect];

    }
}

@end
