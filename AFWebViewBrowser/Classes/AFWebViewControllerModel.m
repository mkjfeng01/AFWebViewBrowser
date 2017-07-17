//Copyright © 2017 <https://github.com/mkjfeng01/WebViewBrowser>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFWebViewControllerModel.h"
#import "AFWebViewController.h"
#import "AFWebViewKitConstaints.h"
#import "AFWebViewInteractiveHandler.h"

//#if __has_include(<UIAlertController/UIAlertController.h>)
//#import <UIAlertController/UIAlertController.h>
//#else
//#import "UIAlertController.h"
//#endif

@interface AFWebViewControllerModel ()
@property (nonatomic, weak) AFWebViewController *webViewController;
@property (nonatomic, assign) BOOL emptyDataSetShouldDisplay;
@end

@implementation AFWebViewControllerModel

- (instancetype)initWithWebViewController:(AFWebViewController *)webViewController {
    self = [super init];
    if (self) {
        _webViewController = webViewController;
        _emptyDataSetShouldDisplay = NO;
    }
    return self;
}

#pragma mark - 
#pragma mark - WKUIDelegate

/**
 点击网页上某个标签时，是否创建新的WebView
 */
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    // AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));
    
    //*(http://www.jianshu.com/p/3a75d7348843)
    //*(http://stackoverflow.com/questions/25713069/why-is-wkwebview-not-opening-links-with-target-blank)
    if (!navigationAction.targetFrame.isMainFrame) {
        if (navigationAction.request) {
            [webView loadRequest:navigationAction.request];
        }
    }
    return nil;
}

- (void)webViewDidClose:(WKWebView *)webView {}

