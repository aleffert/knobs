knobs
=====

Mac side debugging tool for iOS apps

# Frequently Asked Questions

1. What does it do?
Knobs is a general tool for communicating between your Mac and your iOS app during development. It provides a general plugin architecture for tools that want to do this as well built in plugins for live manipulation of view properties, hooking controls up to arbitrary properties - even saving the values of those properties back to your code with a single button press, and logging arbitrary HTML - including images and colors.

Here's an example of knobs tweaking a gradient then saving it back to your code.

2. How do I install it?
Installation is trivial using [Cocoa Pods](http://cocoapods.org). Just add the knobs pod.
```
    pod 'Knobs', '~> 1.0.0'
```

If you're not using Cocoa Pods, there are more detailed instructions in [Setup](docs/SETUP.md).

Once you have it building you can begin using its features by adding the following to your app delegate (or anywhere else early in your app).

```
#include <Knobs.h>

...

[[EKNKnobs sharedController] registerDefaultPlugins];
[[EKNKnobs sharedController] start];
```

Run your app in the simulator or on the device. Then, open up Knobs.xcodeproj and hit run. This will launch the Knobs desktop app.
From there you can choose your device from the dropdown menu in the top left of the window. There's a lot more information in the headers for the respective built in plugins:
``EKNViewFrobPlugin.h", ``EKNLiveKnobsPlugin.h``, ``EKNLog.h``, but here are some simple examples.

```
EKNLogImage(someImage);

EKNMakePushButton(@"do something", ^(id owner) {
    [owner doSomething];
});

EKNMakeColorKnob(self.backgroundColor);

3. This is great. How do I write my own plugins?
There's some general information at the [guide to hacking](docs/HACKING.md) and more specific information at the [plugin guide](docs/PLUGINS.md).

4. This is great, but it still needs a lot of work. How can I help?
Checkout our [guide to hacking](docs/HACKING.md) and our [todo list](docs/TODO.md). If you have your own ideas, create a github issue so we can talk about it.

5. Why is it called Knobs?
Well, it has a lot of knobs (and widgets and doohickeys). But also, @aleffert once had an app rejected from the store by Apple because it "needs more knobs." This is his response.
