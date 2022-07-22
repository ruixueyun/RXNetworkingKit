//
//  RX_NetworkExcuteManager.m
//  OverseaSocialApp
//
//  Created by 陈汉 on 2021/4/15.
//

#import "RXCommonNetworkExcuteManager.h"

@implementation RXCommonNetworkExcuteManager

+ (instancetype)sharedManger
{
    static RXCommonNetworkExcuteManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RXCommonNetworkExcuteManager alloc] init];
    });
    return manager;
}

+ (RXCommonNetworkExcute *)buildNetworkExcuteWithBaseUrl:(NSString *)baseUrl
{
    RXCommonRequestConfigure *config = [[RXCommonRequestConfigure alloc] init];
    NSMutableDictionary *tHeadDic = [RXCommonNetworkExcuteManager sharedManger].headParams;
    config.mheadParams = tHeadDic;
    config.baseUrl= [RXCommonNetworkExcuteManager sharedManger].apiDomain;
    RXCommonNetworkExcute * client= [RXCommonNetworkExcute shareInstanceWithConfig:config];
    if (client) {
        client.configure=config;
        client.tokenBlock = ^{
            //TODO:token失效回调
            NSLog(@"token失效回调");
        };
    }
    return client;
}

+ (RXCommonNetworkExcute *)commonRequestClient
{
    return [self buildNetworkExcuteWithBaseUrl:[RXCommonNetworkExcuteManager sharedManger].apiDomain];
}

@end
