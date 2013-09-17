
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
//  XAppInstallListener.h
//  xFace
//
//

#import <Foundation/Foundation.h>
#import "XInstallListener.h"

@class XJavaScriptEvaluator;

/**
 app安装监听器，负责监听app的安装、卸载进度
 */
@interface XAppInstallListener : NSObject <XInstallListener>
{
    XJavaScriptEvaluator *jsEvaluator;     /**< js语句执行者 */
    NSString             *callbackId;      /**< 回调id */
}

/**
 初始化方法
 @param javascriptEvaluator js语句执行者
 @param cbId       回调id
 @param appViewId  关联的视图id
 @returns 初始化后的XAppInstallListener对象，如果初始化失败，则返回nil
 */
- (id)initWithJsEvaluator:(XJavaScriptEvaluator *)javascriptEvaluator callbackId:(NSString *)cbId;

@end
