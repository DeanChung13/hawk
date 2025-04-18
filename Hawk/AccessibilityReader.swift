import Foundation
import Cocoa
import ApplicationServices

// 定義剪貼簿變更的通知名稱
extension Notification.Name {
    static let clipboardContentChanged = Notification.Name("clipboardContentChanged")
}

class AccessibilityReader {
    
    // Singleton instance
    static let shared = AccessibilityReader()
    
    private var lastErrorTime: Date = Date(timeIntervalSince1970: 0)
    private let errorThrottleInterval: TimeInterval = 5.0 // 錯誤日誌間隔時間(秒)
    private var debugMode = true // 設為 true 來啟用詳細日誌
    
    // 儲存上一次讀取的剪貼簿內容
    private var lastClipboardContent: String = ""
    
    // 剪貼簿監控的計時器
    private var clipboardTimer: Timer?
    
    private init() {
        // 初始化時記錄當前的剪貼簿內容
        lastClipboardContent = NSPasteboard.general.string(forType: .string) ?? ""
    }
    
    // 開始監控剪貼簿變化
    func startMonitoringClipboard() {
        // 如果計時器已存在則先停止
        stopMonitoringClipboard()
        
        // 建立新的計時器，每 0.5 秒檢查一次剪貼簿
        clipboardTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboardChange()
        }
        
        // 將計時器加入到主執行緒的 RunLoop
        if let timer = clipboardTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
        
        debug("開始監控剪貼簿變化")
    }
    
    // 停止監控剪貼簿變化
    func stopMonitoringClipboard() {
        clipboardTimer?.invalidate()
        clipboardTimer = nil
        debug("停止監控剪貼簿變化")
    }
    
    // 檢查剪貼簿是否有變化
    private func checkClipboardChange() {
        guard let currentContent = NSPasteboard.general.string(forType: .string) else {
            return
        }
        
        // 如果內容與上次不同且不為空，則發送通知
        if currentContent != lastClipboardContent && !currentContent.isEmpty {
            debug("剪貼簿內容變更: \"\(currentContent)\"")
            lastClipboardContent = currentContent
            
            // 發送通知，帶上新的剪貼簿內容
            NotificationCenter.default.post(
                name: .clipboardContentChanged,
                object: self,
                userInfo: ["content": currentContent]
            )
        }
    }
    
    // Check if accessibility permissions are enabled
    func checkAccessibilityPermissions() -> Bool {
        // 使用剪貼簿不需要特殊權限
        return true
    }
    
    // 從剪貼簿獲取文字
    func getSelectedText() -> String? {
        debug("讀取剪貼簿內容")
        
        guard let clipboard = NSPasteboard.general.string(forType: .string) else {
            debug("剪貼簿中沒有文字")
            return nil
        }
        
        if clipboard.isEmpty {
            debug("剪貼簿內容為空")
            return nil
        }
        
        debug("剪貼簿內容: \"\(clipboard)\" (長度: \(clipboard.count))")
        
        // 返回剪貼簿內容
        return clipboard
    }
    
    // 控制錯誤輸出頻率的方法
    private func printThrottledError(_ message: String) {
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastErrorTime) >= errorThrottleInterval {
            print("Error: \(message)")
            lastErrorTime = currentTime
        }
    }
    
    // 調試日誌
    private func debug(_ message: String) {
        if debugMode {
            print("[DEBUG] \(message)")
        }
    }
} 
