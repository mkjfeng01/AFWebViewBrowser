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

#import "AFWebViewController.h"
#import "AFWebViewControllerModel.h"
#import "UINavigationController+AFWebViewController.h"
#import "AFWebViewJavascriptBridge.h"

#if __has_include(<AFPopUpMenu/AFPopUpMenu.h>)
#import <AFPopUpMenu/AFPopUpMenu.h>
#else
#import "AFPopUpMenu.h"
#endif
#if __has_include(<Masonry/Masonry.h>)
    #import <Masonry/Masonry.h>
#else
    #import "Masonry.h"
#endif
//#if __has_include(<MJRefresh/MJRefresh.h>)
//    #import <MJRefresh/MJRefresh.h>
//#else
//    #import "MJRefresh.h"
//#endif

@interface AFWebViewController ()

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, copy) NSString *htmlString;

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) AFWebViewControllerModel *webViewControllerModel;
@property (nonatomic, strong) AFWebViewJavascriptBridge *bridge;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *supportFromLabel;

@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *closeBarButtonItem;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem *toolBarBackBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *toolBarForwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *toolBarStopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *toolBarRefreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *toolBarActionBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *doneBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *fixedSpaceBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *fixiableSpaceBarButtonItem;

@property (nonatomic, strong) UIBarButtonItem *tabbarMoreBarButtonItem;

@end

@implementation AFWebViewController

#pragma mark - 
#pragma mark - Initial Methods

- (instancetype)initWithURL:(id)URL {
    self = [super init];
    if (self) {
        if ([URL isKindOfClass:[NSURL class]]) {
            _URL = URL;
        } else if ([URL isKindOfClass:[NSString class]]) {
            _URL = [NSURL URLWithString:URL];
        } else {
            NSAssert(URL, @"无法识别的`URL`类型");
        }
    }
    return self;
}

- (instancetype)initWithHTMLString:(NSString *)htmlString baseURL:(NSURL *)baseURL {
    self = [super init];
    if (self) {
        _htmlString = htmlString;
        _baseURL = baseURL;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateNavigationItemTitleWithTitle:self.webView.title];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // self.automaticallyAdjustsScrollViewInsets = NO;
    // self.extendedLayoutIncludesOpaqueBars = YES;
    // self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    //-默认背景颜色
    self.backgroundColor = self.backgroundColor ?: _WebViewBrowserDefaultBackgroundColor;
    self.canUserInteracive = self.canUserInteracive ?: NO;
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    self.navigationStyle = self.navigationStyle ?: AFWebViewControllerNavigationStyleNavigationBar;
    
    // 设置标题文字大小
     [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.f]}];
    
    self.navigationController.navigationBar.translucent = NO; //设置不透明
    self.navigationController.navigationBar.tintColor = kNavigationBarDefaultTintColor;
    
    [self setup];
    [self addObserver];
    [self registerWebViewJavaScriptBridge];
    [self startLoadRequestWithURL:self.URL];
}

/*!
 *  注册JS交互事件
 */
- (void)registerWebViewJavaScriptBridge {
    [AFWebViewJavascriptBridge bridgeForWebView:self.webView];
}

- (void)setup {
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.bottom.and.right.equalTo(self.view);
    }];
    
    //FIXED:修复进度条有时候一直存在的问题
    // UIView *barBackgroundView = [self.navigationController.navigationBar.subviews firstObject];
    [self.webView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.webView);
        make.top.equalTo(self.webView.mas_top);
        make.height.equalTo(@(2));
    }];
    
    [self.webView.scrollView insertSubview:self.supportFromLabel atIndex:0];
    [self.supportFromLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.webView.scrollView);
        make.top.equalTo(self.view).with.offset(15);
    }];
    
//    __weak __typeof(self) weakSelf = self;
//    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [weakSelf.webView reload];
//    }];
    
    if (self.navigationStyle == AFWebViewControllerNavigationStyleNavigationBar) {
        self.navigationItem.rightBarButtonItem = self.tabbarMoreBarButtonItem;
    }
    
//    self.webView.scrollView.emptyDataSetSource = self.webViewControllerModel;
//    self.webView.scrollView.emptyDataSetDelegate = self.webViewControllerModel;
}

