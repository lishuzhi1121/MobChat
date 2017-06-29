//
//  ViewController.m
//  MobChat
//
//  Created by 李树志 on 2017/6/29.
//  Copyright © 2017年 李树志. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XMPPJID *jid = [XMPPJID jidWithUser:@"wangwu" domain:@"mob.com" resource:@"iOS"];
    [[MCXMPPManager sharedManager] loginWithJID:jid passwd:@"1121"];
}


@end
