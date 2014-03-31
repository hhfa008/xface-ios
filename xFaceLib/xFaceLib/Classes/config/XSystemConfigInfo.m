
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
//  XSystemConfigInfo.m
//  xFaceLib
//
//

#import "XSystemConfigInfo.h"
#import "XConstants.h"

@interface XSystemConfigInfo ()

@property (nonatomic, readwrite, strong) NSMutableArray      *preinstallApps;
@property (nonatomic, readwrite, strong) NSMutableDictionary *settings;

@end

@implementation XSystemConfigInfo

@synthesize preinstallApps;
@synthesize settings;

static NSArray* com_polyvi_xface_ConfigPreferences;

+ (void)initialize
{
    com_polyvi_xface_ConfigPreferences = [[NSArray alloc] initWithObjects:
                                            ENGINE_VERSION,
                                            PERSISTENT_FILE_LOCATION,
                                            LIB_RUNNING_MODE,
                                            CUSTOM_LAUNCH_IMAGE_FILE,
                                            UMENG_APP_KEY,
                                            UMENG_REPORT_POLICY,
                                            UMENG_CHANNEL,
                                            nil];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.settings = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.preinstallApps = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

#pragma mark NSXMLParserDelegate

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName attributes:(NSDictionary*)attributeDict
{
    if ([elementName isEqualToString:TAG_PREFERENCE])
    {
        if ([com_polyvi_xface_ConfigPreferences containsObject:attributeDict[ATTR_NAME]])
        {
            self.settings[attributeDict[ATTR_NAME]] = attributeDict[ATTR_VALUE];
        }
    }
    else if ([elementName isEqualToString:TAG_APP_PACKAGE])
    {
        [self.preinstallApps addObject:attributeDict[ATTR_ID]];
    }
}

- (void)parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError
{
    NSAssert(NO, @"config.xml parse error line %ld col %ld", (long)[parser lineNumber], (long)[parser columnNumber]);
}

@end
