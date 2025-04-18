//
//  ContentView.swift
//  Hawk
//
//  Created by Dean Chung on 2025/4/17.
//

import SwiftUI
import AppKit

// Simple content view for main app window
struct ContentView: View {
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "magnifyingglass.circle.fill")
        .resizable()
        .frame(width: 100, height: 100)
        .foregroundColor(.blue)

      Text("Hawk Search")
        .font(.largeTitle)

      Text("Hawk runs in the background. Look for the icon in your menu bar.")
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .padding(.horizontal)

      Button("Open Search Preferences") {
        StatusBarManager.shared.togglePopover(NSStatusBarButton())
      }
      .buttonStyle(.borderedProminent)
      .padding(.top)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
    ContentView()
}
