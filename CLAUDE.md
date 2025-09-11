# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 專案概述

這是一個高度客製化的 Neovim 配置，專門針對中文使用者和現代編輯體驗優化。配置使用單一 `init.lua` 檔案架構，透過 lazy.nvim 管理插件，包含豐富的快捷鍵映射和專業的 Markdown 編輯支援。

## 核心架構

### 檔案結構
- **單一配置檔案**：所有配置集中在 `init.lua` 中（約 1180 行）
- **插件管理**：使用 lazy.nvim 進行插件管理
- **模組化設計**：透過 autocmd 和函數組織不同功能模組
- **備份支援**：`backup/` 目錄存放配置備份

### 插件生態系統
```lua
-- 核心插件
- lazy.nvim (插件管理器)
- telescope.nvim (模糊搜尋)
- nvim-lspconfig + mason.nvim (LSP 支援)
- nvim-surround (環繞操作)
- tokyonight.nvim (主題)

-- Markdown 支援
- vim-markdown (語法支援)
- glow.nvim (終端預覽)
- markdown-preview.nvim (瀏覽器預覽)
- nvim-lint (markdownlint 整合)
```

## 關鍵功能與快捷鍵

### 領導鍵（Leader Key）
```lua
vim.g.mapleader = " "  -- 空格鍵作為領導鍵
```

### 模式切換快捷鍵
```lua
-- 多種方式退出插入模式
'jj', 'jk', 'kj', 'kk' -> <Esc>

-- 智能 JKL 組合（支援插入模式和終端模式）
'JKL' -> 根據模式自動選擇退出方式
```

### Telescope 檔案操作
```lua
<leader>ff  -- 檔案搜尋（包含隱藏檔案）
<leader>fr  -- 最近開啟檔案
<leader>fg  -- 文字內容搜尋
<leader>fb  -- 緩衝區搜尋
<leader>fh  -- 幫助文檔搜尋
<leader>@   -- 當前檔案模糊搜尋
<leader>nf  -- 進階新檔案創建（NewFile 命令）
```

### 終端整合
```lua
<C-`>       -- VS Code 風格終端開關（在 tmux 外使用）
<leader>tt  -- tmux 相容終端切換（space tt，所有環境皆可用）
<leader>cd  -- 同步 Neovim 工作目錄與終端目錄（CdVimDirHere）
```

### 視窗導航
```lua
<leader>h/j/k/l  -- 視窗間導航
<Tab>/<S-Tab>    -- 縮排/反縮排
```

### 系統剪貼簿操作
```lua
<leader>y    -- 複製選中內容到系統剪貼簿
<leader>yy   -- 複製整行到系統剪貼簿
<leader>yiw  -- 複製單詞到系統剪貼簿
<leader>w    -- 快速儲存檔案
```

### Markdown 專用功能
```lua
-- 快捷鍵（僅在 Markdown 檔案中生效）
<leader>mp  -- Glow 終端預覽
<leader>mb  -- 瀏覽器預覽開關
<leader>ms  -- 停止瀏覽器預覽
<leader>vc  -- 選取當前代碼塊內容

-- 自動功能
- 數字列表自動遞增（按 Enter 鍵）
- 2 空格縮排
- 軟換行與 linebreak
- markdownlint 自動檢查
```

### nvim-surround 自訂映射
```lua
-- Markdown 環繞操作
ysiw + M  -- 粗體 **text**
ysiw + I  -- 斜體 *text*
ysiw + S  -- 刪除線 ~~text~~

-- 刪除/修改環繞
ds + M/I/S  -- 刪除對應標記
cs + 原標記 + 新標記  -- 修改標記
```

## 開發環境配置

### Node.js 環境
```lua
-- markdown-preview.nvim 使用特定 Node.js 版本
vim.g.mkdp_node_path = "/Users/bamboo/.nvm/versions/node/v20.16.0/bin/node"
```

### LSP 配置
```lua
-- Mason 管理的 LSP 伺服器
- ts_ls (TypeScript/JavaScript)
- html, cssls (Web 開發)
- jsonls (JSON)
- marksman (Markdown LSP)
```

### Live Server 整合
```lua
-- 自訂命令
:LiveServer [port]     -- 啟動本地伺服器
:LiveServerStop        -- 停止伺服器
:LiveServerStatus      -- 檢查狀態

