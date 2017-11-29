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
//  CKTLog.m
//  CircuitSDK
//
//

#import "CKTLog.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

NSString *const kLogTagCircuitKit = @"[PCKT]";

#define lss_blocked 0
#define lss_active 1

#define MaxFileSize 1024 * 1024
#define MaxFiles 5

// Swift-compatible interface for logging
void (^CKTLogd)(NSString *, NSString *) = ^void(NSString *tag, NSString *text) {
    if ([[CKTLog sharedDebug] getiLogState] == logStateMaximum) {
        [[CKTLog sharedDebug] logFile:logLevelDebug logTag:tag input:text];
    }
};

void (^CKTLogi)(NSString *, NSString *) = ^void(NSString *tag, NSString *text) {
    if ([[CKTLog sharedDebug] getiLogState] >= logStateMedium) {
        [[CKTLog sharedDebug] logFile:logLevelInfo logTag:tag input:text];
    }
};

void (^CKTLogw)(NSString *, NSString *) = ^void(NSString *tag, NSString *text) {
    if ([[CKTLog sharedDebug] getiLogState] != logStateOff) {
        [[CKTLog sharedDebug] logFile:logLevelWarn logTag:tag input:text];
    }
};

void (^CKTLoge)(NSString *, NSString *) = ^void(NSString *tag, NSString *text) {
    if ([[CKTLog sharedDebug] getiLogState] != logStateOff) {
        [[CKTLog sharedDebug] logFile:logLevelError logTag:tag input:text];
    }
};

void (^CKTLogButtonTap)(NSString *, NSString *) = ^void(NSString *tag, NSString *buttonTapName) {
    if ([[CKTLog sharedDebug] getiLogState] >= logStateMinimum) {
        [[CKTLog sharedDebug] logFile:logLevelInfo logTag:tag input:(@"User action - press/tap: %@"), buttonTapName];
    }
};

@implementation CKTLog

const static NSString *CKT_PREFIX = @"PCKT";  // Specifically for DAT - yes, and DAT is awesome

static NSString *device;
static NSString *version;

static NSArray *JSlevelAry;

+ (CKTLog *)sharedDebug
{
    static CKTLog *sharedDebug = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedDebug = [[CKTLog alloc] init]; });
    return sharedDebug;
}

- (instancetype)init
{
    if ((self = [super init])) {
        NSMutableArray *files = [[NSMutableArray alloc] init];
        NSMutableArray *crfiles = [[NSMutableArray alloc] init];
        NSMutableArray *legibleFiles = [[NSMutableArray alloc] init];
        self.queue = dispatch_queue_create("com.evo.siemens.LogQueue", NULL);

        self.logStatus = lss_blocked;
        // Settings should be setting the Log state from saved value
        // temporary set it to medium
        //----------------------------------------------------------
        self.logState = logStateMaximum;  // logStateMedium;

        self.numOfFiles = 0;
        self.currFile = nil;
        self.quickDiagnosticFile = nil;
        self.myLevel = @[ @"D", @"I", @"W", @"E", @"M" ];
        self.myDateFormatter = [self dateFormatter24Hour:@"yy-MM-dd HH:mm:ss.SSS"];
        self.myPid = [NSProcessInfo processInfo].processIdentifier;

        // With thanks to http://stackoverflow.com/questions/11197509/ios-iphone-get-device-model-and-make
        struct utsname systemInfo;
        uname(&systemInfo);
        device = @(systemInfo.machine);

        // With thanks to the OSMO code
        version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];

// If this is a development build, make that clear so we can tell distribution builds apart from development
// builds. May be useful to understand differences in behavior (e.g. in development builds we log passwords).
#ifdef DEBUG
        version = [NSString stringWithFormat:@"Dev build %s %s", __DATE__, __TIME__];
#endif

        @try {
            [self getLogFileList:&crfiles logDir:@"CRLogs/"];
            [self getLogFileList:&files logDir:@"Logs/"];
            [self getLogFileList:&legibleFiles logDir:@"LogsQuick/"];
            if ([self openExistingLogFile:files] == NO) {
                [self openNewLogFile:&files];
            }
            if ([self openExistingLegibleLogFile:legibleFiles] == NO) {
                [self openNewLegibleLogFile:&legibleFiles];
            }

            JSlevelAry = @[ @"[DEBUG]", @"[INFO]", @"[WARN]", @"[ERROR]" ];
        }
        @catch (NSException *exception)
        {
            NSLog(@"init Exception %@", exception.reason);
        }
        @finally
        {
        }

        self.logStatus = lss_active;
        self.numOfFiles = files.count;
    }

    return self;
}

