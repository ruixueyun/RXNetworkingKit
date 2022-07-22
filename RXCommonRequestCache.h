//
//  RXRequestCache.h
//  OverseaSocialApp
//
//  Created by 陈汉 on 2021/4/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RXCommonRequestCache : NSObject

+ (void) saveCache:(id)httpData URL:(NSString *)url params:(id)params;


+ (id) getCacheForURL:(NSString *)url params:(id)params;

+ (NSInteger)getAllHttpCacheSize;

+ (void) removeAllHttpCache;

@end

NS_ASSUME_NONNULL_END
