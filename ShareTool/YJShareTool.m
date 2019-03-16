//
//  YJShareTool.m
//  YJShareSDK
//
//  Created by nico on 2019/3/16.
//  Copyright © 2019 nico. All rights reserved.
//

#import "YJShareTool.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <WeiboSDK.h>
#import <TwitterKit/Twitter.h>
#import <TwitterKit/TwitterKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface YJShareTool () <WXApiDelegate,TencentSessionDelegate,WeiboSDKDelegate,QQApiInterfaceDelegate,WeiboSDKDelegate,FBSDKSharingDelegate>
{
    NSString *wxKey;
    NSString *wxSecret;
    NSString *tencentKey;
    NSString *wbKey;
    NSString *wbSecret;
    NSString *twKey;
    NSString *twSecret;
    NSString *fbKey;
    NSString *fbSecret;
    NSString *googleKey;
}

@property (nonatomic,strong) NSString *shareMessage;
@property (nonatomic,strong) UIImage *thumbImage;
@property (nonatomic,strong) NSData *imgData;
@property (nonatomic,strong) NSString *shareTitle;
@property (nonatomic,strong) NSString *shareDescription;
@property (nonatomic,strong) NSString *linkUrl;
@property (nonatomic,assign) NSInteger shareType;
@property (nonatomic,assign) int wxShareType;
@property (nonatomic,strong) ShareResponse shareResponse;
@property (nonatomic,strong) NSString* wbtoken;
@property (nonatomic,strong) TencentOAuth *tencentOAuth;
@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,assign) NSInteger tencentSharePlateForm;


@property (nonatomic, assign) BOOL userLogin;
@property (nonatomic, strong) NSMutableDictionary *info;
@property (nonatomic, copy) loginSuccessBlock loginSuccess;
@property (nonatomic, copy) loginFailureBlock loginFailure;

@end

static YJShareTool *shareTool;

@implementation YJShareTool

+(id)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareTool = [[YJShareTool alloc] init];
    });
    return shareTool;
}

- (void)registerWXAppKey:(NSString *)key secret:(NSString *)secret{
    [WXApi registerApp:key enableMTA:NO];
    wxKey = key;
    secret = secret;
}

- (void)registerQQAppKey:(NSString *)key{
    tencentKey = key;
}

- (void)registerWBAppKey:(NSString *)key{
    wbKey = key;
}

- (void)registerTwitterAppKey:(NSString *)key secret:(NSString *)secret{
    twKey = key;
    twSecret = secret;
    [[Twitter sharedInstance] startWithConsumerKey:key consumerSecret:secret];
}

