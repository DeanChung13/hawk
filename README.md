# Hawk - Fast File Search Tool [中文](README_zh.md)



## 🦅 Project Introduction
**Hawk** is a macOS utility that allows users to quickly search for files in a specified local folder based on text in the clipboard. When you copy (Command+C) text in any application, Hawk can immediately find matching files in your designated folder and let you open them quickly.

---

## ✨ Main Features

### 📋 Clipboard Monitoring and Auto Search
- **Auto Search**: Automatically search when clipboard content changes
- **Manual Search**: Use shortcut key (⌘⇧F) or click the menu bar icon to search manually
- **Smart Detection**: Avoid empty or duplicate search requests

### 🔍 Powerful File Search
- **High Efficiency**: Utilize system `find` command for high-performance searches
- **Flexible Matching**: Support fuzzy matching and case sensitivity options
- **Timeout Mechanism**: Search operations automatically time out after 10 seconds to prevent long searches from freezing the system

### 🖥️ Clean and Elegant Interface
- **Menu Bar Icon**: Always ready status bar icon
- **Search Results Window**: Clear file list with filename and path information
- **Preferences**: Customizable search behavior and appearance

### 🔐 Secure Access
- **Sandbox Compatible**: Fully compliant with macOS application sandbox security standards
- **Secure Access**: Proper handling of security-scoped resources

---

## 🚀 Installation and Usage

### System Requirements
- macOS 12 Monterey or higher
- Approximately 10MB of storage space

### Quick Start
1. Download the Hawk application and install it in the "Applications" folder
2. After launching Hawk, click the Hawk icon in the menu bar
3. Set the folder you want to search
4. Choose whether to enable automatic search
5. Start using it! After copying text, Hawk will automatically begin searching

### Common Shortcuts
- **⌘⇧F**: Manually trigger search
- **⌘,**: Open preferences

---

## 🛠️ Technical Implementation

### Core Technologies
- **Swift** and **SwiftUI**: Provide a modern user interface
- **Clipboard Monitoring**: Implement change detection using `NSPasteboard` and timers
- **File Search**: Implement efficient search using the system `find` command
- **Search Timeout Control**: Implement a 10-second timeout mechanism using `DispatchWorkItem` and `asyncAfter`
- **Secure Access**: Properly implement Security-Scoped Bookmarks

### Core Components
- **AccessibilityReader**: Monitor clipboard changes
- **FileSearchManager**: Handle file search logic and timeout control
- **StatusBarManager**: Manage menu bar icon and search results window
- **PreferencesManager**: Handle user preferences
- **HotkeyManager**: Handle global hotkey registration and events

---

## 📝 Future Plans
- [ ] Support for file content search
- [ ] Keyword search history
- [ ] Integration with Spotlight search engine
- [ ] Alfred / Raycast plugin integration
- [ ] iCloud sync settings
- [ ] Cross-folder multi-area search
- [ ] Custom search timeout duration

---

## 🧑‍💻 Contributions and Feedback
Feedback and suggestions to help improve Hawk are welcome! If you find bugs or have feature requests, please open an issue on GitHub.

---

## 📄 License
Hawk is licensed under the MIT License.

---

## 👏 Acknowledgements
Thanks to all users who provided feedback and testing.

