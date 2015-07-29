Pod::Spec.new do |s|

  s.name     = 'ImojiSDK'
  s.version  = '0.2.4'
  s.license  = 'MIT'
  s.summary  = 'iOS SDK for Imoji.'
  s.homepage = 'http://imoji.io/sdk'
  s.authors = {'Nima Khoshini'=>'nima@imojiapp.com'}

  s.source   = { :git => 'https://github.com/imojiengineering/imoji-ios-sdk.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'

  s.source_files = 'Source/**/*.{h,m}'
  s.requires_arc = true

  s.dependency "Bolts", '~> 1.1'
  s.dependency "libwebp", "~> 0.4.3"
  
end
