-- jieba.vim 中文按詞移動的 headless 回歸測試（#107）。
--
-- 用法（在 repo 根目錄）：
--   env -u NVIM nvim --headless -c 'luafile scripts/test_jieba.lua' -c 'cquit! 2'
--
-- 結束碼：0 全部通過、1 有項目失敗、2 腳本本身出錯（尾端的 cquit 防止出錯後 nvim 卡住）
-- 在 nvim :terminal 裡執行必須加 `env -u NVIM`，否則 nvim-unception 會報錯中斷。
-- 最後一段只印出繁體句子的斷詞落點，不判定通過與否，供人工檢視斷詞品質。

local failed = 0

local function check(name, ok, detail)
  io.stdout:write(string.format('%s  %s  %s\n', ok and 'PASS' or 'FAIL', name, detail or ''))
  io.stdout:flush()
  if not ok then failed = failed + 1 end
end

-- 在新 buffer 放入一行文字，游標移到行首
local function setline(text)
  vim.cmd('enew!')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { text })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

local function col() return vim.api.nvim_win_get_cursor(0)[2] end

-- 1. w 有被 jieba 映射
local map = vim.fn.maparg('w', 'n')
check('w 已映射到 jieba', map:find('Jieba') ~= nil, 'maparg=' .. map)

-- 2. 中文按 w 停在第一個詞「我們」之後（原生 w 會一路跳到最後一個字）
local zh = '我們今天去台北車站吃飯'
setline(zh)
vim.cmd('normal w')
check('中文 w 停在第一個詞之後', col() == #'我們', string.format('col=%d want=%d', col(), #'我們'))

-- 3. 英文行為與原生相同
setline('hello world foo')
vim.cmd('normal w')
check('英文 w 落在 world', col() == 6, 'col=' .. col())

-- 4. 中文 yiw 只複製一個詞
setline(zh)
vim.cmd('normal yiw')
local yanked = vim.fn.getreg('"')
check('中文 yiw 只複製一個詞', #yanked > 0 and #yanked < #zh, 'yanked=' .. yanked)

-- 5. 繁體斷詞落點（僅供人工檢視）
io.stdout:write('\n繁體斷詞（以 | 標示 w 的落點）：\n')
for _, s in ipairs({
  '我們明天搭捷運去信義區看電影',
  '這個便當的滷肉飯和珍珠奶茶很好吃',
  '請把設定檔推送到遠端儲存庫',
}) do
  setline(s)
  local cuts, last = {}, -1
  for _ = 1, 30 do
    vim.cmd('normal w')
    local c = col()
    if c <= last then break end
    table.insert(cuts, c)
    last = c
  end
  local out, prev = {}, 0
  for _, c in ipairs(cuts) do
    table.insert(out, s:sub(prev + 1, c))
    prev = c
  end
  table.insert(out, s:sub(prev + 1))
  io.stdout:write('  ' .. table.concat(out, '|') .. '\n')
end

io.stdout:write(string.format('\n%d 項失敗\n', failed))
vim.cmd(failed == 0 and 'qa!' or 'cquit! 1')
