knobs
=====

Mac side debugging tool for iOS apps


# TODO

## UI
- Make window title useful (show connection state)
- Redo the tabs to be more powerful, visually sane, and scalable
- Save runs all in one window so the flow is more like instruments, especially so that the connection starts at app launch
- About box with names of all contributors
- Set proper minimum window size
- Menu items for switch tab

## Logger Plugin
- Log datetime with each item
- Improve logger so it can deal with more types, especially nested ones
- Make thread safe
- Improve logger so that colors and images can be saved
- Improve logger visual style
- Export logger data: images/colors/entire contents
- HTML escape logged strings

## General Plugins
- Easier plugin installation
- More plugins
- Settings UI for adding additional plugin paths or possibly a way to configure this dynamically
- Version plugins

## General Error handling/robustness

## Auto-Updating
- Maybe not worthwhile since you pretty much need to checkout the code anyway

## Tests
- Per plugin tests
- App tests
- Connection tests

## Documentation
- How to use
- How to write a plugin, device side and desktop side
- FAQ

## Bugs
- Fix menu items so there are only relevant ones
- Fix issue where showing a color doesn't work on the first try
- Fix client deadlock on disconnect
