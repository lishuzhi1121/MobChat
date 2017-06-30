//
//  MCMoreInfoTableViewController.m
//  MobChat
//
//  Created by 李树志 on 2017/6/30.
//  Copyright © 2017年 李树志. All rights reserved.
//

#import "MCMoreInfoTableViewController.h"
#import "MCEditTableViewController.h"

@interface MCMoreInfoTableViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation MCMoreInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    XMPPvCardTemp *myvCard = [MCXMPPManager sharedManager].xmppvCard.myvCardTemp;
    self.nickNameLabel.text = myvCard.nickname;
    self.descriptionLabel.text = myvCard.desc;
    self.headImageView.image = [UIImage imageWithData:myvCard.photo];
}


- (IBAction)avatarImageViewClick:(UITapGestureRecognizer *)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    XMPPvCardTemp *myvCard = [MCXMPPManager sharedManager].xmppvCard.myvCardTemp;
    
    myvCard.photo = UIImageJPEGRepresentation(image, 0.1);
    
    [[MCXMPPManager sharedManager].xmppvCard updateMyvCardTemp:myvCard];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    MCEditTableViewController *editVC = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"nickName"]) {
        editVC.title = @"修改昵称";
        
        
    } else if ([segue.identifier isEqualToString:@"description"]) {
        editVC.title = @"修改签名";
        
    }
}

@end
