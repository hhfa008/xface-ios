
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
//  XCommandQueue.m
//  xFaceLib
//
//

//
//  XCommandQueue.m
//  xFace
//
//  Copyright (c) 2013年 Polyvi Inc. All rights reserved.
//

#import "XCommandQueue.h"
#import "XConstants.h"
#import "XAppView.h"
#import "XUtils.h"
#import "XViewController.h"
#import <Cordova/CDVPluginResult.h>
#import <Cordova/CDVInvokedUrlCommand.h>

#define EXTENSION_RESULT_PERMISSION_DENIED             @"Permission denied"

#define CLOSE_XAPPLICATION_COMMAND                     @"closeApplication"
#define XAPPLICATION_SEND_MESSAGE_COMMAND              @"appSendMessage"

@interface XCommandQueue () {
    __weak CDVViewController* _viewController;
}
@end

@implementation XCommandQueue

#pragma mark override

- (id)initWithViewController:(CDVViewController*)viewController
{
    self = [super initWithViewController:viewController];
    _viewController = viewController;
    return self;
}

- (BOOL)execute:(CDVInvokedUrlCommand *)command
{
    if ([self tryExecuteXApplicationCmd:command])
    {
        return YES;
    }
    
    return [super execute:command];
}

#pragma mark private methods

- (BOOL) isXApplicationCmd:(NSString *)cmdMethodName
{
    BOOL ret = NO;
    if ([CLOSE_XAPPLICATION_COMMAND isEqualToString:cmdMethodName] ||
        [XAPPLICATION_SEND_MESSAGE_COMMAND isEqualToString:cmdMethodName])
    {
        ret = YES;
    }
    return ret;
}

- (BOOL) tryExecuteXApplicationCmd:(CDVInvokedUrlCommand *)cmd
{
    NSString *cmdMethodName = cmd.methodName;
    if (![self isXApplicationCmd:cmdMethodName])
    {
        return NO;
    }
    
    if ([CLOSE_XAPPLICATION_COMMAND isEqualToString:cmdMethodName])
    {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:XAPPLICATION_CLOSE_NOTIFICATION object:[(XViewController *)self->_viewController ownerApp]]];
    }
    else if ([XAPPLICATION_SEND_MESSAGE_COMMAND isEqualToString:cmdMethodName])
    {
        NSString *msgId = [cmd.arguments objectAtIndex:0];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:XAPPLICATION_SEND_MESSAGE_NOTIFICATION object:[(XViewController *)self->_viewController ownerApp] userInfo:@{@"msgId": msgId}]];
    }
    else
    {
        NSAssert(NO, nil);
    }
    
    return YES;
}

@end
