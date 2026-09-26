-- jieba.vim 中文按詞移動的 headless 回歸測試（#107）。
--
-- 用法（在 repo 根目錄）：
--   env -u NVIM nvim --headless -c 'luafile scripts/test_jieba.lua' -c 'cquit! 2'
--
-- 結束碼：0 全部通過、1 有項目失敗、2 腳本本身出錯（尾端的 cquit 防止出錯後 nvim 卡住）
-- 在 nvim :terminal 裡執行必須加 `env -u NVIM`，否則 nvim-unception 會報錯中斷。
-- 最後一段只印出繁體句子的斷詞落點，不判定通過與否，供人工檢視斷詞品質。

local failed = 0

local function report(tag, name, detail)
  io.stdout:write(string.format('%s  %s  %s\n', tag, name, detail or ''))
  io.stdout:flush()
end

local function check(name, ok, detail)
  report(ok and 'PASS' or 'FAIL', name, detail)
  if not ok then failed = failed + 1 end
end

-- 已知限制：斷錯印 XFAIL（不算失敗）；哪天斷對會印 XPASS，提醒改成一般 check
local function xfail(name, ok, detail)
  report(ok and 'XPASS' or 'XFAIL', name, detail)
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

-- 5. b / e / ge 也依詞移動（我們|今天|去|台北|車站|吃飯）
setline(zh)
vim.cmd('normal e')
check('中文 e 停在第一個詞的最後一字', col() == #'我', 'col=' .. col())
vim.api.nvim_win_set_cursor(0, { 1, #'我們' })
vim.cmd('normal ge')
check('中文 ge 退到前一個詞的最後一字', col() == #'我', 'col=' .. col())
vim.api.nvim_win_set_cursor(0, { 1, #'我們今天去台北車站吃' })
vim.cmd('normal b')
check('中文 b 退到當前詞首', col() == #'我們今天去台北車站', 'col=' .. col())

-- 6. 插入模式 Ctrl-W 只刪掉一個詞
setline('我們今天')
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('A<C-w><Esc>', true, false, true), 'mx', false)
local after = vim.api.nvim_get_current_line()
check('插入模式 Ctrl-W 只刪一個詞', after == '我們', 'line=' .. after)

-- 7. 繁體詞典：這些詞不應被拆開（需先跑 Lazy! build jieba.vim 下載詞典，否則略過）
-- 游標放在詞首（前面可有上下文 prefix），按一次 w，應剛好停在該詞之後
local dict = require('jieba_dict').path
local function word_case(line, word, prefix)
  prefix = prefix or ''
  setline(line)
  vim.api.nvim_win_set_cursor(0, { 1, #prefix })
  vim.cmd('normal w')
  local want = #prefix + #word
  return col() == want, string.format('col=%d want=%d', col(), want)
end
if vim.fn.filereadable(dict) == 0 then
  report('SKIP', '繁體詞典測試', '找不到 ' .. dict)
else
  for _, case in ipairs({
    { line = '滷肉飯和', word = '滷肉飯' },
    { line = '看電影了', word = '電影', prefix = '看' },
    { line = '遠端儲存庫裡', word = '儲存庫', prefix = '遠端' },
  }) do
    check('繁體詞不拆開：' .. case.word, word_case(case.line, case.word, case.prefix))
  end
  -- 已知限制：受前後文影響斷錯（信義|區看）
  xfail('繁體詞不拆開：信義區', word_case('去信義區看', '信義區', '去'))
end

-- 8. 詞典檔驗證：下載到的若不是詞典（如 HTML 登入頁）或太小，不應拿去覆蓋舊檔
local jd = require('jieba_dict')
check('詞典驗證函數存在', type(jd.valid) == 'function')
if type(jd.valid) == 'function' then
  local tmp = vim.fn.tempname()
  vim.fn.writefile({ '電影 4918 n', '捷運 5 nz' }, tmp .. '.good')
  vim.fn.writefile({ '<!DOCTYPE html>', '<html><body>login</body></html>' }, tmp .. '.html')
  check('正常詞典格式通過驗證', jd.valid(tmp .. '.good', 10))
  check('HTML 內容不通過驗證', not jd.valid(tmp .. '.html', 10))
  check('檔案太小不通過驗證', not jd.valid(tmp .. '.good'))
  check('不存在的檔案不通過驗證', not jd.valid(tmp .. '.missing', 10))
  vim.fn.delete(tmp .. '.good')
  vim.fn.delete(tmp .. '.html')
end

-- 9. 例句斷詞落點（僅供人工檢視；例句放在 dict/test_sentences.txt，公開 repo 勿放私人內容）
io.stdout:write('\n例句斷詞（以 | 標示 w 的落點）：\n')
local sentences = vim.fn.readfile(vim.fn.stdpath('config') .. '/dict/test_sentences.txt')
for _, s in ipairs(sentences) do
  -- 句尾補句號：最後一個詞之後沒有下一個詞時，w 會停在最後一字，造成「電|影」的假象
  s = s .. '。'
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
