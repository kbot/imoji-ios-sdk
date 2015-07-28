platform :ios, "7.0"

source 'https://github.com/CocoaPods/Specs.git'

def shared_pods
  pod 'Bolts'
  pod 'libwebp'
end

target "ImojiSDK", :exclusive => true do
  shared_pods
end

target "ImojiSDKTests", :exclusive => true do
  shared_pods
end
