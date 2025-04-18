import Cocoa
import SwiftUI
import UserNotifications

class StatusBarManager {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var resultsWindow: NSWindow?
    private var isAutoSearchEnabled = true // 控制是否啟用自動搜尋功能
    
    static let shared = StatusBarManager()
    
    private init() {
        // 設置剪貼簿監視器的通知監聽
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleClipboardChange(_:)),
            name: .clipboardContentChanged,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "magnifyingglass.circle.fill", accessibilityDescription: "Hawk Search")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Initialize popover for preferences or search history
        setupPopover()
        
        // 開始監聽剪貼簿變化
        AccessibilityReader.shared.startMonitoringClipboard()
    }
    
    // 處理剪貼簿內容變化的通知
    @objc private func handleClipboardChange(_ notification: Notification) {
        // 如果自動搜尋功能已關閉，則不處理
        if !isAutoSearchEnabled {
            return
        }
        
        // 從通知中取得新的剪貼簿內容
        if let content = notification.userInfo?["content"] as? String, !content.isEmpty {
            // 執行搜尋
            performSearchWithText(content)
        }
    }
    
    // 切換自動搜尋功能的開關
    func toggleAutoSearch() {
        isAutoSearchEnabled = !isAutoSearchEnabled
        
        if isAutoSearchEnabled {
            AccessibilityReader.shared.startMonitoringClipboard()
        } else {
            AccessibilityReader.shared.stopMonitoringClipboard()
        }
    }
    
    // 取得當前自動搜尋的狀態
    func getAutoSearchEnabled() -> Bool {
        return isAutoSearchEnabled
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 400)
        popover?.behavior = .transient
        
        // Set the SwiftUI view as popover content
        popover?.contentViewController = NSHostingController(rootView: PopoverContentView())
    }
    
    @objc func togglePopover(_ sender: NSStatusBarButton) {
        if let popover = popover {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            }
        }
    }
    
    // Search with selected text
    func searchWithSelectedText() {
        guard let clipboardText = AccessibilityReader.shared.getSelectedText(), !clipboardText.isEmpty else {
            showNotification(title: "No text in clipboard", message: "Please copy text to the clipboard before searching")
            return
        }
        
        performSearchWithText(clipboardText)
    }
    
    // 使用指定文字進行搜尋
    private func performSearchWithText(_ searchText: String) {
        guard let searchDirectory = PreferencesManager.shared.getSearchDirectory() else {
            showNotification(title: "No search directory", message: "Please set a search directory in preferences")
            return
        }
        
        let searchOptions = PreferencesManager.shared.getSearchOptions()
        let results = FileSearchManager.shared.searchFiles(name: searchText, in: searchDirectory, options: searchOptions)
        
        if results.isEmpty {
            showNotification(title: "No results found", message: "No files found matching '\(searchText)'")
            showResultsWindow(results: [], searchTerm: searchText)
        } else {
            // Show results window
            showResultsWindow(results: results.map { SearchResult(fileURL: $0) }, searchTerm: searchText)
        }
    }
    
    private func showResultsWindow(results: [SearchResult], searchTerm: String) {
      if let resultsWindow {
        resultsWindow.contentViewController = NSHostingController(
          rootView: SearchResultsView(results: results)
            .frame(minWidth: 600, minHeight: 400)
        )
        return
      }
        // Create window with correct size from the beginning

      let resultsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false)
        
        // Set minimum size to prevent too small windows
        resultsWindow.minSize = NSSize(width: 600, height: 400)
        resultsWindow.title = "Search Results for '\(searchTerm)'"
        resultsWindow.contentViewController = NSHostingController(
            rootView: SearchResultsView(results: results)
                .frame(minWidth: 600, minHeight: 400)
        )
        
        // Center on screen
        resultsWindow.center()
        resultsWindow.isReleasedWhenClosed = false
        resultsWindow.makeKeyAndOrderFront(nil)
      self.resultsWindow = resultsWindow
    }
    
    private func showNotification(title: String, message: String) {
      let content = UNMutableNotificationContent()
      content.title = title
      content.body = message
      content.sound = UNNotificationSound.default

      let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: nil // 立即通知
      )

      UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
          print("Failed to deliver notification: \(error)")
        }
      }
    }
    
    // Register global hotkey
    func registerHotkey() {
        // Implementation will be added in HotkeyManager.swift
    }
}

// MARK: - SwiftUI Views

// 彈出視圖
struct PopoverContentView: View {
    @State private var searchDirectory: String = ""
    @State private var autoSearchEnabled: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Hawk Search")
                .font(.headline)
            
            Divider()
            
            Button("Set Search Directory") {
                showDirectoryPicker()
            }
            
            // Show selected directory if available
            if !searchDirectory.isEmpty {
                Text("Selected Directory:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(searchDirectory)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Divider()
            
            // 自動搜尋開關
            Toggle("Auto Search", isOn: $autoSearchEnabled)
                .onChange(of: autoSearchEnabled) { newValue in
                    StatusBarManager.shared.toggleAutoSearch()
                }
            
            Text("When enabled, Hawk will automatically search when clipboard content changes")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            
            Button("Search Now") {
                StatusBarManager.shared.searchWithSelectedText()
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
            
            Divider()
            
            Text("Keyboard Shortcut: ⌘⇧F")
                .font(.caption)
        }
        .padding()
        .frame(width: 300)
        .onAppear {
            updateDirectoryPath()
            // 同步自動搜尋狀態
            autoSearchEnabled = StatusBarManager.shared.getAutoSearchEnabled()
        }
    }
    
    private func showDirectoryPicker() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                PreferencesManager.shared.saveSearchDirectory(url)
                updateDirectoryPath()
            }
        }
    }
    
    private func updateDirectoryPath() {
        if let directoryURL = PreferencesManager.shared.getSearchDirectory() {
            searchDirectory = directoryURL.path
        } else {
            searchDirectory = ""
        }
    }
}

// 結果視圖
struct SearchResultsView: View {
    let results: [SearchResult]

    var body: some View {
        VStack {
            Text("Found \(results.count) result\(results.count == 1 ? "" : "s")")
                .font(.headline)
                .padding(.top, 10)
            
            List(results, id: \.filePath) { result in
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(result.fileName)
                            .font(.headline)
                        Text(result.filePath)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button("Open") {
                        FileSearchManager.shared.openInFinder(result.fileURL)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding(.vertical, 6)
            }
            .listStyle(.inset)
        }
        .padding()
    }
}

#Preview {
  SearchResultsView(results: [.init(fileURL: URL(string: "dsafdsafdsa")!)])
}
