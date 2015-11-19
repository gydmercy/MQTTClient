//
//  HistoryViewController.m
//  MQTT
//
//  Created by Mercy on 15/7/14.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "HistoryViewController.h"
#import "AppDelegate.h"
#import "Message.h"
#import "HistoryTableViewCell.h"

@interface HistoryViewController() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSManagedObjectContext *context; // Core Data 上下文
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation HistoryViewController

// cell 标识符
static NSString *const cellIdentifer = @"History_Table_View_Cell";


#pragma mark - Lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"历史消息";
    
    [self initTableView];
    [self fetchMessageFromDB];
}

#pragma mark - Initialization

- (void)initTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:_tableView];
    
    // 注册 Cell
    UINib *cellNib = [UINib nibWithNibName:@"HistoryTableViewCell" bundle:nil];
    [_tableView registerNib:cellNib forCellReuseIdentifier:cellIdentifer];
}

// 获得 NSManagedObjectContext 对象
- (NSManagedObjectContext *)context {
    if (!_context) {
        AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
        _context = appdelegate.managedObjectContext;
    }
    return _context;
}

#pragma mark - Core Data

- (void)fetchMessageFromDB {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
//        NSLog(@"读取消息错误，ERROR：%@",error);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"读取消息错误"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[_fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
        
        return [sectionInfo numberOfObjects];
        
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Message *message  = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.typeLabel.text = [NSString stringWithFormat:@"[%@]", message.type];
    cell.contentLabel.text = message.content;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.dateLabel.text = [dateFormatter stringFromDate:message.date];
    
    return cell;
}


#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}


@end
