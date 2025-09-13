# GEMINI.md

This file provides guidance to Gemini when working with code in this repository.

## 專案概述

This is a highly customized Neovim configuration, specifically optimized for Chinese users and a modern editing experience. The configuration uses a single `init.lua` file structure, manages plugins via `lazy.nvim`, and includes rich key mappings and professional Markdown editing support.

A key custom feature is the `lua/renumber.lua` module, which provides automatic renumbering for ordered lists in Markdown files, complete with tests in `test/renumber_spec.lua`.

## 核心架構

### 檔案結構
- **Single Configuration File**: All configurations are centralized in `init.lua`.
- **Plugin Management**: Uses `lazy.nvim` for plugin management. The `lazy-lock.json` file locks plugin versions.
- **Modular Design**: Custom functionality is organized into modules within the `lua/` directory (e.g., `renumber.lua`).
- **Testing**: Tests for custom Lua modules are located in the `test/` directory and use a `busted`-like syntax (e.g., `renumber_spec.lua`).

### 核心插件與功能
- **Plugin Manager**: `lazy.nvim`
- **Fuzzy Search**: `telescope.nvim`
- **LSP**: `nvim-lspconfig` + `mason.nvim`
- **Surround**: `nvim-surround` for text object manipulation.
- **Theme**: `tokyonight.nvim`
- **Git Integration**: `gitsigns.nvim` and `vim-fugitive`.
- **Markdown Support**:
    - `vim-markdown` (syntax)
    - `glow.nvim` (terminal preview)
    - `markdown-preview.nvim` (browser preview)
    - `nvim-lint` (markdownlint integration)
    - **Custom**: `renumber.lua` for automatic list numbering.

## 安裝與執行

This is a Neovim configuration, not a standalone application.

1.  **Installation**:
    *   Clone this repository to `~/.config/nvim`.
    *   Start Neovim (`nvim`).
    *   `lazy.nvim` will automatically handle the installation of all plugins on the first launch.

2.  **Running**:
    *   Simply run `nvim` in your terminal.

3.  **Testing**:
    *   The tests in `test/renumber_spec.lua` seem to be written for a `busted`-like framework. To run them, you would typically need to have the test runner installed and then execute it, pointing to the spec file.
    *   **TODO**: Confirm the exact test command (e.g., `busted` or a custom script).

## 開發慣例

### 領導鍵 (Leader Key)
- The leader key is set to the **spacebar**.
  ```lua
  vim.g.mapleader = " "
  ```

### 關鍵快捷鍵

- **Terminal Toggle**:
    - `<C-`> (Ctrl+`): VS Code-style terminal toggle.
    - `<leader>tt`: tmux-compatible terminal toggle.
- **Telescope (File Operations)**:
    - `<leader>ff`: Find files (includes hidden files).
    - `<leader>fr`: Find recent files.
    - `<leader>fg`: Live grep (search text content).
- **Window Navigation**:
    - `<leader>h/j/k/l`: Navigate between windows.
- **System Clipboard**:
    - `<leader>y`: (Visual mode) Yank selection to system clipboard.
    - `<leader>yy`: Yank current line to system clipboard.
- **Git (Fugitive & Gitsigns)**:
    - `<leader>gd`: Diff working directory vs. staged (`:Gvdiffsplit`).
    - `<leader>gD`: Diff working directory vs. HEAD.
    - `<leader>gs`: Stage current hunk (gitsigns).
    - `<leader>gr`: Reset current hunk (gitsigns).
- **Markdown Features**:
    - `<leader>mp`: Preview in terminal (`Glow`).
    - `<leader>mb`: Toggle browser preview.
    - `<leader>vc`: Select current code block.
    - `<leader>rn`: Manually renumber the current ordered list.
    - `<leader>rN`: Manually renumber all ordered lists in the file.
    - **Automatic**: Pressing `<CR>` at the end of a list item automatically creates and renumbers the next item.

### 中文支援
- The configuration is optimized for displaying Chinese characters correctly by setting `vim.opt.ambiwidth = "double"`.

### 程式碼風格
- **Configuration**: All Neovim settings are in `init.lua`.
- **Plugins**: New plugins are added to the `lazy.setup({...})` table in `init.lua`.
- **Custom Logic**: New standalone logic should be created as a module in the `lua/` directory and `require()`'d in `init.lua`.
- **Tests**: Corresponding tests should be added to the `test/` directory.
