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
  s.preserve_paths = 'ImojiSDK.framework'
  s.public_header_files = 'ImojiSDK.framework/Versions/A/Headers/*.h'
  s.vendored_frameworks = 'ImojiSDK.framework'

  s.dependency "AFNetworking"
  s.dependency "Bolts"
  s.dependency "CocoaLumberjack"
  s.dependency "iOS-WebP", "~> 0.5"
  
end