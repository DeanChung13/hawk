import Cocoa

class PreferencesManager {
  // Singleton instance
  static let shared = PreferencesManager()
    
  // UserDefaults keys
  private enum Keys {
    static let searchDirectoryBookmark = "searchDirectoryBookmark"
    static let allowedExtensions = "allowedExtensions"
    static let caseSensitive = "caseSensitive"
    static let fuzzyMatching = "fuzzyMatching"
    static let searchHotkey = "searchHotkey"
  }
    
  // Default values
  private let defaultAllowedExtensions = ["md", "txt", "pdf", "doc", "docx", "pages"]
  private let defaultCaseSensitive = false
  private let defaultFuzzyMatching = true
    
  private init() {
    // Register defaults
    UserDefaults.standard.register(defaults: [
      Keys.allowedExtensions: defaultAllowedExtensions,
      Keys.caseSensitive: defaultCaseSensitive,
      Keys.fuzzyMatching: defaultFuzzyMatching
    ])
  }
    
  // MARK: - Directory Bookmark Management
    
  // Save a directory bookmark for persistent access
  func saveSearchDirectory(_ url: URL) {
    do {
      let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
      UserDefaults.standard.set(bookmarkData, forKey: Keys.searchDirectoryBookmark)
    } catch {
      print("Error creating bookmark for directory: \(error.localizedDescription)")
    }
  }
    
  // Resolve a saved directory bookmark
  func getSearchDirectory() -> URL? {
    guard let bookmarkData = UserDefaults.standard.data(forKey: Keys.searchDirectoryBookmark) else {
      return nil
    }
        
    do {
      var isStale = false
      let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            
      if isStale {
        // Update the bookmark if it's stale
        saveSearchDirectory(url)
      }

      return url
    } catch {
      print("Error resolving bookmark: \(error.localizedDescription)")
      return nil
    }
  }
    
  // Start accessing a security-scoped resource
  func startAccessingDirectory(_ url: URL) -> Bool {
    return url.startAccessingSecurityScopedResource()
  }
    
  // Stop accessing a security-scoped resource
  func stopAccessingDirectory(_ url: URL) {
    url.stopAccessingSecurityScopedResource()
  }
    
  // MARK: - Search Options
    
  // Get current search options
  func getSearchOptions() -> SearchOptions {
    let caseSensitive = UserDefaults.standard.bool(forKey: Keys.caseSensitive)
    let fuzzyMatching = UserDefaults.standard.bool(forKey: Keys.fuzzyMatching)
        
    return SearchOptions(
      caseSensitive: caseSensitive,
      fuzzyMatching: fuzzyMatching
    )
  }
    
  // Update allowed file extensions
  func setAllowedExtensions(_ extensions: [String]) {
    UserDefaults.standard.set(extensions, forKey: Keys.allowedExtensions)
  }
    
  // Update case sensitivity option
  func setCaseSensitive(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: Keys.caseSensitive)
  }
    
  // Update fuzzy matching option
  func setFuzzyMatching(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: Keys.fuzzyMatching)
  }
    
  // MARK: - Hotkey Management
    
  // Save the hotkey preference
  func setSearchHotkey(_ hotkey: HotkeyDefinition) {
    if let encoded = try? JSONEncoder().encode(hotkey) {
      UserDefaults.standard.set(encoded, forKey: Keys.searchHotkey)
    }
  }
    
  // Get the saved hotkey preference
  func getSearchHotkey() -> HotkeyDefinition? {
    guard let data = UserDefaults.standard.data(forKey: Keys.searchHotkey) else {
      return nil
    }
        
    return try? JSONDecoder().decode(HotkeyDefinition.self, from: data)
  }
}
