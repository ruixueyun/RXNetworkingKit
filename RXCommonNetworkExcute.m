//
//  RXNetworkExcute.m
//  OverseaSocialApp
//
//  Created by 陈汉 on 2021/4/15.
//

#import "RXCommonNetworkExcute.h"
#import "RXCommonNetworkExcuteManager.h"


@interface RXCommonNetworkExcute()
@property (nonatomic, strong) NSMutableDictionary * mRequestDic;
@property (nonatomic, strong) RXCommonRequestConfigure *requestConfig;
@end

@implementation RXCommonNetworkExcute

- (void)dealloc{
    [_tManager.tasks makeObjectsPerformSelector:@selector(cancel)];
}

+ (instancetype) shareInstanceWithConfig:(RXCommonRequestConfigure *)configure{
    static dispatch_once_t onceToken;
    static RXCommonNetworkExcute * client=nil;
    dispatch_once(&onceToken, ^{
        client=[[RXCommonNetworkExcute alloc] init];
        client.configure=configure;
    });
    return client;
}

- (instancetype) init{
    self = [super init];
    if (self) {
        _tManager=[AFHTTPSessionManager manager];
        _tManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _tManager.requestSerializer.timeoutInterval = 12.0;
        _mRequestDic=[[NSMutableDictionary alloc] init];
        AFSecurityPolicy *securityPolicy =[AFSecurityPolicy defaultPolicy];
        // 客户端是否信任非法证书
        securityPolicy.allowInvalidCertificates = YES;
        // 是否在证书域字段中验证域名
        securityPolicy.validatesDomainName = NO;
        _tManager.securityPolicy = securityPolicy;
        
        _requestConfig = [[RXCommonRequestConfigure alloc] init];
        
    }
    return self;
}

/**
 设置请求头
 @param configure 配置文件
 */
- (void)setConfigure:(RXCommonRequestConfigure *)configure{
    _configure=configure;
    [_configure.mheadParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.tManager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

- (void)setTimeBlock:(RequestTimeExpend)timeBlock{
    @synchronized (self) {
        _timeBlock=[timeBlock copy];
    }
}

- (void)setHelloBlock:(RequestHelloTimeOut)helloBlock{
    @synchronized (self) {
        _helloBlock=[helloBlock copy];
    }
}
- (void)setTokenBlock:(RequestTokenExpired)tokenBlock{
    @synchronized (self) {
        _tokenBlock=[tokenBlock copy];
    }
}

/**
 开始网络请求
 @param request 请求类
 */
- (void) beginRequest:(RXCommonRequest *)request{
    [self beginRequest:request success:nil failure:nil];
}

- (void)beginRequest:(RXCommonRequest *)request
             success:(RequestSuccess)success
             failure:(RequestFailed)failure
{
    NSString *baseUrl = request.baseUrl ? request.baseUrl : _configure.baseUrl;
    NSLog(@"请求域名:\n %@",baseUrl);
    if ([request.apiName isEqualToString:@"channelapi/v1/user/legal"]) {
        baseUrl = @"http://api.weiletest.com/";
    }
    
    NSString *urlStr = [[NSURL URLWithString:request.apiName relativeToURL:[NSURL URLWithString:baseUrl]] absoluteString];
     
    NSURLSessionDataTask *task;
    request.startTime = [[NSDate date] timeIntervalSince1970]*1000;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"isRequesting_%@", urlStr]];
    
    if (request.requestMethod == RequestMethod_Get) {
        task = [_tManager GET:urlStr parameters:request.params headers:request.headParams progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([self respondsToSelector:@selector(onRespondSuccessWithRequest:task:andData:success:failure:)]) {
                [self onRespondSuccessWithRequest:request task:task andData:responseObject success:success failure:failure];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"网络请求失败 ----->>>\n%@", error);

            if ([self respondsToSelector:@selector(failWithError:retObj:request:success:failure:)]) {
                [self failWithError:error retObj:nil request:request success:success failure:failure];
            }
        }];
    } else if (request.requestMethod==RequestMethod_Post) {
        if (request.isSetQueryStringSerialization) {
            [_tManager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
                
                return parameters;
                
            }];
        }
        
        _tManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/plain",@"application/x-javascript",nil];
        
        id params;
        if (request.isGzip) {
            params = request.gzipParam;
        } else {
            if (request.params) {
                params = [self getJsonString:request.params];
            }
        }
        
        task = [_tManager POST:urlStr parameters:params headers:request.headParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([self respondsToSelector:@selector(onRespondSuccessWithRequest:task:andData:success:failure:)]) {
                [self onRespondSuccessWithRequest:request task:task andData:responseObject success:success failure:failure];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"网络请求失败 ----->>>\n%@", error);

            if ([self respondsToSelector:@selector(failWithError:retObj:request:success:failure:)]) {
                [self failWithError:error retObj:nil request:request success:success failure:failure];
            }
        }];
    } else if (request.requestMethod==RequestMethod_Put) {
        if (request.isSetQueryStringSerialization) {
            [_tManager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
                
                return parameters;
                
            }];
        }
        
        task = [_tManager PUT:urlStr parameters:[self getJsonString:request.params] headers:request.headParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([self respondsToSelector:@selector(onRespondSuccessWithRequest:task:andData:success:failure:)]) {
                [self onRespondSuccessWithRequest:request task:task andData:responseObject success:success failure:failure];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"网络请求失败 ----->>>\n%@", error);

            if ([self respondsToSelector:@selector(failWithError:retObj:request:success:failure:)]) {
                [self failWithError:error retObj:nil request:request success:success failure:failure];
            }
        }];
    } else if (request.requestMethod == RequestMethod_Delete) {
        if (request.isSetQueryStringSerialization) {
            [_tManager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
                
                return parameters;
                
            }];
        }
        
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"#%^{}\"[]|\\<> "].invertedSet];
        task = [_tManager DELETE:urlStr parameters:[self getJsonString:request.params] headers:request.headParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([self respondsToSelector:@selector(onRespondSuccessWithRequest:task:andData:success:failure:)]) {
                [self onRespondSuccessWithRequest:request task:task andData:responseObject success:success failure:failure];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"网络请求失败 ----->>>\n%@", error);

            if ([self respondsToSelector:@selector(failWithError:retObj:request:success:failure:)]) {
                [self failWithError:error retObj:nil request:request success:success failure:failure];
            }
        }];
    }
}
- (void) beginRequestWithArray:(NSArray<RXCommonRequest *> *) array{
    for (int i=0 ; i<array.count; i++) {
        RXCommonRequest * request=array[i];
        [self beginRequest:request];
    }
}

