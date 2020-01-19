#import "Ssplugin1Plugin.h"
#if __has_include(<ssplugin1/ssplugin1-Swift.h>)
#import <ssplugin1/ssplugin1-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ssplugin1-Swift.h"
#endif

@implementation Ssplugin1Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSsplugin1Plugin registerWithRegistrar:registrar];
}
@end
