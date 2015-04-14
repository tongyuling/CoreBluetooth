//
//  NSData+hex.h
//  DarkBlue
//
//  Created by chenee on 14-3-27.
//  Copyright (c) 2014年 chenee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HexDump)

//将data转十六进制
- (NSString *)hexval;
- (NSString *)hexdump;

@end