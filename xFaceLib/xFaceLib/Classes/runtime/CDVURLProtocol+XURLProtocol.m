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
//  CDVURLProtocol+XURLProtocol.m
//  xFaceLib
//
//

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Cordova/CDVViewController.h>

#import "CDVURLProtocol+XURLProtocol.h"
#import "XHTTPURLResponse.h"

// Contains a set of NSNumbers of addresses of controllers. It doesn't store
// the actual pointer to avoid retaining.
static NSMutableSet* gRegisteredViewControllers = nil;

NSString* const kXAssetsLibraryPrefixes = @"assets-library://";

// Returns the registered view controller that sent the given request.
// If the user-agent is not from a UIWebView, or if it's from an unregistered one,
// then nil is returned.
static CDVViewController *viewControllerForRequest(NSURLRequest* request)
{
    // The exec bridge explicitly sets the VC address in a header.
    // This works around the User-Agent not being set for file: URLs.
    NSString* addrString = [request valueForHTTPHeaderField:@"vc"];

    if (addrString == nil) {
        NSString* userAgent = [request valueForHTTPHeaderField:@"User-Agent"];
        if (userAgent == nil) {
            return nil;
        }
        NSUInteger bracketLocation = [userAgent rangeOfString:@"(" options:NSBackwardsSearch].location;
        if (bracketLocation == NSNotFound) {
            return nil;
        }
        addrString = [userAgent substringFromIndex:bracketLocation + 1];
    }

    long long viewControllerAddress = [addrString longLongValue];
    @synchronized(gRegisteredViewControllers) {
        if (![gRegisteredViewControllers containsObject:[NSNumber numberWithLongLong:viewControllerAddress]]) {
            return nil;
        }
    }

    return (__bridge CDVViewController*)(void*)viewControllerAddress;
}

@implementation CDVURLProtocol (XURLProtocol)

// Called to register the URLProtocol, and to make it away of an instance of
// a ViewController.
+ (void)registerViewController:(XViewController*)viewController
{
    if (gRegisteredViewControllers == nil) {
        [NSURLProtocol registerClass:[CDVURLProtocol class]];
        gRegisteredViewControllers = [[NSMutableSet alloc] initWithCapacity:8];
    }

    @synchronized(gRegisteredViewControllers) {
        [gRegisteredViewControllers addObject:[NSNumber numberWithLongLong:(long long)viewController]];
    }
}

+ (void)unregisterViewController:(XViewController*)viewController
{
    @synchronized(gRegisteredViewControllers) {
        [gRegisteredViewControllers removeObject:[NSNumber numberWithLongLong:(long long)viewController]];
    }
}

+ (BOOL)canInitWithRequest:(NSURLRequest*)theRequest
{
    NSURL* theUrl = [theRequest URL];
    CDVViewController* viewController = viewControllerForRequest(theRequest);

    if ([[theUrl absoluteString] hasPrefix:kXAssetsLibraryPrefixes]) {
        return YES;
    } else if (viewController != nil) {
        if ([[theUrl path] isEqualToString:@"/!gap_exec"]) {
            NSString* queuedCommandsJSON = [theRequest valueForHTTPHeaderField:@"cmds"];
            NSString* requestId = [theRequest valueForHTTPHeaderField:@"rc"];
            if (requestId == nil) {
                NSLog(@"!cordova request missing rc header");
                return NO;
            }
            BOOL hasCmds = [queuedCommandsJSON length] > 0;
            if (hasCmds) {
                SEL sel = @selector(enqueueCommandBatch:);
                [viewController.commandQueue performSelectorOnMainThread:sel withObject:queuedCommandsJSON waitUntilDone:NO];
                [viewController.commandQueue performSelectorOnMainThread:@selector(executePending) withObject:nil waitUntilDone:NO];
            } else {
                SEL sel = @selector(processXhrExecBridgePoke:);
                [viewController.commandQueue performSelectorOnMainThread:sel withObject:[NSNumber numberWithInteger:[requestId integerValue]] waitUntilDone:NO];
            }
            // Returning NO here would be 20% faster, but it spams WebInspector's console with failure messages.
            // If JS->Native bridge speed is really important for an app, they should use the iframe bridge.
            // Returning YES here causes the request to come through canInitWithRequest two more times.
            // For this reason, we return NO when cmds exist.
            return !hasCmds;
        }
        // we only care about http and https connections.
        // CORS takes care of http: trying to access file: URLs.
        if ([[viewController whitelist] schemeIsAllowed:[theUrl scheme]]) {
            // if it FAILS the whitelist, we return TRUE, so we can fail the connection later
            return ![[viewController whitelist] URLIsAllowed:theUrl];
        }
    }

    return NO;
}

- (void)startLoading
{
    // NSLog(@"%@ received %@ - start", self, NSStringFromSelector(_cmd));
    NSURL* url = [[self request] URL];

    if ([[url path] isEqualToString:@"/!gap_exec"]) {
        [self sendResponseWithResponseCode:200 data:nil mimeType:nil];
        return;
    } else if ([[url absoluteString] hasPrefix:kXAssetsLibraryPrefixes]) {
        ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset* asset) {
            if (asset) {
                // We have the asset!  Get the data and send it along.
                ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                NSString* MIMEType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)[assetRepresentation UTI], kUTTagClassMIMEType);
                Byte* buffer = (Byte*)malloc([assetRepresentation size]);
                NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:[assetRepresentation size] error:nil];
                NSData* data = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                [self sendResponseWithResponseCode:200 data:data mimeType:MIMEType];
            } else {
                // Retrieving the asset failed for some reason.  Send an error.
                [self sendResponseWithResponseCode:404 data:nil mimeType:nil];
            }
        };
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError* error) {
            // Retrieving the asset failed for some reason.  Send an error.
            [self sendResponseWithResponseCode:401 data:nil mimeType:nil];
        };

        ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary assetForURL:url resultBlock:resultBlock failureBlock:failureBlock];
        return;
    }

    NSString* body = [NSString stringWithFormat:@"ERROR whitelist rejection: url='%@'", [url absoluteString]];
    [self sendResponseWithResponseCode:401 data:[body dataUsingEncoding:NSASCIIStringEncoding] mimeType:nil];
}

- (void)sendResponseWithResponseCode:(NSInteger)statusCode data:(NSData*)data mimeType:(NSString*)mimeType
{
    if (mimeType == nil) {
        mimeType = @"text/plain";
    }
    NSString* encodingName = [@"text/plain" isEqualToString : mimeType] ? @"UTF-8" : nil;
    XHTTPURLResponse* response =
    [[XHTTPURLResponse alloc] initWithURL:[[self request] URL]
                                   MIMEType:mimeType
                      expectedContentLength:[data length]
                           textEncodingName:encodingName];
    response.statusCode = statusCode;

    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    if (data != nil) {
        [[self client] URLProtocol:self didLoadData:data];
    }
    [[self client] URLProtocolDidFinishLoading:self];
}

@end
