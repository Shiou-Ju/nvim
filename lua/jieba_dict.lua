-- jieba 繁體詞典（#107）
-- g:jieba_vim_user_dict 會「取代」主詞典而非補充，故直接使用 jieba 官方繁體大詞典 dict.txt.big。
-- 為減少維護，不另外維護自訂補詞；斷錯的詞（如「設定檔」「信義區」）接受。
local M = {}

M.url = 'https://raw.githubusercontent.com/fxsjy/jieba/237dc6625e5c65d7a2714ffdfa5238dba5cae7d4/extra_dict/dict.txt.big'
M.dir = vim.fn.stdpath('data') .. '/jieba'
M.path = M.dir .. '/dict.txt.big'

-- 檢查是否像一份詞典：大小超過 min_size（預設 1MB，正版約 8MB），且第一行是「詞 整數詞頻」
-- 避免把代理或登入頁回傳的 HTML 當成詞典，覆蓋掉可用的舊檔
function M.valid(path, min_size)
  if vim.fn.getfsize(path) < (min_size or 1000000) then return false end
  local fh = io.open(path, 'r')
  if not fh then return false end
  local first = fh:read('*l') or ''
  fh:close()
  return first:match('^%S+%s+%d+') ~= nil
end

-- lazy.nvim build 時呼叫：先下載到暫存檔，驗證通過才換上，避免下載失敗或其他 nvim 讀到殘缺詞典
function M.build()
  vim.fn.mkdir(M.dir, 'p')
  local tmp = M.path .. '.tmp'
  -- 逾時：連線 15 秒、整體 300 秒（詞典約 8MB），避免網路卡住時 nvim 凍結
  local res = vim.system({ 'curl', '-fsSL', '--connect-timeout', '15', '--max-time', '300', '-o', tmp, M.url }):wait()
  if res.code == 0 and M.valid(tmp) then
    assert(os.rename(tmp, M.path))
    return
  end
  vim.fn.delete(tmp)
  local reason = res.code == 0 and '下載內容不是詞典' or ('下載失敗：' .. (res.stderr or ''))
  local fallback = vim.fn.filereadable(M.path) == 1 and '沿用先前下載的版本' or '使用 jieba 預設詞典'
  vim.notify('jieba 繁體詞典' .. reason .. '，' .. fallback, vim.log.levels.WARN)
end

return M