- (NSInteger)getiLogState
{
    return self.logState;
}

- (void)setLogState:(NSInteger)state
{
    _logState = state;
}

- (NSInteger)getLogState
{
    return self.logState;
}

- (NSInteger)getLogFileList:(NSMutableArray **)files logDir:(NSString *)logDir
{
    BOOL isDir = NO;
    NSInteger fileCount = 0;
    NSArray *subpaths;

    @try {
        NSFileManager *fileManager = [[NSFileManager alloc] init];  // using "defaultManager" method is not thread safe

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathToDocumentsDir = paths[0];

        NSString *pathToLogsDir =
            [pathToDocumentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", logDir]];

        if ([fileManager fileExistsAtPath:pathToLogsDir isDirectory:&isDir] && isDir) {
            subpaths = [fileManager subpathsAtPath:pathToLogsDir];
            // if ( ! [logDir isEqualToString:@"Logs/"] )
            //    NSLog(@"getLogFileList:count=%d:%@", [subpaths count], pathToLogsDir);

            // Sort
            NSString *file;
            NSDictionary *subpathsFileAttributes;
            NSDate *subpathsFileDate;

            for (int i = 0; i < subpaths.count; i++) {
                BOOL inserted = NO;
                file = [pathToLogsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", subpaths[i]]];
                subpathsFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
                subpathsFileDate = subpathsFileAttributes[NSFileModificationDate];
                NSString *fileSize1 = subpathsFileAttributes[@"NSFileSize"];
                NSInteger subPathsSize = fileSize1.intValue;

                for (int j = 0; j < (*files).count; j++) {
                    NSDictionary *filesAttributes;
                    NSDate *filesFileDate;
                    NSString *file2;
                    file2 =
                        [pathToLogsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", (*files)[j]]];
                    filesAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file2 error:nil];
                    filesFileDate = filesAttributes[NSFileModificationDate];
                    NSString *fileSize2 = filesAttributes[@"NSFileSize"];
                    NSInteger filesFileSize = fileSize2.intValue;

                    if ([subpathsFileDate isEqualToDate:filesFileDate]) {
                        if (subPathsSize >= MaxFileSize) {
                            [*files insertObject:subpaths[i] atIndex:j];
                            inserted = YES;
                            break;
                        } else if (subPathsSize > filesFileSize) {
                            [*files insertObject:subpaths[i] atIndex:j];
                            inserted = YES;
                            break;
                        }
                    } else if ([subpathsFileDate earlierDate:filesFileDate] == subpathsFileDate) {
                        [*files insertObject:subpaths[i] atIndex:j];
                        inserted = YES;
                        break;
                    }
                }
                if (inserted == NO) {
                    [*files addObject:subpaths[i]];
                }
            }

            fileCount = (*files).count;
        } else {
            [self createLogsDirectory:logDir];
        }
        //[fileManager release];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't get file list.....");
    }
    @finally
    {
        // Do something here?
    }

    // return how many files there are in the dir
    return fileCount;
}

- (BOOL)openExistingLogFile:(NSMutableArray *)files
{
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathToDocumentsDir = paths[0];

        NSInteger count = files.count;
        if (count > 0) {
            NSString *pathToFile = files.lastObject;
            NSString *file =
                [pathToDocumentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"Logs/%@", pathToFile]];
            NSFileHandle *lastFile = [NSFileHandle fileHandleForUpdatingAtPath:file];

            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
            NSString *fileSize = attributes[@"NSFileSize"];
            NSInteger size = fileSize.intValue;

            if (size < MaxFileSize) {
                // Go to the end of the existing file before we write anything to it
                [lastFile truncateFileAtOffset:[lastFile seekToEndOfFile]];

                self.currFile = lastFile;
                self.logStatus = lss_active;

                return YES;
            }
        }

        return NO;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't open existing file.....");
        return NO;
    }
    @finally
    {
        // Do something here?
    }
}