/**
 当网页有JavaScript弹窗时触发的方法
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    completionHandler();
    [self showAlertWithTitle:message ?: @"标题"
        textFieldPlacehodler:nil
               cancelHandler:NULL
              confrimHandler:NULL];
    completionHandler();
}

/**
 当网页有JavaScript弹窗时触发的方法
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    [self showAlertWithTitle:message ?: @"标题"
        textFieldPlacehodler:nil
               cancelHandler:^{
        completionHandler(NO);
    }
              confrimHandler:^(id object) {
        completionHandler(YES);
    }];
}

/**
 当网页有JavaScript带输入框样式的弹窗时触发的方法
 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    [self showAlertWithTitle:prompt ?: @"标题"
        textFieldPlacehodler:defaultText
               cancelHandler:^{
        completionHandler(nil);
    }
              confrimHandler:^(id object) {
        completionHandler(object);
    }];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0

// - (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo {}
//- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions {};
// - (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController {};

#endif


#pragma mark -
#pragma mark - WKNavigationDelegate

/**
 在即将加载网页时决定WKWebView是否进行加载/导航
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));

    //* (http://www.jianshu.com/p/3a75d7348843)
    //* (http://stackoverflow.com/questions/25713069/why-is-wkwebview-not-opening-links-with-target-blank)
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView evaluateJavaScript:WebViewEvaluateInteractiveBlankJavaScript
                  completionHandler:nil];
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

/**
 在收到响应后，决定是否跳转/加载
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    // AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/**
 页面开始加载触发的方法
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    // AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.webViewController shouldUpdateNavigaitonBarOrToolBarInterface];
}

/**
 接收到服务器跳转请求触发的方法
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));
}

/**
 页面开始加载时数据加载失败触发的方法
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));
    [self.webViewController resetProgressViewAnimated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self.webViewController shouldUpdateNavigaitonBarOrToolBarInterface];
    [self.webViewController endedLoadingRefreshHeader];
}

/**
 当内容开始返回触发的方法
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));
}

/**
 页面加载完成触发的方法
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));
    
    //-FIXED:6-2-2017 禁止用户交互
    if (!self.webViewController.canUserInteracive) {
        [webView evaluateJavaScript:AFWEBVIEWE_VALUETEINTERACTIVE_INJECTION_USERSELECTDISABLE
                  completionHandler:nil];
        [webView evaluateJavaScript:AFWEBVIEWE_VALUETEINTERACTIVE_INJECTION_TOUCHCALLOUTDISABLE
                  completionHandler:nil];
    }
    
    //-网页背景颜色注入
    NSString *backgroundColor = [NSString stringWithFormat:AFWebViewBrowserEvaluateJavaScriptString, self.webViewController.backgroundColor];
    [webView evaluateJavaScript:backgroundColor completionHandler:nil];
    
    self.webViewController.supportFrom = webView.URL.host;
    [self.webViewController resetProgressViewAnimated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [self.webViewController shouldUpdateNavigaitonBarOrToolBarInterface];
    [self.webViewController endedLoadingRefreshHeader];
}

/**
 页面加载过程中数据加载失败触发的方法
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));
    
    [self.webViewController resetProgressViewAnimated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // _emptyDataSetShouldDisplay = YES;
    // [self.webViewController.webView.scrollView reloadEmptyDataSet];
}

/**
 这与用于授权验证的API，与AFN、UIWebView的授权验证API是一样的
 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
     //AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView { }
#endif

#pragma mark - AFEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"Web Browser Has Fail Load";
    return [[NSAttributedString alloc] initWithString:text attributes:nil];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = [NSString stringWithFormat:@"Please check your network and try again."];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont boldSystemFontOfSize:17.0]
                             range:[attributedString.string rangeOfString:@""]];
    
    return attributedString;
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSString *text = @"Click Here To Try Again";
    UIFont *font = [UIFont systemFontOfSize:16.0];
    UIColor *textColor = [UIColor blueColor];
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIColor whiteColor];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -64.0;
}

#pragma mark - AFEmptyDataSetDelegate

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return _emptyDataSetShouldDisplay;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    AFLog(@"🔴类名与方法名：%@（在第%@行）", @(__PRETTY_FUNCTION__), @(__LINE__));
    
    _emptyDataSetShouldDisplay = NO;
    [self.webViewController.webView reload];
    [self.webViewController.webView.scrollView reloadEmptyDataSet];
}

#pragma mark -
#pragma mark - Private Methods

- (void)webView:(WKWebView *)webView withNavigationAction:(WKNavigationAction *)navigationAction shouldCreateNewWebViewCallBack:(AFUrlBoolResaultBlock)callback {
    NSURL *currentURL = webView.backForwardList.currentItem.URL;
    NSURL *requestURL = navigationAction.request.URL;
    
    //AFLog(@"*** \n%@ \n%@", requestURL, currentURL);
    
    //在研究过`招商银行`APP之后我发现并不是点击链接都会跳转创建新页面，有时候会在当前窗口加载新页面，所以这里取消了当`navigationAction.navigationType == WKNavigationTypeOther`时候的判断
    //FIXME:[已解决]增加了当链接最后边是带有`#`的URL时错误地打开新窗口的问题
    //FIXME:[已修复]当打开`www.tmall.com`时，点击`分类`会导致浏览器跳转两次，所以增加了`webViewNavigationType`的判断
    BOOL filteredLink = currentURL &&
    ! [requestURL isEqual:currentURL] &&
    ! [requestURL.absoluteString hasSuffix:@"#"] &&
    (navigationAction.navigationType == WKNavigationTypeLinkActivated) &&
    [requestURL.absoluteString hasPrefix:@"http"];
    
    !callback ?: callback(filteredLink, requestURL, nil);
}

- (void)showAlertWithTitle:(NSString *)title textFieldPlacehodler:(NSString *)placeholder cancelHandler:(void(^)())cancelHandler confrimHandler:(void(^)(id object))confirmHandler {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title
                                                                          message:nil
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    !placeholder ?: [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeholder;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                             style:UIAlertActionStyleCancel
                                                           handler:cancelHandler];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * _Nonnull action) {
        !confirmHandler ?: confirmHandler(placeholder? [controller.textFields firstObject].text : nil );
    }];
    [controller addAction:cancelAction];
    [controller addAction:confirmAction];
    
    [self.webViewController presentViewController:controller animated:YES completion:NULL];
}

@end