- (void) beginUploadFileWithRequest:(RXCommonRequest *)request
                           fileData:(NSData *)data
                               type:(NSString *)type
                               name:(NSString *)name
                           mimeType:(NSString *)mimeType
                           progress:(RequestProgress)progress
                            success:(RequestSuccess)sucess
                            failure:(RequestFailed)failure{
    NSString * urlStr=[[NSURL URLWithString:request.apiName relativeToURL:[NSURL URLWithString:self.configure.baseUrl]] absoluteString];
    NSURLSessionDataTask * task;
    task=[self.tManager POST:urlStr parameters:request.params headers:request.headParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //        NSString *fileName = nil;
        //        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //        formatter.dateFormat = @"yyyyMMddHHmmss";
        //        NSString *day = [formatter stringFromDate:[NSDate date]];
        //        fileName = [NSString stringWithFormat:@"%@.%@",day,type];
        [formData appendPartWithFileData:data name:name fileName:@"qiye.db" mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progress?progress(uploadProgress):nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        sucess?sucess(resultDictionary):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RXCommonRequestError *err=[[RXCommonRequestError alloc]init];
        err.error=error;
        failure?failure(err):nil;
    }];
}


- (void) beginDownLoadWithRequest:(RXCommonRequest *)request progress:(RequestProgress)progress success:(RequestSuccess)sucess failure:(RequestFailed)failure{
    NSString * urlStr=[[NSURL URLWithString:request.apiName relativeToURL:[NSURL URLWithString:self.configure.baseUrl]] absoluteString];
    NSURLSessionDownloadTask * task;
    NSURLRequest *downrequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    task= [self.tManager downloadTaskWithRequest:downrequest progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_async(dispatch_get_main_queue(), ^{
            progress?progress(downloadProgress):nil;
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //返回一个下载到哪的地址
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //下载完成
        if (error&&failure) {
            RXCommonRequestError * err=[[RXCommonRequestError alloc]init];
            err.error=error;
            failure?failure(err):nil;
        }else{
            sucess?sucess(filePath.absoluteString):nil;
        }
        //        [self removeCurrentRequest:task];
    }];
    //    [self addCurrentRequest:request withTask:task];
}

#pragma mark - <网络请求返回数据处理>
//网络请求成功返回
- (void)onRespondSuccessWithRequest:(RXCommonRequest *)request task:(NSURLSessionDataTask *)task andData:(id)responseObject success:(RequestSuccess)success failure:(RequestFailed)failure
{
    NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"isRequesting_%@%@", request.baseUrl, request.apiName]];
    if (resultDictionary) {
        if ([resultDictionary isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *resultMutableDic = [NSMutableDictionary dictionaryWithDictionary:resultDictionary];
            NSString *tracelid = request.headParams[@"ruixue-traceid"];
            [resultMutableDic setValue:tracelid forKey:@"tracelid"];
            NSString *returnCode = resultDictionary[@"code"];
            NSString *returnMessage = resultDictionary[@"msg"];
            if (returnCode && [returnCode isEqualToString:self.requestConfig.successCode]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestInterfaceExcuteSuccess:apiName:apiFlag:)]) {
                    [self.delegate requestInterfaceExcuteSuccess:resultMutableDic apiName:request.apiName apiFlag:request.apiFlag];
                }
                success ? success(resultMutableDic) : nil;
            } else {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:returnMessage forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:@"errormessage"
                                                     code:[returnCode integerValue]
                                                 userInfo:userInfo];
                [self failWithError:error retObj:resultDictionary request:request success:success failure:failure];
            }
        }
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.requestConfig.requestFailMsg forKey:NSLocalizedDescriptionKey];
        NSHTTPURLResponse *responses = (NSHTTPURLResponse *)task.response;
        NSError *error = [NSError errorWithDomain:@"errormessage"
                                             code:responses.statusCode
                                         userInfo:userInfo];
        [self failWithError:error retObj:resultDictionary request:request success:success failure:failure];
    }

    //返回api耗时统计
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970] * 1000;
    if (self.timeBlock && request.startTime > 0) {
        self.timeBlock(endTime - request.startTime, request.apiName);
    }
}
         
