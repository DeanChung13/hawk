import ApplicationServices
import Cocoa
import SwiftUI

struct MainWindowView: View {
  enum SearchDirectory: Equatable {
    case empty
    case text(String)
    case autoUpdate
  }

  @State private var searchDirectory: SearchDirectory
  @ObservedObject private var textObserver = SelectedTextObserver()
    
  init(searchDirectory: SearchDirectory = .autoUpdate) {
    self.searchDirectory = searchDirectory
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Hawk Search")
        .font(.title)

      Divider()

      // Show selected directory if available
        HStack {
          Text("Selected Directory:")
            .font(.headline)
          Button("Configure") {
            showDirectoryPicker()
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      if case .text(let result) = searchDirectory {
        Text(result)
          .font(.body)
          .foregroundColor(.secondary)
      }
            
      // Show clipboard text if available
      if !textObserver.selectedText.isEmpty {
        Text("Clipboard Content:")
          .font(.headline)
        Text(textObserver.selectedText)
          .font(.body)
          .foregroundColor(.secondary)
          .lineLimit(2)
          .truncationMode(.middle)
      }
            
      Divider()
            
      Text("Copy text with ⌘C to automatically search")
        .font(.caption)
    }
    .padding()
    .frame(width: 320)
    .onAppear {
      if searchDirectory == .autoUpdate {
        updateDirectoryPath()
      }
      startObservingSelectedText()
    }
    .onDisappear {
      textObserver.stopObserving()
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
      searchDirectory = .text(directoryURL.path)
    } else {
      searchDirectory = .empty
    }
  }
    
  private func startObservingSelectedText() {
    textObserver.startObserving()
  }
    
  private func performSearch() {
    guard !textObserver.selectedText.isEmpty else { return }
    StatusBarManager.shared.searchWithSelectedText()
  }
}

// Observer class to track clipboard changes
class SelectedTextObserver: ObservableObject {
  @Published var selectedText: String = ""
  private var timer: Timer?
  private var lastText: String = ""
    
  func startObserving() {
    stopObserving() // Ensure we don't create multiple timers

    // Check the clipboard immediately
    checkClipboard()
        
    // Start a timer to periodically check clipboard
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.checkClipboard()
    }
  }

  func checkClipboard() {
    if let text = AccessibilityReader.shared.getSelectedText(), !text.isEmpty {
      // Only update if text has changed
      if text != lastText {
        lastText = text
        DispatchQueue.main.async {
          self.selectedText = text
          StatusBarManager.shared.searchWithSelectedText() // Automatically search when text changes
        }
      }
    }
  }
    
  func stopObserving() {
    timer?.invalidate()
    timer = nil
  }
    
  deinit {
    stopObserving()
  }
}

#Preview("Empty") {
  MainWindowView(searchDirectory: .empty)
}

#Preview("Normal") {
  MainWindowView(searchDirectory: .text("/Volumes/Temp"))
}
