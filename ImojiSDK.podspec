Pod::Spec.new do |s|
  s.name = 'ImojiSDK'
  s.version = "0.1.16"
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

  s.dependency "Bolts", '~> 1.1'
  s.dependency "libwebp", "~> 0.4.3"
  
end