#pragma mark - 系统回调
-(BOOL)shareOpenURL:(NSURL *)url key:(NSDictionary *)options{
    BOOL can=NO;
    NSString *str=[NSString stringWithFormat:@"%@",url];
    if ([str rangeOfString:wxKey].length) {
        can = [WXApi handleOpenURL:url delegate:self];
    }
    else if ([str rangeOfString:tencentKey].length){
        if (self.userLogin){
            can = [TencentOAuth HandleOpenURL:url];
        }
        else{
            can = [QQApiInterface handleOpenURL:url delegate:self];
        }
    }
    else if([str rangeOfString:twKey].length){
        can = [[Twitter sharedInstance] application:[UIApplication sharedApplication] openURL:url options:options];
    }
    else if([str rangeOfString:fbKey].length){
        can = [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    else if([str rangeOfString:googleKey].length){
//         can =  [[GIDSignIn sharedInstance] handleURL:url
//                                             sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                                                    annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    return can;
}

#pragma mark - 分享
-(void)shareMessage:(NSString *)message shareplatForm:(SharePlatFormType)sharePlatFormType shareResponse:(ShareResponse)shareResponse
{
    _shareMessage=message;
    _shareType=0;
    _shareResponse=shareResponse;
    switch (sharePlatFormType) {
        case SharePlatFormWXFriend:
            //微信好友
            [self wxSendMessage:WXSceneSession text:message];
            break;
        case SharePlatFormWXSpace:
            //微信朋友圈
            [self wxSendMessage:WXSceneTimeline text:message];
            break;
        case SharePlatFormSinaWeiBo:
            //新浪微博
            [self sinaWeiBoSendMessage:message];
            break;
        case SharePlatFormQQFriend:
            //QQ好友
            _tencentSharePlateForm=0;
            if (nil==_tencentOAuth) {
                _tencentOAuth=[[TencentOAuth alloc] initWithAppId:tencentKey andDelegate:nil];
            }
            [self tencentShareMessage:message];
            break;
        case SharePlatFormQQSpace:
            //QQ空间
            if (nil==_tencentOAuth) {
                _tencentOAuth=[[TencentOAuth alloc] initWithAppId:tencentKey andDelegate:nil];
            }
            _tencentSharePlateForm=1;
            [self tencentShareMessage:message];
            break;
        default:
            break;
    }
}

-(void)shareImage:(UIImage *)thumbImage imageData:(NSData *)imgData  message:(NSString *)message shareplatForm:(SharePlatFormType)sharePlatFormType shareResponse:(ShareResponse)shareResponse
{
    _thumbImage=thumbImage;
    _imgData=imgData;
    _shareType=1;
    _shareResponse=shareResponse;
    switch (sharePlatFormType) {
        case SharePlatFormWXFriend:
            //微信好友
            [self wxSendImage:WXSceneSession thumbImage:thumbImage sendImageData:imgData];
            break;
        case SharePlatFormWXSpace:
            //微信朋友圈
            [self wxSendImage:WXSceneTimeline thumbImage:thumbImage sendImageData:imgData];
            break;
        case SharePlatFormSinaWeiBo:
            //新浪微博
            [self sinaWeiBoSendImage:imgData message:message];
            break;
        case SharePlatFormQQFriend:
            //QQ好友
            if (nil==_tencentOAuth) {
                _tencentOAuth=[[TencentOAuth alloc] initWithAppId:tencentKey andDelegate:nil];
            }
            _tencentSharePlateForm=0;
            [self tencentShareImage:imgData title:message description:message];
            break;
        case SharePlatFormQQSpace:
            //QQ空间
            if (nil==_tencentOAuth) {
                _tencentOAuth=[[TencentOAuth alloc] initWithAppId:tencentKey andDelegate:nil];
            }
            _tencentSharePlateForm=1;
            [self tencentShareImage:imgData title:message description:message];
            break;
        default:
            break;
    }
}

-(void)shareLinkContentWithTitle:(NSString *)title description:(NSString *)description thumgImage:(UIImage *)thumgImage linkUrl:(NSString *)linkUrl currentVC:(UIViewController*)currentVC shareplatForm:(SharePlatFormType)sharePlatFormType shareResponse:(ShareResponse)shareResponse
{
    _shareTitle=title;
    _shareDescription=description;
    _thumbImage=thumgImage;
    _linkUrl=linkUrl;
    _shareType=2;
    _shareResponse=shareResponse;
    switch (sharePlatFormType) {
        case SharePlatFormWXFriend:
            //微信好友
            [self wxSendLinkContent:WXSceneSession title:title description:description thumbImage:thumgImage linkUrl:linkUrl];
            break;
        case SharePlatFormWXSpace:
            //微信朋友圈
            [self wxSendLinkContent:WXSceneTimeline title:title description:description thumbImage:thumgImage linkUrl:linkUrl];
            break;
        case SharePlatFormSinaWeiBo:
            //新浪微博
            [self sinaWeiBoSendLinkContent:title description:description imageData:UIImageJPEGRepresentation(thumgImage, 1.0) linkUrl:linkUrl];
            break;
        case SharePlatFormQQFriend:
            //QQ好友
            _tencentSharePlateForm=0;
            if (nil==_tencentOAuth) {
                _tencentOAuth=[[TencentOAuth alloc] initWithAppId:tencentKey andDelegate:nil];
            }
            [self tencentShareLinkContent:UIImageJPEGRepresentation(thumgImage, 1.0) title:title description:description linkUrl:linkUrl];
            break;
        case SharePlatFormQQSpace:
            //QQ空间
            _tencentSharePlateForm=1;
            if (nil==_tencentOAuth) {
                _tencentOAuth=[[TencentOAuth alloc] initWithAppId:tencentKey andDelegate:nil];
            }
            [self tencentShareLinkContent:UIImageJPEGRepresentation(thumgImage, 1.0) title:title description:description linkUrl:linkUrl];
            break;
        case SharePlatFormFB:
        {
            [self facebookShareLinkContent:UIImageJPEGRepresentation(thumgImage, 1.0) title:title description:description linkUrl:linkUrl];
        }break;
        case SharePlatFormTwitter:
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                TWTRComposer *com = [[TWTRComposer alloc]init];
                [com setText:description];
                [com setImage:thumgImage];
                [com setURL:[NSURL URLWithString:linkUrl]];
                [com showFromViewController:[YJShareTool getCurrentVC] completion:^(TWTRComposerResult result) {
                    NSLog(@"twitter分享结果：%ld", (long)result);
                    if(result == TWTRComposerResultCancelled)
                        self.shareResponse(ShareCancel,SharePlatFormTwitter);
                    else
                        self.shareResponse(ShareSuccess,SharePlatFormTwitter);
                }];
            }
            else {
                self.shareResponse(ShareFail,SharePlatFormTwitter);
            }
            break;
        }
        case SharePlatFormWhatsApp:
        {
            //            NSString *str = [NSString stringWithFormat:@"whatsapp://send?text=%@", linkUrl];
            //            NSURL *url = [NSURL URLWithString:str];
            //            if ([[UIApplication sharedApplication] canOpenURL:url]) {
            //                [[UIApplication sharedApplication]openURL:url];
            //            }
            //            else
            //            {
            //                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"分享失败，请确认是否安装App", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
            //                [alert show];
            //            }
        }
            break;
        default:
            break;
    }
}

#pragma mark -微信分享
/**
 *  发送纯文本
 */
-(void)wxSendMessage:(int)scene text:(NSString *)sendText
{
    _wxShareType=scene;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = sendText;
    req.bText = YES;
    req.scene = scene;
    [WXApi sendReq:req];
}
/**
 *  发送纯图片
 */
-(void)wxSendImage:(int)scene thumbImage:(UIImage *)thumbImage sendImageData:(NSData *)sendImageData
{
    _wxShareType=scene;
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:thumbImage];
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = sendImageData;
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_TAG_JUMP_APP";
    message.messageExt = @"华韩软件";
    message.messageAction = @"<action>dotalist</action>";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}
