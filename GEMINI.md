# GEMINI.md

本檔案為 Gemini 在此儲存庫中處理程式碼時提供指導。

## 專案概述

**注意：與此專案相關的所有互動，請優先使用繁體中文 (zh-TW)。**

這是一個高度客製化的 Neovim 設定，專為中文使用者和現代編輯體驗而優化。此設定採用單一 `init.lua` 檔案結構，透過 `lazy.nvim` 管理插件，並包含豐富的快捷鍵映射和專業的 Markdown 編輯支援。

其中一個關鍵的自訂功能是 `lua/renumber.lua` 模組，它為 Markdown 檔案中的有序列表提供自動重新編號功能，並在 `test/renumber_spec.lua` 中附有完整測試。

## 核心架構

### 檔案結構
- **單一設定檔**：所有設定都集中在 `init.lua` 中。
- **插件管理**：使用 `lazy.nvim` 進行插件管理。`lazy-lock.json` 檔案鎖定插件版本。
- **模組化設計**：自訂功能被組織在 `lua/` 目錄下的模組中（例如 `renumber.lua`）。
- **測試**：自訂 Lua 模組的測試位於 `test/` 目錄下，並使用類似 `busted` 的語法（例如 `renumber_spec.lua`）。

### 核心插件與功能
- **插件管理器**：`lazy.nvim`
- **模糊搜尋**：`telescope.nvim`
- **LSP**：`nvim-lspconfig` + `mason.nvim`
- **環繞功能**：`nvim-surround` 用於文字物件操作。
- **主題**：`tokyonight.nvim`
- **Git 整合**：`gitsigns.nvim` 和 `vim-fugitive`。
- **Markdown 支援**：
    - `vim-markdown` (語法)
    - `glow.nvim` (終端預覽)
    - `markdown-preview.nvim` (瀏覽器預覽)
    - `nvim-lint` (markdownlint 整合)
    - **自訂功能**：`renumber.lua` 用於列表自動編號。

## 安裝與執行

這是一個 Neovim 設定，不是一個獨立的應用程式。

1.  **安裝**：
    *   將此儲存庫複製到 `~/.config/nvim`。
    *   啟動 Neovim (`nvim`)。
    *   `lazy.nvim` 將在首次啟動時自動處理所有插件的安裝。

2.  **執行**：
    *   只需在您的終端中執行 `nvim`。

3.  **測試**：
    *   `test/renumber_spec.lua` 中的測試似乎是為一個類似 `busted` 的框架編寫的。要執行它們，您通常需要安裝測試執行器，然後指向該規格檔案來執行。
    *   **待辦事項**：確認確切的測試指令（例如 `busted` 或自訂腳本）。

## 開發慣例

### 領導鍵 (Leader Key)
- 領導鍵被設定為**空白鍵**。
  ```lua
  vim.g.mapleader = " "
  ```

### 關鍵快捷鍵

- **終端切換**：
    - `<C-`> (Ctrl+`): VS Code 風格的終端切換。
    - `<leader>tt`: tmux 相容的終端切換。
- **Telescope (檔案操作)**：
    - `<leader>ff`: 尋找檔案（包含隱藏檔案）。
    - `<leader>fr`: 最近的檔案。
    - `<leader>fg`: 即時 Grep（搜尋文字內容）。
- **視窗導航**：
    - `<leader>h/j/k/l`: 在視窗之間導航。
- **系統剪貼簿**：
    - `<leader>y`: (可視模式下) 複製選取內容到系統剪貼簿。
    - `<leader>yy`: 複製當前行到系統剪貼簿。
- **Git (Fugitive & Gitsigns)**：
    - `<leader>gd`: 工作目錄 vs. 暫存區的差異 (`:Gvdiffsplit`)。
    - `<leader>gD`: 工作目錄 vs. HEAD 的差異。
    - `<leader>gs`: 暫存當前的 hunk (gitsigns)。
    - `<leader>gr`: 重置當前的 hunk (gitsigns)。
- **Markdown 功能**：
    - `<leader>mp`: 在終端中預覽 (`Glow`)。
    - `<leader>mb`: 切換瀏覽器預覽。
    - `<leader>vc`: 選取當前的程式碼區塊。
    - `<leader>rn`: 手動重新編號當前的有序列表。
    - `<leader>rN`: 手動重新編號檔案中所有的有序列表。
    - **自動功能**：在列表項末尾按下 `<CR>` 會自動建立並重新編號下一個項目。

### 中文支援
- 此設定透過設定 `vim.opt.ambiwidth = "double"` 來優化中文字元的正確顯示。

### 程式碼風格
- **設定**：所有 Neovim 設定都在 `init.lua` 中。
- **插件**：新插件被添加到 `init.lua` 的 `lazy.setup({...})` 表中。
- **自訂邏輯**：新的獨立邏輯應在 `lua/` 目錄下建立為模組，並在 `init.lua` 中 `require()`。
- **測試**：相應的測試應被添加到 `test/` 目錄中。