Pod::Spec.new do |s|
  s.name         = "Resolver"
  s.version      = "1.4.4"
  s.summary      = "An ultralight Dependency Injection / Service Locator framework for Swift on iOS."
  s.homepage     = "https://github.com/hmlongco/Resolver"
  s.license      = "MIT"
  s.author       = "Michael Long"
  s.source       = { :git => "https://github.com/hmlongco/Resolver.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "Sources/Resolver/*.swift"
  s.swift_version = '5.1'

  s.ios.deployment_target = "11.0"
  s.ios.framework  = 'UIKit'

  s.tvos.deployment_target = "11.0"
  s.tvos.framework  = 'UIKit'

  s.osx.deployment_target = "10.15"
  s.osx.framework  = 'AppKit'
end