/**
 *  发送外链文章
 *
 */
- (void)wxSendLinkContent:(int)scene title:(NSString *)sendTitle description:(NSString *)sendDescription thumbImage:(UIImage *)thumbImage linkUrl:(NSString *)urlString
{
    if(![WXApi isWXAppInstalled]){
        _shareResponse(ShareUnInstail,SharePlatFormWXFriend);
        return;
    }
    _wxShareType=scene;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = sendTitle;
    message.description = sendDescription;
    [message setThumbImage:thumbImage];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = urlString;
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_TAG";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}

#pragma mark -tencent分享
-(void)tencentShareMessage:(NSString *)message
{
    QQApiTextObject *txtObj = [QQApiTextObject objectWithText:message];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
    QQApiSendResultCode sent;
    if (_tencentSharePlateForm==0) {
        sent= [QQApiInterface sendReq:req];
    }
    else{
        sent = [QQApiInterface SendReqToQZone:req];
    }
}

-(void)tencentShareImage:(NSData *)imgData title:(NSString *)title description:(NSString *)description
{
    QQApiImageObject *imgObj=[QQApiImageObject objectWithData:imgData previewImageData:imgData title:title description:description];
    SendMessageToQQReq *req=[SendMessageToQQReq reqWithContent:imgObj];
    QQApiSendResultCode sent;
    if (_tencentSharePlateForm==0) {
        sent= [QQApiInterface sendReq:req];
    }
    else{
        sent = [QQApiInterface SendReqToQZone:req];
    }
}
-(void)tencentShareLinkContent:(NSData *)imgData title:(NSString *)title description:(NSString *)description linkUrl:(NSString *)url
{
    if(![QQApiInterface isQQInstalled]){
        _shareResponse(ShareUnInstail,SharePlatFormQQFriend);
        return;
    }
    QQApiNewsObject *newsObj=[QQApiNewsObject objectWithURL:[NSURL URLWithString:url] title:title description:description previewImageData:imgData];
    SendMessageToQQReq *req=[SendMessageToQQReq reqWithContent:newsObj];
    QQApiSendResultCode sent;
    if (_tencentSharePlateForm==0) {
        sent= [QQApiInterface sendReq:req];
    }
    else{
        sent = [QQApiInterface SendReqToQZone:req];
    }
}

-(void)dealTencentSendCode:(QQApiSendResultCode)code
{
    SharePlatFormType ssShareType;
    if (_tencentSharePlateForm==0) {
        ssShareType=SharePlatFormQQFriend;
    }
    else{
        ssShareType=SharePlatFormQQSpace;
    }
    switch (code) {
        case EQQAPISENDSUCESS:
            _shareResponse(ShareSuccess,ssShareType);
            break;
        case EQQAPISENDFAILD:
            _shareResponse(ShareFail,ssShareType);
            break;
        default:
            _shareResponse(ShareError,ssShareType);
            break;
    }
}

#pragma mark -新浪微博分享
-(void)sinaWeiBoSendMessage:(NSString *)shareMessage
{
    WBMessageObject *message = [WBMessageObject message];
    message.text =shareMessage;
    [self sinaWeiBoShare:message];
}
-(void)sinaWeiBoSendImage:(NSData *)imageData message:(NSString *)sendTitle
{
    WBMessageObject *message = [WBMessageObject message];
    WBImageObject *image = [WBImageObject object];
    message.text=sendTitle;
    image.imageData = imageData;
    message.imageObject = image;
    [self sinaWeiBoShare:message];
}
-(void)sinaWeiBoSendLinkContent:(NSString *)title description:(NSString *)description imageData:(NSData *)imgData linkUrl:(NSString *)linkUrl
{
    
    WBMessageObject *message = [WBMessageObject message];
    
    WBImageObject *image = [WBImageObject object];
    
    image.imageData = imgData;
    message.imageObject = image;
    
    message.text = [description stringByAppendingString:linkUrl];
    [self sinaWeiBoShare:message];
}

-(void)sinaWeiBoShare:(WBMessageObject *)message
{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    authRequest.scope = @"all";
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:_wbtoken];
    
    [WeiboSDK sendRequest:request];
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

#pragma mark -facebook分享
- (void)facebookShareLinkContent:(NSData *)imgData title:(NSString *)title description:(NSString *)description linkUrl:(NSString *)url{
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:url];
    content.quote = title;

    [FBSDKShareDialog showFromViewController:[YJShareTool getCurrentVC]
                                 withContent:content
                                    delegate:self];
}


