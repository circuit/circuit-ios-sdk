Pod::Spec.new do |s|
s.name             = 'CircuitSDK'
s.version          = '1.2.0'
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
s.source_files = 'Source/Classes/**/*'
s.public_header_files = 'Source/Classes/**/*.h'
s.exclude_files = 'Source/Classes/CoreSDK/Client/CKTClient+Call.{h,m}'
s.resource_bundles = {
'CircuitSDK' => ['Source/scripts/**']
}
s.frameworks = 'JavaScriptCore'
s.dependency 'SocketRocket', '~> 0.4.2'
end

