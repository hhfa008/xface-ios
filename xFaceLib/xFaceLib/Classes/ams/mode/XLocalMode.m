
/*
 Copyright 2012-2013, Polyvi Inc. (http://polyvi.github.io/openxface)
 This program is distributed under the terms of the GNU General Public License.

 This file is part of xFace.

 xFace is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 xFace is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with xFace.  If not, see <http://www.gnu.org/licenses/>.
*/

//
//  XLocalMode.m
//  xFaceLib
//
//

#import "XLocalMode.h"
#import "XApplication.h"
#import "XAppInfo.h"
#import "XConfiguration.h"
#import "XConstants.h"
#import "XUtils.h"
#import "XLocalResourceIterator.h"

@implementation XLocalMode

- (id)initWithApp:(id<XApplication>)app
{
    self = [super init];
    if (self) {
        self.mode = LOCAL;
    }
    return self;
}

- (void)loadApp:(id<XApplication>)app policy:(id<XSecurityPolicy>)policy
{
    [super loadApp:app policy:policy];
}

- (NSURL*)getURL:(id<XApplication>)app
{
    NSString *entry = [[app appInfo] entry];
    NSString *appSrcPath = [self getSrcPathForApp:app];

    NSString *entryPath = [appSrcPath stringByAppendingPathComponent:entry];
    return [NSURL fileURLWithPath:entryPath];
}

- (NSString*)getSrcPathForApp:(id<XApplication>)app
{
    NSString *appSrcPath = [[app appInfo] srcPath];
    NSString *appId = [app getAppId];
    if (![appSrcPath length])
    {
        appSrcPath = [app installedDirectory];
    }

    //没有版本号的UUID，无符号链接
    NSDictionary* UUIDs = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kAppVersionUUIDKey];
    NSString* versionUUID = [UUIDs objectForKey:[app getAppId]];
    if (versionUUID == nil)
    {
        return appSrcPath;
    }

    NSString* linkPath = [appSrcPath stringByAppendingPathComponent:versionUUID];

    return linkPath;
}

- (NSString*)getIconURL:(XAppInfo*)appInfo
{
    NSString* relativeIconPath = [appInfo icon];
    if (0 == [relativeIconPath length])
    {
        return nil;
    }

    NSString* appId = appInfo.appId;
    NSString *iconPath = [XUtils generateAppIconPathUsingAppId:appId relativeIconPath:relativeIconPath];

    NSString *iconURL = (nil == iconPath) ? nil : [[NSURL fileURLWithPath:iconPath] absoluteString];
    return iconURL;
}

- (id<XResourceIterator>)getResourceIterator:(id<XApplication>)app
{
    NSString *appRootPath = [[[app appInfo] srcPath] length] > 0 ? [[app appInfo] srcPath] : [app installedDirectory];

    return [[XLocalResourceIterator alloc] initWithAppRoot:appRootPath];
}

@end