// FBSDKSharingDelegate 分享回调代理
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    NSString *postId = results[@"postId"];
    FBSDKShareDialog *dialog = (FBSDKShareDialog *)sharer;
    if (dialog.mode == FBSDKShareDialogModeBrowser && (postId == nil || [postId isEqualToString:@""])) {
        // 如果使用webview分享的，但postId是空的，
        // 这种情况是用户点击了『完成』按钮，并没有真的分享
        self.shareResponse(ShareCancel, SharePlatFormFB);
    } else {
        self.shareResponse(ShareSuccess, SharePlatFormFB);
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    self.shareResponse(ShareFail, SharePlatFormFB);
}


- (void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    self.shareResponse(ShareCancel, SharePlatFormFB);
}

#pragma mark - 登录
// qq登录
- (void)userLoginWithQQSuccess:(loginSuccessBlock)success  Failure:(loginFailureBlock)failure {
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_SHARE,
                            nil];
    self.tencentOAuth = [[TencentOAuth alloc]initWithAppId:tencentKey andDelegate:self];
    if ([TencentOAuth iphoneQQInstalled]) {
        [self.tencentOAuth authorize:permissions inSafari:NO];
    }else{
        [self.tencentOAuth authorize:permissions inSafari:YES];
    }
    self.userLogin = YES;
    self.loginSuccess = success;
    self.loginFailure = failure;
}

// 微信登录
- (void)userLoginWithWechatSuccess:(loginSuccessBlock)success Failure:(loginFailureBlock)failure {
    SendAuthReq *req =[[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo";
    req.state = wxKey;
    [WXApi sendReq:req];
    
    //BOLCK 回调
    self.loginSuccess = success;
    self.loginFailure = failure;
}

// 微博登录
- (void)userLoginWithWeiboSuccess:(loginSuccessBlock)success Failure:(loginFailureBlock)failure
{
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:wbKey];
    //需要app ID 和app secret
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = @"http://api.weibo.com/oauth2/default.html";

    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};

    [WeiboSDK sendRequest:request];


    self.userLogin = YES;
  //回调的block
    self.loginSuccess = success;
    self.loginFailure = failure;
}

//twitter登录
- (void)userLoginWithTwitterSuccess:(loginSuccessBlock)success Failure:(loginFailureBlock)failure{
    [[Twitter sharedInstance]  logInWithCompletion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
        if (session) {
            TWTRAPIClient *ac = [[TWTRAPIClient alloc]initWithUserID:session.userID];
            [ac loadUserWithID:session.userID completion:^(TWTRUser *user, NSError *error) {
                if (!error) {
                    self.info = [[NSMutableDictionary alloc]init];
                    [self.info setValue:[session userID] forKey:@"openid"];
                    [self.info setValue:user.name forKey:@"nickname"];
                    [self.info setValue:user.profileImageURL forKey:@"avatar"];
                    self.loginSuccess(self.info);
                }
                else
                {
                    self.loginFailure(@"登录失败，请重试.");
                }
            }];
            
        } else {
            self.loginFailure(@"登录失败，请重试.");
        }
    }];
}

