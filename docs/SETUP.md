SETUP
=====

Knobs has two parts: A desktop app and an iOS library. This walks you through adding the library to your project, building the desktop app, and letting them talk to each other.

### Checking Out

You can checkout knobs wherever you want, but normal practice would be as a submodule in your iOS app's repo. For the rest of this HOWTO we're going to assume it's at
    <your project dir>/Libraries/Knobs.
    
So to check it out you'd do e.g.
    cd <your project dir>
    git submodule add <knobs git url> Libraries/Knobs

### Adding As A Subproject
Find Knobs/Knobs-iOS.xcodeproj and drag it into your XCode project as a subproject. It should look something like this:

![Subproject added to XCode project](docs/screenshots/add-to-ios-project.png)

### Linking In and Adding Header Search Paths
Go to the Target Settings > Build Phases and add libKnobs-IOS.a to your Target Dependencies and Link Binaries With Libraries.
![Build Phases](docs/screenshots/build-phases.png)

Now you need to tell XCode where to find the Knobs headers.
Go to Build Settings and search for "Header Search Paths".
Add
    <place you put knobs>/iOS/Include/
e.g. with our above example:
    $(SRCROOT)/Libraries/Knobs/iOS/Include/

### Enabling In Your App
Now you're ready to actually activate knobs in your app. We recommend you only enable it in DEBUG builds because it opens a pipe to your app that can do all sorts of things. Add the following to somewhere early in your app like -[YourAppDelegate application:didFinishLaunchingWithOptions:]

    #if DEBUG
        [[EKNKnobs sharedController] registerDefaultPlugins];
        [[EKNKnobs sharedController] start];
    #endif


The default plugins include:
- A simple logger that can log rich media (images and colors) in addition to text. See EKNLoggerPlugin.h.
- A tool that lets you manipulate live manipulate properties of views from your mac. See EKNViewFrobPlugin.h.
- A tool that lets you controls to the mac app that execute callbacks on the iOS side. See EKNLiveKnobsPlugin.h.

### Running the Desktop App
Now that knobs is enabled in your iOS, you want to talk to it using the desktop app. Make sure your Mac and your iOS device are on the same network. Open up Knobs/Knobs.xcodeproj. Make sure the "Knobs" target is selected and hit Run. If your iOS app is running with Knobs enabled, it should show up in the device picker sheet that appears when you run Knobs on your Mac.

