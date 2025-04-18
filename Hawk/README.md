# Hawk - 開發需求說明書

## 🦅 專案簡介
**Hawk** 是一款 macOS 小工具，使用者在任何應用中選取（highlight）一段文字時，可以快速查詢本地某指定資料夾內是否存在該名稱的檔案。若有相符檔案，將自動提示或開啟檔案位置，幫助用戶更快找到本地資料。

---

## 🎯 核心功能需求

### 1. 文字選取偵測
- ✅ 支援從使用者目前選取的文字中讀取內容
- ✅ 支援多數 macOS App（如瀏覽器、編輯器）
- ✅ 使用 macOS Accessibility API 讀取焦點元素與選取文字

### 2. 本地檔案搜尋
- ✅ 設定預設搜尋資料夾（例如 `~/Documents/Notes`）
- ✅ 使用檔名比對搜尋相符檔案
- ✅ 支援模糊比對（如部分符合、大小寫不敏感）
- ✅ 支援副檔名篩選（例如只查找 .pdf, .md, .txt）

### 3. 匹配結果顯示
- ✅ 若有匹配，提供彈跳通知（Notification）
- ✅ 可選擇開啟 Finder 並選取該檔案
- ✅ 若多筆匹配，顯示選單列表供選擇

### 4. 快捷觸發機制
- ✅ 支援自訂快捷鍵觸發查找（如 Cmd + Shift + F）
- ✅ 或設為常駐選單列（Menu bar app）

### 5. 使用者介面（UI）
- ✅ 簡約狀態列圖示（Hawk 小圖）
- ✅ 點擊可開啟偏好設定頁面：
  - 指定搜尋資料夾
  - 選擇支援的副檔名
  - 是否使用模糊比對
  - 快捷鍵設定

---

## 🧱 技術規格

### 語言與框架
- macOS App（Swift + AppKit）
- 支援 macOS 12 Monterey 以上版本

### 關鍵技術
| 功能               | 技術說明                                |
|--------------------|-----------------------------------------|
| 取得選取文字        | Accessibility API (`AXUIElement`)        |
| 快捷鍵綁定          | NSEvent 或 MASShortcut 套件               |
| 檔案搜尋            | FileManager + 正則表達式比對或模糊演算法     |
| 彈出通知            | NSUserNotification / UNUserNotification  |
| 選單列常駐          | NSStatusBar                              |
| 偏好設定儲存        | UserDefaults                             |

---

## 🧪 測試項目

### 單元測試
- 測試選取文字是否成功擷取
- 測試不同副檔名的比對正確性
- 測試模糊比對與完全比對差異

### 使用情境測試
- 在 Safari、Chrome 中選取文字並查找
- 在 VSCode、Notes 中選取文字並查找
- 匹配成功、匹配失敗、同名多檔案情境

---

## 📦 後續擴充規劃
- 支援 Spotlight 搜尋強化搜尋速度與準確性
- Alfred / Raycast 插件整合
- iCloud 同步設定
- 跨資料夾多區域搜尋

---

## 🧩 專案檔案結構（預設）
```
Hawk/
├── AppDelegate.swift
├── StatusBarController.swift
├── FileSearchManager.swift
├── AccessibilityReader.swift
├── PreferencesView.swift
├── Assets.xcassets
├── Info.plist
└── Resources/
```

---

## 🧑‍💻 作者與版權
- 作者：Dean Chung
- 專案名稱：Hawk
- 授權條款：MIT / 依實際商用需求決定

