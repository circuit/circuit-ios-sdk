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
//  Log.h
//  CircuitSDK
//
//

#import <Foundation/Foundation.h>

#define logStateOff 0
#define logStateMinimum 1
#define logStateMedium 2
#define logStateMaximum 3

#define logLevelDebug 1
#define logLevelInfo 2
#define logLevelWarn 3
#define logLevelError 4
#define logLevelMsg 5

// Log macros

extern void (^ANSLogd)(NSString *, NSString *);
extern void (^ANSLogi)(NSString *, NSString *);
extern void (^ANSLogw)(NSString *, NSString *);
extern void (^ANSLoge)(NSString *, NSString *);
extern void (^ANSLogButtonTap)(NSString *, NSString *);

#define LOGD(tag, format, ...)                                                                     \
    do {                                                                                           \
        if ([[ANSLog sharedDebug] getiLogState] == logStateMaximum) {                              \
            [[ANSLog sharedDebug] logFile:logLevelDebug logTag:tag input:(format), ##__VA_ARGS__]; \
        }                                                                                          \
    } while (0)

#define LOGI(tag, format, ...)                                                                    \
    do {                                                                                          \
        if ([[ANSLog sharedDebug] getiLogState] >= logStateMedium) {                              \
            [[ANSLog sharedDebug] logFile:logLevelInfo logTag:tag input:(format), ##__VA_ARGS__]; \
        }                                                                                         \
    } while (0)

#define LOGW(tag, format, ...)                                                                    \
    do {                                                                                          \
        if ([[ANSLog sharedDebug] getiLogState] != logStateOff) {                                 \
            [[ANSLog sharedDebug] logFile:logLevelWarn logTag:tag input:(format), ##__VA_ARGS__]; \
        }                                                                                         \
    } while (0)

#define LOGE(tag, format, ...)                                                                     \
    do {                                                                                           \
        if ([[ANSLog sharedDebug] getiLogState] != logStateOff) {                                  \
            [[ANSLog sharedDebug] logFile:logLevelError logTag:tag input:(format), ##__VA_ARGS__]; \
        }                                                                                          \
    } while (0)

// Log macros - same as above, but with the function name

#define LOGFD(tag, format, ...)                                       \
    do {                                                              \
        if ([[ANSLog sharedDebug] getiLogState] == logStateMaximum) { \
            [[ANSLog sharedDebug] logFile:logLevelDebug               \
                                   logTag:tag                         \
                             withFunction:__PRETTY_FUNCTION__         \
                                    input:(format), ##__VA_ARGS__];   \
        }                                                             \
    } while (0)

#define LOGFI(tag, format, ...)                                      \
    do {                                                             \
        if ([[ANSLog sharedDebug] getiLogState] >= logStateMedium) { \
            [[ANSLog sharedDebug] logFile:logLevelInfo               \
                                   logTag:tag                        \
                             withFunction:__PRETTY_FUNCTION__        \
                                    input:(format), ##__VA_ARGS__];  \
        }                                                            \
    } while (0)

#define LOGFW(tag, format, ...)                                     \
    do {                                                            \
        if ([[ANSLog sharedDebug] getiLogState] != logStateOff) {   \
            [[ANSLog sharedDebug] logFile:logLevelWarn              \
                                   logTag:tag                       \
                             withFunction:__PRETTY_FUNCTION__       \
                                    input:(format), ##__VA_ARGS__]; \
        }                                                           \
    } while (0)

#define LOGFE(tag, format, ...)                                     \
    do {                                                            \
        if ([[ANSLog sharedDebug] getiLogState] != logStateOff) {   \
            [[ANSLog sharedDebug] logFile:logLevelError             \
                                   logTag:tag                       \
                             withFunction:__PRETTY_FUNCTION__       \
                                    input:(format), ##__VA_ARGS__]; \
        }                                                           \
    } while (0)

// Specialized log macros

// Logs when a user presses a button or taps an option on screen
#define LOG_BUTTON_TAP(tag, buttonTapName)                                                  \
    do {                                                                                    \
        if ([[ANSLog sharedDebug] getiLogState] >= logStateMinimum) {                       \
            [[ANSLog sharedDebug] logFile:logLevelInfo                                      \
                                   logTag:tag                                               \
                                    input:(@"User action - press/tap: %@"), buttonTapName]; \
        }                                                                                   \
    } while (0)

// Verbose logging for development use
#define VERBOSE 0
#if VERBOSE
#define LOGV(tag, format, ...)                                                                     \
    do {                                                                                           \
        if ([[ANSLog sharedDebug] getiLogState] == logStateMaximum) {                              \
            [[ANSLog sharedDebug] logFile:logLevelDebug logTag:tag input:(format), ##__VA_ARGS__]; \
        }                                                                                          \
    } while (0)
#else
#define LOGV(tag, format, ...)
#endif

// Function prototypes
void client_log(int level, const char *tag, const char *msg, ...);
int client_get_log_state(void);

@interface ANSLog : NSObject

// User information - to be set once user is registered
@property (copy) NSString *registeredUserName;
@property (copy) NSString *registeredUserId;
@property (copy) NSString *registeredUserTenantId;
@property (copy) NSString *registeredUserEmail;

+ (ANSLog *)sharedDebug;

- (void)logFile:(int)logLevel logTag:(NSString *)logTag input:(NSString *)input, ...;
- (void)logFile:(int)logLevel
          logTag:(NSString *)logTag
    withFunction:(const char *)lFunction
           input:(NSString *)input, ...;

- (NSInteger)getiLogState;
- (void)setLogState:(NSInteger)state;

- (void)writeJStoLog:(NSString *)msg;

- (NSInteger)getLogFileList:(NSMutableArray **)files logDir:(NSString *)logDir;
- (NSInteger)deleteCrashFiles:(NSInteger)remaining;

@end
