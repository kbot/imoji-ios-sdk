# Imoji SDK

### Setup

Sign up for a free developer account at [https://developer.imoji.io](https://developer.imoji.io) to get your API keys

### Cocoa Pods Setup

Add the ImojiSDK entry to your Podfile

```
pod 'ImojiSDK'
```

Run pods to grab the ImojiSDK framework

```bash
pod install
```

### Authentication

Initiate the client id and api token for ImojiSDK. You can add this to the application:didFinishLaunchingWithOptions: method of AppDelegate

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // setup imoji sdk
    [[ImojiSDK sharedInstance] setClientId:[[NSUUID alloc] initWithUUIDString:@"client-id"]
                                  apiToken:@"api-token"];

    return YES;
}
```

### Synchronization of user accounts

Apps using the ImojiSDK can synchronize with an Imoji account to pull personalized content created by that user (requires Imoji builds version 2.1.1 and greater). In order to do so you must first register a URL type for your application in the following format

```
imoji<client-id>

EX: imoji075286df-163d-4979-be8c-c4f9337aa2c6
```

See [https://coderwall.com/p/mtjaeq/ios-custom-url-scheme](https://coderwall.com/p/mtjaeq/ios-custom-url-scheme) for a simple example of how to set this up for your application.

After setting up the URL type, override the application:openURL:sourceApplication:annotation: method in your AppDelegate class and add checks for handling Imoji SDK entries:

```
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    IMImojiSession *imojiSession = self.imojiSession;
    if ([imojiSession isImojiAppRequest:url sourceApplication:sourceApplication]) {
        return [imojiSession handleImojiAppRequest:url sourceApplication:sourceApplication];
    }

    return NO;
}
```

If authentication succeeded for the user in the Imoji iOS application, the **sessionState** property in **IMImojiSession** will now be set to **IMImojiSessionStateConnectedSynchronized**. 

The **IMImojiSessionDelegate** protocol will also call imojiSession:stateChanged:fromState: when this state changes, therefore you can perform the approach UI actions to display a synchronized state with a delegate.

##### Fetching User Generated Imoji Content

Once you're app has established a synchronized state, you can then call

```
[self.session getImojisForAuthenticatedUserWithResultSetResponseCallback:imojiResponseCallback:]
```

The resultSetResponseCallback and imojiResponseCallback work exactly like they do with searching and pulling featured imojis.


### Troubleshooting

##### Trouble Linking With ImojiSDK for Application Extensions (ie Keybords)

ImojiSDK uses the App Links Protocol support provided by the Bolts library for authenticating sessions. However for application extensions, objects such as [UIApplication sharedApplication] are prohibited from being used. Compiling Bolts statically will cause errors for your application extension. You can instead link to ImojiSDK using frameworks by adding the following line to your Podfile

```
use_frameworks!
```
