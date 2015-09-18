# Imoji SDK Changes

### Version 0.2.11

* Adds the following 
  * Sentence parsing - Just send up a full sentence and Imoji will find relevant content :D
  * Creation and Deletion of Imojis - To be used in conjunction with the ImojiSDKUI editor, you can now upload user generated stickers!
  * Flagging Imojis - Add the ability for users to flag Imoji content within your app. Our review team goes through flagged content to make the appropriate action.

### Version 0.2.10

* Adds support for opening Imoji authentication URL's with web links for iOS 9


### Version 0.2.9

* Addresses issue with fetchImojisByIdentifier not properly loading. The results were not being read properly from the server.


### Version 0.2.8

* Split out Imoji User Authentication Code to a separate Pod subspec. Our authentication portion requires app linking to work, which does not play nicely with WatchKit or Keyboard extensions. Add **pod 'ImojiSDK/Core'** to your Podfile to avoid grabbing the authentication code.


### Version 0.2.5

* Open Sources ImojiSDK!
* Consume Imoji images from our [REST API](https://github.com/imojiengineering/imoji-rest-api)



### Version 0.1.21

* Improved performance for rendering imoji images on the simulator
* Convenience initializers for IMImojiObjectRenderingOptions for displaying borderless, shadowless or border and shadowless images
* Ability to send in a content cache object to IMImojiSession to prevent unnecessary rendering operations
* Updated Readme for developers having trouble linking with Bolts for their extension


### Version 0.1.20

* Addresses memory leak issue with border rendering

### Version 0.1.19

* New border rendering mechanism! smoother corners and subtle drop shadows will help make the imojis look better than before.
* Please note that we've now shifted to using OpenGL to render the borders, which will appear slower than the previous mechanism on the simulator. On the device, performance and memory usage is inline with the old method.

### Version 0.1.18

* Addresses issues with user sync status not being read properly upon creation of IMImojiSession

### Version 0.1.17

* Addresses issues with reachability code within IMImojiSession

### Version 0.1.16

* Adds the ability for sdk clients to add imojis to a users account, this is useful for applications that wish to use the users account for synchronizing favorited/liked Imoji's

### Version 0.1.15

* Sets deployment target to iOS 6.0

### Version 0.1.14

* Improved performence for maximumRenderingSize, re-sizes the target image prior to rendering border and shadow instead of afterwards.
* imoji images are automatically removed from file cache after one day of no use to prevent massive buildup of assets prior to the operating system removing them

### Version 0.1.13

* Adds support for maximumRenderingSize. This can be used in conjunction with aspect ratio to curb the growth of the rendered imoji image.

### Version 0.1.12

* Adds category classification parameter to getImojiCategories

### Version 0.1.11

* Addresses issues with session state not being properly persisted on cold app starts
* Fixes inadvertent error returned for getImojisForAuthenticatedUserWithResultSetResponseCallback when the user does not have any imojis

### Version 0.1.10

* Addresses issues with api clients not being able to properly write to storage policy paths
* Documentation updates

### Version 0.1.9

* Allows for specifying storage paths for assets and persistent data

### Version 0.1.8

* Addresses issue with user syncing not working

### Version 0.1.7

* Remove iOS webp and AFNetworking dependencies
* Add aspect ratio setting to rendering options
* Add ability to clear synchronized user information

### Version 0.1.6

* Introduces ability to synchronize a session with a user account created with imoji. This allows SDK users to populated images created by that user into their application
* Introduces sessionState property to IMImojiSession. The state describes whether or not the user is connected and or synchronized with a user account.
* Adds methods for SDK users to add to UIApplicationDelegate to properly close the loop with user synchronization
* Renames searchResponseCallback parameters to resultSetResponseCallback for clarity
* Adds helper methods for downloading the Imoji application.

### Version 0.1.5

* Adds shadow offset
* Removes cocoa lumberjack dependency
* Removes path from session storage
* Better error checking for imoji rendering

### Version 0.1.4

Consolidate all rendering methods to one method with options parameter
Render imoji objects serially rather than concurrently
Shadow blur % and color are now exposed for rendering
Both shadow and border sizes are now specified as % of the images max width or height. This helps achieve consistency between varying Imoji images.

### Version 0.1.3

* Adds documentation for IMImojiSession error codes, different imoji rendering quality settings, IMImojiObject and IMImojiCategoryObject
* Modifies order and priority to be native NSUInteger values rather than NSNumber's for IMImojiCategoryObject
* Removes support for custom IMImojiSessionStoragePolicy paths
* Adds support for fetching IMImojiObject's from identifiers (IMImojiSession fetchImojisByIdentifiers:fetchedResponseCallback)

### Version 0.1.2

* Expand render methods to encapsulate both downloading and rendering the imoji images
* Add asynchronous callback function to the render methods that are called once the image is ready or an error had occurred
* Have render methods return an NSOperation instance which callers can use to cancel the request if need be

### Version 0.1.1

* Documentation Updates

### Version 0.1.0

* It all begins here :D 



