//
//  RXNetworkExcute.h
//  OverseaSocialApp
//
//  Created by 陈汉 on 2021/4/15.
//

#import <Foundation/Foundation.h>
#import "RXCommonRequest.h"
#import "RXCommonRequestConfigure.h"
#import "RXCommonRequestError.h"
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

typedef void(^RequestHelloTimeOut)(RXCommonRequest * _Nullable request);
typedef void(^RequestTokenExpired)(void);
typedef void(^RequestTimeExpend)(NSTimeInterval interval,NSString * _Nullable apiName);
typedef void(^RequestProgress)(NSProgress * _Nullable progress);
typedef void(^RequestSuccess)(id _Nullable responseObject);
typedef void(^RequestFailed)(RXCommonRequestError * _Nullable error);
@protocol RequestDelegate<NSObject>

@optional

/**
 成功返回
 */
- (void)requestInterfaceExcuteSuccess:(id _Nullable )retObj
                              apiName:(NSString *_Nullable)apiName
                              apiFlag:(NSString *_Nullable)apiFlag;

/**
 错误返回（处理token失效时返回）
 */
- (void)requestInterfaceExcuteError:(NSError *_Nullable)error
                            apiName:(NSString *_Nullable)apiName
                            apiFlag:(NSString *_Nullable)apiFlag
                             retObj:(id _Nullable )retObj;

@end

NS_ASSUME_NONNULL_BEGIN

@interface RXCommonNetworkExcute : NSObject

@property (nonatomic, strong) AFHTTPSessionManager * tManager;
@property (nonatomic, strong) RXCommonRequestConfigure * configure;
@property (nonatomic, weak) id<RequestDelegate> delegate;
@property (nonatomic, strong) RequestHelloTimeOut helloBlock;
@property (nonatomic, strong) RequestTokenExpired tokenBlock;
@property (nonatomic, strong) RequestTimeExpend timeBlock;

/**
 初始化单例

 @param configure 网络请求配置对象
 @return 网络请求管理类
 */
+ (instancetype) shareInstanceWithConfig:(RXCommonRequestConfigure *)configure;
//代理返回的请求
/**
 普通POST GET 请求

 @param request 请求的URL参数信息
 */
- (void) beginRequest:(RXCommonRequest *)request;


/**
 普通POST GET 请求

 @param request 请求的URL参数信息
 @param success 成功返回
 @param failure 失败返回
 */
- (void) beginRequest:(RXCommonRequest *)request
              success:(RequestSuccess)success
              failure:(RequestFailed)failure;

/**
 多个请求

 @param array 数组
 */
- (void) beginRequestWithArray:(NSArray<RXCommonRequest *> *) array;


/**
 图片文件上传

 @param request 请求的URL以及参数
 @param data 图片文件数据
 @param type 类型（png，jpg）
 @param name 服务文件名称
 @param mimeType mimeType
 @param progress 上传进度
 @param sucess 上传成功
 @param failure 上传失败
 */
- (void) beginUploadFileWithRequest:(RXCommonRequest *)request
                           fileData:(NSData *)data
                               type:(NSString *)type
                               name:(NSString *)name
                           mimeType:(NSString *)mimeType
                           progress:(RequestProgress)progress
                            success:(RequestSuccess)sucess
                            failure:(RequestFailed)failure;


/**
 文件下载

 @param request 请求的URL以及参数
 @param progress 下载进度
 @param sucess 下载完成
 @param failure 下载失败
 */
- (void) beginDownLoadWithRequest:(RXCommonRequest *)request
                         progress:(RequestProgress)progress
                          success:(RequestSuccess)sucess
                          failure:(RequestFailed)failure;


@end

NS_ASSUME_NONNULL_END
