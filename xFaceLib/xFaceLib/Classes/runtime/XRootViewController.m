//
//  XRootViewController.m
//  xFaceLib
//
//  Copyright (c) 2014年 Polyvi Inc. All rights reserved.
//

#import "XRootViewController.h"
#import "XRuntime.h"
#import "XConstants.h"
#import "XUtils.h"
#import "XAppManagement.h"

NSString* const kClientNotification = @"kClientNotification";

@interface XRootViewController()

@property (strong, nonatomic) XRuntime *runtime;
@property (strong, nonatomic) NSString *startParams;

@end

@implementation XRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.runtime = [[XRuntime alloc] init];
    self.runtime.rootVC = self;
}

- (void) handleOpenURL:(NSNotification*)notification
{
    if ([[notification object] isKindOfClass:[NSURL class]]){
        NSString *params = nil;
        NSString *urlStr = [[notification object] absoluteString];
        NSRange range = [urlStr rangeOfString:NATIVE_APP_CUSTOM_URL_PARAMS_SEPERATOR];
        if(NSNotFound != range.location){
            params = [urlStr substringFromIndex:(range.location + range.length)];
        }
        self.startParams = params;
    } else if ([[notification object] isKindOfClass:[NSString class]]) {
        self.startParams = [notification object];
    }

    //TODO:测试通过Custom URL启动xFace app的情况
    self.runtime.bootParams = self.startParams;
    if ([self isOptimizedLibRunningMode]) {
        [self.runtime.appManagement startDefaultAppWithParams:self.startParams];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![self isOptimizedLibRunningMode]) {
        if(!self.runtime) {
            self.runtime = [[XRuntime alloc] init];
            self.runtime.rootVC = self;
        }
    }

    if (self.startParams.length) {
        self.runtime.bootParams = self.startParams;
        self.startParams = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated // Called after the view was dismissed, covered or otherwise hidden. Default does nothing
{
    [super viewDidDisappear:animated];

    if ([self isOptimizedLibRunningMode]) {
        return;
    }

    //在库模式下，如果是rootViewController被dismissed，就销毁runtime
    UIWindow* window =[UIApplication sharedApplication].delegate.window;

    //window.rootViewController不是XRootViewController，说明是库模式
    if(window.rootViewController != self )
    {
        //如果presentedViewController存在，说明显示了扩展的viewController，
        //如果presentedViewController为nil，说明rootViewController被dismiss,则销毁runtime
        if (!self.presentedViewController)
        {
            self.runtime = nil;
        }
    }
}

- (BOOL)isOptimizedLibRunningMode
{
    //LibRunningMode取值如下：
    //1) normal: 兼容xFace v3.1, 在库模式下，runtime可以被创建多次，每次退出xFace时销毁runtime；
    //2) optimized: runtime只被创建一次，且在XRootViewController的view已经加载的情况下，可以通过postNotification启动xFace默认应用

    //注意：
    //1）只有添加xface-extra-lib插件时才需配置LibRunningMode，非库模式下无需配置此项，即xFace按照normal的方式启动
    //2）LibRunningMode的取值应根据第三方集成xFaceLib的使用场景决定.具体请参考xFace库模式使用手册
    NSString *libRunningMode = [[XUtils getPreferenceForKey:LIB_RUNNING_MODE] lowercaseString];
    BOOL ret = [libRunningMode isEqualToString:@"optimized"] ? YES : NO;
    return ret;
}

@end