-- 快捷鍵
<leader>ls  -- 啟動 Live Server
<leader>lx  -- 停止 Live Server
```

## 中文支援優化

### 顯示設定
```lua
vim.opt.ambiwidth = "double"  -- 中文字符寬度處理
vim.opt.wrap = true           -- 自動換行
vim.opt.linebreak = true      -- 單詞邊界換行
vim.opt.showbreak = ""        -- 移除換行標記
```

### 終端設定
```lua
-- 終端回滾行數設定
scrollback = 10000  -- 1萬行歷史記錄
```

## 折疊與檔案類型設定

### 全域折疊
```lua
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 99  -- 預設展開所有折疊
-- 自動展開所有檔案的折疊
```

### 檔案類型特殊設定
```lua
-- JSON 檔案：縮排折疊，自動展開
-- TypeScript 檔案：縮排折疊，延遲展開
-- Markdown 檔案：專用編輯設定
```

## 主題與視覺設定

### Tokyo Night 主題配置
```lua
style = "night"
-- 禁用所有斜體樣式
comments/keywords/functions/variables = { italic = false }
```

### 註解高亮優化
```lua
-- Git commit 註解顏色增強
Comment/gitcommitComment = { fg = "#7a88cf", italic = false }
```

## 常用自訂命令

### 檔案操作
```
:NewFile     -- 進階檔案創建（Telescope 整合）
:CdVimDirHere -- 同步工作目錄
```

### Markdown 工具
```
:Glow                 -- 終端 Markdown 預覽  
:MarkdownPreviewToggle -- 瀏覽器預覽開關
:MarkdownPreviewStop   -- 停止瀏覽器預覽
:LintCheck            -- 手動執行 markdownlint
```

### Live Server 命令
```
:LiveServer [port]  -- 啟動本地伺服器
:LiveServerStop     -- 停止伺服器
:LiveServerStatus   -- 檢查運行狀態
```

## VSCode 整合

### 條件載入設定
```lua
if vim.g.vscode then
  -- VSCode 專用快捷鍵映射
  -- 折疊操作重新映射到 VSCode 命令
else
  -- 完整 Neovim 功能載入
end
```

## 效能最佳化

### Lazy Loading
- 大部分插件設為 lazy loading
- 按檔案類型載入對應插件
- Event-driven 插件載入策略

### 記憶體管理
- 自動清理不需要的緩衝區
- 合理的 scrollback 限制
- 折疊狀態記憶

## 故障排除

### 常見問題
1. **Live Server 無法啟動**：檢查 Node.js 環境和 nvm 設定
2. **Markdown 預覽失效**：確認 Node.js 路徑配置
3. **中文顯示異常**：檢查 `ambiwidth` 設定
4. **終端導航失效**：確認是否在終端模式中使用正確快捷鍵
5. **tmux 中 Ctrl+` 無法使用**：改用 `<leader>tt` (space tt) 終端切換

### 調試技巧
- 使用 `:checkhealth` 檢查插件狀態
- `:Lazy` 命令管理插件
- `:Mason` 檢查 LSP 安裝狀態

## 擴展指南

### 添加新插件
1. 在 lazy.nvim setup 中添加插件配置
2. 設定對應的快捷鍵映射
3. 考慮檔案類型特定載入

### 快捷鍵自訂
- 優先使用 `<leader>` 前綴避免衝突
- 為每個映射添加 `desc` 說明
- 考慮不同模式的映射需求

## 版本管理

### 重要檔案
- `init.lua` - 主配置檔案
- `lazy-lock.json` - 插件版本鎖定
- `backup/` - 配置備份目錄

### 最新功能
- JKL 組合鍵智能模式切換
- Markdown 數字列表自動遞增
- 終端回滾行數優化
- TypeScript 專用折疊配置

## Git 工作流程規範

### Commit 和 PR 規範
- **禁止 Claude 署名**：絕對不要在 commit 訊息或 PR 中加入任何 Claude 相關的署名或標記
- **禁止內容**：避免包含 "Claude"、"Co-Authored-By: Claude"、"Generated with Claude Code"、"一起製作" 等字眼
- **原因**：保持開發歷史的專業性和真實性，所有貢獻都應歸屬於實際的開發者
- **正確做法**：使用純粹的技術描述和功能說明

### 開發行為規範
- **🚨 等待明確指示原則**：**CRITICAL - 除非用戶明確要求實作，否則只進行分析和建議**
- **禁止主動實作**：分析問題時不可主動開始編碼或修改檔案
- **正確流程**：分析 → 提供建議 → 等待用戶確認 → 實作
- **待命狀態**：完成分析後明確表示"待命"，等待進一步指示

### GitHub 操作規範
- **🔗 自有倉庫優先使用 gh CLI**：**所有自有倉庫的 Issue、PR、討論操作都優先使用 gh CLI**
- **完整評論檢視**：查看 Issue 時必須使用 `gh issue view [NUMBER] --comments` 確保看到所有留言
- **避免 HTTP 方式**：自有倉庫避免使用 WebFetch 或 HTTP 方式存取 GitHub 內容
- **僅例外情況**：非自有倉庫才考慮使用 HTTP 方式查看
- **Commit 連結格式**：commit hash 與其他符號之間必須有空格，確保 GitHub 能正確產生連結
  - ✅ 正確：`Commit: ba864a6` 或 `實作 commit: ba864a6`
  - ❌ 錯誤：`Commit:ba864a6` 或 `commit:ba864a6`（缺少空格）
