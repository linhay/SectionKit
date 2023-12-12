Pod::Spec.new do |s|
    s.name             = 'SectionUI'
    s.version          = '2.0.58'
    s.summary          = '动态表单框架'
    s.homepage         = "https://github.com/linhay/SectionKit"
    s.license          = { :type => 'Apache', :file => 'LICENSE' }
    s.author           = { "linhay" => "is.linhey@outlook.com"}
    s.source       = { :git => "https://github.com/linhay/SectionKit.git", :tag => "#{s.version}" }
    s.swift_version = "5.7"
    s.module_name = 'SectionUI'

    s.platform = :ios
    s.ios.deployment_target = "13.0"
    s.dependency 'SectionKit2', '>= 2.0.58'

    s.source_files = ["Sources/SectionUI/**/*.{swift,h}"]
end  

# pod lib lint ./SectionUI.podspec --include-podspecs='*.podspec'
# pod trunk push ./SectionUI.podspec  --allow-warnings
# bundle exec pod trunk push ./SectionUI.podspec  --allow-warnings
