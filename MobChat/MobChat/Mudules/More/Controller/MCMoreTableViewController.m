//
//  MCMoreTableViewController.m
//  MobChat
//
//  Created by 李树志 on 2017/6/30.
//  Copyright © 2017年 李树志. All rights reserved.
//

#import "MCMoreTableViewController.h"

@interface MCMoreTableViewController ()
// 头像
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
// JID
@property (weak, nonatomic) IBOutlet UILabel *jidLabel;
// nickName
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
// description
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation MCMoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.jidLabel.text = [MCXMPPManager sharedManager].xmppStream.myJID.bare;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    XMPPvCardTemp *myvCard = [MCXMPPManager sharedManager].xmppvCard.myvCardTemp;
    self.nickNameLabel.text = myvCard.nickname;
    self.descriptionLabel.text = myvCard.desc;
    self.headImageView.image = [UIImage imageWithData:myvCard.photo];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
