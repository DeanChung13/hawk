//
//  HawkApp.swift
//  Hawk
//
//  Created by Dean Chung on 2025/4/17.
//

import SwiftUI

@main
struct HawkApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
  var body: some Scene {
    Settings {
      EmptyView()
    }
    .commands {
      // 添加應用程式選單項
      CommandGroup(replacing: .appInfo) {
        Button("About Hawk") {
          showAboutPanel()
        }
      }
    }
  }
    
  private func showAboutPanel() {
    NSApplication.shared.orderFrontStandardAboutPanel(options: [
      NSApplication.AboutPanelOptionKey.applicationName: "Hawk",
      NSApplication.AboutPanelOptionKey.applicationVersion: "1.0",
      NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
        string: "A fast search utility for quickly finding files from selected text."
      )
    ])
  }
    
  private func openPreferencesWindow() {
    // 創建並顯示偏好設定視窗
    let preferencesWindow = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
      styleMask: [.titled, .closable, .miniaturizable],
      backing: .buffered,
      defer: false
    )
    preferencesWindow.title = "Hawk Preferences"
    preferencesWindow.contentViewController = NSHostingController(
      rootView: MainWindowView()
    )
    preferencesWindow.center()
    preferencesWindow.makeKeyAndOrderFront(nil)
    preferencesWindow.isReleasedWhenClosed = false
  }
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    // Check accessibility permissions
    if !AccessibilityReader.shared.checkAccessibilityPermissions() {
      showAccessibilityPrompt()
    }
        
    // Setup status bar icon
    StatusBarManager.shared.setupStatusBar()
        
    // Register global hotkey for search
    HotkeyManager.shared.registerGlobalHotkey()
  }
    
  private func showAccessibilityPrompt() {
    let alert = NSAlert()
    alert.messageText = "Accessibility Permissions Required"
    alert.informativeText = "Hawk needs accessibility permissions to read selected text from other applications. Please enable this in System Preferences > Security & Privacy > Privacy > Accessibility."
    alert.addButton(withTitle: "Open System Preferences")
    alert.addButton(withTitle: "Later")
        
    if alert.runModal() == .alertFirstButtonReturn {
      let prefpaneURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
      NSWorkspace.shared.open(prefpaneURL)
    }
  }
}
