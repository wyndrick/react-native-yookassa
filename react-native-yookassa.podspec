require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-yookassa"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-yookassa
                   DESC
  s.homepage     = "https://github.com/github_account/react-native-yookassa"
  # brief license entry:
  s.swift_version = '5.0'
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Oleg Wyndrick" => "wyndrick@email.com" }
  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/github_account/react-native-yookassa.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true
  s.dependency "React"
  s.dependency "YooKassaPayments"
  s.vendored_frameworks = "ios/Frameworks/TMXProfiling.framework", "ios/Frameworks/TMXProfilingConnections.framework"

end

