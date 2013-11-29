
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
//  XLog.m
//  xFace
//
//

#import "XLog.h"
#import "XLogRedirect.h"

#define TAG_NAME @"xface"

@implementation XLog

+(void) logV:(NSString*)msg
{
    NSString* s = [self constructLogMessage:msg withLogLevel:@"Verbose"];
    NSLog(@"%@", s);
    [[XLogRedirect getInstance] logV:@"xface" msg:s];
}

+(void) logD:(NSString*)msg
{
    NSString* s = [self constructLogMessage:msg withLogLevel:@"Debug"];
    NSLog(@"%@", s);
    [[XLogRedirect getInstance] logD:@"xface" msg:s];
}

+(void) logI:(NSString*)msg
{
    NSString* s = [self constructLogMessage:msg withLogLevel:@"Info"];
    NSLog(@"%@", s);
    [[XLogRedirect getInstance] logI:@"xface" msg:s];
}

+(void) logW:(NSString*)msg
{
    NSString* s = [self constructLogMessage:msg withLogLevel:@"Warning"];
    NSLog(@"%@", s);
    [[XLogRedirect getInstance] logW:@"xface" msg:s];
}

+(void) logE:(NSString*)msg
{
    NSString* s = [self constructLogMessage:msg withLogLevel:@"Error"];
    NSLog(@"%@", s);
    [[XLogRedirect getInstance] logE:@"xface" msg:s];
}

+(void) close
{
    [[XLogRedirect getInstance] close];
}

+(NSString *) constructLogMessage:(NSString *)msg withLogLevel:(NSString *)logLevel
{
    return [NSString stringWithFormat:@"[__%@__]%@\n", logLevel, msg];
}

@end
