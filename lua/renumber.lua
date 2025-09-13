local M = {}

-- 找到完整列表邊界的輔助函數
local function find_complete_list_boundaries(cursor_line, indent)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local start_line, end_line = cursor_line, cursor_line
  local indent_pattern = indent:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")

  -- 向上搜尋列表開始
  for i = cursor_line - 1, 1, -1 do
    local line = lines[i]
    if line:match("^" .. indent_pattern .. "%d+%.%s+") then
      start_line = i
    elseif not line:match("^%s*$") and not line:match("^#+%s+") then
      -- 遇到非空行且非列表項且非標題就停止
      break
    end
  end

  -- 向下搜尋列表結束
  for i = cursor_line + 1, #lines do
    local line = lines[i]
    if line:match("^" .. indent_pattern .. "%d+%.%s+") then
      end_line = i
    elseif not line:match("^%s*$") and not line:match("^#+%s+") then
      -- 遇到非空行且非列表項且非標題就停止
      break
    end
  end

  return start_line, end_line
end

-- 重新編號整個列表（當前章節）
M.renumber_entire_list = function()
  vim.notify("開始執行 renumber_entire_list", vim.log.levels.INFO)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = vim.api.nvim_get_current_line()
  vim.notify("游標位置：行 " .. cursor_pos[1] .. "，內容：" .. current_line, vim.log.levels.INFO)

  -- 檢查當前行是否在數字列表中
  local indent, num, content = current_line:match("^(%s*)(%d+)%.%s+(.*)")
  if not indent then
    vim.notify("游標不在數字列表項上", vim.log.levels.WARN)
    return
  end
  vim.notify("檢測到列表項：縮排='" .. indent .. "'，編號=" .. num, vim.log.levels.INFO)

  -- 找到整個列表的邊界
  local start_line, end_line = find_complete_list_boundaries(cursor_pos[1], indent)
  vim.notify("邊界檢測結果：start_line=" .. start_line .. "，end_line=" .. end_line, vim.log.levels.INFO)

  -- 重新編號整個列表
  local counter = 1
  local processed_count = 0
  for i = start_line, end_line do
    local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
    if not line then
      vim.notify("第 " .. i .. " 行為空，跳出迴圈", vim.log.levels.WARN)
      break
    end

    vim.notify("檢查第 " .. i .. " 行：" .. line, vim.log.levels.INFO)
    -- 檢查是否為數字列表項（不限制縮排）
    local current_indent, old_num, line_content = line:match("^(%s*)(%d+)%.%s+(.*)")
    if current_indent and old_num and line_content then
      local new_line = current_indent .. counter .. ". " .. line_content
      vim.api.nvim_buf_set_lines(0, i - 1, i, false, {new_line})
      vim.notify("更新第 " .. i .. " 行：" .. old_num .. " → " .. counter, vim.log.levels.INFO)
      counter = counter + 1
      processed_count = processed_count + 1
    else
      vim.notify("第 " .. i .. " 行非列表項，跳過", vim.log.levels.INFO)
    end
  end

  vim.notify("完成重新編號：處理 " .. processed_count .. " 個列表項", vim.log.levels.INFO)
end

-- 重新編號列表區塊（從插入點後開始）- 用於 Enter 鍵自動編號
M.renumber_list_from_insertion = function(insertion_line, indent)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if not lines or #lines == 0 then
    vim.notify("警告：無法獲取緩衝區內容", vim.log.levels.WARN)
    return
  end

  local counter = 1

  -- 向上搜索最後一個相同縮排的數字，但遇到章節標題就停止
  for i = insertion_line - 1, 1, -1 do
    local line = lines[i]
    if line then  -- 添加 nil 檢查
      -- 遇到章節標題（# ## ### 等），停止搜索，當前章節從 1 開始
      if line:match("^#+%s+") then
        counter = 1
        break
      end

      local current_indent, num, content = line:match("^(%s*)(%d+)%.%s+(.*)")
      if current_indent == indent then
        counter = tonumber(num) + 1
        break  -- 找到相同縮排的數字就停止，不再向上搜索
      end
    end
  end

  -- 從插入點開始重新編號
  for i = insertion_line, #lines do
    local line = lines[i]
    if line then  -- 添加 nil 檢查
      local current_indent, old_num, content = line:match("^(%s*)(%d+)%.%s+(.*)")
      if current_indent == indent then
        local new_line = indent .. counter .. ". " .. content
        vim.api.nvim_buf_set_lines(0, i - 1, i, false, {new_line})
        counter = counter + 1
      elseif not line:match("^%s*$") and not line:match("^" .. indent) then
        -- 遇到不同縮排或非空行就停止
        break
      end
    end
  end
