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

#import "AFWebViewInteractiveHandler.h"
#import "AFWebViewController.h"

@implementation AFWebViewInteractiveHandler

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedHandler];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [self sharedHandler];
}

+ (instancetype)sharedHandler {
    AFWebViewInteractiveHandler *handler = nil;
    @synchronized (self) {
        if (handler == nil) {
            handler = [[super allocWithZone:nil] init];
        }
    }
    return handler;
}

- (void)loadRequestWithURL:(NSURL *)URL {
    AFWebViewController *webViewController = [[AFWebViewController alloc] initWithURL:URL];
    [[self topViewController].navigationController pushViewController:webViewController
                                                             animated:YES];
}

- (void)webViewController:(AFWebViewController *)webViewController shouldLoadRequestWithURL:(NSURL *)URL {
    /*!
     *  每次接收到页面跳转请求都是走这个方法，如果不使用下边的这个默认方法创建控制器的话，可以自己在这个模型里边建一个Block回调，将`webViewController`和`URL`回调出去，按照自己的需求进行页面交互方式处理
     */
    
    if (self.shouldLoadRequestHandler) {
        self.shouldLoadRequestHandler(webViewController, URL);
    }
    else { //-使用默认方式进行处理
        AFWebViewController *webViewController = [[AFWebViewController alloc] initWithURL:URL];
        webViewController.navigationStyle = webViewController.navigationStyle;
        [[self topViewController].navigationController pushViewController:webViewController
                                                                 animated:YES];
    }
}

- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
