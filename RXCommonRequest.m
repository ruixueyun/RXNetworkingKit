//
//  RXRequest.m
//  OverseaSocialApp
//
//  Created by 陈汉 on 2021/4/15.
//

#import "RXCommonRequest.h"

@implementation RXCommonRequest

- (instancetype) initWithApiName:(NSString *)apiName andParams:(NSDictionary * __nullable)parmas{
    self = [self initWithApiName:apiName andParams:parmas requsetMethod:RequestMethod_Post];
    return self;
}
- (instancetype) initWithApiName:(NSString *)apiName andParams:(NSDictionary * __nullable)parmas requsetMethod:(RequestMethod)method{
    self= [super init];
    if (self) {
        self.apiName=apiName;
        self.params=[parmas copy];
        self.requestMethod=method;
        self.ssl=YES;
        self.isSetQueryStringSerialization = YES;
    }
    return self;
}

@end