end

-- 重新編號整個章節範圍（支援嵌套列表）
M.renumber_section = function(start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local indent_counters = {}  -- 每個縮排層級的計數器

  for i = 1, #lines do
    local line = lines[i]
    if line then
      local indent, old_num, content = line:match("^(%s*)(%d+)%.%s+(.*)")
      if indent and old_num and content then
        -- 為每個縮排層級維持獨立計數器
        if not indent_counters[indent] then
          indent_counters[indent] = 1
        else
          indent_counters[indent] = indent_counters[indent] + 1
        end

        local new_line = indent .. indent_counters[indent] .. ". " .. content
        vim.api.nvim_buf_set_lines(0, start_line - 1 + i - 1, start_line - 1 + i, false, {new_line})
      end
    end
  end
end

-- 重新編號所有章節（全文檔處理，支援嵌套列表）
M.renumber_all_sections = function()
  vim.notify("開始處理全文檔章節重新編號", vim.log.levels.INFO)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local indent_counters = {}  -- 全域縮排計數器
  local last_indent = ""     -- 記錄上一個列表項的縮排

  for i = 1, #lines do
    local line = lines[i]

    -- 遇到標題，重置所有計數器
    if line:match("^##+%s+") then
      indent_counters = {}
      last_indent = ""

    -- 遇到數字列表項，直接處理
    elseif line:match("^%s*%d+%.%s+") then
      local indent, old_num, content = line:match("^(%s*)(%d+)%.%s+(.*)")
      if indent and old_num and content then
        -- 如果回到較外層的縮排，清除較內層的計數器
        if indent ~= last_indent then
          local keys_to_remove = {}
          for existing_indent, _ in pairs(indent_counters) do
            if #existing_indent > #indent then
              table.insert(keys_to_remove, existing_indent)
            end
          end
          for _, key in ipairs(keys_to_remove) do
            indent_counters[key] = nil
          end
        end

        -- 為每個縮排層級維持獨立計數器
        if not indent_counters[indent] then
          indent_counters[indent] = 1
        else
          indent_counters[indent] = indent_counters[indent] + 1
        end

        local new_line = indent .. indent_counters[indent] .. ". " .. content
        vim.api.nvim_buf_set_lines(0, i - 1, i, false, {new_line})
        vim.notify("更新第 " .. i .. " 行：" .. old_num .. " → " .. indent_counters[indent], vim.log.levels.INFO)
        last_indent = indent
      end

    -- 遇到非列表非空行，重置計數器（但保留標題檢查）
    elseif not line:match("^%s*$") and not line:match("^##+%s+") then
      -- 重置所有縮排計數器，因為列表中斷了
      indent_counters = {}
      last_indent = ""
    end
  end

  vim.notify("完成全文檔章節重新編號", vim.log.levels.INFO)
end

-- Enter 鍵處理函數（可測試版本）
M.handle_enter_key = function()
  local line = vim.api.nvim_get_current_line()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_col = cursor_pos[2]
  local current_line_num = cursor_pos[1]

  -- 檢查是否在數字列表項末尾
  local indent, num, content = line:match("^(%s*)(%d+)%.%s+(.*)")
  -- 修正：0-indexed 游標位置 vs 1-indexed 字串長度
  if indent and current_col >= #line - 1 then
    -- 已經有 indent, num, content 了

    -- 如果內容為空，退出列表模式
    if content == "" then
      return "<CR>"
    end

    -- 插入新列表項
    local next_num = tonumber(num) + 1
    local new_item = "<CR>" .. indent .. next_num .. ". "

    -- 延遲執行重新編號，讓新行先插入
    vim.defer_fn(function()
      M.renumber_list_from_insertion(current_line_num + 2, indent)
    end, 10)

    return new_item
  end

  -- 正常行為
  return "<CR>"
end

return M