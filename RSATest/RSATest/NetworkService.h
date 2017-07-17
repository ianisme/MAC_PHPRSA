//
//  NetworkService.h
//  RSATest
//
//  Created by ian on 2017/7/18.
//  Copyright © 2017年 RengFou.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkService : NSObject

+ (instancetype)shareInstance;

- (void)appRSAPost:(NSString *)url parameters:(NSDictionary *)paramsters handler:(void(^)(BOOL successful, id response))handler;

- (void)appRSAGet:(NSString *)url parameters:(NSDictionary *)paramsters handler:(void(^)(BOOL successful, id response))handler;

@end
