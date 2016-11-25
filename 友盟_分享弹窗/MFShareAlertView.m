//
//  MFShareAlertView.m
//  com.diandian.yundong
//
//  Created by Timmy on 2016/11/4.
//  Copyright © 2016年 Techfaith. All rights reserved.
//

#import "MFShareAlertView.h"
#import "UMSocial.h"

#pragma mark - defaultShareSet
static NSString *const defaultShareTitle = @"点点运动";
static NSString *const defaultShareURL = @"点点运动";
static NSString *const defaultShareContent = @"点点运动";
#define MFDefaultShareImage [UIImage imageNamed:@"icon.png"];

@interface MFShareAlertView ()

//分享 view
@property (weak, nonatomic) IBOutlet UIView *shareDetailView;
//约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weChatLeading;

//点点运动
@property (weak, nonatomic) IBOutlet UIView *diandianView;
@property (weak, nonatomic) IBOutlet UIButton *diandianBtn;
@property (weak, nonatomic) IBOutlet UILabel *diandianLabel;
- (IBAction)diandianBtnClick:(id)sender;

//微信
@property (weak, nonatomic) IBOutlet UIView *weChatView;
@property (weak, nonatomic) IBOutlet UIButton *weChatBtn;
@property (weak, nonatomic) IBOutlet UILabel *weChatLabel;
- (IBAction)weChatBtnClick:(id)sender;

//微信朋友圈
@property (weak, nonatomic) IBOutlet UIView *wxFriendsCircleView;
@property (weak, nonatomic) IBOutlet UIButton *wxFriendsCircleBtn;
@property (weak, nonatomic) IBOutlet UILabel *wxFriendsCircleLabel;
- (IBAction)wxFriendsCircleBtnClick:(id)sender;

//QQ
@property (weak, nonatomic) IBOutlet UIView *QQView;
@property (weak, nonatomic) IBOutlet UIButton *QQBtn;
@property (weak, nonatomic) IBOutlet UILabel *QQLabel;
- (IBAction)QQBtnClick:(id)sender;


@end

@implementation MFShareAlertView

#pragma mark - custom View
-(void)awakeFromNib{
    [super awakeFromNib];
    //切圆角
    _shareDetailView.layer.masksToBounds = YES;
    _shareDetailView.layer.cornerRadius = 4;
    
    //四个按钮均分
    _subViewWidth.constant = (SCREEN_WIDTH - 20*2)/4;
    
}

#pragma mark - return shareAlertView 单例
+(instancetype)defaultShareAlertView{
    static dispatch_once_t onceToken;
    static MFShareAlertView *shareAlertView = nil;
    dispatch_once(&onceToken, ^{
        shareAlertView = [[[NSBundle mainBundle] loadNibNamed:@"MFShareAlertView" owner:self options:nil] firstObject];
        shareAlertView.frame = [UIApplication sharedApplication].keyWindow.frame;
    });
    return shareAlertView;
}

#pragma mark - 实例方法
-(void)showShareAlertView{
    [[UIApplication sharedApplication].windows.lastObject addSubview:self];
}

-(void)hideShareAlertView{
    [self removeFromSuperview];
}

-(void)setShareAlertWithTitle:(NSString *)title url:(NSString *)url content:(NSString *)content image:(UIImage *)image delegate:(id<MFShareAlertViewDelegate>)obj_class show:(BOOL)show_bool diandianbtnClick:(DianDianBtnClcik)block{
    self.title_share = title;
    self.url_share = url;
    self.content_share = content;
    self.image_share = image;
    
    if (!obj_class) {
        self.delegate = obj_class;
    }
    
    if (show_bool == YES) {
        [self showShareAlertView];
    }else{
        [self hideShareAlertView];
    }
    if (block) {
        self.diandianbtnClick = [block copy];
    }
}

#pragma mark - 各渠道分享点击事件
//点点运动
- (IBAction)diandianBtnClick:(id)sender {
    [self hideShareAlertView];
    self.diandianbtnClick();
}

//微信
- (IBAction)weChatBtnClick:(id)sender {
    [self hideShareAlertView];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.title = self.title_share;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = self.url_share;

    [[UMSocialDataService defaultDataService]  postSNSWithTypes:[NSArray arrayWithObjects:UMShareToWechatSession,nil] content:self.content_share image: self.image_share location:nil urlResource:nil presentedController:[UIApplication sharedApplication].keyWindow.rootViewController completion:^(UMSocialResponseEntity *response){
        
        [self getShareStaticsWithResponse:response shareType:kMFShareType_WeChat];
        
    }];

}

//微信朋友圈
- (IBAction)wxFriendsCircleBtnClick:(id)sender {
    [self hideShareAlertView];
    
    //设置微信好友或者朋友圈的分享url,下面是微信好友，微信朋友圈对应wechatTimelineData
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = self.url_share;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = self.content_share;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:[NSArray arrayWithObjects:UMShareToWechatTimeline,nil] content:self.content_share image: self.image_share location:nil urlResource:nil presentedController:[UIApplication sharedApplication].keyWindow.rootViewController completion:^(UMSocialResponseEntity *response){
        
        [self getShareStaticsWithResponse:response shareType:kMFShareType_wxFriendsCircle];
    }];

}

//QQ
- (IBAction)QQBtnClick:(id)sender {
    [self hideShareAlertView];
    
    [UMSocialData defaultData].extConfig.qqData.title = self.title_share;
    [UMSocialData defaultData].extConfig.qqData.url = self.url_share;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:self.content_share image:self.image_share location:nil urlResource:nil presentedController:[UIApplication sharedApplication].keyWindow.rootViewController completion:^(UMSocialResponseEntity *response){
        
        [self getShareStaticsWithResponse:response shareType:kMFShareType_QQ];
        
    }];
}

- (void)getShareStaticsWithResponse:(UMSocialResponseEntity *)response  shareType:(MFShareType)type{
    if (response.responseCode == UMSResponseCodeSuccess) {
        //分享成功
        if (_delegate && [_delegate respondsToSelector:@selector(successfulSharedWithShareAlert:)]) {
            [_delegate successfulSharedWithShareAlert:self];
        }
    }else{
        //分享失败
        if (_delegate && [_delegate respondsToSelector:@selector(failureShared:shareType:)]) {
            [_delegate failureShared:response shareType:type];
        }
    }
}

#pragma mark - touchMaskView action
- (IBAction)maskBtnViewClick:(id)sender {
    [self hideShareAlertView];
}

#pragma mark - re_getter/setter methods
-(NSString *)title_share{
    if (!_title_share) {
        return defaultShareTitle;
    }
    return _title_share;
}

-(NSString *)url_share{
    if (!_url_share) {
        return defaultShareURL;
    }
    return _url_share;
}

-(NSString *)content_share{
    if (!_content_share) {
        return defaultShareContent;
    }
    return _content_share;
}

-(UIImage *)image_share{
    if (!_image_share) {
        return MFDefaultShareImage;
    }
    return _image_share;
}

-(void)setFromVCtype:(FromVC)fromVCtype{
    if (fromVCtype == kFrom_MFSpuare) {
        //广场分享入口
        self.weChatLeading.constant = 0;
        _subViewWidth.constant = (SCREEN_WIDTH - 20*2)/3;

        self.diandianView.hidden = YES;
    }else{
        self.weChatLeading.constant = _subViewWidth.constant;
        self.diandianView.hidden = NO;
    }
}
@end
