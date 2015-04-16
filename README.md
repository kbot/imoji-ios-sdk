#Imoji SDK

To integrate with Imoji, you'll need to add the ImojiSDK framework to your project. The simplest way to do this is by using CocoaPods to get up and running.


###Getting Setup With Pods

Add the Imoji repo to your Podfile

```
source 'https://github.com/imojiengineering/imoji-pods-specs.git'
```

Then add the ImojiSDK entry to your Podfile

```
pod 'ImojiSDK'
```

Run pods to grab the ImojiSDK framework

```bash
pod install
```

###Authentication

Initiate the client id and api token for ImojiSDK. You can add this to the application:didFinishLaunchingWithOptions: method of AppDelegate

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // setup imoji sdk
    [[ImojiSDK sharedInstance] setClientId:[[NSUUID alloc] initWithUUIDString:@"client-id"]
                                  apiToken:@"api-token"];

    return YES;
}
```


