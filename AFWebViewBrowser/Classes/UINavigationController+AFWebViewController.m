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

#import "UINavigationController+AFWebViewController.h"
#import <objc/runtime.h>

@implementation UINavigationController (AFWebViewController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class],
                                                        @selector(navigationBar:shouldPopItem:));
        Method swizzledMethod = class_getInstanceMethod([self class],
                                                        @selector(mk_navigationBar: shouldPopItem:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (BOOL)mk_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    BOOL shouldPopItem = [[self valueForKey:@"_isTransitioning"] boolValue];
    if (shouldPopItem) {
        return [self mk_navigationBar:navigationBar shouldPopItem:item];
    }
    
    UIViewController *topViewController = self.topViewController;
    if ([topViewController respondsToSelector:@selector(navigationBar:shouldPopItem:)]) {
        BOOL shouldPopItemAfterPopViewController = [(id<AFWebViewControllerBackBarButtonHandlerProtocol>)topViewController navigationBar:navigationBar shouldPopItem:item];
        
        if (shouldPopItemAfterPopViewController) {
            return [self mk_navigationBar:navigationBar shouldPopItem:item];
        }
        
        // Make sure the back indicator view alpha set to 1.0.
        [UIView animateWithDuration:0.25f animations:^{
            [[self.navigationBar subviews] lastObject].alpha = 1;
        }];
        
        return shouldPopItemAfterPopViewController;
    }
    return [self mk_navigationBar:navigationBar shouldPopItem:item];
}

@end
