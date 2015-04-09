Pod::Spec.new do |s|
  s.name = 'ImojiSDK'
  s.version = "0.1.0"
  s.summary = "iOS SDK for Imoji"
  s.homepage = "http://imojiapp.com/sdk"
  s.license = 'Commercial'
  s.authors = {"Nima Khoshini"=>"nima@imojiapp.com"}
  s.libraries = 'z'
  s.requires_arc = true
  s.source = { git: 'https://github.com/imojiengineering/imoji-ios-sdk.git', tag: "#{s.version}" }
  s.platform = :ios, '7.0'
  s.ios.platform             = :ios, '7.0'
  s.ios.preserve_paths       = 'ImojiSDK.framework'
  s.ios.public_header_files  = 'ImojiSDK.framework/Versions/A/Headers/*.h'
  s.ios.vendored_frameworks  = 'ImojiSDK.framework'
  s.ios.frameworks = ["UIKit"]

  s.dependency "AFNetworking"
  s.dependency "Bolts"
  s.dependency "CocoaLumberjack"
  
end