// facebook 登录
- (void)userLoginWithFacebookSuccess:(loginSuccessBlock)success Failure:(loginFailureBlock)failure{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile"]
     fromViewController:[YJShareTool getCurrentVC]
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"FB:%@",error.localizedDescription);
             self.loginFailure(@"登录失败，请重试。");
         } else if (result.isCancelled) {
             self.loginFailure(@"取消登录");
         } else {
             if ([FBSDKAccessToken currentAccessToken]) {
                 NSDictionary*params=@{@"fields": @"id,name,gender,email,picture"}  ;
                 FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:result.token.userID parameters:params HTTPMethod:@"GET"];
                 [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,id result,NSError *error) {
                     NSLog(@"%@",result);
                     NSString*name=[result objectForKey:@"name"];
                     NSDictionary *pic = [result objectForKey:@"picture"];
                     [self.info setObject:name forKey:@"nickname"];
                     [self.info setObject:[pic objectForKey:@"data"][@"url"] forKey:@"avatar"];
                     self.loginSuccess(self.info);
                 }];
             }
         }
     }];
}

#pragma 微博代理回调放啊
-(void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        // NSString* userID = [sendMessageToWeiboResponse.authResponse userID];

        if (accessToken)
        {
            self.wbtoken = accessToken;
        }
        switch (response.statusCode) {
            case WeiboSDKResponseStatusCodeSuccess:
                _shareResponse(ShareSuccess,SharePlatFormSinaWeiBo);
                break;
            case WeiboSDKResponseStatusCodeSentFail:
                _shareResponse(ShareFail,SharePlatFormSinaWeiBo);
                break;
            case WeiboSDKResponseStatusCodeUserCancel:
                _shareResponse(ShareCancel,SharePlatFormSinaWeiBo);
                break;
            default:
                _shareResponse(ShareError,SharePlatFormSinaWeiBo);
                break;
        }
    }else if ([response isKindOfClass:[WBAuthorizeResponse class]]) {

        WBAuthorizeResponse *AuthoResponse = (WBAuthorizeResponse *)response;
        if (AuthoResponse) {
            NSString *openId = [AuthoResponse userID];
            NSString *toke = [AuthoResponse accessToken];
            if (toke) {
                _info = [[NSMutableDictionary alloc]init];
                [_info setObject:openId forKey:@"openid"];

             [WBHttpRequest requestWithAccessToken:toke url:@"https://api.weibo.com/2/users/show.json" httpMethod:@"GET" params:[NSDictionary  dictionaryWithObject:openId forKey:@"uid"] delegate:(id)self withTag:@"hello_xixi"];
            } else {
                self.loginFailure(@"登录失败，请重试。");
            }
        }
    }
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data
{
    NSDictionary *content = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];//转换数据格式
//    NSLog(@"%@",content); //这里会返回 一些Base Info
    [_info setObject:content[@"name"] forKey:@"nickname"];
    [_info setObject:content[@"avatar_hd"] forKey:@"avatar"];
    self.loginSuccess(_info);
    self.loginFailure = nil;
    self.loginSuccess = nil;
}

- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response
{
//    NSLog(@"%@",response);
}
- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
//    NSLog(@"%@",result);
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
//    NSLog(@"%@",error);
}

#pragma - mark qq登录代理方法
//登陆完成调用
- (void)tencentDidLogin
{
    if (self.tencentOAuth.accessToken &&  0 != self.tencentOAuth.accessToken.length)
    {
        //获取用户信息
        [self.tencentOAuth getUserInfo];
    }
    else
    {
        //NSLog(@"登录不成功没有获取accesstoken");
        self.loginFailure(@"登录不成功没有获取accesstoken。");
    }
}

//非网络错误导致登录失败：
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    //    NSLog(@"tencentDidNotLogin");
    if (cancelled)
    {
        self.loginFailure(@"用户取消登录。");
    }else{
        self.loginFailure(@"用户登录失败。");
    }
    
}
// 网络错误导致登录失败：
-(void)tencentDidNotNetWork
{
    if(self.loginFailure)
        self.loginFailure(@"网络链接失败，清检查您的网络设置。");
}

