# TelescopePreviewLine 高亮樣式對照 (Issue #74)

`<leader>fg` 預覽窗命中行用 `TelescopePreviewLine` 整行高亮,但目前沿用 Telescope 預設 `link = "Visual"`(tokyonight night ≈ `#283457`),對比太低、偏淡。本資料夾提供視覺對照,供挑選新樣式。

## 用途
純參考 mockup(HTML),不影響 Neovim 設定。

## 如何看
瀏覽器直接開 `index.html`:
```
open index.html        # macOS
```
或在 nvim 裡用既有 `:LiveServer` / Live Server 快捷鍵預覽。

## 內容
並排展示「目前樣式」與 4 種更新候選:
- **A** 亮藍底 `#3d59a1`(同色系加亮)
- **B** 黃色左側 accent bar + 微底 `#24304e`(需 extmark/sign 實作 bar)
- **C** 黃底黑字整行 `#ffc777`(最醒目,呼應結果列表 `TelescopeMatching`)
- **D** 中藍底 `#2e3c64` + 粗體亮字

每格附對應的 `nvim_set_hl(...)` Lua 片段。

## 選定後怎麼套
把選定候選的片段加進 `init.lua` 的 `ColorScheme` autocmd,緊鄰既有的 `TelescopeMatching` 設定:
```lua
vim.api.nvim_set_hl(0, "TelescopePreviewLine", { bg = "<選定色>", bold = true })
```
之後在實機 `<leader>fg` 確認醒目度。

## 色值來源(tokyonight night)
底 `#1a1b26` / 前景 `#c0caf5` / Visual `#283457` / 黃 `#ffc777` / blue0 `#3d59a1`。
