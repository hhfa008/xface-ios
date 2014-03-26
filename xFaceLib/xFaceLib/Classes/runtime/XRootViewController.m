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
    if ([XUtils isOptimizedLibRunningMode]) {
        [self.runtime.appManagement startDefaultAppWithParams:self.startParams];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![XUtils isOptimizedLibRunningMode]) {
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

    if ([XUtils isOptimizedLibRunningMode]) {
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

@end
