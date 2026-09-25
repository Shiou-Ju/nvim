-- jieba 繁體詞典合成（#107）
-- g:jieba_vim_user_dict 會「取代」主詞典而非補充，故以官方繁體大詞典 dict.txt.big 為底，
-- 再接上 repo 內的自訂補詞（dict/zh_tw_extra.txt），合成一份完整詞典
local M = {}

M.url = 'https://raw.githubusercontent.com/fxsjy/jieba/237dc6625e5c65d7a2714ffdfa5238dba5cae7d4/extra_dict/dict.txt.big'
M.dir = vim.fn.stdpath('data') .. '/jieba'
M.path = M.dir .. '/dict.zh_tw.txt'
M.extra = vim.fn.stdpath('config') .. '/dict/zh_tw_extra.txt'

-- 補詞格式：「詞 整數詞頻」或「詞 整數詞頻 詞性」；格式錯一行就會讓整本詞典載入失敗
local function valid_line(line)
  return line:match('^%S+%s+%d+$') ~= nil or line:match('^%S+%s+%d+%s+%S+$') ~= nil
end

-- 合成 big + extra 到 out；回傳被略過的補詞 { { lnum, line }, ... }
-- 先寫暫存檔再改名，避免其他 nvim 在寫入途中讀到殘缺詞典
function M.merge(big, extra, out)
  local fh = assert(io.open(big, 'r'))
  local text = fh:read('*a')
  fh:close()
  if text ~= '' and text:sub(-1) ~= '\n' then text = text .. '\n' end

  local skipped = {}
  if vim.fn.filereadable(extra) == 1 then
    for lnum, line in ipairs(vim.fn.readfile(extra)) do
      line = vim.trim(line)
      if line ~= '' then
        if valid_line(line) then
          text = text .. line .. '\n'
        else
          table.insert(skipped, { lnum = lnum, line = line })
        end
      end
    end
  end

  local tmp = out .. '.tmp'
  local w = assert(io.open(tmp, 'w'))
  w:write(text)
  w:close()
  assert(os.rename(tmp, out))
  return skipped
end

-- lazy.nvim build 時呼叫：下載大詞典（失敗則沿用先前下載的版本）後合成
function M.build()
  vim.fn.mkdir(M.dir, 'p')
  local big = M.dir .. '/dict.txt.big'
  local res = vim.system({ 'curl', '-fsSL', '-o', big .. '.tmp', M.url }):wait()
  if res.code == 0 then
    assert(os.rename(big .. '.tmp', big))
  else
    vim.fn.delete(big .. '.tmp')
    if vim.fn.filereadable(big) == 0 then
      local fallback = vim.fn.filereadable(M.path) == 1 and '沿用現有合成詞典' or '使用 jieba 預設詞典'
      vim.notify('jieba 繁體詞典下載失敗，' .. fallback .. '：' .. (res.stderr or ''), vim.log.levels.WARN)
      return
    end
    vim.notify('jieba 繁體詞典下載失敗，改用先前下載的版本合成', vim.log.levels.WARN)
  end

  for _, s in ipairs(M.merge(big, M.extra, M.path)) do
    vim.notify(string.format('jieba 補詞第 %d 行格式錯誤已略過：%s', s.lnum, s.line), vim.log.levels.WARN)
  end
end

return M
