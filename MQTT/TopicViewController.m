//
//  TopicViewController.m
//  MQTT
//
//  Created by Mercy on 15/11/18.
//  Copyright © 2015年 Mercy. All rights reserved.
//

#import "TopicViewController.h"

@interface TopicViewController () <UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *topicTextField;  //!< 输入主题

@end

@implementation TopicViewController


#pragma mark - Lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"输入主题";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(certainButtonAction:)];
    
    [self initTableView];
}


#pragma mark - Initialization

- (void)initTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

- (UITextField *)topicTextField {
    if (!_topicTextField) {
        _topicTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, self.view.frame.size.width - 20, 34)];
        _topicTextField.delegate = self;
        _topicTextField.returnKeyType = UIReturnKeyDone;
        _topicTextField.placeholder = @"请输入主题名称";
    }
    return _topicTextField;
}


#pragma mark - Actions

- (void)certainButtonAction:(id)sender {
    
    if ([self.topicTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"主题不能为空"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        // 传递“主题”值
        if (self.passTopicBlock) {
            self.passTopicBlock(self.topicTextField.text);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; // 键盘隐藏
    
    return YES;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell_Identifier"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell addSubview:self.topicTextField];
    
    return cell;
}



@end
