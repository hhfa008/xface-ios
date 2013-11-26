
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
//  XSystemWorkspaceFactory.m
//  xFace
//
//

#import "XSystemWorkspaceFactory.h"
#import "XConstants.h"
#import "XUtils.h"

@implementation XSystemWorkspaceFactory

+ (NSString *)create
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];

    // 系统工作空间路径形如：<Applilcation_Home>/Documents/xface3/
    return [documentDirectory stringByAppendingFormat:@"%@%@%@", FILE_SEPARATOR, XFACE_WORKSPACE_FOLDER, FILE_SEPARATOR];
}

@end
