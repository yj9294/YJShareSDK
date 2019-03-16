//
//  YJShareTool.h
//  YJShareSDK
//
//  Created by nico on 2019/3/16.
//  Copyright © 2019 nico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ShareResponseCode) {
    ShareSuccess=0,
    ShareError=1,
    ShareCancel=2,
    ShareFail=3,
    ShareUnInstail=4
} ;

typedef NS_ENUM(NSUInteger, SharePlatFormType) {
    SharePlatFormQQFriend=1,
    SharePlatFormQQSpace=1<<1,
    SharePlatFormWXFriend=1<<2,
    SharePlatFormWXSpace=1<<3,
    SharePlatFormSinaWeiBo=1<<4,
    SharePlatFormMessage=1<<5,
    SharePlatFormFB=1<<6,
    //  SharePlatFormLine=1<<7,
    SharePlatFormTwitter=1<<7,
    SharePlatFormWhatsApp=1<<8,
} ;

typedef void(^loginSuccessBlock)(NSDictionary *info);
typedef void(^loginFailureBlock)(NSString *failureMeg);
typedef void(^ShareResponse)(ShareResponseCode responseCode,SharePlatFormType sharePlatFormType);

@interface YJShareTool : NSObject
/*
 * 初始化
 */
+(id)sharedInstance;

/*
 * 注册微信key secret
 */
- (void)registerWXAppKey:(NSString *)key secret:(NSString *)secret;

/*
 * 注册qq key
 */
- (void)registerQQAppKey:(NSString *)key;

/*
 * 注册微博 key
 */
- (void)registerWBAppKey:(NSString *)key;

/*
 * 注册推特key
 */
- (void)registerTwitterAppKey:(NSString *)key secret:(NSString *)secret;
/*
 * 回调方法
 */
-(BOOL)shareOpenURL:(NSURL *)url key:(NSDictionary *)options;

/*
 * 分享方法
 */
-(void)shareMessage:(NSString *)message shareplatForm:(SharePlatFormType)sharePlatFormType shareResponse:(ShareResponse)shareResponse;

-(void)shareImage:(UIImage *)thumbImage imageData:(NSData *)imgData message:(NSString *)message shareplatForm:(SharePlatFormType)sharePlatFormType shareResponse:(ShareResponse)shareResponse;

-(void)shareLinkContentWithTitle:(NSString *)title description:(NSString *)description thumgImage:(UIImage *)thumgImage linkUrl:(NSString *)linkUrl currentVC:(UIViewController*)currentVC shareplatForm:(SharePlatFormType)sharePlatFormType shareResponse:(ShareResponse)shareResponse;

/*
 * 登录方法 需先注册相应的key
 */
- (void)userLoginWithQQSuccess:(loginSuccessBlock)success Failure:(loginFailureBlock)failure;

- (void)userLoginWithWechatSuccess:(loginSuccessBlock)success Failure:(loginFailureBlock)failure;

- (void)userLoginWithWeiboSuccess:(loginSuccessBlock)success Failure:(loginFailureBlock)failure;

- (void)userLoginWithTwitterSuccess:(loginSuccessBlock)success Failure:(loginFailureBlock)failure;

- (void)userLoginWithFacebookSuccess:(loginSuccessBlock)success Failure:(loginFailureBlock)failure;

@end