- (void)failWithError:(NSError *)error retObj:(id)retObj request:(RXCommonRequest *)request success:(RequestSuccess)success failure:(RequestFailed)failure
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"isRequesting_%@%@", request.baseUrl, request.apiName]];
    if (error.code == [self.requestConfig.tokenTimeoutCode integerValue] && self.tokenBlock) {
//        self.tokenBlock();
        NSLock *cpuUsageLock = [[NSLock alloc] init];
        [cpuUsageLock lock];
        
//        [RXLoginManager refreshTokenWithComplete:^(RXCommonRequestError * _Nonnull error) {
//            [cpuUsageLock unlock];
//            if (!error) {
//                request.headParams = [RXCommonNetworkExcuteManager headParams];
//                [self beginRequest:request success:success failure:failure];
//            }
//        }];
        
        // 普通错误回调
        if ([retObj isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *resultMutableDic = [NSMutableDictionary dictionaryWithDictionary:retObj];
            NSString *tracelid = request.headParams[@"ruixue-traceid"];
            [resultMutableDic setValue:tracelid forKey:@"tracelid"];
            retObj = resultMutableDic;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestInterfaceExcuteError:apiName:apiFlag:retObj:)]) {
            [self.delegate requestInterfaceExcuteError:error apiName:request.apiName apiFlag:request.apiFlag retObj:retObj];
        }
        
        return;
    }
    /**
     * 网络异常导致请求失败时更换域名重新请求
     */
    else if (!retObj) {
        request.failedTimes++;
        // 同个接口失败三次不再调用
        if (request.failedTimes > 3) {
            return;
        }
        request.baseUrl = [RXCommonNetworkExcuteManager sharedManger].apiDomain;
        [self beginRequest:request success:success failure:failure];
        return;
    }
    // 普通错误回调
    if ([retObj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *resultMutableDic = [NSMutableDictionary dictionaryWithDictionary:retObj];
        NSString *tracelid = request.headParams[@"ruixue-traceid"];
        [resultMutableDic setValue:tracelid forKey:@"tracelid"];
        retObj = resultMutableDic;
    }
//    else if (self.delegate && [self.delegate respondsToSelector:@selector(requestInterfaceExcuteError:apiName:apiFlag:retObj:)]) {
//        [self.delegate requestInterfaceExcuteError:error apiName:request.apiName apiFlag:request.apiFlag retObj:retObj];
//    }
    RXCommonRequestError *err = [[RXCommonRequestError alloc] init];
    err.error = error;
    err.responesObject = retObj;
    failure ? failure(err) : nil;
}

/**
 * 转换为JSON 字符串
 */
- (NSString *)getJsonString:(NSDictionary *)jsonDic
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"json解析失败:%@", error);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
