//
//  RXRequestConfigure.h
//  OverseaSocialApp
//
//  Created by 陈汉 on 2021/4/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RXCommonRequestConfigure : NSObject
@property (nonatomic, strong) NSMutableDictionary *mheadParams;
@property (nonatomic, strong) NSString *baseUrl;

@property (nonatomic, strong) NSString *successCode;
@property (nonatomic, strong) NSString *tokenTimeoutCode;
@property (nonatomic, strong) NSString *requestFailMsg;

+ (instancetype)sharedManger;

@end

NS_ASSUME_NONNULL_END
