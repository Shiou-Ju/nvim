-- glow.nvim Markdown 預覽的 headless 回歸測試（#113）。
--
-- 用法（在 repo 根目錄）：
--   env -u NVIM nvim --headless -c 'luafile scripts/test_glow.lua' -c 'cquit! 2'
--
-- 結束碼：0 全部通過、1 有項目失敗、2 腳本本身出錯（尾端的 cquit 防止出錯後 nvim 卡住）
-- 在 nvim :terminal 裡執行必須加 `env -u NVIM`，否則 nvim-unception 會報錯中斷。
-- headless 沒有真的終端，glow 會輸出未上色的文字，因此只驗證內容有出現，不驗證排版。

local failed = 0

local function report(tag, name, detail)
  io.stdout:write(string.format('%s  %s  %s\n', tag, name, detail or ''))
  io.stdout:flush()
end

local function check(name, ok, detail)
  report(ok and 'PASS' or 'FAIL', name, detail)
  if not ok then failed = failed + 1 end
end

local function finish()
  io.stdout:write(string.format('\n%d 項失敗\n', failed))
  vim.cmd(failed == 0 and 'qa!' or 'cquit! 1')
end

-- 1. glow 執行檔可用
local glow_ok = vim.fn.executable('glow') == 1
check('glow 執行檔在 PATH 上', glow_ok, vim.fn.exepath('glow'))
if not glow_ok then return finish() end

local version = vim.fn.system({ 'glow', '--version' })
check('glow --version 可執行', vim.v.shell_error == 0, vim.trim(version))

-- 2. 開 md 檔後，:Glow 指令與 <leader>mp 映射存在
local marker = 'GlowTestMarker'
local md = vim.fn.tempname() .. '.md'
vim.fn.writefile({ '# ' .. marker, '', '- item one', '- item two' }, md)
vim.cmd('edit ' .. vim.fn.fnameescape(md))

check('檔案類型是 markdown', vim.bo.filetype == 'markdown', 'ft=' .. vim.bo.filetype)
check(':Glow 指令存在', vim.fn.exists(':Glow') == 2)
local map = vim.fn.maparg('<leader>mp', 'n')
check('<leader>mp 映射到 Glow', map:find('Glow') ~= nil, 'maparg=' .. map)

-- 3. 按 <leader>mp 會開出預覽用的浮動視窗
local src_win = vim.api.nvim_get_current_win()
vim.api.nvim_feedkeys(vim.g.mapleader .. 'mp', 'mx', false)

local win = vim.api.nvim_get_current_win()
local is_float = vim.api.nvim_win_get_config(win).relative ~= ''
check('開出浮動視窗', win ~= src_win and is_float, 'relative=' .. vim.api.nvim_win_get_config(win).relative)

local buf = vim.api.nvim_win_get_buf(win)
check('預覽 buffer 類型是 glowpreview', vim.bo[buf].filetype == 'glowpreview', 'ft=' .. vim.bo[buf].filetype)

-- 4. 預覽內容出現原檔文字（glow 非同步輸出，等最多 5 秒）
local function buf_text()
  if not vim.api.nvim_buf_is_valid(buf) then return '' end
  return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
end
local rendered = vim.wait(5000, function() return buf_text():find(marker, 1, true) ~= nil end, 50)
check('預覽內容包含標題文字', rendered, rendered and '' or ('內容=' .. buf_text():sub(1, 200)))
check('預覽內容沒有錯誤訊息', not buf_text():lower():find('error', 1, true))

-- 5. 按 q 關閉預覽，回到原本的視窗
if vim.api.nvim_win_is_valid(win) then
  vim.api.nvim_feedkeys('q', 'mx', false)
end
check('按 q 關閉預覽', not vim.api.nvim_win_is_valid(win))
check('回到原本的視窗', vim.api.nvim_get_current_win() == src_win)

vim.fn.delete(md)
finish()
