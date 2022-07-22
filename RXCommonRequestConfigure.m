//
//  RXRequestConfigure.m
//  OverseaSocialApp
//
//  Created by 陈汉 on 2021/4/15.
//

#import "RXCommonRequestConfigure.h"

@implementation RXCommonRequestConfigure

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestFailMsg = @"您的网络好像出了问题，请试试切换网络";
    }
    return self;
}

@end
