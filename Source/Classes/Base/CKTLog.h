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
//  CKTLog.h
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

extern void (^CKTLogd)(NSString *, NSString *);
extern void (^CKTLogi)(NSString *, NSString *);
extern void (^CKTLogw)(NSString *, NSString *);
extern void (^CKTLoge)(NSString *, NSString *);
extern void (^CKTLogButtonTap)(NSString *, NSString *);

#define LOGD(tag, format, ...)                                                                     \
    do {                                                                                           \
        if ([[CKTLog sharedDebug] getiLogState] == logStateMaximum) {                              \
            [[CKTLog sharedDebug] logFile:logLevelDebug logTag:tag input:(format), ##__VA_ARGS__]; \
        }                                                                                          \
    } while (0)

#define LOGI(tag, format, ...)                                                                    \
    do {                                                                                          \
        if ([[CKTLog sharedDebug] getiLogState] >= logStateMedium) {                              \
            [[CKTLog sharedDebug] logFile:logLevelInfo logTag:tag input:(format), ##__VA_ARGS__]; \
        }                                                                                         \
    } while (0)

#define LOGW(tag, format, ...)                                                                    \
    do {                                                                                          \
        if ([[CKTLog sharedDebug] getiLogState] != logStateOff) {                                 \
            [[CKTLog sharedDebug] logFile:logLevelWarn logTag:tag input:(format), ##__VA_ARGS__]; \
        }                                                                                         \
    } while (0)

#define LOGE(tag, format, ...)                                                                     \
    do {                                                                                           \
        if ([[CKTLog sharedDebug] getiLogState] != logStateOff) {                                  \
            [[CKTLog sharedDebug] logFile:logLevelError logTag:tag input:(format), ##__VA_ARGS__]; \
        }                                                                                          \
    } while (0)

// Log macros - same as above, but with the function name

#define LOGFD(tag, format, ...)                                       \
    do {                                                              \
        if ([[CKTLog sharedDebug] getiLogState] == logStateMaximum) { \
            [[CKTLog sharedDebug] logFile:logLevelDebug               \
                                   logTag:tag                         \
                             withFunction:__PRETTY_FUNCTION__         \
                                    input:(format), ##__VA_ARGS__];   \
        }                                                             \
    } while (0)

#define LOGFI(tag, format, ...)                                      \
    do {                                                             \
        if ([[CKTLog sharedDebug] getiLogState] >= logStateMedium) { \
            [[CKTLog sharedDebug] logFile:logLevelInfo               \
                                   logTag:tag                        \
                             withFunction:__PRETTY_FUNCTION__        \
                                    input:(format), ##__VA_ARGS__];  \
        }                                                            \
    } while (0)

#define LOGFW(tag, format, ...)                                     \
    do {                                                            \
        if ([[CKTLog sharedDebug] getiLogState] != logStateOff) {   \
            [[CKTLog sharedDebug] logFile:logLevelWarn              \
                                   logTag:tag                       \
                             withFunction:__PRETTY_FUNCTION__       \
                                    input:(format), ##__VA_ARGS__]; \
        }                                                           \
    } while (0)

#define LOGFE(tag, format, ...)                                     \
    do {                                                            \
        if ([[CKTLog sharedDebug] getiLogState] != logStateOff) {   \
            [[CKTLog sharedDebug] logFile:logLevelError             \
                                   logTag:tag                       \
                             withFunction:__PRETTY_FUNCTION__       \
                                    input:(format), ##__VA_ARGS__]; \
        }                                                           \
    } while (0)

// Specialized log macros

// Logs when a user presses a button or taps an option on screen
#define LOG_BUTTON_TAP(tag, buttonTapName)                                                  \
    do {                                                                                    \
        if ([[CKTLog sharedDebug] getiLogState] >= logStateMinimum) {                       \
            [[CKTLog sharedDebug] logFile:logLevelInfo                                      \
                                   logTag:tag                                               \
                                    input:(@"User action - press/tap: %@"), buttonTapName]; \
        }                                                                                   \
    } while (0)

// Verbose logging for development use
#define VERBOSE 0
#if VERBOSE
#define LOGV(tag, format, ...)                                                                     \
    do {                                                                                           \
        if ([[CKTLog sharedDebug] getiLogState] == logStateMaximum) {                              \
            [[CKTLog sharedDebug] logFile:logLevelDebug logTag:tag input:(format), ##__VA_ARGS__]; \
        }                                                                                          \
    } while (0)
#else
#define LOGV(tag, format, ...)
#endif

extern NSString *const kLogTagCircuitKit;

// Function prototypes
void client_log(int level, const char *tag, const char *msg, ...);
int client_get_log_state(void);

@interface CKTLog : NSObject

@property (nonatomic) NSInteger logState;
@property (nonatomic) NSInteger numOfFiles;
@property (strong) NSFileHandle *currFile;
@property (strong) NSFileHandle *quickDiagnosticFile;
@property (nonatomic) NSInteger logStatus;
@property (nonatomic) dispatch_queue_t queue;
@property (strong) NSArray *myLevel;
@property (nonatomic) NSInteger myPid;
@property (strong) NSDateFormatter *myDateFormatter;

// User information - to be set once user is registered
@property (copy) NSString *registeredUserName;
@property (copy) NSString *registeredUserId;
@property (copy) NSString *registeredUserTenantId;
@property (copy) NSString *registeredUserEmail;

+ (CKTLog *)sharedDebug;
- (void)logFile:(int)logLevel logTag:(NSString *)logTag input:(NSString *)input, ...;
- (void)logFile:(int)logLevel
          logTag:(NSString *)logTag
    withFunction:(const char *)lFunction
           input:(NSString *)input, ...;
- (void)iphoneLogPrint:(int)logLevel logTag:(NSString *)logTag msg:(NSString *)msg;
- (NSInteger)getiLogState;
- (void)setLogState:(NSInteger)state;
- (NSInteger)getLogFileList:(NSMutableArray **)files logDir:(NSString *)logDir;
- (BOOL)openExistingLogFile:(NSMutableArray *)files;
- (BOOL)openNewLogFile:(NSMutableArray **)files;
- (BOOL)openNewLegibleLogFile:(NSMutableArray **)files;
- (NSInteger)deleteLogFiles:(NSInteger)remaining;
- (NSInteger)deleteCrashFiles:(NSInteger)remaining;
- (NSInteger)deleteLegibleLogFiles:(NSInteger)remaining;
- (void)logSystemData:(NSString *)pathToFile;
- (void)closeLogFile;
- (void)writeToLog:(NSArray *)msgList;
- (void)writeToLog:(NSString *)log_tag level:(NSInteger)levelIdx message:(NSString *)log_msg dateObject:(NSDate *)date;
- (void)writeJStoLog:(NSString *)msg;
- (void)basicPrint:(NSData *)message;
- (void)writeLegible:(NSString *)message;
- (void)logHeaderPrint:(NSData *)message;
- (BOOL)createLogsDirectory:(NSString *)logDir;
- (BOOL)checkCurrFileHandler;
- (NSString *)logLevelToStr:(NSInteger)logLevel;

@end
