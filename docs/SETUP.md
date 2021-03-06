SETUP
=====

Knobs has two parts: A desktop app and an iOS library. This walks you through adding the library to your project, building the desktop app, and letting them talk to each other.

### Checking Out

You can checkout knobs wherever you want, but normal practice would be as a submodule or subtree in your iOS app's repo. For the rest of this HOWTO we're going to assume it's at

    YOUR_PROJECT_DIR/Libraries/Knobs.

So to check it out you'd do e.g.

    cd YOUR_PROJECT_DIRECTORY
    git submodule add KNOBS_GITHUB_URL Libraries/Knobs
    git submodule update --init

### Adding As A Subproject
Find Knobs/Knobs-iOS.xcodeproj and drag it into your XCode project as a subproject. It should look something like this:

![Subproject added to XCode project](screenshots/add-to-ios-project.png)

### Linking In and Adding Header Search Paths
Go to the Target Settings > Build Phases and add libKnobs-IOS.a to your Target Dependencies and Link Binaries With Libraries.
![Build Phases](screenshots/build-phases.png)

Now you need to tell XCode where to find the Knobs headers.
Go to Build Settings and search for "Header Search Paths".
Add
    KNOBS_DIR/iOS/Include/
e.g. with our above example:
    $(SRCROOT)/Libraries/Knobs/iOS/Include/

Next, you will need to enable the [ObjC linker flag](http://developer.apple.com/library/mac/#qa/qa1490/_index.html) in your project.
Go into Build Settings, search for "Other Linker Flags", and add `-ObjC`. It should look like this:

![Add ObjC linker flag to XCode project](screenshots/objc-linker-flag.png)

Finally, add CFNetworking.framework and Security.framework to your project's Link Binaries With Libraries section.

### Enabling In Your App
Now you're ready to actually activate knobs in your app. We recommend you only enable it in DEBUG builds because it opens a pipe to your app that can do all sorts of things. Add the following to somewhere early in your app like -[YourAppDelegate application:didFinishLaunchingWithOptions:]

    #if DEBUG
        [[EKNKnobs sharedController] registerDefaultPlugins];
        [[EKNKnobs sharedController] start];
    #endif


The default plugins include:
- A simple logger that can log rich media (images and colors) in addition to text. See EKNLoggerPlugin.h.
- A tool that lets you manipulate live manipulate properties of views from your mac. See EKNViewFrobPlugin.h.
- A tool that lets you add controls to the mac app that execute callbacks on the iOS side. This also allows you to update your code directly with the changes you've made. See EKNLiveKnobsPlugin.h.

### Running the Desktop App
Now that knobs is enabled in your iOS app, you want to talk to it using the desktop app. Make sure your Mac and your iOS device are on the same network. Open up Knobs/Knobs.xcodeproj. Make sure the "Knobs" target is selected and hit Run. If your iOS app is running with Knobs enabled, the device picker pop up menu will change from "No Device Selected" to "None". Just chose your device from that menu.

