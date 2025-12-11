require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'CapacitorPluginCactus'
  s.version = package['version']
  s.summary = package['description']
  s.license = package['license']
  s.homepage = package['repository']['url']
  s.author = package['author']
  s.source = { :git => package['repository']['url'], :tag => s.version.to_s }
  
  s.ios.deployment_target = '14.0'
  s.dependency 'Capacitor'
  s.dependency 'Zip'
  s.swift_version = '6.2'
  
  # Add system frameworks
  s.frameworks = 'Foundation', 'UIKit'
  
  # Include our plugin's source files, Cactus module, and CXXCactusShims
  # Include the binary frameworks from swift-cactus
  s.vendored_frameworks = [
     'ios/External/swift-cactus/bin/CXXCactusDarwin.xcframework',
     'ios/External/swift-cactus/bin/cactus_util.xcframework'
   ]
   
   # Include our plugin's source files, Cactus module, and CXXCactusShims
  s.source_files = [
    'ios/Sources/CactusPlugin/**/*.{swift,h,m}',
    'ios/External/swift-cactus/Sources/Cactus/**/*.swift',
    'ios/External/swift-cactus/Sources/CXXCactusShims/**/*.swift'
  ]
  
  # Exclude documentation and test files
  s.exclude_files = [
    'ios/External/swift-cactus/Sources/Cactus/Documentation.docc/**/*',
    'ios/External/swift-cactus/Sources/Cactus/**/*Tests.swift'
  ]
  
  # Add dependencies required by swift-cactus
  s.dependency 'Zip', '~> 2.1.2'
  s.dependency 'swift-log', '~> 1.5.4'
  
  # Add build settings to ensure modules are found
  s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_TARGET_SRCROOT}/ios/External/swift-cactus/combined-xcframework"',
    'ALWAYS_SEARCH_USER_PATHS' => 'YES',
    'SWIFT_COMPILATION_MODE' => 'wholemodule',
    'OTHER_SWIFT_FLAGS' => '$(inherited) -package-name CapacitorPluginCactus',
    'MODULEMAP_FILE' => '${PODS_TARGET_SRCROOT}/ios/Sources/CactusPlugin/CXXCactusShims.modulemap'
  }
end