- (BOOL)openNewLogFile:(NSMutableArray **)files
{
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathToDocumentsDir = paths[0];

        // Logs/evoMMddHHmmss.log
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [self dateFormatter24Hour:@"MMddHHmmss"];
        NSString *newFile = [dateFormatter stringFromDate:today];

        NSString *pathToFile =
            [pathToDocumentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"Logs/pans%@.log", newFile]];
        [[NSFileManager defaultManager] createFileAtPath:pathToFile contents:nil attributes:nil];

        self.currFile = [NSFileHandle fileHandleForUpdatingAtPath:pathToFile];
        self.logStatus = lss_active;

        [*files addObject:pathToFile];
        if (self.logState > logStateOff) {
            [self logSystemData:pathToFile];
        }

        return YES;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't open new file.....");
        return NO;
    }
    @finally
    {
        // Do something here?
    }
}

- (BOOL)openExistingLegibleLogFile:(NSMutableArray *)files
{
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathToDocumentsDir = paths[0];

        NSInteger count = files.count;
        if (count > 0) {
            NSString *pathToFile = files.lastObject;
            NSString *file = [pathToDocumentsDir
                stringByAppendingPathComponent:[NSString stringWithFormat:@"LogsQuick/%@", pathToFile]];
            NSFileHandle *lastFile = [NSFileHandle fileHandleForUpdatingAtPath:file];

            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil];
            NSString *fileSize = attributes[@"NSFileSize"];
            NSInteger size = fileSize.intValue;

            if (size < MaxFileSize) {
                // Go to the end of the existing file before we write anything to it
                [lastFile truncateFileAtOffset:[lastFile seekToEndOfFile]];

                self.quickDiagnosticFile = lastFile;

                return YES;
            }
        }

        return NO;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't open existing file.....");
        return NO;
    }
    @finally
    {
        // Do something here?
    }
}

- (BOOL)openNewLegibleLogFile:(NSMutableArray **)files
{
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathToDocumentsDir = paths[0];

        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [self dateFormatter24Hour:@"MMddHHmmss"];
        NSString *date = [dateFormatter stringFromDate:today];

        NSString *newFile = @"pansQuickDiagnostic.txt";

        NSString *pathToFile = [pathToDocumentsDir
            stringByAppendingPathComponent:[NSString stringWithFormat:@"LogsQuick/%@%@", date, newFile]];
        [[NSFileManager defaultManager] createFileAtPath:pathToFile contents:nil attributes:nil];

        self.quickDiagnosticFile = [NSFileHandle fileHandleForUpdatingAtPath:pathToFile];
        [*files addObject:pathToFile];

        return YES;
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't open new file.....");
        return NO;
    }
    @finally
    {
        // Do something here?
    }
}

// Create logs directory within Documents folder
- (BOOL)createLogsDirectory:(NSString *)logDir
{
    NSFileManager *fileManager;
    NSArray *paths;
    NSString *pathToDocumentsDir;
    NSString *logsDir;
    BOOL success;

    fileManager = [NSFileManager defaultManager];

    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    pathToDocumentsDir = paths[0];

    logsDir = [pathToDocumentsDir stringByAppendingPathComponent:logDir];

    // Create ./Logs, ./CRLogs directory...
    NSError *error;
    success = [fileManager createDirectoryAtPath:logsDir withIntermediateDirectories:NO attributes:nil error:&error];
    if (!success)
        NSLog(@"ERROR create %@ directory: %@", logDir, error);

    return success;
}

