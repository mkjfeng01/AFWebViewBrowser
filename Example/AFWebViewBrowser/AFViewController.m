//
//  AFViewController.m
//  AFWebViewBrowser
//
//  Created by mkjfeng01 on 07/17/2017.
//  Copyright (c) 2017 mkjfeng01. All rights reserved.
//

#import "AFViewController.h"
#import <AFWebViewBrowser/AFWebViewController.h>

@interface AFViewController ()

@end

@implementation AFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*!
     *  请在`上一个界面`设置返回按钮标题
     */
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *tmallURL = @"https://www.tmall.com";
    
    if (indexPath.row == 0) {
        AFWebViewController *webviewController = [[AFWebViewController alloc] initWithURL:tmallURL];
        [self.navigationController pushViewController:webviewController animated:YES];
    } else if (indexPath.row == 1) {
        AFWebViewController *webviewController = [[AFWebViewController alloc] initWithURL:tmallURL];
        webviewController.navigationStyle = AFWebViewControllerNavigationStyleToolBar;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webviewController];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

@end
