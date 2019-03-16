# YJShareSDK
集成一些第三方登录和第三方分享 主要包含了微信 QQ 新浪微博 Facebook Twitter。

如下微信登录
    [[YJShareTool sharedInstance] registerWXAppKey:@"XXXXXXXXXX" secret:@"XXXXXXXXXXXXXX"];
    [[YJShareTool sharedInstance] userLoginWithWechatSuccess:^(NSDictionary *info) {
        
    } Failure:^(NSString *failureMeg) {
        
    }];
    XXXXXXXXXXXXX对应是自己的微信开发平台中应用的key 和secret。
    
    
 分享方法：
 [[YJShareTool sharedInstance] shareLinkContentWithTitle:@"your title" description:@"your description" thumgImage:[UIImage imageNamed:@"your image"] linkUrl:@"your link url" currentVC:nil shareplatForm:SharePlatFormWXSpace shareResponse:^(ShareResponseCode responseCode, SharePlatFormType sharePlatFormType) {
        
    }];
