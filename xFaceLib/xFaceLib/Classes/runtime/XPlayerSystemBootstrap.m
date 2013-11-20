
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
//  XPlayerSystemBootstrap.m
//  xFace
//
//

#import "XPlayerSystemBootstrap.h"
#import "XConfiguration.h"
#import "XAppManagement.h"
#import "XAppPreinstallListener.h"
#import "XAppList.h"
#import "XApplication.h"
#import "XAppInfo.h"
#import "XUtils.h"
#import "XConstants.h"
#import "XPlayerSystemBootstrap_Privates.h"
#import "XFileUtils.h"
#import "XAppManagement.h"
#import "XSync.h"
#import "XApplicationFactory.h"
#import "XApplication.h"
#import "iToast.h"

@implementation XPlayerSystemBootstrap

@synthesize bootDelegate;

/**
    启动之前的准备工作
 */
-(void) prepareWorkEnvironment
{
    [[XConfiguration getInstance] prepareSystemWorkspace];
    XSync* sync = [[XSync alloc] initWith:self];
    [sync run];
}

#pragma mark XSyncDelegate

-(void)syncDidFinish
{
    // 执行资源部署
    if ([self deployResources])
    {
        [[self bootDelegate] didFinishPreparingWorkEnvironment];
    }
    else
    {
        NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : @"fail to deployResources"};
        NSError *anError = [[NSError alloc] initWithDomain:@"xface" code:0 userInfo:errorDictionary];
        [[self bootDelegate] didFailToPrepareEnvironmentWithError:anError];
    }
}

/**
  使用player模式进行启动
 */
-(void) boot:(XAppManagement*)appManagement
{
    //清空所有缓存的response数据
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    id<XApplication> app = [self createDefaultApp];

    XAppList *appList = [appManagement appList];
    [appList add:app];
    [appList markAsDefaultApp:[app getAppId]];

    NSString *params = [[self bootDelegate] bootParams];
    [appManagement startDefaultAppWithParams:params];
}

- (BOOL) deployResources
{
    BOOL ret = NO;
    XConfiguration *config = [XConfiguration getInstance];

    //首先检查<Applilcation_Home>/Documents/目录下是否存在xface_player.zip:
    //1) 如果存在，则将其解压到<Applilcation_Home>/Documents/xface_player/apps/helloxface目录并将其作为默认应用进行加载
    //2) 如果不存在，则直接将<Applilcation_Home>/xFacePlayer.app/xface3/helloxface下的离散文件作为默认应用进行加载
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];

    // packagePath路径形如：<Applilcation_Home>/Documents/xface_player.zip
    NSString *packagePath = [documentDirectory stringByAppendingFormat:@"%@%@", FILE_SEPARATOR, XFACE_PLAYER_PACKAGE_NAME];
    NSString *destPath = [[config appInstallationDir] stringByAppendingPathComponent:DEFAULT_APP_ID_FOR_PLAYER];

    ret = [XUtils copyJsCore];
    if (!ret)
    {
        [[[[iToast makeText:@"Failed to copy js core files!"] setGravity:iToastGravityCenter] setDuration:iToastDurationLong] show];
        return ret;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isPackageExisted = [fileManager fileExistsAtPath:packagePath];
    if (isPackageExisted)
    {
        _defaultAppSrcRoot = APP_ROOT_WORKSPACE;
        ret = [XUtils unpackPackageAtPath:packagePath toPath:destPath];
        return ret;
    }
    else
    {
        _defaultAppSrcRoot = APP_ROOT_PREINSTALLED;

        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *srcAppFolderPath = [mainBundle pathForResource:DEFAULT_APP_ID_FOR_PLAYER ofType:nil inDirectory:XFACE_BUNDLE_FOLDER];
        NSAssert(srcAppFolderPath, @"Start app using player mode, but the default app files don't exist!");

        //为提高player启动速度，仅拷贝workspace,data目录，不再拷贝应用离散文件
        ret = [self copyUserDataRecursivelyAtPath:srcAppFolderPath toPath:destPath];
        return ret;
    }
}

- (BOOL) copyUserDataRecursivelyAtPath:(NSString *)srcPath toPath:(NSString *)destPath
{
    NSArray *userDataDirs = [NSArray arrayWithObjects:APP_WORKSPACE_FOLDER, APP_DATA_DIR_FOLDER, nil];
    NSEnumerator *enumerator = [userDataDirs objectEnumerator];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dir = nil;
    BOOL isDir = NO;
    BOOL ret = YES;

    if (![fileManager fileExistsAtPath:destPath])
    {
        // 保证destPath目录存在，否则执行copyItem时将失败（Cocoa error 4）
        [fileManager createDirectoryAtPath:destPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    while (dir = [enumerator nextObject])
    {
        NSString *srcUserDataDir = [srcPath stringByAppendingPathComponent:dir];
        if ([fileManager fileExistsAtPath:srcUserDataDir isDirectory:&isDir] && isDir)
        {
            NSString *destUserDataDir = [destPath stringByAppendingPathComponent:dir];
            ret &= [XFileUtils copyFileRecursively:srcUserDataDir toPath:destUserDataDir];
        }
    }
    return ret;
}

- (id<XApplication>)createDefaultApp
{
    NSString *appRoot = [[[XConfiguration getInstance] appInstallationDir] stringByAppendingPathComponent:DEFAULT_APP_ID_FOR_PLAYER];
    NSString *appConfigFilePath = [appRoot stringByAppendingPathComponent:APPLICATION_CONFIG_FILE_NAME];
    XAppInfo* info = [XUtils getAppInfoFromConfigFileAtPath:appConfigFilePath];

    if (info == nil) {
        info = [[XAppInfo alloc] init];
        info.isEncrypted = NO;
        info.entry = DEFAULT_APP_START_PAGE;
        info.type = APP_TYPE_XAPP;
    }

    info.appId = DEFAULT_APP_ID_FOR_PLAYER;
    info.srcRoot = _defaultAppSrcRoot;
    return [XApplicationFactory create:info];
}

@end
