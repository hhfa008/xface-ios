
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
//  XHTTPSURLProtocol.m
//  xFaceLib
//
//

#import "XHTTPSURLProtocol.h"
#import "XCredentialManager.h"

static BOOL gExchangeCredentialFinished = YES;             /**< 用于标记是否完成证书交换 */

@implementation XHTTPSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)theRequest
{
    //FIXME: 后来的https类型的reqeust应该也要被处理
    return ([[[theRequest URL] scheme] isEqualToString:@"https"] && gExchangeCredentialFinished);
}

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest*)request
{
    return request;
}

- (void)startLoading
{
    gExchangeCredentialFinished = NO;
    NSURLConnection *theConncetion = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (theConncetion) {
        _data = [NSMutableData data];
    }
}

- (void)stopLoading
{
    // NOTE:如有清理工作，可以在此处添加
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest*)requestA toRequest:(NSURLRequest*)requestB
{
    return NO;
}

#pragma mark - NSURLConnectionDelegate

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    //响应服务器证书认证请求和客户端证书认证请求
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] ||
    [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential* credential;
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        //服务器证书认证
        credential= [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    }
    else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
    {
        //客户端证书认证
        credential = [XCredentialManager firstCredential];
    }

    if (credential != nil)
    {
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }
    else
    {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[self client] URLProtocol:self didLoadData:_data];
    [[self client] URLProtocolDidFinishLoading:self];
    gExchangeCredentialFinished = YES;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
    gExchangeCredentialFinished = YES;
}

@end
