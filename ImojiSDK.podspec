Pod::Spec.new do |s|
  s.name = 'ImojiSDK'
  s.version = "0.2.0"
  s.summary = "iOS SDK for Imoji"
  s.homepage = "http://imoji.io/sdk"
  s.license = 'MIT'
  s.authors = {"Nima Khoshini"=>"nima@imojiapp.com"}
  s.libraries = 'c++'
  s.requires_arc = true
  s.source = { git: 'https://github.com/imojiengineering/imoji-ios-sdk.git', tag: "#{s.version}" }
  s.platform = :ios, '7.0'
  s.ios.frameworks = ["Accelerate"]
  s.source_files = 'Source/**/*.{h,m}'
  s.dependency "Bolts", '~> 1.1'
  s.dependency "libwebp", "~> 0.4.3"
  
end
