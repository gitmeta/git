Pod::Spec.new do |s|
s.name             = 'Git'
s.version          = '0.1'
s.summary          = 'Git client'
s.description      = <<-DESC
Git native for iOS and MacOS
DESC
s.homepage         = 'https://github.com/gitmeta/git'
s.license          = { :type => "MIT", :file => "LICENSE" }
s.author           = { 'iturbide' => 'reach@iturbi.de' }
s.platforms        = { :ios => "9.0", :osx => "10.11" }
s.source           = { :git => 'https://github.com/gitmeta/git.git', :tag => s.version }
s.source_files     = 'Git/*.swift'
s.swift_version    = '5'
s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
s.prefix_header_file = false
s.static_framework = true
end
