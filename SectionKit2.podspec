Pod::Spec.new do |s|
    s.name             = 'SectionKit2'
    s.version          = '2.0.48'
    s.summary          = '动态表单框架'
    s.homepage         = "https://github.com/linhay/SectionKit"
    s.license          = { :type => 'Apache', :file => 'LICENSE' }
    s.author           = { "linhay" => "is.linhey@outlook.com"}
    s.source       = { :git => "https://github.com/linhay/SectionKit.git", :tag => "#{s.version}" }
    s.swift_version = "5.7"
    s.module_name = 'SectionKit'

    s.platform = :ios
    s.ios.deployment_target = "13.0"
    s.source_files = ["Sources/SectionKit/**/*.{swift,h}"]
end  

# pod trunk push ./SectionKit2.podspec  --allow-warnings
