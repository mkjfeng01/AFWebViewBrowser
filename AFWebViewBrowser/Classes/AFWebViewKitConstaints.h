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

#pragma mark - KVO Observing
///=======================================================================
/// @name KVO Observing
///=======================================================================

/*!
 KVO [NSString] 获取网页标题
 */
static NSString * const WebViewObserverTitleKeyPath = @"title";

/*!
 KVO [NSURL] 获取当前加载的URL
 */
static NSString * const WebViewObserverURLKeyPath = @"URL";

/*!
 KVO [BOOL] 浏览器是否正在加载
 */
static NSString * const WebViewObserverLoadingKeyPath = @"loading";

/*!
 KVO [double] 加载进度
 */
static NSString * const WebViewObserverEstimatedProgressKeyPath = @"estimatedProgress";

/*!
 KVO [BOOL] 标识加载的链接是否安全
 */
static NSString * const WebViewObserverHasOnlySecureContentKeyPath = @"hasOnlySecureContent";

/*!
 KVO [SecTrustRef] [iOS10+]
 */
static NSString * const WebViewObserverServerTrustKeyPath = @"serverTrust";


#pragma mark - Common Const
///=======================================================================
/// @name Common Const
///=======================================================================

/*!
 如果导航栏返回标题文字超过此数值，为防止文字显示过长，则按一定规则进行截取
 */
static NSUInteger const WebViewBackBarItemTitleMaxAllowedLength = 5;

/*!
 导航栏返回标题文字过长时截取到的文字下标
 */
static NSUInteger const WebViewBackBarItemTitleSubstringToIndex = 4;

/*!
 当页面开始加载时，如果导航栏返回按钮文字太长，那么截取一段文字，之后未显示完的文字显示为此变常量标记的
 */
static NSString * const WebViewBackBarItemAfterSubstringAppendedString = @"…";

/*!
 如果导航栏标题文字超过此数值，为防止文字显示过长，则按一定规则进行截取
 */
static NSUInteger const WebViewNavigationTitleMaxAllowedLength = 10;

/*!
 导航栏标题文字过长时截取到的文字下标
 */
static NSUInteger const WebViewNavigationTitleSubstringToIndex = 9;

/*!
 当页面加载时，如果导航栏标题文字太长，那么截取一段文字，之后未显示完的文字显示为此变常量标记的
 */
static NSString * const WebViewNavigationTitleAfterSubstringAppendedString = @"…";

#ifdef DEBUG
    #define AFLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);
#else
    #define AFLog(...)
#endif


#pragma mark - JavaScript Interactive
///=======================================================================
/// @name JavaScript Interactive
///=======================================================================

#define WebViewEvaluateInteractiveBlankJavaScript @" var a = document.getElementsByTagName('a'); "  \
                                                  @" for(var i=0; i<a.length; i++){ "               \
                                                      @" a[i].setAttribute('target', ''); "         \
                                                  @" } "


/**
 WebView`初始化的时候注入事件，禁止长按
 */
#define WebViewEvaluateInteractiveToucheCanJavaScript @"document.documentElement.style.webkitTouchCallout='none';"

/**
 设置默认背景色
 */
#define AFWebViewBrowserEvaluateJavaScriptString @"document.getElementsByTagName('body')[0].style.backgroundColor='#%@'"

/**
 事件注入，禁止用户同网页交互
 */
#define AFWEBVIEWE_VALUETEINTERACTIVE_INJECTION_USERSELECTDISABLE @"document.documentElement.style.webkitUserSelect='none';"


/**
 事件注入，禁止事件调出
 */
#define AFWEBVIEWE_VALUETEINTERACTIVE_INJECTION_TOUCHCALLOUTDISABLE @"document.documentElement.style.webkitTouchCallout='none';"


#pragma mark - WebView ViewController Life Time Block
///=======================================================================
/// @name WebView ViewController Life Time Block
///=======================================================================

typedef void (^AFVoidBlock) (void);
typedef void (^AFBoolResaultBlock) (BOOL succeed, NSError *error);
typedef void (^AFIntegerResaultBlock) (NSInteger index, NSError *error);
typedef void (^AFUrlBoolResaultBlock) (BOOL succeed, NSURL *URL, NSError *error);

typedef NS_ENUM(NSInteger, AFWebViewControllerNavigationStyle) {
    AFWebViewControllerNavigationStyleNavigationBar = 0,
    AFWebViewControllerNavigationStyleToolBar,
};

#pragma mark - UI & Color
///=======================================================================
/// @name UI & Color
///=======================================================================

/**
 判断设备类型是否是iPhone
 */
#define _UIUserInterfaceIdiomPhone_ UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone

/**
 判断设备类型是否是iPad
 */
#define _UIUserInterfaceIdiomPad_ UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

/**
 白色
 */
#define _WebViewBrowserDefaultBackgroundColor @"FFFFFF"

/**
 进度条默认颜色，默认蓝色
 */
#define kProgressViewDefaultProgressTintColor [UIColor blueColor]

/**
 导航栏默认`tintColor`
 */
#define kNavigationBarDefaultTintColor [UIColor colorWithRed:0.100f green:0.100f blue:0.100f alpha:0.800f]
