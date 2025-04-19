import Cocoa

// Search options for file search
public struct SearchOptions {
  var caseSensitive: Bool = false
  var fuzzyMatching: Bool = true
}

// Search result for display
public struct SearchResult {
  let fileURL: URL
  let fileName: String
  let filePath: String
    
  init(fileURL: URL) {
    self.fileURL = fileURL
    self.fileName = fileURL.lastPathComponent
    self.filePath = fileURL.path
  }
}

// Hotkey definition
public struct HotkeyDefinition: Codable {
  let keyCode: Int
  let modifiers: Int
    
  var stringRepresentation: String {
    var modString = ""
        
    // Common modifier flags
    if modifiers & 256 != 0 { modString += "⌘" } // Command
    if modifiers & 512 != 0 { modString += "⌥" } // Option
    if modifiers & 1024 != 0 { modString += "⌃" } // Control
    if modifiers & 2048 != 0 { modString += "⇧" } // Shift
        
    // Key character mapping (simplified)
    let keyChar: String
    switch keyCode {
    case 0: keyChar = "A"
    case 1: keyChar = "S"
    case 2: keyChar = "D"
    case 3: keyChar = "F"
    case 4: keyChar = "H"
    case 5: keyChar = "G"
    case 6: keyChar = "Z"
    case 7: keyChar = "X"
    case 8: keyChar = "C"
    case 9: keyChar = "V"
    case 11: keyChar = "B"
    case 12: keyChar = "Q"
    case 13: keyChar = "W"
    case 14: keyChar = "E"
    case 15: keyChar = "R"
    case 16: keyChar = "Y"
    case 17: keyChar = "T"
    case 32: keyChar = "U"
    case 31: keyChar = "O"
    case 35: keyChar = "P"
    case 37: keyChar = "L"
    case 38: keyChar = "J"
    case 40: keyChar = "K"
    case 41: keyChar = ";"
    case 39: keyChar = "'"
    case 42: keyChar = "\\"
    case 43: keyChar = ","
    case 45: keyChar = "N"
    case 46: keyChar = "M"
    case 47: keyChar = "."
    case 49: keyChar = "Space"
    case 123: keyChar = "←"
    case 124: keyChar = "→"
    case 125: keyChar = "↓"
    case 126: keyChar = "↑"
    default: keyChar = "#\(keyCode)"
    }
        
    return modString + keyChar
  }
}
