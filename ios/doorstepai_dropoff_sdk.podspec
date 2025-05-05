#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint doorstepai_dropoff_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'doorstepai_dropoff_sdk'
  s.version          = '0.0.2'
  s.summary          = 'DropoffSDK for Flutter'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Doing Doorstep Better, inc.' => 'sheel@doorstep.ai' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.vendored_frameworks = "DoorstepDropoffSDK.xcframework"

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'doorstepai_dropoff_sdk_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
