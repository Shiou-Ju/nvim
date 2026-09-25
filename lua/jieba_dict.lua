-- jieba 繁體詞典（#107）
-- g:jieba_vim_user_dict 會「取代」主詞典而非補充，故直接使用 jieba 官方繁體大詞典 dict.txt.big。
-- 為減少維護，不另外維護自訂補詞；斷錯的詞（如「設定檔」「信義區」）接受。
local M = {}

M.url = 'https://raw.githubusercontent.com/fxsjy/jieba/237dc6625e5c65d7a2714ffdfa5238dba5cae7d4/extra_dict/dict.txt.big'
M.dir = vim.fn.stdpath('data') .. '/jieba'
M.path = M.dir .. '/dict.txt.big'

-- lazy.nvim build 時呼叫：先下載到暫存檔，成功才換上，避免下載失敗或其他 nvim 讀到殘缺詞典
function M.build()
  vim.fn.mkdir(M.dir, 'p')
  local tmp = M.path .. '.tmp'
  local res = vim.system({ 'curl', '-fsSL', '-o', tmp, M.url }):wait()
  if res.code == 0 then
    assert(os.rename(tmp, M.path))
    return
  end
  vim.fn.delete(tmp)
  local fallback = vim.fn.filereadable(M.path) == 1 and '沿用先前下載的版本' or '使用 jieba 預設詞典'
  vim.notify('jieba 繁體詞典下載失敗，' .. fallback .. '：' .. (res.stderr or ''), vim.log.levels.WARN)
end

return M
