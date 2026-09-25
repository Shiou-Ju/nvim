-- <leader>tt / <leader>tm 終端切換的 headless 回歸測試。
--
-- 用法（在 repo 根目錄）：
--   env -u NVIM nvim --headless -c 'luafile scripts/test_tt.lua' -c 'cquit! 2'
--
-- 結束碼：0 全部通過、1 有項目失敗、2 腳本本身出錯（尾端的 cquit 防止出錯後 nvim 卡住）
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
  io.stdout:flush()
  if not ok then failed = failed + 1 end
end

-- 每個測試前回到單一 tab、單一視窗，並清掉所有終端 buffer
local function reset()
  vim.cmd('stopinsert')
  vim.cmd('silent! tabonly | silent! only | enew')
  vim.w.tt_mode, vim.w.tt_prev_buf = nil, nil
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

-- #105：只有一欄開在底部，多欄時目前視窗直接變成終端（replace）
local function buftype(win) return vim.bo[vim.api.nvim_win_get_buf(win)].buftype end
local function term_count()
  return #vim.tbl_filter(function(w) return buftype(w) == 'terminal' end, vim.api.nvim_tabpage_list_wins(0))
end
local function two_lanes()
  reset()
  vim.cmd('vsplit')
  local left = vim.api.nvim_get_current_win()
  vim.cmd('wincmd l')
  return left, vim.api.nvim_get_current_win()
end

reset()
tt()
check('#105 單欄開在底部', vim.w.tt_mode == 'split' and #vim.api.nvim_tabpage_list_wins(0) == 2
  and vim.fn.winwidth(0) == vim.o.columns)

local left, right = two_lanes()
local rbuf, rh = vim.api.nvim_win_get_buf(right), vim.fn.winheight(right)
tt()
check('#105 多欄時目前視窗變終端', vim.api.nvim_get_current_win() == right and buftype(right) == 'terminal'
  and vim.w[right].tt_mode == 'replace' and #vim.api.nvim_tabpage_list_wins(0) == 2
  and vim.fn.winheight(right) == rh)

vim.cmd('stopinsert')
tt()
check('#105 關閉時切回原檔', vim.api.nvim_win_get_buf(right) == rbuf and #vim.api.nvim_tabpage_list_wins(0) == 2
  and vim.w[right].tt_mode == nil)

tt()
vim.cmd('stopinsert')
vim.api.nvim_set_current_win(left)
tt()
check('#105 搬到左欄', buftype(left) == 'terminal' and vim.api.nvim_win_get_buf(right) == rbuf
  and term_count() == 1)

reset()
vim.cmd('vsplit | split')
local top = vim.api.nvim_get_current_win()
tt()
vim.cmd('stopinsert | wincmd j')
tt()
check('#105 同一欄只跳過去不搬移', vim.api.nvim_get_current_win() == top and term_count() == 1)

left, right = two_lanes()
vim.cmd('enew')
tt()
vim.cmd('stopinsert')
tt()
check('#105 空白 buffer 被終端重用時仍能切回', vim.api.nvim_win_get_buf(right) ~= nil
  and buftype(right) == '' and vim.api.nvim_win_is_valid(right))

left, right = two_lanes()
vim.cmd('enew')
local scratch = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(scratch, 0, -1, false, { 'scratch' })  -- 有內容才不會被 :terminal 重用
tt()
vim.cmd('stopinsert')
vim.api.nvim_buf_delete(scratch, { force = true })
tt()
local nb = vim.api.nvim_win_get_buf(right)
check('#105 原檔不存在時開空白 buffer', nb ~= scratch and vim.bo[nb].buftype == ''
  and vim.api.nvim_buf_get_name(nb) == '')

left, right = two_lanes()
rbuf = vim.api.nvim_win_get_buf(right)
tt()
vim.cmd('stopinsert')
tm()
check('#105 replace 模式按 tm 欄位不消失', vim.fn.tabpagenr('$') == 2
  and #vim.api.nvim_tabpage_list_wins(vim.api.nvim_list_tabpages()[1]) == 2
  and vim.api.nvim_win_get_buf(right) == rbuf)

vim.cmd('stopinsert')
tm()
check('#105 tm 降回時依版面變成終端', vim.fn.tabpagenr('$') == 1 and #vim.api.nvim_tabpage_list_wins(0) == 2
  and buftype(0) == 'terminal' and vim.w.tt_mode == 'replace')

reset()
io.stdout:write(string.format('\n%d 項失敗\n', failed))
vim.cmd(failed == 0 and 'qa!' or 'cquit! 1')
