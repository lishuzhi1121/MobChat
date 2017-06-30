//
//  MCContactsTableViewController.m
//  MobChat
//
//  Created by 李树志 on 2017/6/28.
//  Copyright © 2017年 mob. All rights reserved.
//

#import "MCContactsTableViewController.h"
#import "MCChatViewController.h"

static NSString *const reuseID = @"contact";

@interface MCContactsTableViewController ()<NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) NSFetchedResultsController *fetchController;
// 联系人数组
@property(nonatomic, strong) NSArray<XMPPUserCoreDataStorageObject *> *contacts;

@end

@implementation MCContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refreshData];
    
}

- (void)refreshData {
    NSError *error = nil;
    [self.fetchController performFetch:&error];
    self.contacts = self.fetchController.fetchedObjects;
    [self.tableView reloadData];
}

// 添加好友
- (IBAction)addContact:(UIBarButtonItem *)sender {
    
    XMPPJID *jid = [XMPPJID jidWithUser:@"lisi" domain:@"mob.com" resource:@"iOS"];
    [[MCXMPPManager sharedManager].xmppRoster addUser:jid withNickname:@"李四"];
//    [[MCXMPPManager sharedManager] addContactJID:jid nickName:@"李四"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    
    UIImageView *avatarImageView = [cell.contentView viewWithTag:1001];
    
    avatarImageView.image = [UIImage imageWithData:[[MCXMPPManager sharedManager].xmppAvatar photoDataForJID:self.contacts[indexPath.row].jid]];
    
    UILabel *label = [cell.contentView viewWithTag:1002];
    label.text = self.contacts[indexPath.row].jidStr;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [[MCXMPPManager sharedManager].xmppRoster removeUser:self.contacts[indexPath.row].jid];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }   
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    MCChatViewController *chatVC = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    chatVC.contactJID = self.contacts[indexPath.row].jid;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self refreshData];
}


#pragma mark - 懒加载

- (NSFetchedResultsController *)fetchController {
    
    if (!_fetchController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:[XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext];
        fetchRequest.entity = entity;
        // 设置过滤条件 出席并相互订阅的才是好友
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"subscription = 'both'"];
        fetchRequest.predicate = predicate;
        // 设置排序
        NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"jidStr" ascending:YES];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        _fetchController.delegate = self;
    }
    return _fetchController;
}



@end
