//
//  MCEditTableViewController.m
//  MobChat
//
//  Created by 李树志 on 2017/6/30.
//  Copyright © 2017年 李树志. All rights reserved.
//

#import "MCEditTableViewController.h"

@interface MCEditTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *editTextField;

@end

@implementation MCEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XMPPvCardTemp *myvCard = [MCXMPPManager sharedManager].xmppvCard.myvCardTemp;
    if ([self.title isEqualToString:@"修改昵称"]) {
        
        self.editTextField.text = myvCard.nickname;
        
    } else if ([self.title isEqualToString:@"修改签名"]) {
        
        self.editTextField.text = myvCard.desc;
    }
    
}

- (IBAction)cancelItemClick:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)saveItemClick:(UIBarButtonItem *)sender {
    
    XMPPvCardTemp *myvCard = [MCXMPPManager sharedManager].xmppvCard.myvCardTemp;
    
    if ([self.title isEqualToString:@"修改昵称"]) {
        
        myvCard.nickname = self.editTextField.text;
        
    } else if ([self.title isEqualToString:@"修改签名"]) {
        
        myvCard.desc = self.editTextField.text;
    }
    
    [[MCXMPPManager sharedManager].xmppvCard updateMyvCardTemp:myvCard];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
