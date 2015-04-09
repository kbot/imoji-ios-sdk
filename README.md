#Imoji SDK

To integrate with Imoji, you'll need to add the ImojiSDK framework to your project. The simplest way to do this is by using CocoaPods to get up and running.


###Getting Setup With Pods

Add the Imoji repo to your Podfile

```
source 'https://github.com/imojiengineering/imoji-pods-specs.git'
```

Then add the ImojiSDK and webp entries to your Podfile

```
pod 'iOS-WebP', :git => 'https://github.com/imojiengineering/iOS-WebP'
pod 'ImojiSDK'
```

Run pods to grab the ImojiSDK framework

```bash
pod install
```

###Authentication

You'll need to provide your API key in your Info.plist before you start integrating. 

```
IMOJI_API_KEY=<UUID-HASH>
```


