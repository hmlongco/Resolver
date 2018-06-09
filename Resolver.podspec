Pod::Spec.new do |s|
  s.name         = "Resolver"
  s.version      = "1.0.5"
  s.summary      = "An ultralight Dependency Injection / Service Locator framework for Swift 4 and iOS."
  s.homepage     = "https://github.com/hmlongco/Resolver"
  s.license      = "MIT"
  s.author       = "Michael Long"
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/hmlongco/Resolver.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "Sources/*.swift"
  s.swift_version = '4.0'
end
