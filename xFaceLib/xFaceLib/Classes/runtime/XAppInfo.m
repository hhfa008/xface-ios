
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
//  XAppInfo.m
//  xFace
//
//

#import "XAppInfo.h"
#import "XConstants.h"
#import "XUtils.h"

@implementation XAppInfo

@synthesize appId;
@synthesize name;
@synthesize version;
@synthesize entry;
@synthesize icon;
@synthesize type;
@synthesize isEncrypted;
@synthesize width;
@synthesize height;
@synthesize displayMode;
@synthesize runningMode;
@synthesize engineType;
@synthesize channelId;
@synthesize channelName;
@synthesize prefRemotePkg;
@synthesize appleId;
@synthesize srcRoot;
@synthesize srcPath = _srcPath;
@synthesize whitelistHosts = _whitelistHosts;
@synthesize engineVersion;

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.whitelistHosts = [[NSMutableArray alloc] initWithCapacity:10];
        [self.whitelistHosts addObject:@"file:///*"];
        [self.whitelistHosts addObject:@"content:///*"];
        [self.whitelistHosts addObject:@"data:///*"];
    }
    return self;
}

-(NSString *) srcPath
{
    //Fix bug 3072:http://zentao.polyvi.com/bug-view-3072.html
    NSString *appSrcPath = [self srcRoot];
    if ([appSrcPath isEqualToString:APP_ROOT_PREINSTALLED])
    {
        appSrcPath = [XUtils buildPreinstalledAppSrcPath:[self appId]];
    }
    else if([appSrcPath isEqualToString:APP_ROOT_WORKSPACE])
    {
        appSrcPath = [XUtils buildWorkspaceAppSrcPath:[self appId]];
    }
    return appSrcPath;
}

@end

