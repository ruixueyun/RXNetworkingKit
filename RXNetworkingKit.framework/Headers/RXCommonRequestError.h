//
//  RXRequestError.h
//  OverseaSocialApp
//
//  Created by 陈汉 on 2021/4/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RXCommonRequestError : NSObject
@property (nonatomic, strong) NSError * error;
@property (nonatomic, strong) id responesObject;
@end

NS_ASSUME_NONNULL_END
