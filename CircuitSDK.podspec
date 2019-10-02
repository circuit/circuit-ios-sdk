Pod::Spec.new do |s|
s.name             = 'CircuitSDK'
s.version          = '1.6.0'
s.summary          = 'Circuit iOS SDK to build a text or media mobile application for iOS'
s.description      = <<-DESC
                     'The iOS SDK is the Circuit client, exposing a clear abstracted API for Circuit PaaS.
                      The iOS SDK is built upon the Circuit JS SDK.'
                      DESC
s.homepage         = 'https://github.com/circuit/circuit-ios-sdk'
s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
s.author           = { 'Unify Inc.' => 'https://www.unify.com' }
s.source           = { :git => 'https://github.com/circuit/circuit-ios-sdk.git', :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/unifyco'
s.ios.deployment_target = '10.0'

# SDK src
s.source_files = 'Source/Classes/**/*', 'CKTNavigator/*.h'
s.public_header_files = 'Source/Classes/**/*.h'
s.resource_bundles = { 'CircuitSDK' => ['Source/scripts/**'] }

# CKTNavigator src
s.vendored_libraries = 'Source/libCKTNavigator.a'
s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lc++ -ObjC'  }

s.frameworks = 'JavaScriptCore', 'AudioToolbox', 'AVFoundation', 'VideoToolbox', 'CoreMedia', 'GLKIT'
s.dependency 'SocketRocket', '~> 0.4.2'
end

