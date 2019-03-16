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
    
 FAQ:
     
     1.为毛不跳转：
     在info.plist文件右键点击openAsSourceCode 然后复制下面添加
     <key>LSApplicationQueriesSchemes</key>
	<array>
		<string>wtloginmqq2</string>
		<string>mqqopensdkapiV3</string>
		<string>mqqwpa</string>
		<string>mqqopensdkapiV2</string>
		<string>mqqOpensdkSSoLogin</string>
		<string>mqq</string>
		<string>tim</string>
		<string>mqqapi</string>
		<string>mqqbrowser</string>
		<string>mttbrowser</string>
		<string>sinaweibohd</string>
		<string>sinaweibo</string>
		<string>weibosdk</string>
		<string>weibosdk2.5</string>
		<string>weixin</string>
		<string>wechat</string>
		<string>fbauth2</string>
		<string>line</string>
		<string>whatapp</string>
		<string>googlechrome</string>
		<string>googlechrome-x-callback</string>
		<string>hasgplus4</string>
		<string>google</string>
		<string>com.google.gppconsent</string>
		<string>com.google.gppconsent.2.2.0</string>
		<string>com.google.gppconsent.2.3.0</string>
		<string>com.google.gppconsent.2.4.0</string>
		<string>com.google.gppconsent.2.4.1</string>
		<string>twitter</string>
		<string>fbauth</string>
		<string>fb</string>
		<string>twitter</string>
		<string>twitterauth</string>
	</array>
    
    2.在target-project中的info下的URL types增加 URLSchemes
      新增一个 点击+
      identifier 填入 "wx" or "qq"
      URLSchemes 填入对应的key+平台名字 例如 tencent12123451 ， wx232xdd1s20fs2f003
    
	</array>
