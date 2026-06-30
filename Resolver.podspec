Pod::Spec.new do |s|
  s.name         = "Resolver"
  s.version      = "1.5.1"
  s.summary      = "An ultralight Dependency Injection / Service Locator framework for Swift on iOS."
  s.homepage     = "https://github.com/hmlongco/Resolver"
  s.license      = "MIT"
  s.author       = "Michael Long"
  s.source       = { :git => "https://github.com/hmlongco/Resolver.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "Sources/Resolver/*.swift"
  s.resource_bundles = {"Resolver" => ["Sources/PrivacyInfo.xcprivacy"]}
  s.swift_version = '5.9'

  s.ios.deployment_target = "12.0"
  s.tvos.deployment_target = "13.0"
  s.watchos.deployment_target = "8.2"
  s.osx.deployment_target = "10.14"
end
