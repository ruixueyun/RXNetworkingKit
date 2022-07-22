//
//  RXRequestCache.m
//  OverseaSocialApp
//
//  Created by 陈汉 on 2021/4/15.
//

#import "RXCommonRequestCache.h"
#import <YYCache/YYCache.h>

static NSString *const kPPNetworkResponseCache = @"kPPNetworkResponseCache";

@implementation RXCommonRequestCache

static YYCache *_dataCache;


+ (void)initialize {
    _dataCache = [YYCache cacheWithName:kPPNetworkResponseCache];
}

+ (void) saveCache:(id)httpData URL:(NSString *)url params:(id)params{
    NSString *cacheKey = [self cacheKeyWithURL:url parameters:params];
    //异步缓存,不会阻塞主线程
    [_dataCache setObject:httpData forKey:cacheKey withBlock:nil];
}


+ (id) getCacheForURL:(NSString *)url params:(id)params{
    NSString *cacheKey = [self cacheKeyWithURL:url parameters:params];
    return [_dataCache objectForKey:cacheKey];;
}
+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    if(!parameters || parameters.count == 0){return URL;};
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@%@",URL,paraString];
}

+ (NSInteger)getAllHttpCacheSize{
     return [_dataCache.diskCache totalCost];;
}

+ (void) removeAllHttpCache{
    [_dataCache.diskCache removeAllObjects];
}
@end
