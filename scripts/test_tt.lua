-- <leader>tt / <leader>tm 終端切換的 headless 回歸測試。
--
-- 用法（在 repo 根目錄）：
--   env -u NVIM nvim --headless -c 'luafile scripts/test_tt.lua'
--
-- 注意：在 nvim :terminal 裡執行時，必須用 `env -u NVIM` 拿掉環境變數，
-- 否則 nvim-unception 會把 headless nvim 當成巢狀開檔而報錯中斷。
-- 兩個函數都是 init.lua 裡的 local，因此從 keymap 取出 callback 來呼叫。
-- 無法驗證的部分：終端內程式（如 Claude Code）的實際重繪，需手動測。

local tt = vim.fn.maparg('<leader>tt', 'n', false, true).callback
local tm = vim.fn.maparg('<leader>tm', 'n', false, true).callback
local failed = 0

local function check(name, ok, detail)
  io.stdout:write(string.format('%s  %s  %s\n', ok and 'PASS' or 'FAIL', name, detail or ''))
  if not ok then failed = failed + 1 end
end

-- 每個測試前回到單一 tab、單一視窗，並清掉所有終端 buffer
local function reset()
  vim.cmd('stopinsert')
  vim.cmd('silent! tabonly | silent! only | enew')
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == 'terminal' then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

-- #103：終端在另一個 tab 時，tt 不應跳過去
reset()
vim.cmd('vsplit')
tm()
vim.cmd('stopinsert | tabprevious')
local before = vim.fn.tabpagenr()
tt()
check('#103 tt 不跨 tab', vim.fn.tabpagenr() == before,
  string.format('before=%d after=%d', before, vim.fn.tabpagenr()))

-- #104：高度 = 行數 × 23%，夾在 8~20 行，並固定高度
local orig_lines = vim.o.lines
for _, case in ipairs({ { lines = 24, want = 8 }, { lines = 60, want = 13 }, { lines = 120, want = 20 } }) do
  reset()
  vim.o.lines = case.lines
  tt()
  local h = vim.fn.winheight(0)
  check(string.format('#104 lines=%d 高度', case.lines), h == case.want,
    string.format('lines=%d want=%d got=%d', vim.o.lines, case.want, h))
  check(string.format('#104 lines=%d winfixheight', case.lines), vim.wo.winfixheight)
end
vim.o.lines = orig_lines

reset()
io.stdout:write(string.format('\n%d 項失敗\n', failed))
vim.cmd(failed == 0 and 'qa!' or 'cquit! 1')
