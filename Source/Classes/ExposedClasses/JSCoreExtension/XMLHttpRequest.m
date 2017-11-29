// Apache 2.0 License
//
// Copyright 2017 Unify Software and Solutions GmbH & Co.KG.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// XMLHttpRequest.m
//  CircuitSDK
//
//

#import "XMLHttpRequest.h"
#import "CKTHttp.h"

@implementation XMLHttpRequest {
    NSString *_method;
    NSString *_url;
    NSMutableDictionary *_object;
    BOOL _async;
    JSManagedValue *_onLoad;
    JSManagedValue *_onError;
}

@synthesize responseText;
@synthesize readyState;
@synthesize status;
@synthesize response;

static NSURLSession *urlSession;
NSMutableURLRequest *req;

+ (void)setURLSession:(NSURLSession *)session
{
    urlSession = session;
}

- (void)open:(NSString *)httpMethod:(NSString *)url:(bool)async;
{
    _method = httpMethod;
    _url = url;
    _async = async;
    readyState = 1;
    req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_url]];
}

- (void)setRequestHeader:(NSString *)key:(NSString *)value
{
    /*
        All headers must be set on the native request object,
        not the XMLHttpRequest object being injected to the JavaScript.

        Setting headers on the XMLHttpRequest object will not be passed into
        the correlating JavaScript call.

        This is because we are natively sending requests using NSURLRequest.
    */

    [req setValue:value forHTTPHeaderField:key];
}

- (void)setOnload:(JSValue *)onload
{
    _onLoad = [JSManagedValue managedValueWithValue:onload];
    [[[JSContext currentContext] virtualMachine] addManagedReference:_onLoad withOwner:self];
}

- (JSValue *)onload
{
    return _onLoad.value;
}

- (void)setOnerror:(JSValue *)onerror
{
    _onError = [JSManagedValue managedValueWithValue:onerror];
    [[[JSContext currentContext] virtualMachine] addManagedReference:_onError withOwner:self];
}
- (JSValue *)onerror
{
    return _onError.value;
}

- (void)send:(NSString *)formData
{
    readyState = 2;

    req.HTTPMethod = _method;
    if (![_method isEqualToString:@"GET"]) {
        NSData *payloadData = [formData dataUsingEncoding:NSUTF8StringEncoding];
        req.HTTPBody = payloadData;
    }

    NSURLSessionDataTask *dataTask;

    readyState = 3;

    dataTask =
        [urlSession dataTaskWithRequest:req
                      completionHandler:^(NSData *data, NSURLResponse *serverResponse, NSError *error) {
                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)serverResponse;
                          self.response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                          self.status = [httpResponse statusCode];
                          if (httpResponse.statusCode == 200) {
                              responseText = response;
                              readyState = 4;
                              if (!error && _onLoad)
                                  [[_onLoad.value invokeMethod:@"bind" withArguments:@[ self ]] callWithArguments:NULL];
                              else if (error && _onError)
                                  [[_onError.value invokeMethod:@"bind" withArguments:@[ self ]] callWithArguments:@[
                                      [JSValue valueWithNewErrorFromMessage:error.localizedDescription
                                                                  inContext:[JSContext currentContext]]
                                  ]];
                          }
                      }];

    [dataTask resume];
}

@end