- (NSInteger)deleteLogFiles:(NSInteger)remaining
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *file;
    NSMutableArray *files = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathToDocumentsDir = paths[0];

        count = [self getLogFileList:&files logDir:@"Logs/"];

        for (int idx = 0; count > remaining; count--, idx++) {
            file =
                [pathToDocumentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"Logs/%@", files[idx]]];

            [fileManager removeItemAtPath:file error:nil];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't delete log file.....");
    }
    @finally
    {
        return count;
    }
}

- (NSInteger)deleteLegibleLogFiles:(NSInteger)remaining
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *file;
    NSMutableArray *files = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathToDocumentsDir = paths[0];

        count = [self getLogFileList:&files logDir:@"LogsQuick/"];

        for (int idx = 0; count > remaining; count--, idx++) {
            file = [pathToDocumentsDir
                stringByAppendingPathComponent:[NSString stringWithFormat:@"LogsQuick/%@", files[idx]]];

            [fileManager removeItemAtPath:file error:nil];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't delete log file.....");
    }
    @finally
    {
        return count;
    }
}

- (NSInteger)deleteCrashFiles:(NSInteger)remaining
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *file;
    NSMutableArray *files = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *pathToDocumentsDir = paths[0];

        count = [self getLogFileList:&files logDir:@"CRLogs/"];

        for (int idx = 0; count > remaining; count--, idx++) {
            file = [pathToDocumentsDir
                stringByAppendingPathComponent:[NSString stringWithFormat:@"CRLogs/%@", files[idx]]];

            [fileManager removeItemAtPath:file error:nil];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't delete log file.....");
    }
    @finally
    {
        return count;
    }
}

- (void)logSystemData:(NSString *)pathToFile
{
    NSMutableString *fileHeader;
    NSData *data;

    @synchronized(self)
    {
        // Opening file
        fileHeader = [[NSMutableString alloc] initWithString:@"Opening Log File "];
        [fileHeader appendFormat:@"%@ \r\n", pathToFile];

        [fileHeader appendFormat:@"OS Version: %@ \r\n", [UIDevice currentDevice].systemVersion];
        [fileHeader appendFormat:@"Project Circuit Version: %@ \r\n", version];
        [fileHeader appendFormat:@"Device Model: %@ \r\n", device];

        // Read system preferences (Settings)
        NSString *tmp = nil;
        [fileHeader appendString:@"Project Circuit Server: "];
        if (tmp != nil) {
            [fileHeader appendFormat:@"%@ \r\n", tmp];
        } else {
            [fileHeader appendString:@"Not initialized \r\n"];
        }

        // Read battery indication
        [fileHeader appendString:@"Battery Level: "];
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        float batteryLevel = [UIDevice currentDevice].batteryLevel;
        [UIDevice currentDevice].batteryMonitoringEnabled = NO;

        if (batteryLevel < 0.0) {
            // -1.0 means battery state is UIDeviceBatteryStateUnknown
            [fileHeader appendString:@"Unknown \r\n"];
        } else {
            batteryLevel = batteryLevel * 100;
            [fileHeader appendFormat:@"%0.0f \r\n", batteryLevel];
        }

        // User information
        [fileHeader appendFormat:@"User display name: %@\r\n",
                                 self.registeredUserName.length ? self.registeredUserName : @"Not initialized"];
        [fileHeader
            appendFormat:@"User ID: %@\r\n", self.registeredUserId.length ? self.registeredUserId : @"Not initialized"];
        [fileHeader appendFormat:@"Tenant ID: %@\r\n",
                                 self.registeredUserTenantId.length ? self.registeredUserTenantId : @"Not initialized"];
        [fileHeader appendFormat:@"Account: %@\r\n",
                                 self.registeredUserEmail.length ? self.registeredUserEmail : @"Not initialized"];

        data = [fileHeader dataUsingEncoding:NSUTF8StringEncoding];
        [self logHeaderPrint:data];
    }
}