- (void)startLoadRequestWithURL:(NSURL *)URL {
    NSURLRequest *request = [NSURLRequest requestWithURL:URL
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:20];
    [self.webView loadRequest:request];
}

- (void)addObserver {
    [self.webView addObserver:self forKeyPath:WebViewObserverTitleKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:WebViewObserverURLKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:WebViewObserverLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:WebViewObserverEstimatedProgressKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:WebViewObserverTitleKeyPath];
    [self.webView removeObserver:self forKeyPath:WebViewObserverURLKeyPath];
    [self.webView removeObserver:self forKeyPath:WebViewObserverLoadingKeyPath];
    [self.webView removeObserver:self forKeyPath:WebViewObserverEstimatedProgressKeyPath];
    AFLog(@"%s", __FUNCTION__);
}

#pragma mark -
#pragma mark - Override

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (![self.navigationController.topViewController isKindOfClass:[self class]]) {
        return YES;
    }
    if (self.progressView.progress != 1.f) {
        [self resetProgressViewAnimated:YES];
    }
    if (self.webView.canGoBack) {
        ![self.webView isLoading] ?: [self.webView stopLoading];
        [self.webView goBack];
        [self.webView reload]; //-返回之后刷新页面
        return NO;
    } else {
        //-将进度条移除
        [self.progressView removeFromSuperview];
        return YES;
    }
}

#pragma mark -
#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    id value = change[NSKeyValueChangeNewKey];
    if (keyPath == WebViewObserverTitleKeyPath) {
        NSString *title = value;
        [self updateNavigationItemTitleWithTitle:title];
    }
    if (keyPath == WebViewObserverURLKeyPath) {
        //AFLog(@"地址：%@", value);
    }
    if (keyPath == WebViewObserverLoadingKeyPath) {
        //AFLog(@"加载：%@", value);
    }
    if (keyPath == WebViewObserverEstimatedProgressKeyPath) {
        //AFLog(@"进度：%@", value);
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        [self updateProgressViewWithProgress:progress];
    }
}

