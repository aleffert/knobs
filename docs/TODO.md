knobs
=====
# TODO
Knobs is very much not a finished product, but it is useful today. Here is a somewhat complete list of things that could be improved.

## Plain Old Bugs
- Fix menu items so there are only relevant ones

## Application UI
- Make window title useful (show connection state)
- Redo the tabs to be more powerful, visually sane, and scalable
- Save runs all in one window so the flow is more like instruments, especially so that the connection starts at app launch
- About box with names of all contributors

## General Plugin Features
- Easier plugin installation
- More plugins: notifications, network traffic, autolayout, dynamics
- Settings UI for adding additional plugin paths or possibly a way to configure this dynamically
- Version plugins?

## Improved Error handling/robustness

## Logger Plugin
- Improve desktop display to support more types, especially nested plist ones
- Make thread safe
- Improve logger so that colors and images can be copied/saved
- Export logger data: images/colors/entire contents
- Improve logger visual style
- HTML escape logged strings

## KnobGeneratorView
- More editors
- Disable the frobber when the connection closes.
- Tighten row spacing and generally pretty it up.

## ViewFrobPlugin
- Add more fields to UIView subclasses
- Consider using method swizzling to do push instead of poll.
- Update source with changes

## LiveKnobsPlugin
- Allow using multiple channel names/provide a default channel
- Visual improvements.
- Thread safety

## Auto-Updating
- Maybe not worthwhile since you pretty much need to checkout the code anyway

## Tests
- Per plugin tests
- App tests
- Connection tests

## Documentation
- How to write a plugin, device side and desktop side
- How to add an editor.
- How to add custom view frob properties to your view
- FAQ

