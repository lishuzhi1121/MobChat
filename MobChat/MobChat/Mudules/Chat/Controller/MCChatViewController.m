//
//  MCChatViewController.m
//  MobChat
//
//  Created by 李树志 on 2017/6/29.
//  Copyright © 2017年 李树志. All rights reserved.
//

#import "MCChatViewController.h"

static NSString *const sendReuseID = @"sended";
static NSString *const receiveReuseID = @"received";

@interface MCChatViewController ()<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate>
// 聊天信息tableView
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
// 查询结果控制器
@property(nonatomic, strong) NSFetchedResultsController *fetchController;

@property(nonatomic, strong) NSArray<XMPPMessageArchiving_Message_CoreDataObject *> *messages;

@end

@implementation MCChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置自动计算高度
    self.chatTableView.estimatedRowHeight = 200;
    self.chatTableView.rowHeight = UITableViewAutomaticDimension;
    
    [self refreshData];
}


- (void)refreshData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSError *error = nil;
        [self.fetchController performFetch:&error];
        
        self.messages = self.fetchController.fetchedObjects;
        
        [self.chatTableView reloadData];
        
        if (self.messages.count > 0) {
            [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *tempStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; //清空空格
    if([tempStr isEqualToString:@""] || tempStr.length == 0) {
        NSString *msg = @"发送的内容不能为空";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"消息提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:sure];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        textField.text = @"";
        return NO;
    }
    // type: 单聊为'chat' 群聊为'group'
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.contactJID];
    
    [msg addBody:textField.text];
    
    [[MCXMPPManager sharedManager].xmppStream sendElement:msg];
    
    textField.text = @"";
    return YES;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self refreshData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    XMPPMessageArchiving_Message_CoreDataObject *msgCDO = self.messages[indexPath.row];
    
    if (msgCDO.isOutgoing) { //发送
        
        cell = [tableView dequeueReusableCellWithIdentifier:sendReuseID forIndexPath:indexPath];
        
    } else { //接收
        
        cell = [tableView dequeueReusableCellWithIdentifier:receiveReuseID forIndexPath:indexPath];
    }
    
    UILabel *label = [cell.contentView viewWithTag:1002];
    label.text = msgCDO.body;
    
    return cell;
}




#pragma mark - 懒加载

- (NSFetchedResultsController *)fetchController {
    if (!_fetchController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext];
        fetchRequest.entity = entity;
        // 设置过滤条件 取出当前联系人的消息
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.contactJID.bare];
        fetchRequest.predicate = predicate;
        // 设置排序
        NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
        //设置代理
        _fetchController.delegate = self;
    }
    return _fetchController;
}



@end
