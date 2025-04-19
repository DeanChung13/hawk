import ApplicationServices
import Cocoa
import SwiftUI

struct MainWindowView: View {
  @State private var searchDirectory: String = ""
  @ObservedObject private var textObserver = SelectedTextObserver()

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Hawk Search")
        .font(.title)

      Divider()

      // Show selected directory if available
      if !searchDirectory.isEmpty {
        HStack {
          Text("Selected Directory:")
            .font(.headline)
            .foregroundColor(.white)
          Button("Configure") {
            showDirectoryPicker()
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        Text(searchDirectory)
          .font(.body)
          .foregroundColor(.secondary)
      }
            
      // Show clipboard text if available
      if !textObserver.selectedText.isEmpty {
        Text("Clipboard Content:")
          .font(.headline)
          .foregroundColor(.white)
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
      updateDirectoryPath()
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
      searchDirectory = directoryURL.path
    } else {
      searchDirectory = ""
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

#Preview {
  MainWindowView()
}