//获得用户信息方法调用
- (void)getUserInfoResponse:(APIResponse *)response {
    //  记录登录用户的OpenID
    _info = [[NSMutableDictionary alloc]init];
    if(self.tencentOAuth.openId)
        [_info setObject:self.tencentOAuth.openId forKey:@"openid"];
    if(response.jsonResponse[@"nickname"])
        [_info setObject:response.jsonResponse[@"nickname"] forKey:@"nickname"];
    if(response.jsonResponse[@"figureurl_2"])
        [_info setObject:response.jsonResponse[@"figureurl_2"] forKey:@"avatar"];
    self.loginSuccess(_info);
    self.loginFailure = nil;
    self.loginSuccess = nil;
}

#pragma - mark 微信qq代理回调
-(void)onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        SharePlatFormType ssShareType;
        if (_wxShareType==WXSceneSession) {
            ssShareType=SharePlatFormWXFriend;
        }
        else{
            ssShareType=SharePlatFormWXSpace;
        }
        if (resp.errCode==0) {
            //分享成功
            _shareResponse(ShareSuccess,ssShareType);
        }
        else if (resp.errCode==1){
            //普通错误类型
            _shareResponse(ShareError,ssShareType);
        }
        else if (resp.errCode==-2){
            //取消
            _shareResponse(ShareCancel,ssShareType);
        }
        else if (resp.errCode==-3){
            //发送失败
            _shareResponse(ShareFail,ssShareType);
        }
    }else if ([resp isKindOfClass:[QQBaseResp class]]) {
        NSInteger code = [((QQBaseResp*)resp).result integerValue];
        if (code==0) {
            //分享成功
            _shareResponse(ShareSuccess,0);
        }
        else if (code==-4){
            //取消
            _shareResponse(ShareCancel,0);
        }
        else if (resp.errCode==-3){
            //发送失败
            _shareResponse(ShareFail,0);
        }
    }else if ([resp isKindOfClass:[SendAuthResp class]]){
        if (resp.errCode == 0)
        {
            // statusCodeLabel.text = @"用户同意";
            SendAuthResp *aresp = (SendAuthResp *)resp;
            
            [self getAccessTokenWithCode:aresp.code];
            
        }else if (resp.errCode == -4){
            //statusCodeLabel.text = @"用户拒绝";
            self.loginFailure(@"用户拒绝");
        }else if (resp.errCode == -2){
            //statusCodeLabel.text = @"用户取消";
            self.loginFailure(@"用户取消");
        }
    }
}

- (void)isOnlineResponse:(NSDictionary *)response {
    NSLog(@"%@",response);
}


- (void)onReq:(QQBaseReq *)req {
    NSLog(@"%@",req);
}


- (void)getAccessTokenWithCode:(NSString *)code
{
    NSString *Urlpath = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token"];
    NSDictionary * urlDic = [NSDictionary dictionaryWithObjectsAndKeys:wxKey,@"appid",wxSecret,@"secret",code ,@"code",@"authorization_code",@"grant_type",nil];
    //网络加载
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDataTask *task = [manager GET:Urlpath parameters:urlDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //网络加载
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        [hud hideAnimated:YES];

        NSDictionary *dic = responseObject;
        NSString *token = [dic objectForKey:@"access_token"];
        NSString *openID = dic[@"openid"];
        self->_info = [[NSMutableDictionary alloc]init];
        [self->_info setObject:openID forKey:@"openid"];
        [self getUserInfo:token andOpenId:openID];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //网络加载
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        [hud hideAnimated:YES];

        self.loginFailure(@"登录失败，请重新登录！");
    }];
    [task resume];
}


-(void) getUserInfo:(NSString *)token andOpenId:(NSString *)openId
{
    NSString *Urlpath =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo"];
    NSDictionary *urlDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"access_token",openId,@"openid", nil];
    //网络加载
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDataTask *task = [manager GET:Urlpath parameters:urlDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //网络加载
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        [hud hideAnimated:YES];
        
        NSDictionary *dic = responseObject;
        [self->_info setObject:dic[@"nickname"] forKey:@"nickname"];
        [self->_info setObject:dic[@"headimgurl"] forKey:@"avatar"];
        self.loginSuccess(self->_info);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //网络加载
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        [hud hideAnimated:YES];
        
        self.loginFailure(@"登录失败，请重新登录！");
    }];
    [task resume];
}

#pragma mark - Util 获取当前视图控制器
+ (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    
    return currentVC;
}

- (UIView *)view{
    return [YJShareTool getCurrentVC].view;
}
@end
