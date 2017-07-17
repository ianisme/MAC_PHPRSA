//
//  NetworkService.m
//  RSATest
//
//  Created by ian on 2017/7/18.
//  Copyright © 2017年 RengFou.Inc. All rights reserved.
//

#import "NetworkService.h"
#import <AFNetworking.h>
#import "CCMCryptor.h"
#import "CCMKeyLoader.h"
#import "CCMPublicKey.h"
#import "CCMBase64.h"

#define SERVER_URL @"http://localhost:8888/"

@implementation NetworkService

+ (instancetype)shareInstance
{
    static NetworkService *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedClient = [[NetworkService alloc] init];
    });
    return sharedClient;
}

- (void)appRSAPost:(NSString *)url parameters:(NSDictionary *)paramsters handler:(void(^)(BOOL successful, id response))handler
{
    NSString *urlString = [SERVER_URL stringByAppendingString:[NSString stringWithFormat:@"%@",url]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:urlString parameters:[self rsaEncryption:paramsters] progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        handler(YES,[self rsaDecrypt:resultDic]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handler(NO , error);
    }];
    
}

- (void)appRSAGet:(NSString *)url parameters:(NSDictionary *)paramsters handler:(void(^)(BOOL successful, id response))handler
{
    NSString *urlString = [SERVER_URL stringByAppendingString:[NSString stringWithFormat:@"%@",url]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:urlString parameters:[self rsaEncryption:paramsters] progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        handler(YES,[self rsaDecrypt:resultDic]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handler(NO , error);
    }];
}

- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *ceshi = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return ceshi;
}

// RSA加密
- (NSDictionary *)rsaEncryption:(NSDictionary *)params
{
    NSString *pubkey = @"-----BEGIN PUBLIC KEY-----MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCCbQ6dCdhDpN7gDhIfzBMM2+QhYRexKNoQevbFLqhhqHbb28L/LktHlTPMWhGiYJroFyrC8vK+oxws/fE7oMIlN0HMpdciQqYLa8g7ihf7H+LsYdVenU5yFslwJmVfkXFvKf5QI3Onp2dHk2aLQ7Fa3VyhqUNt8ej9j19z8dta1QIDAQAB-----END PUBLIC KEY-----";
    
    NSData *data = [[self dictionaryToJson:params] dataUsingEncoding:NSUTF8StringEncoding];
    
    CCMKeyLoader *keyLoader = [[CCMKeyLoader alloc] init];
    CCMPublicKey *publicKey = [keyLoader loadX509PEMPublicKey:pubkey];
    
    NSError *error;
    
    CCMCryptor *cryptor = [[CCMCryptor alloc] init];
    NSData *crytorData = [cryptor encryptData:data withPublicKey:publicKey error:&error];
    
    NSString *encWithPubKey = [CCMBase64 base64StringFromData:crytorData];
    
    // base64编码替换
    NSString *encWithPubKey1 = [encWithPubKey stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    NSString *encWithPubKey2 = [encWithPubKey1 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *encWithPubKey3 = [encWithPubKey2 stringByReplacingOccurrencesOfString:@"=" withString:@""];
    NSDictionary *dataParams = @{@"data" : encWithPubKey3};
    return dataParams;
}

// RSA解密
- (NSDictionary *)rsaDecrypt:(NSDictionary *)params
{
    NSString *privkey = @"-----BEGIN RSA PRIVATE KEY-----MIICXQIBAAKBgQCpXOMTRiRKmnjK8sD0I785RH25rltHMLFO3J3SUzZ2rrDeCCRcETMT+KVJEnsVTnN0IHB5hlnkLXfxFp05E8/ESQT8Qt0xqeVbzXkX8jQjnq0GgE3biuUsHOMZNLhzIne9/PbIRhi+E/WM3JVc3VBNzYLVjIi3Iu+eX/avSLwv3QIDAQABAoGAA3DC9CXyoB6vNtWORzy1VRZ9GgPeutLUZ0O4Dl5pDCl+/PkGtBAYDN8k4cJ3BEx0WqGQvLHsADn5kR430hcC8MiQ5dVuR8njE5VpXgDf7AOVQasBUDUXU+nXWf74enE/ukaVfYxYm0ixMcG/ZyJ8JqXxNucBc+lXbwy22HELVQkCQQCsSOO+7iEDA7Jh3WlQiiE3wUn/yeq73fwqALT1G6urbIZ30VjqIJlgKPPFpRFGqhbV4Qu7ACJ4F/DosQMKu1CjAkEA+6iIntUQXQErsrNA+wdKacDOyH+7yZrtk6aOnkFc3IoXJ94BqHhoI1zbLxJ7K1yK6lOOjSOEXMVmKZuYhZQFfwJBAJqolEpB2sCqAOh5qqDyXv9+NL+6s04S6NuL5uZiAKnSsqO8+uSyfv0jxjIXDHszFWzKqY0lgcvtMgaxYNmxbaECQQDa+vze0OGrPDCNEAPUK7TprteAif2a4VAnsb/aH2Axm4uoqjrhINzlIJCtNjStN5q9ajXZxHUR0MckH3upiHL7AkBVmuLakI+vwUdXi773+d4JaxPfcthYl/DMbKVEiMsJJ3REb2m0leF3FDHnCyvilRYIwqEIXIqEDAGvU93DK6px-----END RSA PRIVATE KEY-----";
    NSString *responseString = params[@"data"];
    if (responseString.length == 0) {
        return nil;
    }
    // base64编码替换
    NSString *responseString1 = [responseString stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    NSString *responseString2 = [responseString1 stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    NSUInteger mod4 = responseString2.length % 4;
    if (mod4 != 0) {
        NSString *mod5 = [@"====" substringFromIndex:mod4];
        responseString2  = [responseString2 stringByAppendingString:mod5];
    }
    
    NSData *inputData = [CCMBase64 dataFromBase64String:responseString2];
    
    CCMKeyLoader *keyLoader = [[CCMKeyLoader alloc] init];
    CCMPrivateKey *privateKey = [keyLoader loadRSAPEMPrivateKey:privkey];
    
    CCMCryptor *cryptor = [[CCMCryptor alloc] init];
    NSData *crytorData = [cryptor decryptData:inputData withPrivateKey:privateKey error:nil];
    
    id json = [NSJSONSerialization JSONObjectWithData:crytorData options:0 error:nil];
    NSDictionary *responseDic = (NSDictionary *)json;
    return responseDic;
}

@end
