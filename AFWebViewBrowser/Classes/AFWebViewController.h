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

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "AFWebViewKitConstaints.h"

@interface AFWebViewController : UIViewController

/**
 类似 网页由 wwww.baidu.com 提供
 */
@property (nonatomic, copy) NSString *supportFrom;

/**
 标记用户是否可以对网页内容进行复制粘贴以及事件调出，默认`NO`
 */
@property (nonatomic, assign) BOOL canUserInteracive;

/**
 导航方式：`微信`导航样式 | `Safari`导航样式
 
 默认：`微信`导航样式 [MKWebViewControllerNavigationStyleNavigationBar]
 */
@property (nonatomic, assign) AFWebViewControllerNavigationStyle navigationStyle;

/**
 进度条颜色
 */
@property (nonatomic, strong) UIColor *progressTintColor UI_APPEARANCE_SELECTOR;

/**
 导航栏`tintColor`
 */
@property (nonatomic, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR;

/**
 修改网页背景色，若果不设置此属性，默认颜色值`FFFFFF`
 */
@property (nonatomic, copy) NSString *backgroundColor UI_APPEARANCE_SELECTOR;

/**
 加载网页的`webView`
 */
@property (nonatomic, strong, readonly) WKWebView *webView;

/**
 加载网页URL
 */
@property (nonatomic, strong) NSURL *URL;

/**
 加载URL

 @param URL 链接`NSString`类型或者`NSURL`类型
 */
- (instancetype)initWithURL:(id)URL;

/**
 加载本地HTML内容
 */
- (instancetype)initWithHTMLString:(NSString *)htmlString
                           baseURL:(NSURL *)baseURL;


- (void)resetProgressViewAnimated:(BOOL)animated;

- (void)shouldUpdateNavigaitonBarOrToolBarInterface;

/**
 手动结束刷新
 */
- (void)endedLoadingRefreshHeader;

@end
