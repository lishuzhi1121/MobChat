//
//  MCXMPPManager.m
//  MobChat
//
//  Created by 李树志 on 2017/6/28.
//  Copyright © 2017年 mob. All rights reserved.
//

#import "MCXMPPManager.h"
#import "XMPPLogging.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

static NSString *const hostName = @"127.0.0.1";
static const UInt16 hostPort = 5222;

static MCXMPPManager *instance = nil;

@interface MCXMPPManager()<XMPPStreamDelegate, XMPPAutoPingDelegate, XMPPRosterDelegate>

// 账号密码
@property(nonatomic, copy) NSString *passwd;
// 是否是登录,不是则为注册
@property(nonatomic, assign, getter=isLogin) BOOL login;


@end

@implementation MCXMPPManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MCXMPPManager alloc] init];
        // 初始化XMPP通信日志
        [instance setupLogging];
        // 初始化模块
        [instance setupModules];
    });
    
    return instance;
}

#pragma mark - 通信日志

- (void)setupLogging {
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
}


#pragma mark - 注册

- (void)registerJID:(XMPPJID *)jid passwd:(NSString *)passwd {
    
    self.login = NO;
    self.passwd = passwd;
    self.xmppStream.myJID = jid;
    self.xmppStream.hostName = hostName;
    self.xmppStream.hostPort = hostPort;
    
    NSError *error = nil;
    BOOL success = [self.xmppStream connectWithTimeout:-1.0 error:&error];
    
    if (!success) {
        NSLog(@"连接服务器失败：%@", error);
    }
}

#pragma mark - 登录

- (void)loginWithJID:(XMPPJID *)jid passwd:(NSString *)passwd {
    
    self.login = YES;
    self.passwd = passwd;
    self.xmppStream.myJID = jid;
    self.xmppStream.hostName = hostName;
    self.xmppStream.hostPort = hostPort;
    
    NSError *error = nil;
    BOOL success = [self.xmppStream connectWithTimeout:-1.0 error:&error];
    
    if (!success) {
        NSLog(@"连接服务器失败：%@", error);
    }
}

#pragma mark - 添加联系人

- (void)addContactJID:(XMPPJID *)jid nickName:(NSString *)nickName {
    
    [self.xmppRoster addUser:jid withNickname:nickName];
}

#pragma mark - 模块

- (void)setupModules {
    // 模块使用一般步骤: 创建模块->设置属性->(监听数据)->激活模块
    
    // 心跳检测模块
    self.xmppAutoPing.pingInterval = 10.0f;
    self.xmppAutoPing.pingTimeout = 10.0f;
    self.xmppAutoPing.respondsToQueries = YES;
    [self.xmppAutoPing addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppAutoPing activate:self.xmppStream];
    
    // 自动重连
    self.xmppReconnect.reconnectDelay = 3.0f;
    [self.xmppReconnect activate:self.xmppStream];
    
    // 花名册模块
    self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = NO;
    self.xmppRoster.autoFetchRoster = YES;
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppRoster activate:self.xmppStream];
    
    // 消息缓存模块
    [self.xmppMessageArchiving activate:self.xmppStream];
    
    // 电子名片模块
    [self.xmppvCard activate:self.xmppStream];
    
    // 头像模块
    [self.xmppAvatar activate:self.xmppStream];
}


#pragma mark - XMPPStreamDelegate

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"连接服务器成功!");
    
    NSError *error = nil;
    if (self.isLogin) {
        BOOL success = [self.xmppStream authenticateWithPassword:self.passwd error:&error];
        if (!success) {
            NSLog(@"登录认证失败：%@", error);
        }
    } else {
        BOOL success = [self.xmppStream registerWithPassword:self.passwd error:&error];
        if (!success) {
            NSLog(@"注册失败：%@", error);
        }
    }
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    NSLog(@"注册成功!");
    
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"登录成功!");
    
//    NSError *error = nil;
//    XMPPPresence *presence = [[XMPPPresence alloc] initWithXMLString:@"<presence type=\"available\" />" error:&error];
    XMPPPresence *presence = [XMPPPresence presence];
    DDXMLElement *showElement = [DDXMLElement elementWithName:@"show" stringValue:@"chat"];
    [presence addChild:showElement];
    // 必须先设置默认可选状态
    DDXMLElement *statusElement = [DDXMLElement elementWithName:@"status" stringValue:@"来找我呀~"];
    [presence addChild:statusElement];
    
    [self.xmppStream sendElement:presence];
    
    // 登录成功后切换跟控制器
    [UIApplication sharedApplication].keyWindow.rootViewController = [[UIStoryboard storyboardWithName:@"Root" bundle:nil] instantiateInitialViewController];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"连接已断开!");
    
}

#pragma mark - XMPPAutoPingDelegate

- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender {
    NSLog(@"心跳检测正常!");
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender {
    NSLog(@"心跳检测超时!");
}

#pragma mark - XMPPRosterDelegate

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    // 这里要区分"我主动加别人"还是"别人加我"?
    // CoreData 查询数据
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:[XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext];
    fetchRequest.entity = entity;
    // 设置过滤条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ask = 'subscribe'"];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *result = [[XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (XMPPUserCoreDataStorageObject *contact in result) {
        // 我主动添加别人的时候,别人订阅我时直接同意.
        if ([contact.jid.bare isEqualToString:presence.from.bare]) {
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
            NSString *msg = [NSString stringWithFormat:@"%@ 已经同意添加您为好友!", presence.from.bare];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"好友通知" message:msg preferredStyle:UIAlertControllerStyleAlert];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alertController dismissViewControllerAnimated:YES completion:nil];
                });
            }];
            
            return;
        }
    }
    
    // 下面是别人加我为好友
    NSString *msg = [NSString stringWithFormat:@"收到来自 %@ 的好友请求!", presence.from.bare];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"好友请求" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.xmppRoster rejectPresenceSubscriptionRequestFrom:presence.from];
    }];
    [alertController addAction:cancel];
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
    }];
    [alertController addAction:sure];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    
}


#pragma mark - 懒加载

- (XMPPStream *)xmppStream {
    if (!_xmppStream) {
        _xmppStream = [[XMPPStream alloc] init];
        // 设置代理 监听连接情况
        // 多播代理 类似通知,但是比通知强大
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _xmppStream;
}

- (XMPPAutoPing *)xmppAutoPing {
    if (!_xmppAutoPing) {
        _xmppAutoPing = [[XMPPAutoPing alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    }
    return _xmppAutoPing;
}

- (XMPPReconnect *)xmppReconnect {
    if (!_xmppReconnect) {
        _xmppReconnect = [[XMPPReconnect alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    }
    return _xmppReconnect;
}

- (XMPPRoster *)xmppRoster {
    if (!_xmppRoster) {
        _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:[XMPPRosterCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_main_queue()];
    }
    return _xmppRoster;
}

- (XMPPMessageArchiving *)xmppMessageArchiving {
    if (!_xmppMessageArchiving) {
        _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:[XMPPMessageArchivingCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_main_queue()];
    }
    return _xmppMessageArchiving;
}

- (XMPPvCardTempModule *)xmppvCard {
    if (!_xmppvCard) {
        _xmppvCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:[XMPPvCardCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_main_queue()];
    }
    return _xmppvCard;
}

- (XMPPvCardAvatarModule *)xmppAvatar {
    if (!_xmppAvatar) {
        _xmppAvatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCard dispatchQueue:dispatch_get_main_queue()];
    }
    return _xmppAvatar;
}

@end
