#import <Foundation/Foundation.h>
#import <HBLog.h>
#import <dlfcn.h>

extern char ***_NSGetArgv();

NSString *dir = @"/Library/MobileSubstrate/DynamicLibraries";
NSString *rootlessDir = @"/var/jb/Library/MobileSubstrate/DynamicLibraries";

// Credits to simject (my contributions) and Choicy
%ctor {
    char *arg0 = **_NSGetArgv();
    if (strstr(arg0, "/Application") && NSBundle.mainBundle.bundleIdentifier) {
        NSError *e = nil;
        NSString *dylibDir = dir;
        NSArray *dylibDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dylibDir error:&e];
        if (e) {
            e = nil;
            dylibDir = rootlessDir;
            dylibDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dylibDir error:&e];
            if (e) {
                HBLogError(@"InjectionFoundation: Could not read dynamic libraries directory");
                return;
            }
        }
        NSArray *plists = [dylibDirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", @"plist"]];
        for (NSString *plist in plists) {
            if ([plist isEqualToString:@"AAAInjectionFoundation.plist"])
                continue;
            NSString *plistPath = [dylibDir stringByAppendingPathComponent:plist];
            NSDictionary *filter = [NSDictionary dictionaryWithContentsOfFile:plistPath];
            NSArray *supportedVersions = filter[@"Filter"][@"CoreFoundationVersion"];
            if (supportedVersions) {
                if (supportedVersions.count != 1 && supportedVersions.count != 2)
                    continue;
                if (supportedVersions.count == 1 && [supportedVersions[0] doubleValue] > kCFCoreFoundationVersionNumber)
                    continue;
                if (supportedVersions.count == 2 && ([supportedVersions[0] doubleValue] > kCFCoreFoundationVersionNumber || [supportedVersions[1] doubleValue] <= kCFCoreFoundationVersionNumber))
                    continue;
            }
            NSString *dylibName = [[plistPath stringByDeletingPathExtension] stringByAppendingString:@".dylib"];
            for (NSString *entry in filter[@"Filter"][@"Bundles"]) {
                if ([entry isEqualToString:@"com.apple.UIKit"]) {
                    dlopen([dylibName UTF8String], RTLD_LAZY | RTLD_GLOBAL);
                    break;
                }
            }
        }
    }
}