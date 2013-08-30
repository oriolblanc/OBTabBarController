OBTabBarController
==================

OBTabBarController is an adaptive and customizable tab bar for iOS.


##Features
- Custom images and highlighted images on tabs.
- Custom tab bar background.
- Hide/show titles on tabs.
- Custom enabling/disabling selection on tabs.
- Custom behaviour when selecting tabs (e.g. present a modal view controller).


##Usage

###Install
We strongly encourage you to use Cocoapods. It's simple, just add the dependency to your `Podfile`:

```ruby
platform :ios

pod 'OBTabBarController'
```

And then running `pod install` will install the dependencies.

Finally, import the header file wherever you want to use it:

```objc
#import "OBTabBarController.h"
```

And you are done!

### Initialization
``` objective-c  
_tabBarController = [[OBTabBarController alloc] initWithViewControllers:
            @[self.firstViewController, self.secondViewController, self.thirdViewController, self.fourthViewController]
                                                               delegate:self];
```


##Previews

![iPhone portrait](https://raw.github.com/joanromano/OBTabBarController/master/Screenshots/Screenshot-2.png) 

![iPhone portrait](https://raw.github.com/joanromano/OBTabBarController/master/Screenshots/Screenshot-1.png)



##What's next?
- Support landscape mode.

