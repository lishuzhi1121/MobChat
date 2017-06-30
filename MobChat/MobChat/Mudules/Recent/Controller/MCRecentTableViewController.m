//
//  MCRecentTableViewController.m
//  MobChat
//
//  Created by 李树志 on 2017/6/30.
//  Copyright © 2017年 李树志. All rights reserved.
//

#import "MCRecentTableViewController.h"
#import "MCChatViewController.h"

static NSString *const reuseID = @"recent";

@interface MCRecentTableViewController ()<NSFetchedResultsControllerDelegate>

// 查询结果控制器
@property(nonatomic, strong) NSFetchedResultsController *fetchController;

@property(nonatomic, strong) NSArray<XMPPMessageArchiving_Contact_CoreDataObject *> *recentContacts;

@end

@implementation MCRecentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refreshData];
}

- (void)refreshData {
    
    NSError *error = nil;
    [self.fetchController performFetch:&error];
    
    self.recentContacts = self.fetchController.fetchedObjects;
    
    [self.tableView reloadData];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self refreshData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recentContacts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    
    XMPPMessageArchiving_Contact_CoreDataObject *recentContact = self.recentContacts[indexPath.row];
    
    UIImageView *avatarImageView = [cell.contentView viewWithTag:1001];
    
    avatarImageView.image = [UIImage imageWithData:[[MCXMPPManager sharedManager].xmppAvatar photoDataForJID:recentContact.bareJid]];
    
    UILabel *nameLabel = [cell.contentView viewWithTag:1002];
    nameLabel.text = recentContact.bareJidStr;
    
    UILabel *contentLabel = [cell.contentView viewWithTag:1003];
    contentLabel.text = recentContact.mostRecentMessageBody;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    MCChatViewController *chatVC = segue.destinationViewController;
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    chatVC.contactJID = self.recentContacts[indexPath.row].bareJid;
}


#pragma mark - 懒加载

- (NSFetchedResultsController *)fetchController {
    if (!_fetchController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Contact_CoreDataObject" inManagedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext];
        fetchRequest.entity = entity;
        // 设置排序
        NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"mostRecentMessageTimestamp" ascending:NO];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
        //设置代理
        _fetchController.delegate = self;
    }
    return _fetchController;
}



@end
