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
//  CKTProxyConfiguration.m
//  CircuitSDK
//
//

#import "CKTLog.h"
#import "CKTProxyConfiguration.h"

// Make the properties writable in the implementation
@interface CKTProxyConfiguration ()

@property (nonatomic, readwrite) NSString *address;
@property (nonatomic, readwrite) int port;

@end

static NSString *LOG_TAG = @"[CKTProxyConfiguration]";

@implementation CKTProxyConfiguration

static CKTProxyConfiguration *sharedInstance = nil;
+ (CKTProxyConfiguration *)sharedInstance
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{ sharedInstance = [[CKTProxyConfiguration alloc] init]; });
    return sharedInstance;
}

- (BOOL)getProxyForUrl:(NSURL *)url
{
    // Reset values in case this instance was used for another url or another
    // network
    self.address = @"";
    self.port = 0;

    if (!url) {
        LOGD(LOG_TAG, @"URL is nil");
        return NO;
    }

    // Good references for what will happen next:
    //     http://allseeing-i.com/ASIHTTPRequest/
    //     http://src.chromium.org/svn/trunk/src/net/proxy/proxy_config_service_ios.cc
    // The first one is somewhat out of date and no longer maintained, but the
    // general idea of how to deal with the network settings is still valid

    // Get list of proxies for the URL
    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    NSArray *allProxies = CFBridgingRelease(CFNetworkCopyProxiesForURL((__bridge CFURLRef)url, proxySettings));
    CFRelease(proxySettings);
    LOGD(LOG_TAG, @"Proxies for URL %@: %@", url, allProxies);

    // We will use the first proxy in the list (the preferred one)
    NSDictionary *firstProxy = allProxies[0];

    // Check if it's a PAC (proxy configuration script) and handle it by replacing
    // the PAC with the preferred proxy from the PAC
    NSURL *pacUrl = firstProxy[(NSString *)kCFProxyAutoConfigurationURLKey];
    if (pacUrl) {
        LOGD(LOG_TAG, @"Found PAC: %@", pacUrl);
        firstProxy = [self proxyFromPAC:pacUrl forURL:url];
    }

    // At this point the first proxy in the list is a proxy we got from the
    // settings, a proxy we got by resolving the PAC or nothing at all (when
    // proxies are not configured)

    NSString *proxyAddress = firstProxy[(NSString *)kCFProxyHostNameKey];
    if (proxyAddress.length > 0) {
        self.address = proxyAddress;
        self.port = (int)([firstProxy[(NSString *)kCFProxyPortNumberKey] integerValue]);
        LOGD(LOG_TAG, @"Found proxy %@:%d", self.address, self.port);
        return YES;  // found a proxy
    }

    LOGD(LOG_TAG, @"No proxy found");
    return NO;  // no proxy found
}

- (NSDictionary *)proxyFromPAC:(NSURL *)pacUrl forURL:(NSURL *)url
{
    // Download the PAC file
    // We will attempt a synchronous download with a short timeout - if we can't
    // get the PAC file quickly we are in trouble already
    __block NSDictionary *proxy;

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    // Send the request and handle response
    NSURLSessionDataTask *dataTask;
    dataTask = [[NSURLSession sharedSession]
          dataTaskWithURL:pacUrl
        completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)urlResponse;
            // Check if we got it
            if (error || (response.statusCode != 200)) {
                LOGE(LOG_TAG, @"PAC download failed:\n   Status code: %zd\n   Error: %@", response.statusCode, error);
            } else {
                // Run the PAC rules to find the proxy for the URL
                NSString *pacScript = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                if (pacScript) {
                            // The workaround below is in both samples I found (see links above)
                            // Since they know what they are doing, I'll keep the workaround in place

                            // Work around <rdar://problem/5530166>.  This dummy call to
                            // CFNetworkCopyProxiesForURL initialise some state within CFNetwork
                            // that is required by CFNetworkCopyProxiesForAutoConfigurationScript.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
                    CFRelease(CFNetworkCopyProxiesForURL((__bridge CFURLRef)url, NULL));
#pragma clang diagnostic pop

                    // Run the PAC script to get the list of proxies for the URL
                    CFErrorRef cfError = nil;
                    NSArray *allProxies = CFBridgingRelease(CFNetworkCopyProxiesForAutoConfigurationScript(
                        (__bridge CFStringRef)pacScript, (__bridge CFURLRef)url, &cfError));
                    if (cfError) {
                        NSError *error = (__bridge NSError *)cfError;
                        LOGE(LOG_TAG, @"PAC script failed: %@", error);
                    } else if (allProxies.count == 0) {
                        LOGE(LOG_TAG, @"PAC script returned no proxy");
                    } else {
                        // We will use the first (preferred) proxy
                        proxy = allProxies[0];
                    }
                } else {
                    LOGE(LOG_TAG, @"Failed to decode PAC URL response - received data:\n%@", data);
                }
            }
            dispatch_semaphore_signal(semaphore);
        }];

    [dataTask resume];
    dispatch_time_t pacScriptResponseTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_semaphore_wait(semaphore, pacScriptResponseTime);

    LOGD(LOG_TAG, @"proxyFromPAC - proxy:%@", proxy);
    return proxy;
}

@end
