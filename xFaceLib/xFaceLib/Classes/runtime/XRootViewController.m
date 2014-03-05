//
//  XRootViewController.m
//  xFaceLib
//
//  Copyright (c) 2014年 Polyvi Inc. All rights reserved.
//

#import "XRootViewController.h"
#import "XRuntime.h"

NSString* const kClientNotification = @"kClientNotification";

@interface XRootViewController()

@property (strong, nonatomic) XRuntime *runtime;

@end

@implementation XRootViewController

- (void)viewWillAppear:(BOOL)animated
{
    if(!self.runtime)
    {
        self.runtime = [[XRuntime alloc] init];
        self.runtime.rootVC = self;
    }
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated // Called after the view was dismissed, covered or otherwise hidden. Default does nothing
{
    //在库模式下，如果是rootViewController被dismissed，就销毁runtime
    UIWindow* window =[UIApplication sharedApplication].delegate.window;

    //window.rootViewController不是XRootViewController，说明是库模式
    if(window.rootViewController != self )
    {
        //如果presentedViewController存在，说明显示了扩展的viewController，
        //如果presentedViewController为nil，说明rootViewController被dismiss,则销毁runtime
        if (!self.presentedViewController)
        {
            self.runtime =nil;
        }
    }
    [super viewDidDisappear:animated];
}

@end
