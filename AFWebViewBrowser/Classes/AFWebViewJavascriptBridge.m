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

#import "AFWebViewJavascriptBridge.h"
#import "AFWebViewKitConstaints.h"

static NSMutableDictionary *WebViewHandlers;

@interface AFWebViewJavascriptBridge ()
@property (nonatomic, weak) WKWebView *webView;
@end

@implementation AFWebViewJavascriptBridge

+ (instancetype)bridgeForWebView:(WKWebView *)webView {
    AFWebViewJavascriptBridge *bridge = [[self alloc] init];
    [bridge setupForWebView:webView];
    return bridge;
}

- (void)setupForWebView:(WKWebView *)webView {
    _webView = webView;
    WebViewHandlers = [[NSMutableDictionary alloc] init];
    [self resigterHandlers];
}

/**
 在这里进行OC和JS的交互，使用的时候只需要关注这个方法即可
 */
- (void)resigterHandlers {
    [self registerHandler:@"ShareEvent" handler:^(id data, AFWebViewResponseCallback responseCallback) {
        responseCallback(@"responseCallback");
    }];
}

#pragma mark - Public Methods

- (void)registerHandler:(NSString *)handlerName handler:(AFWebViewHandler)handler {
    if ([[WebViewHandlers allKeys] containsObject:handlerName]) {
        return;
    }
    [WebViewHandlers setObject:handler forKey:handlerName];
    [self.webView.configuration.userContentController addScriptMessageHandler:self
                                                                         name:handlerName];
}

#pragma mark -
#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    AFLog(@"body:%@   name:%@", message.body, message.name);
    
    AFWebViewHandler handler = WebViewHandlers[message.name];
    AFWebViewResponseCallback responseCallback = ^(id responseData) {
        
    };
    handler(message.body, responseCallback);
}

@end
