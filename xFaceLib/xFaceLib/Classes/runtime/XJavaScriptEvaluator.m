
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
//  XJavaScriptEvaluator.m
//  xFace
//
//

#import "XJavaScriptEvaluator.h"
#import "XAppWebView.h"
#import "XAppList.h"
#import "XApplication.h"
#import "XCommandQueue.h"
#import <Cordova/CDVViewController.h>
#import "XViewController.h"
#import "XAppInfo.h"

@interface XJavaScriptEvaluator () {
    __weak CDVViewController* _viewController;
}
@end

@implementation XJavaScriptEvaluator

- (void) eval:(NSMutableArray *)arguments
{
    NSString *callbackId = [arguments objectAtIndex:0];
    CDVPluginResult *result = [arguments objectAtIndex:1];

    [self sendPluginResult:result callbackId:callbackId];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    NSString* root = [[((XViewController*)_viewController).ownerApp appInfo] srcPath];

    NSString* fullPath = [root stringByAppendingPathComponent:resourcepath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:nil]) {
        return nil;
    }
    return fullPath;

}

@end
