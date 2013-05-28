knobs
=====
# TODO
Knobs is very much not a finished product, but it is useful today. Here is a somewhat complete list of things that could be improved.

## Plain Old Bugs
- Fix menu items so there are only relevant ones
- Fix issue where showing a color doesn't work on the first try
- Fix occasional client crash on disconnect

## Application UI
- Make window title useful (show connection state)
- Redo the tabs to be more powerful, visually sane, and scalable
- Save runs all in one window so the flow is more like instruments, especially so that the connection starts at app launch
- About box with names of all contributors
- Set proper minimum window size
- Menu items+key commands for switch tab

## General Plugin Features
- Easier plugin installation
- More plugins
- Settings UI for adding additional plugin paths or possibly a way to configure this dynamically
- Version plugins

## Improved Error handling/robustness

## Logger Plugin
- Log datetime with each item
- Improve desktop display to support more types, especially nested plist ones
- Make thread safe
- Improve logger so that colors and images can be saved
- Improve logger visual style
- Export logger data: images/colors/entire contents
- HTML escape logged strings
- Add conveniences
- Get rid of EKNWireColor. It turns out that UIColor and NSColor are bridged when unarchiving.

## KnobGeneratorView
- More editors
- Rework the rect editor to support arbitrary field names. To support things like UIEdgeInsets
- Disable the frobber when the connection closes.
- Tighten row spacing and generally pretty it up.
## ViewFrobPlugin
- Add more fields to UIView subclasses
- Consider using method swizzling to do push instead of poll.
## LiveKnobsPlugin
- Allow using multiple channel names/provide a default channel
- Use NSCollectionView to stick multiple editors in a single row.
- Visual improvements.
- Send all exiting knobs when a connection is opened.

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

