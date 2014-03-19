
/*
 This file was modified from or inspired by Apache Cordova.

 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.
*/

//
//  XRuntime.m
//  xFace
//
//

#import "XRuntime.h"
#import "XAppManagement.h"
#import "XApplication.h"
#import "XConstants.h"
#import "XAppList.h"
#import "XRuntime_Privates.h"
#import "XUtils.h"
#import "XSystemBootstrapFactory.h"
#import "XSystemEventHandler.h"
#import "XConfiguration.h"
#import "XViewController.h"
#import "XAppWebView.h"
#import "XRootViewController.h"

// TODO:日后需要增加本地化操作
// 系统初始化失败时，相关的提示信息
static NSString * const SYSTEM_INITIALIZE_FAILED_ALERT_TITLE        = @"Initialisation Failed";
static NSString * const SYSTEM_INITIALIZE_FAILED_ALERT_MESSAGE      = @"Please press Home key to exit and try to reinstall!";
static NSString * const SYSTEM_INITIALIZE_FAILED_ALERT_BUTTON_TITLE = @"OK";

@implementation XRuntime

@synthesize appManagement;
@synthesize systemBootstrap;
@synthesize sysEventHandler;
@synthesize bootParams;
@synthesize rootVC;

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:CDVPluginHandleOpenURLNotification object:nil];

        // 加载系统配置信息
        BOOL ret = [[XConfiguration getInstance] loadConfiguration];
        if (ret)
        {
            // 由于初始化操作比较耗时，所以这里使用performSelectorOnMainThread进行异步调用
            [self performSelectorOnMainThread:@selector(doInitialization) withObject:nil waitUntilDone:NO];
        }
        else
        {
            NSError *anError = [[NSError alloc] initWithDomain:@"xface" code:0
                                                      userInfo:@{NSLocalizedDescriptionKey:@"Failed to load config.xml!"}];
            [self showErrorAlert:anError];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
  进行runtime的初始化操作，然后启动应用
 */
- (void) doInitialization
{
    self.systemBootstrap = [XSystemBootstrapFactory createWithDelegate:self];
    [self.systemBootstrap prepareWorkEnvironment];
}

-(void) handleOpenURL:(NSNotification*)notification
{
    // invoke string is passed to your app on launch, this is only valid if you
    // edit project-Info.plist to add a protocol
    // a simple tutorial can be found here :
    // http://iphonedevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html

    NSURL* url = [notification object];
    if ([url isKindOfClass:[NSURL class]])
    {
        // calls into javascript global function 'handleOpenURL'
        NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
        [self.rootVC.webView stringByEvaluatingJavaScriptFromString:jsString];

        NSString *params = nil;
        NSString *urlStr = [url absoluteString];
        NSRange range = [urlStr rangeOfString:NATIVE_APP_CUSTOM_URL_PARAMS_SEPERATOR];
        if(NSNotFound != range.location)
        {
            params = [urlStr substringFromIndex:(range.location + range.length)];
        }

        [self setBootParams:params];
    }
}

#pragma mark XSystemBootstrapDelegate

//系统环境准备好了之后继续初始化
-(void) didFinishPreparingWorkEnvironment
{
    [self initialize];
}

//系统环境准备失败
-(void)didFailToPrepareEnvironmentWithError:(NSError *)error
{
    [self showErrorAlert:error];
}

#pragma mark Privates

-(void) initialize
{
    // Initialize components
    self.appManagement = [[XAppManagement alloc] initWithAmsDelegate:self];
    self.sysEventHandler = [[XSystemEventHandler alloc] initWithAppManagement:[self appManagement]];
    [self.systemBootstrap boot:self.appManagement];
}

-(void)showErrorAlert:(NSError *)error
{
    // 系统环境准备失败时,给出相应的提示信息
    NSString* msg = [NSString stringWithFormat:@"%@. %@", error.localizedDescription, SYSTEM_INITIALIZE_FAILED_ALERT_MESSAGE];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SYSTEM_INITIALIZE_FAILED_ALERT_TITLE message:msg delegate:nil cancelButtonTitle:SYSTEM_INITIALIZE_FAILED_ALERT_BUTTON_TITLE otherButtonTitles:nil];

    [alert show];
    return;
}

#pragma mark XAmsDelegate

-(void) startApp:(id<XApplication>)app
{
    NSAssert((app && ![app isActive]), nil);
    BOOL isDefaultApp = [[self appManagement] isDefaultApp:[app getAppId]];
    if (isDefaultApp)
    {
        NSAssert([[self.rootVC webView] conformsToProtocol:@protocol(XAppView)], nil);
        app.viewController = self.rootVC;
        self.rootVC.ownerApp = app;
    }
    else
    {
        XViewController *vc = [[XViewController alloc] init];
        app.viewController = vc;
        vc.ownerApp = app;

        //NOTE:如有需求，可以根据配置信息指定transition style
        UIViewController *topVC = [XUtils topViewController];
        [topVC presentViewController:vc animated:NO completion:nil];
    }
    [app load];

    [self.appManagement handleAppEvent:app event:kAppEventStart msg:nil];
}

-(void) closeApp:(id<XApplication>)app
{
    NSAssert([app isActive], nil);
    NSString *appId = [app getAppId];
    BOOL isDefaultApp = [self.appManagement isDefaultApp:appId];
    if (isDefaultApp)
    {
        //如果是库模式则关闭xFace
        [self tryCloseXFace:app];
    }
    else
    {
        XViewController *vc = [app viewController];
        [vc dismissViewControllerAnimated:NO completion:^{
            [self.appManagement handleAppEvent:app event:kAppEventClose msg:nil];
        }];
    }
}

-(void) tryCloseXFace:(id<XApplication>) app
{
    if ([app.viewController navigationController])
    {
        [app.viewController.navigationController popViewControllerAnimated:NO];
    }
    else if ([app.viewController presentingViewController])
    {
        [app.viewController dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
