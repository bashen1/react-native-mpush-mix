require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-mpush-mix"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/bashen1/react-native-mpush-mix.git", :tag => "#{s.version}" }
  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.vendored_libraries = "ios/**/*.a"
  s.frameworks = "UserNotifications", "SystemConfiguration", "MobileCoreServices", "CFNetwork", "CoreTelephony"
  s.libraries = "resolv", "xml2", "z"
  s.dependency "React-Core"
end
