//
//  myCell.h
//  ble4.0
//
//  Created by rejoin on 15/4/8.
//  Copyright (c) 2015年 rejoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *topName;

@property (weak, nonatomic) IBOutlet UILabel *uuid;

@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet UILabel *service;

@property (weak, nonatomic) IBOutlet UILabel *RSSI;

@end