#pragma mark - Action Methods
//返回
- (void)customBarButtonItemPressed {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        return;
    }
    [self closeBarButtonItemPressed];
}
//关闭
- (void)closeBarButtonItemPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toolBarBackBarButtonItemPressed {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (void)toolBarForwardBarButtonItemPressed {
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

- (void)toolBarStopBarButtonItemPressed {
    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
}

- (void)toolBarRefreshBarButtonItemPressed {
    if (!self.webView.isLoading) {
        [self.webView reload];
    }
}

- (void)toolBarActionBarButtonItemPressed {
    
}

- (void)doneBarButtonItemPressed {
    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)tabbarMoreBarButtonItemPressed {
    
    
    [AFPopUpMenu showWithTitle:@"请选择要进行的操作"
                     menuArray:@[@[@"搜索", @"复制链接", @"刷新"]]
                    imageArray:@[@[[self imageInBundleForImageName:@"Action_SearchInPage@2x"],
                                   [self imageInBundleForImageName:@"Action_Copy@2x"],
                                   [self imageInBundleForImageName:@"Action_Refresh@2x"]]]
                     doneBlock:^(NSIndexPath * _Nonnull selectedIndexPath) {
        
    } dismissBlock:NULL];
}

#pragma mark - 
#pragma mark - Public Methods

- (void)fetchNavigationUpdateTypeBlock:(void(^)(BOOL shouldUpdateNavigationBar, BOOL shouldUpdateToolBar))block {
    BOOL shouldUpdateNavigationBar = self.navigationStyleWithNavigaitionBar ||
                                     (self.navigationStyleWithToolBar && _UIUserInterfaceIdiomPad_);
    BOOL shouldUpdateToolBar = self.navigationStyleWithToolBar && _UIUserInterfaceIdiomPhone_;
    !block ?: block(shouldUpdateNavigationBar, shouldUpdateToolBar);
}

- (void)shouldUpdateNavigaitonBarOrToolBarInterface {
    [self fetchNavigationUpdateTypeBlock:^(BOOL shouldUpdateNavigationBar, BOOL shouldUpdateToolBar) {
        if (shouldUpdateNavigationBar) {
            [self updateNavigaitonBarIfNeeded];
        }
        if (shouldUpdateToolBar) {
            [self updateNavigationToolBarIfNeeded];
        }
    }];
}

- (void)updateNavigaitonBarIfNeeded {
    if (_UIUserInterfaceIdiomPad_ && !self.navigationStyleWithNavigaitionBar) {
        [self updateBarButtonItemsWithCallBack:^{
            [self.navigationItem setLeftBarButtonItems:@[
                                                         self.fixedSpaceBarButtonItem,
                                                         self.toolBarBackBarButtonItem,
                                                         self.fixedSpaceBarButtonItem,
                                                         self.toolBarForwardBarButtonItem,
                                                         self.fixiableSpaceBarButtonItem
                                                         ]
                                              animated:NO];
            
            UIBarButtonItem *refreshOrStopBarButtonItem = self.webView.isLoading ? self.toolBarStopBarButtonItem : self.toolBarRefreshBarButtonItem;
            [self.navigationItem setRightBarButtonItems:@[
                                                          self.fixedSpaceBarButtonItem,
                                                          self.doneBarButtonItem,
                                                          self.fixedSpaceBarButtonItem,
                                                          self.toolBarActionBarButtonItem,
                                                          self.fixedSpaceBarButtonItem,
                                                          refreshOrStopBarButtonItem,
                                                          self.fixiableSpaceBarButtonItem
                                                          ]
                                               animated:NO];
        }];
        return;
    }
    if (_UIUserInterfaceIdiomPhone_ || self.navigationStyleWithNavigaitionBar) {
        [self.navigationItem setLeftBarButtonItems:nil animated:NO];
        if (self.webView.canGoBack) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            [self.navigationItem setLeftBarButtonItems:@[self.closeBarButtonItem]
                                              animated:NO];
        } else {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            [self.navigationItem setLeftBarButtonItems:nil];
        }
        return;
    }
}

- (void)updateBarButtonItemsWithCallBack:(void(^)())callback {
    BOOL isLoading = self.webView.isLoading;
    self.toolBarBackBarButtonItem.enabled = self.webView.canGoBack;
    self.toolBarForwardBarButtonItem.enabled = self.webView.canGoForward;
    self.toolBarRefreshBarButtonItem.enabled = !isLoading;
    self.toolBarActionBarButtonItem.enabled = !isLoading;
    dispatch_async(dispatch_get_main_queue(), ^{
       !callback ?: callback();
    });
}

- (void)updateNavigationToolBarIfNeeded {
    [self updateBarButtonItemsWithCallBack:^{
        UIBarButtonItem *refreshOrStopBarButtonItem = self.webView.isLoading ? self.toolBarStopBarButtonItem : self.toolBarRefreshBarButtonItem;
        
        NSArray *items = @[self.fixedSpaceBarButtonItem,
                           self.toolBarBackBarButtonItem,
                           self.fixiableSpaceBarButtonItem,
                           self.toolBarForwardBarButtonItem,
                           self.fixiableSpaceBarButtonItem,
                           refreshOrStopBarButtonItem,
                           self.fixiableSpaceBarButtonItem,
                           self.toolBarActionBarButtonItem,
                           self.fixedSpaceBarButtonItem];
        
        self.navigationController.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        self.navigationController.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        self.navigationController.toolbar.barTintColor = self.navigationController.navigationBar.barTintColor;
        self.toolbarItems = items;
        
        if (_UIUserInterfaceIdiomPhone_) {
            [self.navigationItem setRightBarButtonItems:@[self.doneBarButtonItem]
                                               animated:NO];
        }
    }];
}

- (void)endedLoadingRefreshHeader {
//    if ([self.webView.scrollView.mj_header isRefreshing]) {
//        [self.webView.scrollView.mj_header endRefreshing];
//    }
}

#pragma mark -
#pragma mark - Private Methods

- (void)updateProgressViewWithProgress:(double)progress {
    [self.progressView setProgress:progress animated:YES];
    progress != 1.0 ?: [self resetProgressViewAnimated:NO];
}

- (void)resetProgressViewAnimated:(BOOL)animated {
    // FXIME:5.23修复：加载完成或者失败之后移除
    // [self.progressView removeFromSuperview];
    [self.progressView setProgress:0. animated:animated];
}

- (BOOL)navigationStyleWithNavigaitionBar {
    return self.navigationStyle == AFWebViewControllerNavigationStyleNavigationBar;
}

- (BOOL)navigationStyleWithToolBar {
    return self.navigationStyle == AFWebViewControllerNavigationStyleToolBar;
}

- (void)updateNavigationItemTitleWithTitle:(NSString *)title {
    if (title != nil && title.length > WebViewNavigationTitleMaxAllowedLength) {
        title = [[title substringToIndex:WebViewNavigationTitleSubstringToIndex] stringByAppendingString:WebViewNavigationTitleAfterSubstringAppendedString];
    }
    self.navigationItem.title = title;
}

- (BOOL)webViewControllerWithNavigationStyle {
    return self.navigationStyle == AFWebViewControllerNavigationStyleNavigationBar;
}

- (void)fetchAvailableProgressTintColorBlock:(void(^)(UIColor *progressTintColor))block {
    UIColor *progressTintColor = nil;
    if (self.progressTintColor) {
        progressTintColor = self.progressTintColor;
    }
    if (self.navigationStyleWithNavigaitionBar) {
        progressTintColor = self.navigationController.navigationBar.tintColor;
    }
    progressTintColor = progressTintColor ?: kProgressViewDefaultProgressTintColor;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        !block ?: block(progressTintColor);
    });
}

