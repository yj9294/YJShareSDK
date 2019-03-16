//
//  ViewController.m
//  YJShareSDK
//
//  Created by nico on 2019/3/16.
//  Copyright © 2019 nico. All rights reserved.
//

#import "ViewController.h"
#import "YJShareTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //微信登录
    [self doQQLogin];
}


- (void)doWeiXinlogin{
    // 测试
    //    微信登录
    [[YJShareTool sharedInstance] registerWXAppKey:@"wxf6c1836699e7a0ee" secret:@"2686bba537c6bba33bd2e9ba89083add"];
    [[YJShareTool sharedInstance] userLoginWithWechatSuccess:^(NSDictionary *info) {
        
    } Failure:^(NSString *failureMeg) {
        
    }];
}

- (void)doQQLogin{
    [[YJShareTool sharedInstance] registerQQAppKey:@"1105070496"];
    [[YJShareTool sharedInstance] userLoginWithQQSuccess:^(NSDictionary *info) {
        
    } Failure:^(NSString *failureMeg) {
        
    }];
}

- (void)doWeiboLogin{
    [[YJShareTool sharedInstance] registerWBAppKey:@"wb"];
    [[YJShareTool sharedInstance] userLoginWithWeiboSuccess:^(NSDictionary *info) {

    } Failure:^(NSString *failureMeg) {
    }];
}

- (void)doTwitterLogin{
    [[YJShareTool sharedInstance] registerTwitterAppKey:@"1kCjz3ibVlKaLeaAqA8sher9G" secret:@"zJJUBiHfqgJxvLNCmVSo6B4ZxRIBAKj0jKaD5a2e1Cza8gsOeW"];
    [[YJShareTool sharedInstance] userLoginWithTwitterSuccess:^(NSDictionary *info) {
        
    } Failure:^(NSString *failureMeg) {
        
    }];
}

- (void)doWXShare{
    [[YJShareTool sharedInstance] registerWXAppKey:@"wxf6c1836699e7a0ee" secret:@"2686bba537c6bba33bd2e9ba89083add"];
    [[YJShareTool sharedInstance] userLoginWithWechatSuccess:^(NSDictionary *info) {
        
    } Failure:^(NSString *failureMeg) {
        
    }];
    [[YJShareTool sharedInstance] shareLinkContentWithTitle:@"your title" description:@"your description" thumgImage:[UIImage imageNamed:@"your image"] linkUrl:@"your link url" currentVC:nil shareplatForm:SharePlatFormWXSpace shareResponse:^(ShareResponseCode responseCode, SharePlatFormType sharePlatFormType) {
        
    }];
}

@end
