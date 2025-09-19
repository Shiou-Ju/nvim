# LSP 自動化驗證系統

這是一個全自動化的 LSP (Language Server Protocol) 驗證系統，用於檢測和報告各種程式語言的 LSP 功能狀態。

## 🎯 功能特色

- **全自動驗證**：一鍵檢測所有配置的 LSP 功能
- **多語言支援**：TypeScript、JavaScript、Markdown、Java
- **詳細測試**：定義跳轉、hover 資訊、引用查找、診斷功能
- **多種報告格式**：人類可讀和 JSON 格式
- **錯誤診斷**：精確定位問題並提供修復建議

## 📁 檔案結構

```
test/lsp-validation/
├── samples/                    # 測試樣本檔案
│   ├── test.ts                # TypeScript 測試檔案
│   ├── test.js                # JavaScript 測試檔案
│   ├── test.md                # Markdown 測試檔案
│   └── Test.java              # Java 測試檔案
├── validate-lsp.lua           # Neovim Lua 驗證腳本
├── run-test.sh                # Shell 包裝腳本
└── README.md                  # 本說明檔案
```

## 🚀 快速開始

### 基本使用

```bash
# 執行完整驗證（預設可讀格式）
./test/lsp-validation/run-test.sh

# 輸出 JSON 格式報告
./test/lsp-validation/run-test.sh -f json

# 同時生成兩種格式報告
./test/lsp-validation/run-test.sh -f both

# 詳細輸出模式
./test/lsp-validation/run-test.sh -v

# 儲存報告到檔案
./test/lsp-validation/run-test.sh -o validation_report.txt
```

### 在 Neovim 中使用

```vim
" 載入驗證腳本並執行
:luafile test/lsp-validation/validate-lsp.lua
:LspValidate

" 生成 JSON 格式報告
:LspValidate json
```

## 📊 報告格式

### 人類可讀格式

```
=== LSP 自動化驗證報告 ===
執行時間: 2025-09-19 14:30:00
Neovim 版本: v0.9.5

┌─────────────┬─────────┬─────┬─────┬─────┬──────────┐
│ Language    │ Status  │ gd  │ K   │ gr  │ Diag     │
├─────────────┼─────────┼─────┼─────┼─────┼──────────┤
│ typescript  │ ✅ 正常  │ ✓   │ ✓   │ ✓   │ ✓        │
│ javascript  │ ✅ 正常  │ ✓   │ ✓   │ ✓   │ ✓        │
│ markdown    │ ✅ 正常  │ ✓   │ ✓   │ ✓   │ ✓        │
│ java        │ ⚠️ 未裝  │ -   │ -   │ -   │ -        │
└─────────────┴─────────┴─────┴─────┴─────┴──────────┘

整體健康度: 75% (3/4 可用)
建議: 安裝 Java LSP 以支援 Java 開發
```

### JSON 格式

```json
{
  "timestamp": "2025-09-19T14:30:00Z",
  "nvim_version": "0.9.5",
  "languages": {
    "typescript": {
      "status": "active",
      "clients": ["ts_ls"],
      "tests": {
        "definition": true,
        "hover": true,
        "references": true,
        "diagnostics": true
      },
      "errors": []
    }
  },
  "summary": {
    "total": 4,
    "active": 3,
    "health_score": 0.75
  }
}
```

## 🔧 測試項目

### 測試的 LSP 功能

1. **定義跳轉 (gd)**：測試 `textDocument/definition` 請求
2. **Hover 資訊 (K)**：測試 `textDocument/hover` 請求
3. **引用查找 (gr)**：測試 `textDocument/references` 請求
4. **診斷功能**：測試語法錯誤和警告顯示

### 測試樣本特色

每個測試檔案都包含：
- 典型的語法結構（函數、變數、類別等）
- 多種引用和定義關係
- 故意的語法錯誤（測試診斷功能）
- 詳細的 JSDoc/註解（測試 hover 功能）

## 🔍 故障排除

### 常見問題

#### LSP 服務器未啟動
```bash
# 檢查 Mason 安裝狀態
:Mason

# 檢查 LSP 配置
:LspInfo

# 重新安裝 LSP 服務器
:MasonInstall ts_ls marksman jdtls
```

#### 測試失敗
```bash
# 查看詳細日誌
./test/lsp-validation/run-test.sh -v

# 檢查日誌檔案
cat test/lsp-validation/validation.log
```

#### 權限問題
```bash
# 確保腳本有執行權限
chmod +x test/lsp-validation/run-test.sh
```

## 🛠️ 自訂和擴展

### 添加新語言支援

1. **創建測試檔案**：在 `samples/` 目錄添加新的測試檔案
2. **更新配置**：修改 `validate-lsp.lua` 中的 `TEST_CONFIG`
3. **添加測試位置**：定義測試符號的行號和列號

### 修改測試邏輯

編輯 `validate-lsp.lua` 中的測試函數：
- `test_lsp_function()` - 修改 LSP 功能測試
- `test_diagnostics()` - 修改診斷測試
- `test_language_lsp()` - 修改語言特定測試

### 自訂報告格式

修改 `generate_readable_report()` 或 `generate_json_report()` 函數來自訂輸出格式。

## 📋 系統需求

- Neovim v0.8.0 或更高版本
- 已配置的 LSP 服務器（ts_ls, marksman, jdtls 等）
- Bash shell 環境

## 🔄 相關 Issues

此系統解決的問題：
- [#11](https://github.com/Shiou-Ju/nvim/issues/11) - LSP 功能驗證
- [#29](https://github.com/Shiou-Ju/nvim/issues/29) - TypeScript LSP 設定
- [#30](https://github.com/Shiou-Ju/nvim/issues/30) - LSP 導航功能測試

## 🤝 貢獻指南

1. Fork 專案
2. 創建功能分支
3. 添加測試
4. 提交 Pull Request

## 📝 授權

此專案使用 MIT 授權條款。