- (UIImage *)imageInBundleForImageName:(NSString *)imageName {
    NSString *pathComponent = @"AFWebViewBrowser.bundle";
    NSString *bundlePath =[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:pathComponent];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return ({
        [UIImage imageWithContentsOfFile:[bundle pathForResource:imageName ofType:@"png"]];
    });
}

#pragma mark - Methods (Setters)

- (void)setSupportFrom:(NSString *)supportFrom {
    if (supportFrom == nil) {
        return;
    }
    self.supportFromLabel.text = [NSString stringWithFormat:@"网页由 %@ 提供", supportFrom];
}

- (void)setNavigationStyle:(AFWebViewControllerNavigationStyle)navigationStyle {
    _navigationStyle = navigationStyle;
    
    BOOL showToolBar = (_navigationStyle == AFWebViewControllerNavigationStyleToolBar) && _UIUserInterfaceIdiomPhone_;
    [self.navigationController setToolbarHidden:!showToolBar animated:NO];
}

#pragma mark - Methods (Lazy Load)

- (WKWebView *)webView {
    if (_webView) {
        return _webView;
    }
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.processPool = [[WKProcessPool alloc] init];
    configuration.preferences = [[WKPreferences alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    _webView.allowsBackForwardNavigationGestures = YES;
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.navigationDelegate = self.webViewControllerModel;
    _webView.UIDelegate = self.webViewControllerModel;
    return _webView;
}

- (AFWebViewControllerModel *)webViewControllerModel {
    if (!_webViewControllerModel) {
        _webViewControllerModel = [[AFWebViewControllerModel alloc] initWithWebViewController:self];
    }
    return _webViewControllerModel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        _progressView.progressViewStyle = UIProgressViewStyleBar;
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _progressView.trackTintColor = [UIColor clearColor];
        [self fetchAvailableProgressTintColorBlock:^(UIColor *progressTintColor) {
            _progressView.progressTintColor = progressTintColor;
        }];
        _progressView.progress = .0;
    }
    return _progressView;
}

- (UIBarButtonItem *)backBarButtonItem {
    if (!_backBarButtonItem) {
        UIImage *backItemImage = [[UIImage imageNamed:@"backItemImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *backItemHLImage = [[UIImage imageNamed:@"backItemImage_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton *customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [customBackButton setTitle:@"返回" forState:UIControlStateNormal];
        [customBackButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [customBackButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [customBackButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [customBackButton setImage:backItemImage forState:UIControlStateNormal];
        [customBackButton setImage:backItemHLImage forState:UIControlStateHighlighted];
        [customBackButton sizeToFit];
        [customBackButton addTarget:self action:@selector(customBarButtonItemPressed) forControlEvents:UIControlEventTouchUpInside];
        
        _backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem *)closeBarButtonItem {
    if (!_closeBarButtonItem) {
        _closeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeBarButtonItemPressed)];
    }
    return _closeBarButtonItem;
}

- (UILabel *)supportFromLabel {
    if (!_supportFromLabel) {
        _supportFromLabel = [[UILabel alloc] init];
        _supportFromLabel.font = [UIFont systemFontOfSize:12.f];
        _supportFromLabel.textColor = [UIColor lightGrayColor];
        _supportFromLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _supportFromLabel;
}

- (UIToolbar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        _toolBar.barStyle = self.navigationController.navigationBar.barStyle;
        _toolBar.tintColor = self.navigationController.navigationBar.tintColor;
    }
    return _toolBar;
}

- (UIBarButtonItem *)toolBarBackBarButtonItem {
    if (!_toolBarBackBarButtonItem) {
        UIImage *backBarButtonImage = [self imageInBundleForImageName:@"toolBar_back"];
        _toolBarBackBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backBarButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(toolBarBackBarButtonItemPressed)];
    }
    return _toolBarBackBarButtonItem;
}

- (UIBarButtonItem *)toolBarForwardBarButtonItem {
    if (!_toolBarForwardBarButtonItem) {
        UIImage *backBarButtonImage = [self imageInBundleForImageName:@"toolBar_forward"];
        _toolBarForwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backBarButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(toolBarForwardBarButtonItemPressed)];
    }
    return _toolBarForwardBarButtonItem;
}

- (UIBarButtonItem *)toolBarStopBarButtonItem {
    if (!_toolBarStopBarButtonItem) {
        _toolBarStopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(toolBarStopBarButtonItemPressed)];
    }
    return _toolBarStopBarButtonItem;
}

- (UIBarButtonItem *)toolBarRefreshBarButtonItem {
    if (!_toolBarRefreshBarButtonItem) {
        _toolBarRefreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(toolBarRefreshBarButtonItemPressed)];
    }
    return _toolBarRefreshBarButtonItem;
}

- (UIBarButtonItem *)toolBarActionBarButtonItem {
    if (!_toolBarActionBarButtonItem) {
        _toolBarActionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(toolBarActionBarButtonItemPressed)];
    }
    return _toolBarActionBarButtonItem;
}

