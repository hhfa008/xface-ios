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
//  XViewController.m
//  xFaceLib
//
//

#import <cordova/CDV.h>
#import "XViewController.h"
#import "XApplication.h"
#import "XJavaScriptEvaluator.h"
#import "XConstants.h"
#import "XUtils.h"
#import "XCommandQueue.h"
#import "XAppWebView.h"

@implementation XViewController

@synthesize ownerApp;
@synthesize loadFromString;

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _commandQueue = [[XCommandQueue alloc] initWithViewController:self];
        _commandDelegate = [[XJavaScriptEvaluator alloc] initWithViewController:self];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _commandQueue = [[XCommandQueue alloc] initWithViewController:self];
        _commandDelegate = [[XJavaScriptEvaluator alloc] initWithViewController:self];
    }
    return self;
}

#pragma mark override

- (CDVWhitelist*)whitelist
{
    return [[self ownerApp] whitelist];
}

- (UIWebView*)newCordovaViewWithFrame:(CGRect)bounds
{
    XAppWebView *appView = [[XAppWebView alloc] initWithFrame:bounds];
    return appView;
}

- (void)viewDidLoad
{
    //避免控制台输出错误信息："ERROR: Start Page at 'www/index.html' was not found."
    self.wwwFolderName = XFACE_BUNDLE_FOLDER;

    [super viewDidLoad];

    //避免加载错误页面："ERROR: Start Page at 'www/index.html' was not found."
    [self.webView stopLoading];
}

- (void)registerPlugin:(CDVPlugin*)plugin withClassName:(NSString*)className
{
    NSAssert(className, @"className should not be nil!");
    if (!plugin) {
        if (![className isEqualToString:NSStringFromClass([CDVLocalStorage class])]) {
            ALog(@"Failed to register plugin %@", className);
        }
        return;
    }
    [super registerPlugin:plugin withClassName:className];
}

#pragma mark UIWebViewDelegate

- (void) webViewDidFinishLoad:(UIWebView *)theWebView
{
    //将初始化数据设置到js端
    NSString *params = [[self ownerApp] getDataForKey:APP_DATA_KEY_FOR_START_PARAMS];
    params = (nil == params) ? @"null" : [NSString stringWithFormat:@"'%@'",params];
    [[self ownerApp] removeDataForKey:APP_DATA_KEY_FOR_START_PARAMS];

    NSString* initPrivateData = [[NSMutableString alloc] initWithFormat:@"try{cordova.require('xFace/privateModule').initPrivateData(['%@','%@', %@]);}catch(e){alert(e);}", [[self ownerApp] getAppId], [[self ownerApp] getWorkspace], params];
    [self.commandDelegate evalJs:initPrivateData];

    NSString *nativeReady = [NSString stringWithFormat:@"try{cordova.require('cordova/channel').onNativeReady.fire();}catch(e){window._nativeReady = true;}"];
    [self.commandDelegate evalJs:nativeReady];

    [super webViewDidFinishLoad:theWebView];
}

@end
