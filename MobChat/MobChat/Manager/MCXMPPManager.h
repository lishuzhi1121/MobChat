//
//  MCXMPPManager.h
//  MobChat
//
//  Created by 李树志 on 2017/6/28.
//  Copyright © 2017年 mob. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCXMPPManager : NSObject

// 数据流对象,直接负责Socket通信
@property(nonatomic, strong) XMPPStream *xmppStream;
// 自动心跳检测
@property(nonatomic, strong) XMPPAutoPing *xmppAutoPing;
// 自动重连
@property(nonatomic, strong) XMPPReconnect *xmppReconnect;
// 好友模块
@property(nonatomic, strong) XMPPRoster *xmppRoster;
// 消息缓存模块
@property(nonatomic, strong) XMPPMessageArchiving *xmppMessageArchiving;

/**
 单例对象

 @return 单例对象
 */
+ (instancetype)sharedManager;

/**
 注册
 
 @param jid 账号
 @param passwd 密码
 */
- (void)registerJID:(XMPPJID *)jid passwd:(NSString *)passwd;

/**
 登录

 @param jid 账号
 @param passwd 密码
 */
- (void)loginWithJID:(XMPPJID *)jid passwd:(NSString *)passwd;

/**
 添加联系人

 @param jid 账号
 @param nickName 备注昵称
 */
- (void)addContactJID:(XMPPJID *)jid nickName:(NSString *)nickName;


@end