- (UIBarButtonItem *)doneBarButtonItem {
    if (!_doneBarButtonItem) {
        _doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBarButtonItemPressed)];
    }
    return _doneBarButtonItem;
}

- (UIBarButtonItem *)fixedSpaceBarButtonItem {
    if (!_fixedSpaceBarButtonItem) {
        _fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:NULL action:NULL];
        _fixedSpaceBarButtonItem.width = 35.f;
    }
    return _fixedSpaceBarButtonItem;
}

- (UIBarButtonItem *)fixiableSpaceBarButtonItem {
    if (!_fixiableSpaceBarButtonItem) {
        _fixiableSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:NULL action:NULL];
    }
    return _fixiableSpaceBarButtonItem;
}

- (UIBarButtonItem *)tabbarMoreBarButtonItem {
    if (!_tabbarMoreBarButtonItem) {
        UIImage *tabbarMoreBarButtonItemImage = [self imageInBundleForImageName:@"barbuttonicon_more_black@2x"];
        UIBarButtonItem *tabbarMoreBarButtonItem = [[UIBarButtonItem alloc] initWithImage:tabbarMoreBarButtonItemImage style:UIBarButtonItemStylePlain target:self action:@selector(tabbarMoreBarButtonItemPressed)];
        tabbarMoreBarButtonItem.tintColor = self.navigationController.navigationBar.tintColor;
        _tabbarMoreBarButtonItem = tabbarMoreBarButtonItem;
    }
    return _tabbarMoreBarButtonItem;
}

- (UIColor *)tintColor {
    if (!_tintColor) {
        _tintColor = self.navigationController.navigationBar.tintColor;
    }
    return _tintColor;
}

@end
