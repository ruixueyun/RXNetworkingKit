//
//  RX_NetworkExcuteManager.h
//  OverseaSocialApp
//
//  Created by 陈汉 on 2021/4/15.
//

#import <Foundation/Foundation.h>
#import "RXCommonNetworkExcute.h"

NS_ASSUME_NONNULL_BEGIN

@interface RXCommonNetworkExcuteManager : NSObject

@property (nonatomic, copy) NSString *apiDomain;
@property (nonatomic, strong) NSMutableDictionary *headParams;

+ (instancetype)sharedManger;

+ (RXCommonNetworkExcute *)commonRequestClient;

@end

NS_ASSUME_NONNULL_END
