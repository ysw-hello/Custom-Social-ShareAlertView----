//
//  MFShareAlertView.h
//  com.diandian.yundong
//
//  Created by Timmy on 2016/11/4.
//  Copyright © 2016年 Techfaith. All rights reserved.
//

/*****************************************************************************/

                        /* 注：目前只接受web类型的分享 */

/*****************************************************************************/

#import <UIKit/UIKit.h>

@class MFShareAlertView;

@class UMSocialResponseEntity;

//调出分享入口
typedef NS_ENUM(NSUInteger, FromVC) {
    kFrom_MFPaceDetail = 1,//配速详情
    kFrom_MFHistoryDetail,//运动记录详情
    kFrom_MFSpuare //广场
    
};
//分享渠道
typedef NS_ENUM(NSUInteger, MFShareType) {
    kMFShareType_WeChat = 1,//微信
    kMFShareType_wxFriendsCircle,//微信朋友圈
    kMFShareType_QQ,//QQ
};

typedef void(^DianDianBtnClcik)();

@protocol MFShareAlertViewDelegate <NSObject>

@optional
/// 分享成功的回调
-(void)successfulSharedWithShareAlert:(MFShareAlertView *)shareAlert;

/// 分享失败的回调
-(void)failureShared:(UMSocialResponseEntity *)response_code shareType:(MFShareType)type;

@end

@interface MFShareAlertView : UIView

/// 分享title
@property (nonatomic, strong) NSString *title_share;

/// 分享URL
@property (nonatomic, strong) NSString *url_share;

/// 分享content
@property (nonatomic, strong) NSString *content_share;

/// 分享image
@property (nonatomic, strong) UIImage *image_share;

/// 分享入口
@property (nonatomic, assign) FromVC fromVCtype;

/// 分享渠道
@property (nonatomic, assign) MFShareType shareType;

/// 分享delegate
@property (nonatomic, assign) id<MFShareAlertViewDelegate> delegate;

/// 点点 点击block 回调
@property (nonatomic, copy) DianDianBtnClcik diandianbtnClick;

/// shareAlertView 单例
+(instancetype)defaultShareAlertView;

/*实例方法**/
-(void)showShareAlertView;

-(void)hideShareAlertView;

-(void)setShareAlertWithTitle:(NSString *)title url:(NSString *)url content:(NSString *)content image:(UIImage *)image delegate:(id<MFShareAlertViewDelegate>)obj_class show:(BOOL)show_bool diandianbtnClick:(DianDianBtnClcik)block;


@end
