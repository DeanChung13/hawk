import Cocoa
import Carbon

class HotkeyManager {
    static let shared = HotkeyManager()
    
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    
    private init() {}
    
    func registerGlobalHotkey() {
        // Get hotkey from preferences or use default
        let hotkeyDef = PreferencesManager.shared.getSearchHotkey() ?? 
                        HotkeyDefinition(keyCode: 3, modifiers: 1280)  // Default: Command+Shift+F
        
        // Remove any existing hotkey
        unregisterHotkey()
        
        // Set up the hotkey
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType("HAWK".utf8.reduce(0) { ($0 << 8) + UInt32($1) })
        hotKeyID.id = UInt32(1)
        
        // Convert modifiers to Carbon format
        var carbonModifiers: UInt32 = 0
        if hotkeyDef.modifiers & 256 != 0 { carbonModifiers |= UInt32(cmdKey) }
        if hotkeyDef.modifiers & 512 != 0 { carbonModifiers |= UInt32(optionKey) }
        if hotkeyDef.modifiers & 1024 != 0 { carbonModifiers |= UInt32(controlKey) }
        if hotkeyDef.modifiers & 2048 != 0 { carbonModifiers |= UInt32(shiftKey) }
        
        // Register the hotkey
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)
        
        // Install event handler
        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // Define callback function
        let callback: EventHandlerUPP = { (_, eventRef, userData) -> OSStatus in
            guard let userData = userData else { return noErr }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.hotkeyPressed()
            return noErr
        }
        
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            selfPtr,
            &eventHandler
        )
        
        if status != noErr {
            print("Error: Failed to install event handler with status \(status)")
            return
        }
        
        // Register the hotkey with Carbon
        let registerStatus = RegisterEventHotKey(
            UInt32(hotkeyDef.keyCode),
            carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if registerStatus != noErr {
            print("Error: Failed to register hotkey with status \(registerStatus)")
        }
    }
    
    func unregisterHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }
    
    private func hotkeyPressed() {
        // Trigger the search with selected text
        StatusBarManager.shared.searchWithSelectedText()
    }
    
    deinit {
        unregisterHotkey()
    }
} 