- (void)logHeaderPrint:(NSData *)message
{
    @try {
        if (self.logStatus == lss_active) {
            if (self.currFile != nil) {
                [self.currFile truncateFileAtOffset:0];
                [self.currFile writeData:message];
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't write into file (logHeaderPrint).....");
    }
}

- (void)closeLogFile
{
    [self.currFile synchronizeFile];
    [self.currFile closeFile];
    self.currFile = nil;
}

- (void)closeLegibleLogFile
{
    [self.quickDiagnosticFile synchronizeFile];
    [self.quickDiagnosticFile closeFile];
    self.quickDiagnosticFile = nil;
}

- (NSString *)logLevelToStr:(NSInteger)logLevel
{
    NSString *level;

    if ((logLevel >= 0) && (logLevel < 6)) {
        level = self.myLevel[(logLevel)];
        return level;
    }
    return @"D";
}

- (void)writeToLog:(NSArray *)msgList
{
    @try {
        NSDate *today = [NSDate date];
        NSThread *threadId = [NSThread currentThread];

        dispatch_async(self.queue, ^{

            @try {
                NSData *data;
                if (self.logStatus == lss_active) {
                    NSString *tempDate;
                    @synchronized(self.myDateFormatter)
                    {
                        tempDate = [self.myDateFormatter stringFromDate:today];
                    }

                    NSString *level = msgList[0];
                    NSString *logTag = msgList[1];
                    NSString *msg = msgList[2];

                    NSString *log =
                        [NSString stringWithFormat:@"%@ %ld %p %@ %@ : %@ %@\r\n", tempDate, (long)self.myPid, threadId,
                                                   level, CKT_PREFIX, logTag, msg];

#ifdef DEBUG
                    NSString *log2 =
                        [NSString stringWithFormat:@"%p %@ %@ : %@ %@", threadId, level, CKT_PREFIX, logTag, msg];
                    NSLog(@"%@", log2);
#endif
                    data = [log dataUsingEncoding:NSUTF8StringEncoding];

                    [self basicPrint:data];
                }

            }  // @try
            @catch (NSException *exception)
            {
                NSLog(@"writeToLog Exception %@", exception.reason);
            }
        });
    }
    @catch (NSException *exception)
    {
        NSLog(@"writeToLog Exception %@", exception.reason);
    }
}

// This method writes JavaScript entries to the Log
- (void)writeToLog:(NSString *)log_tag level:(NSInteger)levelIdx message:(NSString *)log_msg dateObject:(NSDate *)date;
{
    @try {
        if (self.logState == logStateOff)
            return;

        NSThread *threadId = [NSThread currentThread];

        dispatch_async(self.queue, ^{

            @try {
                NSData *data;
                if (self.logStatus == lss_active) {
                    NSString *tempDate;
                    @synchronized(self.myDateFormatter)
                    {
                        tempDate = [self.myDateFormatter stringFromDate:date];
                    }

                    NSString *log_level = [self logLevelToStr:levelIdx];

                    NSString *log =
                        [NSString stringWithFormat:@"%@ %ld %p %@ %@ : %@ %@\r\n", tempDate, (long)self.myPid, threadId,
                                                   log_level, CKT_PREFIX, log_tag, log_msg];

#ifdef DEBUG
                    NSString *log2 = [NSString
                        stringWithFormat:@"%p %@ %@ : %@ %@", threadId, log_level, CKT_PREFIX, log_tag, log_msg];
                    NSLog(@"%@", log2);
#endif
                    data = [log dataUsingEncoding:NSUTF8StringEncoding];

                    [self basicPrint:data];
                }

            }  // @try
            @catch (NSException *exception)
            {
                NSLog(@"writeToLog Exception %@", exception.reason);
            }
        });
    }
    @catch (NSException *exception)
    {
        NSLog(@"writeToLog Exception %@", exception.reason);
    }
}

// This method writes JavaScript entries to the Log
- (void)writeJStoLog:(NSString *)msg
{
    // Parse out the Time and Level from the string
    NSRange lrng = [msg rangeOfString:@"["];
    NSString *msecStr = [msg substringToIndex:lrng.location];
    NSString *lMsg = [msg substringFromIndex:lrng.location];
    NSRange lrng2 = [lMsg rangeOfString:@"]"];
    NSString *lvlStr = [lMsg substringToIndex:lrng2.location + 1];
    NSString *jsLogMsg = [lMsg substringFromIndex:lrng2.location + 1];

    // Convert JS Level to numeric value
    // JSlevelAry = @"[DEBUG]", @"[INFO]", @"[WARN]", @"[ERROR]",
    NSInteger lvlIdx = [JSlevelAry indexOfObject:lvlStr];

    // Convert millisecond string into Date object
    NSDate *lDate = [NSDate dateWithTimeIntervalSince1970:(msecStr.doubleValue / 1000)];

    // Log the JavaScript message
    [self writeToLog:@"[JS]" level:lvlIdx message:jsLogMsg dateObject:lDate];
}

- (BOOL)checkCurrFileHandler
{
    // Skip if file handle is available
    if (self.currFile != nil) {
        return YES;
    }

    NSMutableArray *files = [[NSMutableArray alloc] init];
    @try {
        [self getLogFileList:&files logDir:@"Logs/"];
        if ([self openExistingLogFile:files] == NO) {
            [self openNewLogFile:&files];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't open files.....");
    }
    @finally
    {
        // Do something here?
    }
    self.numOfFiles = files.count;
    //[files release];
    return YES;
}

- (BOOL)checkLegibleFileHandler
{
    // Skip if file handle is available
    if (self.quickDiagnosticFile != nil) {
        return YES;
    }

    NSMutableArray *files = [[NSMutableArray alloc] init];
    @try {
        [self getLogFileList:&files logDir:@"LogsQuick/"];
        if ([self openExistingLegibleLogFile:files] == NO) {
            [self openNewLegibleLogFile:&files];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't open files.....");
    }
    @finally
    {
        // Do something here?
    }
    // numOfFiles = [files count];
    return YES;
}

- (void)basicPrint:(NSData *)message
{
    @try {
        if (self.logStatus == lss_active) {
            if ([self checkCurrFileHandler] == YES) {
                if (self.currFile != nil) {
                    [self.currFile writeData:message];
                    unsigned long long offset = (self.currFile).offsetInFile;

                    if (offset >= MaxFileSize) {
                        NSMutableArray *files = [[NSMutableArray alloc] init];
                        // write end of file
                        [self closeLogFile];
                        [self getLogFileList:&files logDir:@"Logs/"];
                        [self openNewLogFile:&files];
                        self.numOfFiles = files.count;
                        //[files release];
                    }

                    if (self.numOfFiles > MaxFiles) {
                        self.numOfFiles = [self deleteLogFiles:MaxFiles];
                    }
                }
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Couldn't write into file (basicPrint).....");
    }
    @finally
    {
        // Do something here?
    }
}

- (void)writeLegible:(NSString *)message
{
    if (self.logState > logStateOff) {
        NSData *data;
        NSDate *today = [NSDate date];
        NSString *log;
        @try {
            if (message.length != 0) {
                // CQ00223331
                NSString *tempDate;
                @synchronized(self.myDateFormatter)
                {
                    tempDate = [self.myDateFormatter stringFromDate:today];
                }

                log = [NSString stringWithFormat:@"%@ - %@\r\n", tempDate, message];
            } else {
                log = [NSString stringWithFormat:@"\r\n"];
            }
            data = [log dataUsingEncoding:NSUTF8StringEncoding];

        }  // @try
        @catch (NSException *exception)
        {
            NSLog(@"writeLegible Exception %@", exception.reason);
        }

        @try {
            if ([self checkLegibleFileHandler] == YES) {
                if (self.quickDiagnosticFile != nil) {
                    [self.quickDiagnosticFile writeData:data];
                    unsigned long long offset = (self.quickDiagnosticFile).offsetInFile;

                    if (offset >= MaxFileSize) {
                        NSMutableArray *files = [[NSMutableArray alloc] init];
                        // write end of file
                        [self closeLegibleLogFile];
                        [self getLogFileList:&files logDir:@"LogsQuick/"];
                        [self openNewLegibleLogFile:&files];

                        if (files.count > 2) {
                            [self deleteLegibleLogFiles:2];
                        }
                    }
                }
            }
        }
        @catch (NSException *exception)
        {
            NSLog(@"Couldn't write into file (basicPrint).....");
        }
        @finally
        {
            // Do something here?
        }
    }
}

// These logFile methods invoked by the Objective-C Logging Macros
- (void)logFile:(int)logLevel logTag:(NSString *)logTag input:(NSString *)input, ...
{
    va_list ap;
    NSString *print;

    va_start(ap, input);
    print = [[NSString alloc] initWithFormat:input arguments:ap];
    va_end(ap);

    if ([NSThread isMainThread])
        [self writeToLog:@[ self.myLevel[(logLevel - 1)], logTag, [NSString stringWithFormat:@"%@", print] ]];
    else {
        NSArray *wels = @[ self.myLevel[(logLevel - 1)], logTag, [NSString stringWithFormat:@"%@", print] ];
        [self writeToLog:wels];
    }
}

- (void)logFile:(int)logLevel
          logTag:(NSString *)logTag
    withFunction:(const char *)lFunction
           input:(NSString *)input, ...
{
    va_list ap;
    NSString *print;

    NSString *lFF = [NSString stringWithFormat:@"%s", lFunction];

    va_start(ap, input);
    print = [[NSString alloc] initWithFormat:input arguments:ap];
    va_end(ap);

    if ([NSThread isMainThread])
        [self writeToLog:@[ self.myLevel[(logLevel - 1)], logTag, [NSString stringWithFormat:@"%@ %@", lFF, print] ]];
    else {
        NSArray *wels = @[ self.myLevel[(logLevel - 1)], logTag, [NSString stringWithFormat:@"%@ %@", lFF, print] ];
        [self writeToLog:wels];
    }
}

- (void)iphoneLogPrint:(int)logLevel logTag:(NSString *)logTag msg:(NSString *)msg
{
    if (self.logState == logStateOff) {
        return;
    } else if (self.logState == logStateMinimum) {
        // error, warn, msg
        if ((logLevel == logLevelDebug) || (logLevel == logLevelInfo)) {
            return;
        }
    } else if (self.logState == logStateMedium) {
        // error, warn, info, msg
        if (logLevel == logLevelDebug) {
            return;
        }
    }
    NSArray *wels = @[ self.myLevel[(logLevel - 1)], logTag, msg ];
    [self writeToLog:wels];
}

// Returns a date formatter that always uses 24-hour format, independent of what the user
// chose in the iOS settings date/time format
- (NSDateFormatter *)dateFormatter24Hour:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    // Force 24-hour mode, regarless of the user's 12/24 hour mode setting
    NSLocale *formatterLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];

    formatter.locale = formatterLocale;
    formatter.dateFormat = format;
    return formatter;
}

#pragma mark - C/C++ interface

// This method invoked by the C++ Logging Macros
void client_log(int level, const char *tag, const char *msg, ...)
{
    if ([[CKTLog sharedDebug] getiLogState] != logStateOff) {
        va_list ap;
        NSString *pMsg;

        NSString *pMsg2 = @((char *)msg);
        va_start(ap, msg);
        pMsg = [[NSString alloc] initWithFormat:pMsg2 arguments:ap];
        va_end(ap);

        NSString *logTag = @((char *)tag);

        [[CKTLog sharedDebug] iphoneLogPrint:level logTag:logTag msg:pMsg];
    }
}

int client_get_log_state()
{
    return (int)[[CKTLog sharedDebug] getiLogState];
}

@end
